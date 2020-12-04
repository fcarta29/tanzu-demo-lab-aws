# Prerequisites
1. Create new AWS cluster with TMC
2. Copy/Download Access Key for Cluster and add in /config/kube.conf - This file will automatically be added to container when built
NOTE - AWS K8s clusters deployed by TMC require some additional RBAC bindings to allow priv pod deployments. Make sure to bind the appropriate group/user for your token. (replace with your group/service account values)
```
kubectl create clusterrolebinding privileged-cluster-role-binding --clusterrole=vmware-system-tmc-psp-privileged <group/service-acct>
```
3. Grab API token from Cloud console 