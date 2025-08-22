cwlVersion: v1.2
$graph:
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