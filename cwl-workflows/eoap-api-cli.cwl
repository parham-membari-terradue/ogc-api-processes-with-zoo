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
      run: https://github.com/eoap/schemas/releases/download/0.1.0/stac-api-client.0.1.0.cwl
      out:
      - search_output

    prepare-execute-request:
      label: Prepare Execute Request
      in:
        in_execute_request: execute_request
        search_results:
          source: discovery/search_output
      run: '#prepare-execute-request'
      out:
      - execute_request
      - process_id

    processes:
      label: Processes Step
      in:
        api_endpoint: processes_api_endpoint
        execute_request: 
          source: prepare-execute-request/execute_request
        process_id:
          source: prepare-execute-request/process_id
      run: '#ogc-api-processes-client'
      out: 
      - process_output

  id: eoap-api

- class: CommandLineTool
  id: prepare-execute-request
  label: Prepare Execute Request
  doc: Prepare the execute request for OGC API Processes based on search results 

  baseCommand: ["/bin/bash", "run.sh"]
  arguments: []

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
    - entryname: input_execute_request.json
      entry: |-
        ${ return JSON.stringify(inputs.in_execute_request, null, 2); }
    - entryname: process_id.json
      entry: |-
        ${ return JSON.stringify(inputs.in_execute_request.process_id, null, 2); }
    - entryname: run.sh
      entry: |-
        #!/usr/bin/env bash
        set -x
        set -euo pipefail


        jq '[.features[].links[] | select(.rel=="self") | .href]' "$(inputs.search_results.path)" > items.json

        jq --argjson items "`cat items.json`" \
          'del(.process_id) | .inputs.items = $items' \
          input_execute_request.json > execute_request.json

        cat execute_request.json | jq .
 
  inputs:
    in_execute_request:
      label: OGC API Processes settings
      doc: OGC API Processes settings for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml#OGCExecuteProcessSettings

    search_results:
      label: Search Results
      doc: Search results from the discovery step
      type: File

  outputs:
    execute_request:
      type: File
      outputBinding:
        glob: execute_request.json
    process_id:
      type: Any
      outputBinding:
        glob: process_id.json
        loadContents: true
        outputEval: ${ return JSON.parse(self[0].contents); }
  


- class: CommandLineTool
  id: ogc-api-processes-client
  label: geo API - Processes

  requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull:  localhost/ogc 
  - class: SchemaDefRequirement
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
    - $import: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/experimental/process.yaml
  inputs:
    api_endpoint:
      label: OGC API endpoint
      doc: OGC API endpoint for Landsat-9 data
      type: |-
        https://raw.githubusercontent.com/eoap/schemas/main/experimental/api-endpoint.yaml#APIEndpoint
    execute_request:
      label: OGC API Processes settings
      doc: OGC API Processes settings for Landsat-9 data
      type: File
    process_id:
      label: Process ID
      doc: Process ID for the OGC API Processes
      type: Any

  outputs:
    process_output:
      type: File
      outputBinding:
        glob: feature-collection.json
  baseCommand: ["ogc-api-processes-client"]
  arguments:
    - --api-endpoint
    - $(inputs.api_endpoint.url.value)
    - --process-id
    - $(inputs.process_id)
    - --execute-request 
    - $(inputs.execute_request.path)
    - --output
    - feature-collection.json

  
cwlVersion: v1.2
