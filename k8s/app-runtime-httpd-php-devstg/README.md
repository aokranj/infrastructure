# HTTPD+PHP Application Runtime

This is the container that runs all our _development/staging_ PHP apps (for now).



## How to apply new runtime (HTTPD, PHP) configuration

First, build the new Docker image:
```
./build.sh
```

Then, since the `app-runtime-httpd-php-devstg-dp` deployment already exists, just delete
the corresponding pod and k8s will create a new pod from the newly built image:
```
kubectl delete pod app-runtime-httpd-php-devstg-...`
```

You can observe the status of pod creation like this:
```
kubectl get pods
```



## The whys



### Why a single runtime?

TL;DR answer: to conserve system resources.

Docker/Kubernetes's goal is to have independent and self-sufficient services that
can be managed independently. Why are we taking a step back and using a common PHP
runtime?



### Why HTTPD+PHP and not PHP-FPM?

TL;DR answer: security.

To protect ourselves from a buggy Wordpress instance(s), we're doing the following:
- Application files (PHP, JS, CSS) are owned by a regular user
- Application files are non-writable to others
- HTTPD/PHP runs under a different user (i.e. `www-data`)
- The above means that PHP cannot modify own files
- Any directory that is writable by PHP (i.e. `wp-content/uploads`) has PHP execution disabled by the HTTPD vhost configuration

The above means that even if WP gets hacked, there is no place to store
malignant files other than the `wp-content/uploads/...` directory.
Therefore, disabling the PHP execution in that directory (and in any other
writable directory) prevents said malignant code from being executed by
requesting the i.e. https://my-wp-site.com/wp-content/uploads/hack.php URI.
