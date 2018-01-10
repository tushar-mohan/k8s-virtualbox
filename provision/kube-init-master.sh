#!/bin/sh

# usage:
#   kube-init-master <advertise-ip-address>
#
outfile="/vagrant/kube-init-master.out"

KUBE_CONFIG=/vagrant/kube.config

exec > $outfile 2>&1

if [ -f /etc/kubernetes/admin.conf ]; then
    echo "kubeadm already initialized on master. Bailing out"
    exit 0
fi

node_ip=${1:?"Node IP not set for master. Please set it and try again"}

INIT_CMD="kubeadm init --apiserver-advertise-address=$node_ip --pod-network-cidr=10.244.0.0/16"

rm -f $KUBE_CONFIG
systemctl daemon-reload
echo $INIT_CMD
while ! eval $INIT_CMD ; do
    echo "Retrying kubeadm init.."
    systemctl restart kubelet.service
    kubeadm reset
done
systemctl restart kubelet.service
cp /etc/kubernetes/admin.conf $KUBE_CONFIG
