# Users management



## Install the Ansible collection

```
ansible-galaxy collection install ansible.posix
```



## Check if all accounts are set up as intended

```
../bin/run-playbook admins.yml --check
```



## Set up all user accounts

```
../bin/run-playbook admins.yml
```



## Security system in place

The following were the guidelines when setting up the system:
- The only management service in place is SSH.
- Users can authenticate to SSH service with public/private key authentication only.
- To elevate privileges to access root, users need to enter their _own_ password.
