### Use helm to install dih on multiple namespaces at the same cluster

Edit the following variables inside the script (helm_install_multiple_ns.sh)

```
NAMESPACES="couponhub producthub orderhub associatehub namespace5 namespace6"  ## This list contains all the namespaces that dih will be installed on, 'space' is the delimiter

HELM_REPO="dih-repo" ## based on the previous step: 'helm repo add dihrepo https://resources.gigaspaces.com/helm-charts-dih'

DIH_VERSION="16.4.2" ## chart version
```

This script generates the helm command for each namespace:
Assumption: Each namespace has their own override.yaml - it's not mandatory but strongly recommended in order to simplify future changes.

```
./helm_install_multiple_ns.sh

helm install couponhub-dih dih-repo/dih --version 16.4.2 -f ./couponhub-override.yaml

helm install producthub-dih dih-repo/dih --version 16.4.2 -f ./producthub-override.yaml

helm install orderhub-dih dih-repo/dih --version 16.4.2 -f ./orderhub-override.yaml

helm install associatehub-dih dih-repo/dih --version 16.4.2 -f ./associatehub-override.yaml

helm install namespace5-dih dih-repo/dih --version 16.4.2 -f ./namespace5-override.yaml

helm install namespace6-dih dih-repo/dih --version 16.4.2 -f ./namespace6-override.yaml
```