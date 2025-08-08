#!/usr/bin/env cwl-runner

$graph:
- class: Workflow
  label: EOAP API Workflow

  requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
    - $import: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/experimental/discovery.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml

  inputs:
  - id: stac_api_endpoint
    type: |-
      https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml#APIEndpoint
  - id: search_request
    type: |-
      https://raw.githubusercontent.com/eoap/schemas/main/experimental/discovery.yaml#STACSearchSettings
  - id: processes_api_endpoint
    type: |-
      https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml#APIEndpoint
  - id: execute_request
    type: |-
      https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml#OGCExecuteProcessSettings

  outputs:
  - id: search_output
    outputSource:
      - discovery/search_output
    type: File
  - id: process_output
    outputSource:
      - processes/process_output
    type: File

  steps:
    discovery:
      label: Discovery Step
      in:
        api_endpoint: stac_api_endpoint
        search_request: search_request
      run: '#stac-client'
      out:
      - search_output
    processes:
      label: Processes Step
      in:
        api_endpoint: processes_api_endpoint
        execute_request: execute_request
        search_results:
          source: discovery/search_output
      run: '#ogc-api-processes-client'
      out: 
      - process_output
  id: eoap-api
- class: CommandLineTool
  label: STAC Client Tool
  doc: |
    This tool uses the STAC Client to search for STAC items

  requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: docker.io/library/stac-client 
  - class: NetworkAccess
    networkAccess: true
  - class: SchemaDefRequirement
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
    - $import: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/experimental/discovery.yaml
  - class: InitialWorkDirRequirement
    listing:
    - entryname: run.sh
      entry: |2-
        #!/bin/bash
        set -x
        collections="${ 
          const collections = inputs.search_request.collections;
          return (collections && Array.isArray(collections) && collections.length > 0) ? "--collections " + collections.join(",") : "";
        }"

        bbox="${ 
          const bbox = inputs.search_request?.bbox;
          return (bbox && Array.isArray(bbox) && bbox.length >= 4) ? "--bbox " + bbox.join(" ") : "";
        }"

        stac_api=$(inputs.api_endpoint.url.value)

        

        limit="${ 
          const limit = inputs.search_request?.limit;
          return limit ? '--limit ' + limit : '';
        }"



        stac-client search \
          $stac_api \
          $collections \
          $bbox \
          --max-items 10 \
          --limit 10 \
          --save discovery-output.json

  inputs:
    api_endpoint:
      label: STAC API endpoint
      doc: STAC API endpoint for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml#APIEndpoint
    search_request:
      label: STAC API settings
      doc: STAC API settings for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/discovery.yaml#STACSearchSettings

  outputs:
    search_output:
      type: File
      outputBinding:
        glob: discovery-output.json

  baseCommand: ["/bin/bash", "run.sh"]
  arguments: []
  id: stac-client



- class: CommandLineTool
  label: geo API - Processes

  requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
    - $import: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml
  - class: InitialWorkDirRequirement
    listing:
    - entryname: run.sh
      entry: |-
        #!/usr/bin/env bash
        set -euo pipefail

        process_id=$(inputs.execute_request.process_id)

        jq '[.features[].links[] | select(.rel=="self") | .href]' "$(inputs.search_results.path)" > items.json

        echo '${ return JSON.stringify(inputs.execute_request, null, 2); }' | jq . > temp_execute_request.json

        jq --argjson items "`cat items.json`" \
          'del(.process_id) | .inputs.items = $items' \
          temp_execute_request.json > execute_request.json

        cat execute_request.json | jq .

        # invoke the OGC API Processes endpoint
        # TODO
  inputs:
    api_endpoint:
      label: OGC API endpoint
      doc: OGC API endpoint for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml#APIEndpoint
    execute_request:
      label: OGC API Processes settings
      doc: OGC API Processes settings for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml#OGCExecuteProcessSettings
    search_results:
      label: Search Results
      doc: Search results from the discovery step
      type: File
  outputs:
    process_output:
      type: File
      outputBinding:
        glob: execute_request.json


  baseCommand: ["/bin/bash", "run.sh"]
  arguments: []

  id: ogc-api-processes-client
cwlVersion: v1.2
