# MySQL/MariaDB service

This is the sole (for now) MySQL/MariaDB service deployment for all our apps.



## How to deploy

First, build the new Docker image:
```
./build.sh
```

If the deployment already exists, delete it. This will leave the data files intact:
```
kubectl delete -f mariadb-dp.yml`
```

Now recreate the deployment. This picks up the latest image you've just built:
```
kubectl apply -f mariadb-dp.yml
```
