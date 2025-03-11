# Installing the ZOO-Project Helm chart on your platform

## Requirements

Before you begin, make sure you have the following tools installed and set up on your local environment:

### Skaffold

Skaffold is used to build, push, and deploy your application to Kubernetes. 

You can install it by following the instructions [here](https://skaffold.dev/docs/install/#standalone-binary).

### Helm

Helm is a package manager for Kubernetes, enabling you to manage Kubernetes applications easily. 

You can install it by following the steps [here](https://helm.sh/docs/intro/install/).

### Docker.Desktop (required for Apple silicon)

You can install it by following the steps [here](https://docs.docker.com/desktop/setup/install/mac-install/).

From Docker.Desktop, enable Kubernetes in the Kubernetes settings pannel. Click on "Apply & restart" button.

### Minikube (not required for Apple silicon)

Minikube runs a local Kubernetes cluster, ideal for development and testing. 

You can install it by following the guide [here](https://minikube.sigs.k8s.io/docs/start).

Start your minikube instance with:

```
minikube start
```

### Optional requirements

#### Kubectl

Kubectl is a command-line tool for interacting with Kubernetes clusters. It allows you to manage and inspect cluster resources. While not strictly required, it's highly recommended for debugging and interacting with your Kubernetes environment.

You can install it by following the instructions [here](https://kubernetes.io/docs/tasks/tools/#kubectl).

#### OpenLens

OpenLens is a graphical user interface for managing and monitoring Kubernetes clusters. It provides a visual way to interact with resources. 

While it's optional, it can significantly improve your workflow. You can download it [here](https://github.com/MuhammedKalkan/OpenLens?tab=readme-ov-file#installation).

### Add the helm repositories


```
helm repo add localstack https://helm.localstack.cloud
helm repo add zoo-project https://zoo-project.github.io/charts/
```

### Checking the requirements

After installing these tools, ensure they are available in your terminal by running the following commands:

```bash
skaffold version
helm version
# The following command is not required to work on Apple silicon
minikube version
```

If all commands return a version, you’re good to go!

## Deploying the workshop environment

For the purpose of this workshop, we will use the following GitHub repository: [dev-platform-eoap](https://github.com/eoap/dev-platform-eoap) from the EOAP organization.

Start the workshop environment.

````
git clone https://github.com/eoap/dev-platform-eoap.git
cd dev-platform-eoap/ogc-api-processes-with-zoo/
skaffold dev -p standard
# Apple user must use the additional options below
docker pull zooproject/zoo-project:dru-2b3610cbb1198accadc14b6dead93ae29bd927fd --platform linux/amd64
skaffold dev -p macos --platform linux/amd64 --enable-platform-node-affinity=true
````



After some time you will see something like the following indicating that everything is in place.

````
No tags generated
Starting deploy...
Helm release zoo-project-dru not installed. Installing...
NAME: zoo-project-dru
LAST DEPLOYED: Mon Mar 10 18:46:58 2025
NAMESPACE: eoap-zoo-project
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace eoap-zoo-project -l "app.kubernetes.io/name=zoo-project-dru,app.kubernetes.io/instance=zoo-project-dru" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace eoap-zoo-project $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace eoap-zoo-project port-forward $POD_NAME 8080:$CONTAINER_PORT
Helm release eoap-zoo-project-coder not installed. Installing...
NAME: eoap-zoo-project-coder
LAST DEPLOYED: Mon Mar 10 18:47:00 2025
NAMESPACE: eoap-zoo-project
STATUS: deployed
REVISION: 1
TEST SUITE: None
Helm release eoap-zoo-project-localstack not installed. Installing...
NAME: eoap-zoo-project-localstack
LAST DEPLOYED: Mon Mar 10 18:47:01 2025
NAMESPACE: eoap-zoo-project
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace "eoap-zoo-project" -l "app.kubernetes.io/name=localstack,app.kubernetes.io/instance=eoap-zoo-project-localstack" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace "eoap-zoo-project" $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace "eoap-zoo-project" port-forward $POD_NAME 8080:$CONTAINER_PORT
Waiting for deployments to stabilize...
 - eoap-zoo-project:deployment/zoo-project-dru-kubeproxy is ready. [6/7 deployment(s) still pending]
I0310 18:47:06.018653 2854542 request.go:697] Waited for 1.124380065s due to client-side throttling, not priority and fairness, request: GET:https://127.0.0.1:36205/api/v1/namespaces/eoap-zoo-project/events?fieldSelector=involvedObject.name%3Dcode-server-deployment-d94b68f99-p5qdv%2CinvolvedObject.namespace%3Deoap-zoo-project%2CinvolvedObject.kind%3DPod%2CinvolvedObject.uid%3D28193f9d-458c-476d-af26-c4bf45b0f9e4
 - eoap-zoo-project:deployment/code-server-deployment: FailedToRetrieveImagePullSecret: Unable to retrieve some image pull secrets (kaniko-secret); attempting to pull the image may not succeed.
    - eoap-zoo-project:pod/code-server-deployment-d94b68f99-p5qdv: FailedToRetrieveImagePullSecret: Unable to retrieve some image pull secrets (kaniko-secret); attempting to pull the image may not succeed.
      > [code-server-deployment-d94b68f99-p5qdv init-file-on-volume] Cloning into 'ogc-api-processes-with-zoo'...
      > [code-server-deployment-d94b68f99-p5qdv init-file-on-volume] [2025-03-10T17:47:04.843Z] info  Wrote default config file to /workspace/.config/code-server/config.yaml
 - eoap-zoo-project:deployment/eoap-zoo-project-localstack: waiting for rollout to finish: 0 of 1 updated replicas are available...
 - eoap-zoo-project:deployment/zoo-project-dru-zoofpm: waiting for init container init-wait-for-dependencies-zoofpm to complete
    - eoap-zoo-project:pod/zoo-project-dru-zoofpm-5d77cbb77f-8t2lw: waiting for init container init-wait-for-dependencies-zoofpm to complete
      > [zoo-project-dru-zoofpm-5d77cbb77f-8t2lw init-wait-for-dependencies-zoofpm] nc: bad address 'zoo-project-dru-rabbitmq:5672'
      > [zoo-project-dru-zoofpm-5d77cbb77f-8t2lw init-wait-for-dependencies-zoofpm] zoo-project-dru-rabbitmq:5672 is unavailable - sleeping
      > [zoo-project-dru-zoofpm-5d77cbb77f-8t2lw init-wait-for-dependencies-zoofpm] nc: bad address 'zoo-project-dru-rabbitmq:5672'
      > [zoo-project-dru-zoofpm-5d77cbb77f-8t2lw init-wait-for-dependencies-zoofpm] zoo-project-dru-rabbitmq:5672 is unavailable - sleeping
 - eoap-zoo-project:deployment/zoo-project-dru-zookernel: waiting for init container init-wait-for-dependencies-zookernel to complete
    - eoap-zoo-project:pod/zoo-project-dru-zookernel-8675b6d96f-xfjhp: waiting for init container init-wait-for-dependencies-zookernel to complete
      > [zoo-project-dru-zookernel-8675b6d96f-xfjhp init-wait-for-dependencies-zookernel] nc: bad address 'zoo-project-dru-rabbitmq:5672'
      > [zoo-project-dru-zookernel-8675b6d96f-xfjhp init-wait-for-dependencies-zookernel] zoo-project-dru-rabbitmq:5672 is unavailable - sleeping
      > [zoo-project-dru-zookernel-8675b6d96f-xfjhp init-wait-for-dependencies-zookernel] nc: bad address 'zoo-project-dru-rabbitmq:5672'
      > [zoo-project-dru-zookernel-8675b6d96f-xfjhp init-wait-for-dependencies-zookernel] zoo-project-dru-rabbitmq:5672 is unavailable - sleeping
 - eoap-zoo-project:statefulset/zoo-project-dru-postgresql: Waiting for 1 pods to be ready...
 - eoap-zoo-project:statefulset/zoo-project-dru-rabbitmq: Waiting for 1 pods to be ready...
 - eoap-zoo-project:statefulset/zoo-project-dru-postgresql is ready. [5/7 deployment(s) still pending]
 - eoap-zoo-project:deployment/eoap-zoo-project-localstack is ready. [4/7 deployment(s) still pending]
 - eoap-zoo-project:statefulset/zoo-project-dru-rabbitmq is ready. [3/7 deployment(s) still pending]
 - eoap-zoo-project:deployment/zoo-project-dru-zoofpm is ready. [2/7 deployment(s) still pending]
 - eoap-zoo-project:deployment/zoo-project-dru-zookernel is ready. [1/7 deployment(s) still pending]
 - eoap-zoo-project:deployment/code-server-deployment is ready.
Deployments stabilized in 40.089 seconds
Port forwarding service/zoo-project-dru-service in namespace eoap-zoo-project, remote port 80 -> http://localhost:8080
Port forwarding service/code-server-service in namespace eoap-zoo-project, remote port 8080 -> http://localhost:8000
No artifacts found to watch
Press Ctrl+C to exit
Watching for changes...

````

## Accessing the OGC API Processes Engine

From there, you can access the EOEPCA Processing - OGC API Processes Engine using the following URL: [http://localhost:8080](http://localhost:8080).

In addition, there is a Code Server available on [http://localhost:8000](http://localhost:8000) where you can find the notebooks.




