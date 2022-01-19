# How to manage dev/ops team accounts



## Create :: Developer

(access to dev & staging + tools.dev.aokranj.com)

Things to do when adding a new admin:
- System user: add to [users/admins.yml](../users/admins.yml) playbook
- MariaDB user: Add to [MySQL/MariaDB user](../db/admins.yml) playbook
- Add them to our GitHub organization
  - Add them to `everyone` team in our GitHub org
- Add them to `devops@aokranj.com` ("Web infrastructure developers & admins") group in Google Workspace (for https://tools.dev.aokranj.com/ access)



## Create :: Master

(access to production)

Things to do when adding a new admin:
- (same as above, with the following adjustents)
- Enable root access
- Create MariaDB "username-admin" user that has access to production databases
- On GitHub, add them to the `masters` team
