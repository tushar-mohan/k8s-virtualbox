#!/bin/sh

# usage:
#   kube-init-master <advertise-ip-address>
#
outfile="/vagrant/kube-init-master.out"

KUBE_CONFIG=/vagrant/kube.config
FLANNEL_SCRIPT=/vagrant/flannel.sh

exec > $outfile 2>&1

if [ -f /etc/kubernetes/admin.conf ]; then
    echo "kubeadm already initialized on master. Bailing out"
    exit 0
fi

node_ip=${1:?"Node IP not set for master. Please set it and try again"}

INIT_CMD="kubeadm init --apiserver-advertise-address=$node_ip --pod-network-cidr=10.244.0.0/16"

rm -f $KUBE_CONFIG $FLANNEL_SCRIPT

# make sure the kubelet uses the correct interface
cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS="--node-ip=$node_ip"
EOF

systemctl daemon-reload
echo $INIT_CMD
while ! eval $INIT_CMD ; do
    echo "Retrying kubeadm init.."
    systemctl restart kubelet.service
    kubeadm reset
done
systemctl restart kubelet.service
cp /etc/kubernetes/admin.conf $KUBE_CONFIG

# add route to kube-dns via our private network
iface=$(/sbin/ip ro| grep $node_ip|awk '{print $3}'); echo "private interface: $iface"
cat > /etc/rc.local <<EOF
#!/bin/sh -e
/sbin/ip ro add 10.96.0.0/12 dev $iface
EOF
chmod +x /etc/rc.local
/etc/rc.local

# create flannel script
cat > $FLANNEL_SCRIPT <<EOF
#!/bin/sh
curl -sL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml |sed "/kube-subnet-mgr/a\        - --iface=$iface" | KUBECONFIG=kube.config kubectl apply -f -
EOF
chmod +x $FLANNEL_SCRIPT
