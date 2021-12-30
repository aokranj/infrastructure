# CloudFlare DNS configuration



## Install the Ansible collection

```
ansible-galaxy collection install community.general
```



## Store access tokens and import them into environment

The `~/.cloudflare.env` file should contain the following:
```
export CLOUDFLARE_EMAIL="..."
export CLOUDFLARE_TOKEN="..."
```

Then simply source the file:
```
. ~/.cloudflare.env        # bash
source ~/.cloudflare.env   # zsh
```



## To verify the Cloudflare configuration

```
ansible-playbook playbook-cloudflare-aokranj.com.yml --check
ansible-playbook playbook-cloudflare-pdkranj.si.yml  --check
```

Caveat - this system does not automatically remove entries configured in Cloudflare
but missing in these playbooks. Those need to be removed with a `state: absent` flag.



## Run the Ansible playbook (to apply the configuration to Cloudflare's DNS service)

```
ansible-playbook playbook-cloudflare-aokranj.com.yml
ansible-playbook playbook-cloudflare-pdkranj.si.yml
```
