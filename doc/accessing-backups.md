# Accessing backups

TL;DR:
- Local backups are located in a `/backup/daily` directory.
- To access them, you need to be a member of `backup` system group (or `root`)
- Backup storage is BTRFS subvolume-/snapshot-based, and persistent daily snapshots are created as read-only subvolumes.
