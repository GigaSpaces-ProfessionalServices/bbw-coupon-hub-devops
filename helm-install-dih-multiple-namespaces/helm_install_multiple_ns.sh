#!/bin/bash


NAMESPACES="couponhub producthub orderhub associatehub namespace5 namespace6"  ## This list contains all the namespaces that dih will be installed on, 'space' is the delimiter
HELM_REPO="dih-repo" ## based on the previous step: 'helm repo add dihrepo https://resources.gigaspaces.com/helm-charts-dih'
DIH_VERSION="16.4.2" ## chart version

for NS in ${NAMESPACES[@]};do
   
   DIH="${NS}-dih"
   YAML="${NS}-override.yaml"  ##  allows having a dedicated override yaml for each namespace
   echo
   echo helm install ${DIH} ${HELM_REPO}/dih --version ${DIH_VERSION} -f ./${YAML} # remove 'echo' run the command
done
