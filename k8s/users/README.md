# K8s users



## For the admin - How to add a new user

To use the folowing commands, 
either replace the `${NEWUSERNAME}` with the actual username,
or set the `NEWUSERNAME` environment variable like this:
```
set -u
export NEWUSERNAME="<FIXME-ACTUAL-NEW-USERNAME-HERE>"
```


#### 1. Generate a private key

```
openssl genrsa -out ${NEWUSERNAME}.key 4096
```


#### 2. Generate a CSR

The important bit is the group association in the CSR's subject:
```
openssl req -new -key ${NEWUSERNAME}.key -out ${NEWUSERNAME}.csr -subj "/CN=${NEWUSERNAME}/O=ao:cluster-admins"
openssl req -text -in ${NEWUSERNAME}.csr
```


#### 3. Generate a CSR object in Kubernetes

Generate the YAML representation of the CSR object first:
```
CSRCONTENT_BASE64=`cat ${NEWUSERNAME}.csr | base64 | tr -d '\n'`

cat <<EOF > ${NEWUSERNAME}-csr.yml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${NEWUSERNAME}-csr
spec:
  groups:
  - system:authenticated
  request: ${CSRCONTENT_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF
```

Apply the generated YAML to create the CSR object:
```
kubectl apply -f ${NEWUSERNAME}-csr.yml
```


#### 4. Approve the CSR

```
kubectl certificate approve ${NEWUSERNAME}-csr
```


#### 5. Get the certificate

```
kubectl get csr ${NEWUSERNAME}-csr -o jsonpath='{.status.certificate}' | base64 -d > ${NEWUSERNAME}.crt
kubectl get csr ${NEWUSERNAME}-csr -o jsonpath='{.status.certificate}'             > ${NEWUSERNAME}.crt.base64
cat ${NEWUSERNAME}.key | base64                                                    > ${NEWUSERNAME}.key.base64
```


#### 6. Done

Now pass the certificate and private key files to the user for which they were generated:
- `${NEWUSERNAME}.crt`
- `${NEWUSERNAME}.key`
- `${NEWUSERNAME}.crt.base64`
- `${NEWUSERNAME}.key.base64`



## For the user - How to use the new certificate

Two options:
- Manually edit the `~/.kube/config` file and replace the values of `client-certificate-data` and `client-key-data` fields of already existing configuration.
- Use `kubectl config ...` commands to manipulate the `~/.kube/config contents`, which is the method described below.

Replace the `my-user`, `my-cluster` and `my-context` with your preferred names.


#### 1. Create a new credential set

```
kubectl config set-credentials my-user --client-certificate=<USER>.crt --client-key=<USER>.key --embed-certs=true
```


#### 2. Create a new cluster

```
kubectl config set-cluster my-cluster --server=https://10.33.33.2:6443 --certificate-authority=cluster-ca.crt --embed-certs=true
```
You can get the CA certificate file [here](cluster-ca.crt).


#### 3. Create a new context

```
kubectl config set-context my-context --cluster=my-cluster --user=my-user
```


#### 4. Switch to using the new context

```
kubectl config use-context my-context
```



## Init

We need to create a dedicated cluster role binding that contains `cluster-admin` role
(since we can't use `system:masters` group directly [because](https://blog.aquasec.com/kubernetes-authorization) [reasons](https://www.frakkingsweet.com/adding-a-full-admin-user-in-kubernetes/).

To create the `ao:cluster-admins` cluster role binding, run:
```
kubectl apply -f ao-cluster-admin-crb.yml
```
