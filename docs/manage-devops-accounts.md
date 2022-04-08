# How to manage dev/ops team accounts



## Create :: Developer

(access to dev & staging + tools.dev.aokranj.com)

Things to do when adding a new admin:
- System user: add to [users/admins.yml](../users/admins.yml) playbook
- MariaDB user: Add to [MariaDB user](../mariadb/admins.yml) playbook
- Add them to our GitHub organization `aokranj`:
  - Add them to the `everyone` team too



## Create :: Master

(access to production)

Things to do when adding a new admin:
- (same as above, with the following adjustments)
- Enable root access
- Create dedicated kubernetes credentials ([guide](../k8s/users/README.md))
- Create MariaDB "username-admin" user that has access to production databases
- On GitHub, add them to the `masters` team
