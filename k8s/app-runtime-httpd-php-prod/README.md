# HTTPD+PHP Application Runtime

This is the container that runs all our _production_ PHP apps (for now).



## How to deploy

First, build the required Docker image:
```
./build.sh
```

Then deploy all the `*.yml` files in "correct" order:
```
# Storage definitions
for FILE in `ls storage-*.yml`; do
    kubectl apply -f $FILE.yml
done

# Then pod & service
kubectl apply -f app-runtime-httpd-php-prod-dp.yml
kubectl apply -f app-runtime-httpd-php-prod-svc.yml

# Then ingresses
for FILE in `ls ingress-*.yml`; do
    kubectl apply -f $FILE.yml
done
```



## How to update the runtime

First, reconfigure the runtime as you see fit (`Dockerfile`, config files).

Now build a new Docker image:
```
./build.sh
```

Then, since the `app-runtime-httpd-php-prod-dp` deployment already exists, just delete
the corresponding pod and k8s will create a new pod using the newly built image:
```
kubectl delete pod app-runtime-httpd-php-prod-...
```

To observe the status of pod creation:
```
kubectl get pods
```

Sample output of the above status command (while the new pod is still in the `ContainerCreating` phase):
```
22:56 $ kubectl get pods
NAME                                               READY   STATUS              RESTARTS   AGE
app-runtime-httpd-php-prod-dp-7d78889d48-f55sl     0/1     ContainerCreating   0          3s
```

At the end of the process, the pod should have a `Running` status:
```
22:57 $ kubectl get pods
NAME                                               READY   STATUS    RESTARTS   AGE
app-runtime-httpd-php-prod-dp-7d78889d48-f55sl     1/1     Running   0          61s
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
