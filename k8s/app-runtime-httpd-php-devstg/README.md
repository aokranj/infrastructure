# HTTPD+PHP Application Runtime

This is the container that runs all our _development/staging_ PHP apps (for now).



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

# Secrets
# WARNING: Actual secret values are not committed in this git repo. You'll need to find them elsewhere, or recreate them yourself.
for FILE in `ls secret-*.yml`; do
    kubectl apply -f $FILE.yml
done

# Then pod & service
kubectl apply -f app-runtime-httpd-php-devstg-dp.yml
kubectl apply -f app-runtime-httpd-php-devstg-svc.yml
kubectl apply -f tools.dev.aokranj.com-oauth2.yml

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

Then, since the `app-runtime-httpd-php-devstg-dp` deployment already exists, just delete
the corresponding pod and k8s will create a new pod using the newly built image:
```
kubectl delete pod app-runtime-httpd-php-devstg-...
```

To observe the status of pod creation:
```
kubectl get pods
```

Sample output of the above status command (while the new pod is still in the `ContainerCreating` phase):
```
22:56 $ kubectl get pods
NAME                                               READY   STATUS              RESTARTS   AGE
app-runtime-httpd-php-devstg-dp-7d78889d48-f55sl   0/1     ContainerCreating   0          3s
```

At the end of the process, the pod should have a `Running` status:
```
22:57 $ kubectl get pods
NAME                                               READY   STATUS    RESTARTS   AGE
app-runtime-httpd-php-devstg-dp-7d78889d48-f55sl   1/1     Running   0          61s
```



## Other relevant information location

In [prod README.md](../app-runtime-httpd-php-prod/README.md).
