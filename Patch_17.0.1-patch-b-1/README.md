# Upgrade DIH and xap-pu 17.0.1 to 17.0.1-patch-b-1

## Update the Private Registry Container
*Images list place holder* 

DIH and xap-pu images
```
gigaspaces/mcs-query-service:2.0.3
quay.io/kiwigrid/k8s-sidecar:1.26.1
docker.io/grafana/grafana:10.4.1
alpine/openssl:3.1.3
busybox:1.36.0
gigaspaces/cache-operator:17.0.1-patch-b-1
gigaspaces/mcs-service-creator:2.0.1
gigaspaces/mcs-service-operator:2.0.1
gigaspaces/spacedeck:1.2.39
influxdb:1.8.10
gigaspaces/smart-cache-enterprise:17.0.1-patch-b-1
docker.io/bats/bats:v1.4.1
bitnami/kubectl:1.30.1
```

Tiered Storage Backup tool image
``` 
gigaspaces/smart-cache-backup:0.1
```


### Pull images from dockerhub and push images to BBW private registry
```
docker pull ...
docker tag ...
docker push ...
```

### Update dih repo
``` helm repo update <DIHREPO>```

### Install Tiered Storage Backup & Recovery tool
``` helm install ts-backup <DIHREPO>/ts-backup -n <NAMESPACE> -f ./ts-backup.yaml ```

## Backup Tiered Storage data (xap-pu)
## *Stop the Pluggable Connector to avoid writes into the space*

Open a terminal to the ts-backup pod (you can use openshift console or kubectl exec)

Edit the backup configuration file:
```
cd scripts
vim config.properties
```
   ``` NAMESPACE=dih3 ``` \
   ``` SPACE=couponhub ```

Save the file.

Run:
``` 
./backup.sh
```

The backup tool will collect the sqlite backup from each partition and store them at /opt/gigaspaces/backup/backup_*\<timestamp\>* \
Please make sure you get the correct summary from the validation tool (Num of partitions, tables and total entries.)

To run the validation tool manually, run this command:

```
cd scripts
./validate_backup.sh /opt/gigaspaces/backup/backup_<timestamp>
```

## Upgrade DIH umbrella from 17.0.1 to 17.0.1-patch-b-1
To upgrade dih umbrella run this command:
```
helm upgrade --install dih dih/dih --version 17.0.1-patch-b-1 --namespace dih3 -f ./dih_openshift_values.yaml
```
Verify the dih components have upgraded.

# Upgrade the xap-pu 

## Plan A - xap-pu will be removed, but their PVCs are still available
### Uninstall xap-pu 17.0.1
*CAUTION:* \
DO NOT DELETE xap-pu PVCs

```
helm uninstall -n <NAMESPACE>> couponhub
```
Wait until all xap-pu pods terminate. 

### Install xap-pu 17.0.1-patch-b-1
```
helm install couponhub dih/xap-pu --version 17.0.1-patch-b-1 -n <NAMESPACE>> -f space_values.yaml
``` 
Validate:
* The xap-pu pods are running.
* All the partitions are ready and ALL data is available (run a few queries from spacedeck, or call some rest service)

## Plan B - PVCs are deleted/corrupted - xap-pu will be installed from scratch with fresh PVCs
### Full Recovery from Tiered Storage backup
Open a terminal to the ts-backup pod (you can use openshift console or kubectl exec)

``` 
cd scripts
./restore.sh /opt/gigaspaces/backup/backup_<timestamp>
```

Restart the xap-pu pods by scalling down the xap-pu statefulset to 0 and back to the original value.

To get the current replicas value, run:
```
kubectl get sts -n <NAMESPACE> <SPACE>-xap-pu -o jsonpath='{.spec.replicas}'
```
For example:
```
kubectl get sts -n dihprod couponhub-xap-pu -o jsonpath='{.spec.replicas}'

40
```
To set replicas to 0, run
```
kubectl scale sts -n <NAMESPACE> <SPACE>-xap-pu --replicas=0

```

To set replicas to the original value, run:
```
kubectl scale sts -n <NAMESPACE> <SPACE>-xap-pu --replicas=<OriginalReplicas>
```
i.e
```
kubectl scale sts -n dihprod couponhub-xap-pu --replicas=40
```

Validate:
* The xap-pu pods are running.
* All the partitions are ready and ALL data is available (run a few queries from spacedeck, or call some rest service)