# Prerequisites
1. Create new AWS cluster with TMC
2. Copy/Download Access Key for Cluster and add in /config/kube.conf - This file will automatically be added to container when built
3. NOTE - AWS K8s clusters deployed by TMC require some additional RBAC bindings to allow priv pod deployments. Make sure to bind the appropriate group/user for your token. (replace with your group/service account values)
```
kubectl create clusterrolebinding privileged-cluster-role-binding --clusterrole=vmware-system-tmc-psp-privileged <group/service-acct>
```

# Building and Running the Local Management Container
## Build Container
`make build`
## Rebuild Container
`make rebuild`
## Start and exec to the container
`make run`
## Join Running Container
`make join`
## Start an already built Local Management Container
`make start`
## Stop a running Local Management Container
`make stop`
# Connecting to AWS Cluster from Management Container

## If you dont have /config/kube.conf configured and built into the container you will need to authenticate with TMC.
1. Login to AWS Cluster with TMC cli
`tmc login`
2. When prompted enter TMC API Access Token, context name, log level, credential, region, ssh key information
3. If TMC authentication is successful you should be able to run 
`kubectl get pods -A`

## If you have /config/kube.conf configured and built into container then your ~/.kube/config file will be present already
1. Run a kubectl command like the following and TMC will prompt for your API Token
`kubectl get pods -A`
2. Enter your TMC API Token when prompted
`? API Token ****************************************************************`
3. Your current login context should be prepopulated - hit enter to continue
`? Login context name xxxxxxx-491d-4162-b9b6-e10dxxxxxxx`
4. TMC authentication should be successful, to test run
`kubectl get pods -A`


# Installing Tools from the Local Management Container
## Tanzu Build Service
1. Install the kpack K8s bits (using v0.1.2 at the time of this writing)
```
kubectl apply -f /opt/kpack/release-0.1.2.yaml
```
2. Verify Install 
```
kubectl get pods --n kpack --watch
```
3. Create Demo namespace
```
k create ns spring-petclinic
```
4. Configure Docker and Git for Build Service

Add Docker Secret (replace username/password fields)
```
kubectl create secret docker-registry demo-docker-credentials \
    --docker-username=<joedev> \
    --docker-password= <joedevpwd> \
    --docker-server=https://index.docker.io/v1/ \
    --namespace spring-petclinic
```
Add Git Secret (replace username/password fields)
NOTE if you have 2FA (2 Factor Authentication) enabled you will need to put your developer access token for the password
```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: demo-git-credentials
  namespace: spring-petclinic
  annotations:
    kpack.io/git: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: <joedev>
  password: <joedevpwd>
EOF
``` 
4. Configure Default Store and Stack for buildpacks (only adding Java and NodeJS buildpacks from Paketo)
```
cat << EOF | kubectl apply -f -
apiVersion: kpack.io/v1alpha1
kind: ClusterStore
metadata:
  name: default-cluster-store
spec:
  sources:
  - image: gcr.io/paketo-buildpacks/java
  - image: gcr.io/paketo-buildpacks/nodejs
EOF
```
```
cat << EOF | kubectl apply -f -
apiVersion: kpack.io/v1alpha1
kind: ClusterStack
metadata:
  name: default-cluster-stack
spec:
  id: "io.buildpacks.stacks.bionic"
  buildImage:
    image: "paketobuildpacks/build:base-cnb"
  runImage:
    image: "paketobuildpacks/run:base-cnb"
EOF
```
5. Create Spring PetClinic Builder and Image (replace git url with your cloned version)
```
cat << EOF | kubectl apply -f -
apiVersion: kpack.io/v1alpha1
kind: Builder
metadata:
  name: spring-petclinic-builder
  namespace: spring-petclinic
spec:
  serviceAccount: spring-petclinic-service-account
  tag: spring-petclinic/builder
  stack:
    name: default-cluster-stack
    kind: ClusterStack
  store:
    name: default-cluster-store
    kind: ClusterStore
  order:
  - group:
    - id: paketo-buildpacks/java
  - group:
    - id: paketo-buildpacks/nodejs
EOF
```
```
cat << EOF | kubectl apply -f -
apiVersion: kpack.io/v1alpha1
kind: Image
metadata:
  name: spring-petclinic-image
  namespace: spring-petclinic
spec:
  tag: spring-petclinic/app
  serviceAccount: spring-petclinic-service-account
  builder:
    name: spring-petclinic-builder
    kind: Builder
  source:
    git:
      url: <joedev-git-repo-url>/tree/master/examples/spring-petclinic
      revision: master
EOF
```


TODO - contour - for ingress
TODO - argocd - to manage application deployments
TODO - build service - for getting applications autobuilt
TODO - dockerhub/harbor - for application image store
TODO - openfaas - for next steps
