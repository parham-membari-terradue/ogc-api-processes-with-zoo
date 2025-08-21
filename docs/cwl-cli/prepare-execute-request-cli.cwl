cwlVersion: v1.2
$graph:
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
  - class: NetworkAccess
    networkAccess: true
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


        jq '[.features[].links[] | select(.rel=="self") | .href]' "$(inputs.search_results.path)" > stac_items.json

        jq --argjson stac_items "`cat stac_items.json`" \
          'del(.process_id) | .inputs.stac_items = $stac_items' \
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