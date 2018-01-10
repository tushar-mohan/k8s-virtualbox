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

