### Goal 

Create a container and run the `ogc-api-processes-client` step in the container image. This container will interact with the a deployrd process (e.g. water-bodies) on the OGC API endpint, submit a job with the recived inputs, monitor the job for any upcoming event(e.g **running**, **successful**, **failed**), and finally create STAC ItemCollection with assets pointing to the results. 

### Lab

This step has a dedicated lab available at [execute-monitor-process.md](../execute-monitor-process.md). But it is very important to run [01-Deploy-an-application-package.ipynb](../deploy-application.md) before proceeding with job execution step.

### Container

This `ogc-api-processes-client` has its own recipe to build the container image. The recipe is provided in the cell below:

```dockerfile linenums="1" title="ogc-api-processes-client/Dockerfile"
--8<--
containers/ogc-api-processes-client/Dockerfile
--8<--
```
 
Build the container image with:

```bash linenums="1" title="terminal"
--8<--
docs/containers/build_container_ogc_api_processes_client.sh
--8<--
```

### How to run a step in a container

We'll use `podman` container engine (`docker` is also fine).

Before running the container using `podman` it is very important to deploy the application package such as `water-bodies` on the OGC endpoint. The deployment of water-bodies application package is explained in [01-Deploy-an-application-package.ipynb](../deploy-application.md). Once the deployment was successful, the command to run the `ogc-api-processes-client` step in the container is:

```
docker_tag=$(yq eval '
  ."$graph"[]
  | select(.id == "ogc-api-processes-client")
  | .requirements[]
  | select(.class == "DockerRequirement")
  | .dockerPull
' cwl-workflows/eoap-api-cli.cwl)

podman \
    run \
    -i \
    --userns=keep-id \
    --mount=type=bind,source=/workspace/ogc-api-processes-with-zoo/runs,target=/runs \
    --workdir=/runs \
    --read-only=true \
    --user=1001:100 \
    --rm \
    --env=TMPDIR=/tmp \
    --env=HOME=/runs \
    $docker_tag \
    ogc-api-processes-client \
    --api-endpoint \
    http://zoo-project-dru-service/acme/ogc-api/ \
    --process-id \
    water-bodies \
    --execute-request \
    containers/ogc-api-processes-client/execute_request.json \
    --output \
    feature-collection.json
```

Let's break down what this command does:

* `podman run`: This is the command to run a container.
* `-i`: This flag makes the container interactive, allowing you to interact with it via the terminal.
* `--userns=keep-id`: It instructs `podman` to keep the user namespace ID.
`--mount=type=bind,source=/workspace/ogc-api-processes-with-zoo/runs,target=/runs`: This option mounts a directory from the host system to the container. In this case, it mounts the `/workspace/ogc-api-processes-with-zoo/runs` directory on the host to the `/runs` directory inside the container.
* `--workdir=/runs`: Sets the working directory inside the container to `/runs`.
* `--read-only=true`: Makes the file system inside the container read-only, meaning you can't write or modify files inside the container.
* `--user=1001:100`: Specifies the user and group IDs to be used within the container.
* `--rm`: This flag tells podman to remove the container after it has finished running.
* `--env=HOME=/runs`: Sets the `HOME` environment variable inside the container to `/runs`.
* `$docker_tag`: This is the name of the container image that you were built earlier and want to run.
* `ogc-api-processes-client`: This is the command to run inside the container. It runs a Python module named "ogc-api-processes-client"
* `--api-endpoint "http://zoo-project-dru-service/acme/ogc-api/"`: This provides command-line arguments to the Python module. It specifies the address to the OGC API endpoint where the service is running.
* `--process-id`: Specifies the id of process we deployed (e.g. `water-bodies`) in [01-Deploy-an-application-package.ipynb](../deploy-application.md).
* `--execute-request`: This input point to the JSON file containing the information of two sentinel-2/landsat products from [planetarycomputer](https://planetarycomputer.microsoft.com/api/stac/v1/collections) are going to pass to the `water-bodies` [application pacakge](https://github.com/eoap/mastering-app-package/releases/download/1.1.1/app-water-bodies-cloud-native.1.1.1.cwl). An expample of this JSON file is mentioned below:

```bash linenums="1" title="execute_request.json"
--8<--
docs/containers/execute_request.json
--8<--
```


* `--output`: This input would pass the JSON file name containing the result of wate-bodies detection in STAC ItemCollection format


### Expected outcome

The folder `/workspace/ogc-api-processes-with-zoo/runs` contains: 

```
(base) jovyan@coder-mrossi:~/runs$ tree .
.
└── feature-collection.json

0 directories, 1 file
``` 
