#!/bin/bash

while [ ! -f /vagrant/kube.config ]; do
    echo "sleeping 5 seconds waiting for master to be ready"
    sleep 5
done


token_cmd=$(grep -o "kubeadm join --token.*" /vagrant/kube-init-master.out)
echo $token_cmd
case $token_cmd in
    *--token*) eval $token_cmd
               ;;
    *) echo "Invalid join token: $token_emd"; exit 1
esac

systemctl restart kubelet.service

subnet=$(grep -Po "\d+.\d+.\d+.\d+:6443" /vagrant/kube-init-master.out | cut -f1 -d:|cut -f1-3 -d.)
iface=$(/sbin/ip ro | grep $subnet| awk '{print $3'})
cat > /etc/rc.local <<EOF
#!/bin/sh -e
/sbin/ip ro add 10.96.0.0/12 dev $iface
EOF
chmod +x /etc/rc.local
/etc/rc.local
