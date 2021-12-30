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



## Run the Ansible playbook (to configure Cloudflare's DNS service)

```
ansible-playbook playbook-cloudflare-aokranj.com.yml
```
