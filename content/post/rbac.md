+++
title = "RBAC made easy"
description = ""
tags = [
    "kubernetes",
    "rbac",
    "authorization",
]
date = "2018-07-20"
categories = [
    "Development",
    "golang",
    "kubernetes",
]
menu = "main"
+++

Different ways to use rbac. How to limit the scope of a user in kubernetes namespace or give the user the whole cluster scope. 

# Prerequisite

- [openssl]()
- [kubectl]()
- Have admin permission to create rbac role

# Create Specific Namespace Scoped Role

1. First, needs to generate private key

```
openssl genrsa -out <name>.pem 2048
```

2. Second, generate certificate signing request(.csr)

```
openssl req -new -key <name>.pem -out <name>.csr -subj "/CN=<name>"
```

3. Now, needs to file a signing request to kubernetes CA. So that kubernetes CA can sign this request.

```
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: user-request
spec:
  groups:
  - system:authenticated
  request: <this field's value is base64 encoded the .csr file, which we generated previously.>
  usages:
  - digital signature
  - key encipherment
  - client auth

  ```

4. Now, create the `CertificateSigningRequest` by


```console
kubectl apply -f <file-name of CertificateSigningRequest>
```

5. Now, time to approve `CertificateSigningRequest`, which we created in previous step.

```
kubectl certificate approve user-request
```
this command signed the certificate.

6. Now, download the signed certificate and save it in some file.

```
kubectl get csr user-request -o jsonpath='{.status.certificate}' | base64 -d > <name>.crt

```

7. Now, set config context

```
kubectl config set-cluster <name> --insecure-skip-tls-verify=true --server=<server-url>
kubectl config set-credentials <name> --client-certificate=<name>.crt --client-key=<name>.pem --embed-certs=true
kubectl config set-context <name> --cluster=<name> --user=<name>
kubectl config use-context <nmae>
```

8. Now, create cluterrole/role and cluterrolebinding/rolebinding.

