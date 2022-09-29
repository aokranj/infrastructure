# Increase `/data` storage size - Runbook - AO Kranj Infrastructure

This is a runbook to increase the size of the main `/data` storage:
* Works with a live system (no need to shut down services and/or reboot)

System state before this runbook was created and applied:
```shell
root@host1:~# mount | grep data
/dev/mapper/data--vg1-data--lv1 on /data type ext4 (rw,relatime,discard)

root@host1:~# lvs
  LV         VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  backup-lv1 backup-vg1 -wi-ao---- 83.00g                                                    
  data-lv1   data-vg1   -wi-ao---- 79.00g                                                    

root@host1:~# vgs
  VG         #PV #LV #SN Attr   VSize   VFree   
  backup-vg1   1   1   0 wz--n- <84.00g 1020.00m
  data-vg1     1   1   0 wz--n- <80.00g 1020.00m

root@host1:~# pvs
  PV         VG         Fmt  Attr PSize   PFree   
  /dev/sdb   data-vg1   lvm2 a--  <80.00g 1020.00m
  /dev/sdc   backup-vg1 lvm2 a--  <84.00g 1020.00m

root@host1:~# df -h /data
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/data--vg1-data--lv1   78G   47G   27G  64% /data

root@host1:~# 
```



## Step 1 - HETZNER: Increase the size of the existing data volume

Increase the existing `host1-datavol1` volume size in [Hetzner management console](https://console.hetzner.cloud).

Verify:
```shell
root@host1:~# tail -f /var/log/syslog
Aug 29 00:45:43 host1 kernel: [  499.108167] sd 2:0:0:4: Capacity data has changed
Aug 29 00:45:43 host1 kernel: [  499.109430] sd 2:0:0:4: [sdb] 171966464 512-byte logical blocks: (88.0 GB/82.0 GiB)
Aug 29 00:45:43 host1 kernel: [  499.110733] sdb: detected capacity change from 85899345920 to 88046829568
```
We've increased the size for 2GB only here.



## Step 2 - LVM: Rezise the PV

```shell
pvresize /dev/sdb
```
This increases the PV size to the detected size.

Verify:
```shell
root@host1:~# pvs
  PV         VG         Fmt  Attr PSize   PFree   
  /dev/sdb   data-vg1   lvm2 a--  <82.00g   <3.00g   # Notice the increase
  /dev/sdc   backup-vg1 lvm2 a--  <84.00g 1020.00m
root@host1:~# 
```



## Step 3 - LVM: Extend the LV size

In this case, we've increased the Hetzner's volume via 2GB, so let's use the same
size increment here. Adjust this value as needed:
```shell
lvextend --size +2G /dev/data-vg1/data-lv1
```

Verify:
```shell
root@host1:~# lvs
  LV         VG         Attr       LSize
  backup-lv1 backup-vg1 -wi-ao---- 83.00g
  data-lv1   data-vg1   -wi-ao---- 81.00g   # Was 79 before
root@host1:~# 
```



## Step 4 - EXT4: Extend the filesystem

```shell
resize2fs /dev/data-vg1/data-lv1 
```

Verify:
```shell
root@host1:~# df -h /data
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/data--vg1-data--lv1   80G   47G   29G  63% /data        # Size was 78G before
root@host1:~# 
```

All done.
