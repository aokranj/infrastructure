# Manage `/data` storage - Runbook - AO Kranj Infrastructure

This runbook describes how to shut down enough services to be able to manage
the `/data` mount point on a "live" system.

Runbook facts:
* Impacts the availability of end-user services



## Shut down services

```shell
systemctl stop kubelet
systemctl stop docker          # This one shuts down all Docker containers too
systemctl stop docker.socket   # To prevent automatic startup of Docker of someone connects to its socket
```



## Verify open files

```shell
lsof -n | grep /data/
```
This command should produce no output.



## Manage the `/data` storage

Do whatever you need to do.



## Start the services again

```shell
systemctl start docker.socket
systemctl start docker          # This one does not start back the k8s containers...
systemctl start kubelet         # ...but this one does :)
```
