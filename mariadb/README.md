## Configure accounts and databases

Install MySQL community-based Ansible collection + python mysql support:
```
apt install python3-pymysql
ansible-galaxy collection install community.mysql
```

Configure access credentials in `~/.my.cnf` (do not forget to chmod it to `0600`):
```
[client]
host =
user =
password =
```

Then run the playbooks:
```
../bin/run-playbook admins.yml
../bin/run-playbook app-db-and-users.yml
../bin/run-playbook backup.yml
../bin/run-playbook devs.yml
```
