# Increase `/backup` storage size - Runbook - AO Kranj Infrastructure

Runbook facts:
* Can be performed on a live system
* Does not impact the service availability



## Initial system state

System state when this runbook was created:
```shell
root@host1:~# mount | grep backup
/dev/mapper/backup--vg1-backup--lv1 on /backup type btrfs (rw,relatime,discard,space_cache,subvolid=5,subvol=/)

root@host1:~# lvs
  LV         VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  backup-lv1 backup-vg1 -wi-ao----  63.00g                                                    
  data-lv1   data-vg1   -wi-ao---- 125.00g                                                    

root@host1:~# vgs
  VG         #PV #LV #SN Attr   VSize    VFree   
  backup-vg1   1   1   0 wz--n-  <64.00g 1020.00m
  data-vg1     1   1   0 wz--n- <128.00g   <3.00g

root@host1:~# pvs
  PV         VG         Fmt  Attr PSize    PFree   
  /dev/sdb   backup-vg1 lvm2 a--   <64.00g 1020.00m
  /dev/sdc   data-vg1   lvm2 a--  <128.00g   <3.00g

root@host1:~# df -h /backup
Filesystem                           Size  Used Avail Use% Mounted on
/dev/mapper/backup--vg1-backup--lv1   63G   52G  5.9G  90% /backup

root@host1:~# 
```



## Step 1 - Order a new storage volume

* Do that in https://console.hetzner.cloud
* Order a new volume of final appropriate size
* Do not mount it automatically



## Step 2 - Make sure the new volume shows up in the system

```shell
root@host1:~# tail -f /var/log/syslog
...
Aug 28 22:31:28 host1 kernel: [1458225.705833] scsi 2:0:0:3: Direct-Access     HC       Volume           2.5+ PQ: 0 ANSI: 5
Aug 28 22:31:28 host1 kernel: [1458225.707861] sd 2:0:0:3: Power-on or device reset occurred
Aug 28 22:31:28 host1 kernel: [1458225.708005] sd 2:0:0:3: Attached scsi generic sg4 type 0
Aug 28 22:31:28 host1 kernel: [1458225.709277] sd 2:0:0:3: [sdd] 176160768 512-byte logical blocks: (90.2 GB/84.0 GiB)
Aug 28 22:31:28 host1 kernel: [1458225.709383] sd 2:0:0:3: [sdd] Write Protect is off
Aug 28 22:31:28 host1 kernel: [1458225.709387] sd 2:0:0:3: [sdd] Mode Sense: 63 00 00 08
Aug 28 22:31:28 host1 kernel: [1458225.709582] sd 2:0:0:3: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Aug 28 22:31:28 host1 kernel: [1458225.741889] sd 2:0:0:3: [sdd] Attached SCSI disk
^C
root@host1:~#
```
You can see the new volume showed up as `/dev/sdd` in this case.



## Step 3 - LVM: Create a new physical volume (PV)

```shell
pvcreate /dev/sdd
```

Verify:
```shell
root@host1:~# pvs
  PV         VG         Fmt  Attr PSize    PFree   
  /dev/sdb   backup-vg1 lvm2 a--   <64.00g 1020.00m
  /dev/sdc   data-vg1   lvm2 a--  <128.00g   <3.00g
  /dev/sdd              lvm2 ---    84.00g   84.00g    # Here it is, not assigned to any VG yet
root@host1:~# 
```



## Step 4 - LVM: Assign new PV to a volume group (VG)

```shell
vgextend backup-vg1 /dev/sdd
```

Verify:
```shell
root@host1:~# pvs
  PV         VG         Fmt  Attr PSize    PFree   
  /dev/sdb   backup-vg1 lvm2 a--   <64.00g 1020.00m
  /dev/sdc   data-vg1   lvm2 a--  <128.00g   <3.00g
  /dev/sdd   backup-vg1 lvm2 a--   <84.00g  <84.00g   # Now it is assigned to a VG
root@host1:~# 
```



## Step 5 - LVM: Migrate data off old PV

```shell
pvmove /dev/sdb
```
This took about 15 minutes for the 63GB volume (~70MB/s).

Verify:
```shell

root@host1:~# pvdisplay 
  --- Physical volume ---
  PV Name               /dev/sdc
  VG Name               data-vg1
  PV Size               128.00 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              32767
  Free PE               767
  Allocated PE          32000
  PV UUID               X6OBni-opcq-p8st-vG0k-cZYi-Ut7c-Fj5QXD
   
  --- Physical volume ---
  PV Name               /dev/sdb
  VG Name               backup-vg1
  PV Size               64.00 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              16383
  Free PE               16383                                     # All PEs are unoccupied now
  Allocated PE          0
  PV UUID               2F0Yhx-GSK0-b2F9-GV2k-TJFK-SDyp-2OJUWl
   
  --- Physical volume ---
  PV Name               /dev/sdd
  VG Name               backup-vg1
  PV Size               84.00 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              21503
  Free PE               5375
  Allocated PE          16128
  PV UUID               8xJ2BW-ZlVr-4mGa-4mJd-ZvQY-hxNz-TzbfPs
   
root@host1:~# 
```



## Step 6 - LVM: Remove old PV

```shell
vgreduce backup-vg1 /dev/sdb
```

Verify:
```shell
root@host1:~# pvs
  PV         VG         Fmt  Attr PSize    PFree  
  /dev/sdb              lvm2 ---    64.00g  64.00g   # No more VG assigned to this PV
  /dev/sdc   data-vg1   lvm2 a--  <128.00g  <3.00g
  /dev/sdd   backup-vg1 lvm2 a--   <84.00g <21.00g
```



## Step 7 - LVM: Destroy the old PV

```shell
pvremove /dev/sdb
```

Verify
```shell
root@host1:~# pvs
  PV         VG         Fmt  Attr PSize    PFree  
  /dev/sdc   data-vg1   lvm2 a--  <128.00g  <3.00g   # No more /dev/sdb here
  /dev/sdd   backup-vg1 lvm2 a--   <84.00g <21.00g
```



## Step 8 - LVM: Extend the logical volume

```shell
lvextend --size +20G /dev/backup-vg1/backup-lv1
```
Always leave 1GB unused in the VG when using btrfs, as btrfs can be a [bastard](https://serverfault.com/questions/478733/rm-can-not-remove-xxx-no-space-left-on-device-on-btrfs) if it runs out of space.

Verify:
```shell
root@host1:~# lvs
  LV         VG         Attr       LSize
  backup-lv1 backup-vg1 -wi-ao----  83.00g   # Was 63GB before
  data-lv1   data-vg1   -wi-ao---- 125.00g
root@host1:~# 
```



## Step 9 - BTRFS: Extend to the full size of the new LV

```shell
root@host1:~# btrfs filesystem resize max /backup
Resize '/backup' of 'max'
```

Verify:
```shell
# Before
root@host1:~# df -h /backup
Filesystem                           Size  Used Avail Use% Mounted on
/dev/mapper/backup--vg1-backup--lv1   63G   52G  5.9G  90% /backup

# After
root@host1:~# df -h /backup
Filesystem                           Size  Used Avail Use% Mounted on
/dev/mapper/backup--vg1-backup--lv1   83G   52G   26G  67% /backup
root@host1:~# 
```



## Step 10 - HETZNER: Detach the old volume from VM

Back in https://console.hetzner.cloud:
* Click `Detach volume` in the volume's context menu.

Verify on the system:
```shell
root@host1:~# tail -f /var/log/syslog
Aug 28 23:23:11 host1 kernel: [1461328.168337] sd 2:0:0:2: [sdb] Synchronizing SCSI cache
Aug 28 23:23:11 host1 kernel: [1461328.170451] sd 2:0:0:2: [sdb] Synchronize Cache(10) failed: Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
Aug 28 23:23:11 host1 kernel: [1461328.170464] sd 2:0:0:2: [sdb] Sense Key : Illegal Request [current] 
Aug 28 23:23:11 host1 kernel: [1461328.170482] sd 2:0:0:2: [sdb] Add. Sense: Logical unit not supported
Aug 28 23:23:11 host1 systemd[1]: Stopping LVM event activation on device 8:16...
Aug 28 23:23:11 host1 lvm[235636]:   pvscan[235636] device 8:16 not found.
Aug 28 23:23:11 host1 systemd[1]: lvm2-pvscan@8:16.service: Succeeded.
Aug 28 23:23:11 host1 systemd[1]: Stopped LVM event activation on device 8:16.
```



## Step 11 - HETZNER: Delete the old volume

Click `Delete` in the volume's context menu (you may need to unlock the volume first).



## Step 12 - HETZNER: Lock the new volume

Click `Enable protection` (or the lock icon) in the volume's context menu.

All done.



## Future considerations

* Consider just extending existing volume to speed up the process (like we did in the [increase data storage ](increase-data-storage.md) runbook).
* Consider just adding a new volume, the side of which is the intended size increase.

This should speed up the process (avoid the waiting in step 5).
