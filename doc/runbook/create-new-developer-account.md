# Create a new developer account - Runbook - AO Kranj Infrastructure



## Request from the new developer

Request the following things from the new developer:
* Their GitHub handle
* (Preferred username - try to use the GitHub handle)
* Their public SSH key(s)
* A cryptographic hash of their preferred MySQL password ([generate here](https://www.browserling.com/tools/mysql-password))
* Their desktop operating system of choice (just to make sure we're providing all the necessary tools)



## Create accounts

### Github

The new developer must already have their own GitHub username.

Invite the new developer to our `aokranj` GitHub organisation,
to the `developers` team [here](https://github.com/orgs/aokranj/teams/developers/members?add=true).



### System account

Create a new account via the [users/devs.yml](../../users/devs.yml) playbook:
* No password
* Create the `users/ssh-auth-keys/authorized_keys.USERNAME` file



### MySQL admin account

Create a new MySQL account via the [mariadb/devs.yml](../../mariadb/devs.yml) playbook:
* Use the provided password HASH



### Kubernetes access vhost(s)

Not yet at this point.



### Dedicated development vhost(s)

TODO



## Inform the newcomer

Inform the new engineer of the created username(s), and provide the link to [overview & onboarding document](../overview-for-onboarding.md).
