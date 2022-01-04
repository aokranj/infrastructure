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
ansible-playbook admins.yml
ansible-playbook app-db-and-users.yml
```
