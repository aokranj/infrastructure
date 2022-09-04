# System setup



## Make sure mounts are in order

There is the [/etc/fstab](fstab) content available in this directory, but it's not applied automatically.



## Install all required software

```
ansible-playbook playbooks/network.yml

ansible-playbook playbooks/basics.yml
ansible-playbook playbooks/docker.yml
ansible-playbook playbooks/k8s.yml
ansible-playbook playbooks/php.yml
ansible-playbook playbooks/security.yml

../bin/run-playbook playbooks/status-logging.yml
../bin/run-playbook playbooks/backup.yml
```



## Init the Kubernetes cluster

Start the init (the IP segment must be `10.244.0.0/16` because of Flannel,
the advertised IP address is from our internal network for now - to avoid
any risk exposing k8s to the public IP address):
```
sudo kubeadm init \
  --apiserver-advertise-address=10.33.33.2 \
  --pod-network-cidr 10.244.0.0/16
```

After you get kubectl working, install the Flannel networking plugin:
```
kubectl apply -f ../k8s/_flannel/kube-flannel.yml
```

After that, add shell completion too (via `sudo -s`):
```
kubectl completion bash >/etc/bash_completion.d/kubectl
```

Untaint the master node (to allow it to receive workloads):
```
kubectl taint nodes host1 node-role.kubernetes.io/master-

```
