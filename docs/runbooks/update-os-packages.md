# How to update host OS packages - Runbook - AO Kranj Infrastructure

This runbook describes how to update Kubernetes host OS (Ubuntu) packages.

Runbook facts:
* Impacts the availability of end-user services
* Does not upgrade Docker nor Kubernetes



## Verify held packages

These packages should **not** be updated during this procedure:
```
sudo apt-mark showheld
```

The result should be:
```
containerd.io
cri-tools
docker-ce
docker-ce-cli
docker-compose
helm
kubeadm
kubectl
kubelet
kubernetes-cni
```



## Upgrade

```shell
sudo apt update
sudop apt upgrade
```



## Reboot

```
sudo reboot
```



## Remove stale packages

Once the system is back up:
```
sudo apt autoremove
```
