# System setup



## Install all required software

```
ansible-playbook playbooks/data.yml

ansible-playbook playbooks/basics.yml
ansible-playbook playbooks/apache2.yml
ansible-playbook playbooks/docker.yml
ansible-playbook playbooks/k8s.yml

# Legacy - TODO REMOVE once migrated to k8s
ansible-playbook playbooks/lxc.yml
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
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

After that, add shell completion too (via `sudo -s`):
```
kubectl completion bash >/etc/bash_completion.d/kubectl
```

Untaint the master node (to allow it to receive workloads):
```
kubectl taint nodes host1 node-role.kubernetes.io/master-

```
