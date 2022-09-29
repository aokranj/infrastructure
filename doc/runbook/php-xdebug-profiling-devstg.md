# How to run PHP Xdebug in `devstg` environment - Runbook - AO Kranj Infrastructure

This runbook describes how to enable PHP Xdebug extension for vhosts running in `devstg` environment.

Runbook effects:
* Does not affect production environment significantly (slight CPU impact).
* May increase disk usage - delete `cachegrind.out.*` files and other artifacts once done.



## Run the Xdebug profiler using a URL trigger

First, create a world-writable directory that the webserver (and thus PHP, and thus Xdebug) can write to:
```shell
mkdir     /data/ao-dev/b.dev.aokranj.com/tmp
chmod 777 /data/ao-dev/b.dev.aokranj.com/tmp
```

_Temporarily_ enable URL-triggered profiling via the main `.htaccess` file:
```
php_flag  xdebug.profiler_enable_trigger       = 1
php_value xdebug.profiler_enable_trigger_value = ZlamborPaZmula
php_value xdebug.profiler_output_dir           = /data/ao-dev/b.dev.aokranj.com/tmp   # Requires absolute path
php_value xdebug.profiler_output_name          = cachegrind.out.%p
```

Now request the URL you want to profile, and include the `XDEBUG_PROFILE=...` trigger:
```
https://b.dev.aokranj.com/?XDEBUG_PROFILE=ZlamborPaZmula
```

The profiling information should now be available in the configured directory:
```
$ ls -la /data/ao-dev/b.dev.aokranj.com/tmp
```
