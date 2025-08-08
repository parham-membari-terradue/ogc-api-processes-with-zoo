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
  id: stac-client
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

  baseCommand: ["stac-client"]
  arguments:
  - "search"
  - $(inputs.api_endpoint.url.value)
  - ${
      const args = [];
      const collections = inputs.search_request.collections;
      args.push('--collections', collections.join(","));
      return args;
    }
  - ${
      const args = [];
      const bbox = inputs.search_request?.bbox;
      if (Array.isArray(bbox) && bbox.length >= 4) {
        args.push('--bbox', ...bbox.map(String));
      }
      return args;
    }  
  - ${
      const args = [];
      const limit = inputs.search_request?.limit;
      args.push("--limit", (limit ?? 10).toString());
      return args;
    }
  - ${ 
      const maxItems = 5;
      return ['--max-items', maxItems.toString()];
    }
  - ${
      const args = [];
      const filter = inputs.search_request?.filter;
      const filterLang = inputs.search_request?.['filter-lang'];
      if (filterLang) {
        args.push('--filter-lang', filterLang);
      }
      if (filter) {
        args.push('--filter', JSON.stringify(filter));
      }
      return args;
    }
  - ${
      const datetime = inputs.search_request?.datetime;
      const datetimeInterval = inputs.search_request?.datetime_interval;
      if (datetime) {
        return ['--datetime', datetime];
      } else if (datetimeInterval) {
        const start = datetimeInterval.start?.value || '..';
        const end = datetimeInterval.end?.value || '..';
        return ['--datetime', `${start}/${end}`];
      }
      return [];
    }
  - ${
      const ids = inputs.search_request?.ids;
      if (ids && Array.isArray(ids) && ids.length > 0) {
        return ['--ids', ids.join(",")];
      }
      return [];
    }
  - ${ 
      const intersects = inputs.search_request?.intersects;
      if (intersects) {
        return ['--intersects', JSON.stringify(intersects)];
      }
      return [];
    }
  - --save
  - discovery-output.json

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
