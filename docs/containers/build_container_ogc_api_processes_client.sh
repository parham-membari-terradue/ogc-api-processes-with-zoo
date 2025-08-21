#!/bin/bash
export WORKSPACE=$PWD
docker_tag=$(yq eval '
  ."$graph"[]
  | select(.id == "ogc-api-processes-client")
  | .requirements[]
  | select(.class == "DockerRequirement")
  | .dockerPull
' cwl-workflows/eoap-api-cli.cwl)

echo $docker_tag
docker build -t $docker_tag $WORKSPACE/containers/ogc-api-processes-client





