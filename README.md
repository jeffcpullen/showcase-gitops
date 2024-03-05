# GitOpsified showcase of selected Red Hat Products

This repository helps to get quickly up and running with selected Red Hat products. It's not meant to be used in production-like environments, but mostly for demo purposes.

Here is a list of currently supported ArgoCD Application and the respective Red Hat products which they install:

 - Red Hat OpenShift Dev Spaces
 - Red Hat Trusted Artifact Signer (RHTAS)
 - Namespace Config Operator (Community support only)
 - Red Hat Single Sign On (integrated with RHTAS)
 - ArgoCD RBAC - this is to prevent fixing ArgoCD with `cluster-admin` permissions and allow more fine grained permissions.

Component diagram of this solution looks like this:

![Component diagram](showcase-gitops-1.png)

# Usage

 - Configure what ArgoCD Application you want to enable in [parent application](argo-apps/tooling-app-of-apps/values.yaml)
 - If you want to use RHTAS, make sure to fix [argo-apps/rhtas-install/values.yaml](argo-apps/rhtas-install/values.yaml) so it fits your cluster
 - Using `oc` cli , log into the OpenShift cluster as cluster-admin
 - Execute installation script
 ```bash
cd install/
./install.sh -p <ARGO_CD_ADMIN_PASSWORD>
```
 - Once the command finishes, you can log in to the ArgoCD Console to observe the installation progress. You can locate the ArgoCD Server URL via:
  ```bash
  oc get route argocd-server -n openshift-gitops -o jsonpath='{.spec.host}{"\n"}'
  ```
 - Use `admin` username and password which you passed to the install script

