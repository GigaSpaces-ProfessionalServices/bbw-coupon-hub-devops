# Upgrade DIH and xap-pu 17.0.1 to 17.0.1-patch-b-1

## Update the Private Registry Container

DIH and xap-pu images
```
gigaspaces/smart-cache-enterprise:17.0.1-patch-b-1
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
## *It is recommended to stop the Pluggable Connector and the Cuoponhub Service to prevent writes to the space.*

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
helm upgrade --install dih <DIHREPO>/dih --version 17.0.1-patch-b-1 --namespace <NAMESPACE> -f dih-overrides.yaml
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
helm install couponhub dih/xap-pu --version 17.0.1-patch-b-1 -n <NAMESPACE>> -f xap-pu-overrides.yaml
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
