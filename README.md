## Kubernetes cluster on Virtualbox using Vagrant and Ansible ##

The code in this repo will automate the creation of a single master
N slave cluster. We use Vagrant to create the virtualbox machines and
ansible to provision `kubeadm` and its dependencies.

### Requirements ###

 * ansible (2.3.3)
 * vagrant (1.9+)
 * virtualbox (5.2.6)

### Quickstart ###


```
export NUM_SLAVES=3
vagrant up
```

This will provision a kubernetes cluster with one master and 3 slaves.
The names of the nodes and other helpful details will be printed once the
cluster is up.

Here is the sample output once provisioning is completed and the cluster is up:
```
==> master:     ------------------------------------------------------
==> master:     k8s cluster: master 192.168.56.100, 3 slaves
==> master:     master: vagrant ssh master
==> master:     slaves are called node-1,...
==> master:     
==> master:     To use cluster:
==> master:     
==> master:     $ export KUBECONFIG=$PWD/kube.config
==> master:     $ kubectl ...
==> master:     
==> master:     To set up flannel:
==> master:     $ ./flannel.sh
==> master:     
==> master:     Shared directory:
==> master:     /vagrant/data on all nodes => ./data (from this host)
==> master:     ------------------------------------------------------
```

Once the machines are booted and configured, two files will be created:
`kube.config` and `flannel.sh`.

As outlined, you simply set `KUBECONFIG` and start using `kubectl`.
`flannel.sh` is a helper script created to setup `flannel`.

## Environment Variables
The scripts honor:

  * `NUM_SLAVES`: number of slave nodes
  * `NODE_MEMORY`: memory of slave nodes (not master) in MB. Defaults to 1024.
  * `SUBNET`: defaults to 192.168.56.0/24
