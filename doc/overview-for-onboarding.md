# Overview for Onboarding - AO Kranj Infrastructure

Welcome to AO Kranj's web engineering team.
This document should serve as an overview of our infrastructure,
and a collection of links to further resources.



## Service providers

AO Kranj and PD Kranj web resources are hosted with the following providers:
* Domain registration: GoDaddy (for aokranj.com), Zabec.net (for pdkranj.si)
* DNS provider: [CloudFlare](https://dash.cloudflare.com/)
* Web hosting provider: [Hetzner](https://console.hetzner.cloud) (the new Cloud offerings)
* Mail hosting provider: [Google](https://admin.google.com) (Google Workspace for non-profits)



## Web infrastructure diagram

![Infrastructure diagram](infrastructure-diagram.drawio.png?raw=true "Infrastructure diagram")



## Apps / Websites

As or late 2022, we're handling the following ([WordPress](https://wordpress.org/)-based) websites:
* [aokranj.com](https://www.aokranj.com)
* [pdkranj.si](https://www.pdkranj.si)
* [prodaja.pdkranj.si](https://prodaja.pdkranj.si) (mainly handled by @jnastran)

We'll use `aokranj.com` as an example in sections below.



### Git repository structure

These are the main elements of each of our WordPress repositories:

| Location                                      | Description                  |
|-----------------------------------------------|------------------------------|
| `conf/`                                       | Configuration files (common, and templates for local settings) |
| `conf/maps/`                                  | Experimental support for managing WP configuration with `wp-cli-configmaps` |
| `doc/`                                        | Documentation |
| `doc/runbook/`                                | Runbooks for common tasks |
| `docker/`                                     | Local development environment-related files |
| `public/`                                     | WordPress code is in here |
| `public/wp-content/plugins/aokranj/`          | AO Kranj's custom functionality |
| `public/wp-content/plugins/aokranj-wp-misc/`  | AO Kranj's misc WP tweaks |
| `public/wp-content/themes/aokranj/`           | AO Kranj's frontend theme |
| `sbin/`                                       | Deployment & management tools |
| `sbin/libexec/`                               | `wp-cli` and `wp-cli`'s packages |
| `sbin/wp-in-docker`                           | Shortcut for running `wp-cli` in a local development environment |
| `wp` / `public/wp` / `sbin/wp`                | Local `wp-cli` instance |



### Local development environment

[Docker](https://www.docker.com/)- and [docker-compose](https://docs.docker.com/compose/)-based
local development environment is available.
A guide for setting it up is located in the [doc/docker-dev-environment.md](https://github.com/aokranj/website-aokranj.com/blob/master/doc/docker-dev-environment.md) file.

As of this writing (late 2022), local development environment is Linux- and Mac-centric,
since Windows support has not been needed yet.

Generally, `Dockerfile` and PHP/HTTPD configuration used for [local development environment](https://github.com/aokranj/website-aokranj.com/blob/master/docker)
and for [devstg](../k8s/app-runtime-httpd-php-devstg) and [prod](../k8s/app-runtime-httpd-php-devstg) runtime should be kept in sync.



### Runtime environment

Configuration of the app's runtime environment is stored [in the `infrastructure`](https://github.com/aokranj/infrastructure) repository
(
 [devstg](https://github.com/aokranj/infrastructure/tree/master/k8s/app-runtime-httpd-php-devstg),
 [prod](https://github.com/aokranj/infrastructure/tree/master/k8s/app-runtime-httpd-php-prod)
).

The reason for having just two runtimes and not per-app-env k8s deployment is resource conservation.



### Database transfers

Database transfers are described in [a dedicated runbook](https://github.com/aokranj/website-aokranj.com/blob/master/doc/runbook/database-transfers.md).
Everyone has access to the staging environment, where they can copy the latest database from.

TODO: Database transfers from `prod` to `stg` for engineers without access to production.



### User-uploaded content transfers

WordPress stores uploaded content (media, other files) in `public/wp-content/uploads./` directory.
For non-prod environments we've created a solution that automatically retrieves missing files from `prod` environment (via a public HTTP GET) and stores it locally for subsequent access.
Implementation of this on-the-fly fetch mechanism starts [here](https://github.com/aokranj/website-aokranj.com/blob/e452fbae003bd2dbc6699bf73f517befaaa6e082/public/.htaccess#L61).



### Deployments

Deployments to `stg` and `prod` environments are automated via git events:
* Pushes to `master` are immediately deployed to `stg` environment;
* Tags `prod-...` are immediately deployed to `prod` environment.

Anyone with the ability to push `prod-...` tags to repo also has access to production files,
in case issues with automated deployment arise, and manual intervention is required.

More information about the deployments is available in the main
[README.md](https://github.com/aokranj/website-aokranj.com/),
and in the detailed deployment guides (
[stg](https://github.com/aokranj/website-aokranj.com/blob/master/doc/runbook/deploy-to-stg.md),
[prod](https://github.com/aokranj/website-aokranj.com/blob/master/doc/runbook/deploy-to-prod.md)
).



### Web security

Three main rules:
* All code on `prod` must be committed to the git repository.
* No code that contains `eval()` or any other construct that allow execution of arbitrary PHP code should be present in the git repository.
* Filesystem locations that are writable by the app runtime (i.e. `mod_php` in our case) must have PHP execution disabled ([example](https://github.com/aokranj/infrastructure/blob/2a28c9380419b04057c47baa827f4abd94715a65/k8s/app-runtime-httpd-php-prod/conf/apache2/sites-enabled/www.aokranj.com.conf#L6)).



### Management tools

[tools.dev.aokranj.com](https://tools.dev.aokranj.com) is the location where an instance of phpMyAdmin
and a few other bits and bobs are deployed. Location is protected by a GitHub-based authentication,
meaning you need to be a member of `aokranj` GitHub organization to be able to access it at all.



### Further information

Each website repository has the main `README.md` file and a `doc/` directory containing further information.


#### Runbooks

Each website repository should have a `doc/runbook/` diretory containing runbooks for common tasks.

If runbook for a particular task is not present yet, check the parent `doc/` directory for documentation on the subject.
Then consider writing a new runbook, potentially converting the documentation found in `doc/` into actinable runbook items.
