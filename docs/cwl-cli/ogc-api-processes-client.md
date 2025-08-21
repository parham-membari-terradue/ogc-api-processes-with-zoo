### Goal 

Wrap the `ogc-api-processes-client` step as a Common Workflow Language CommandLineTool and execute it with a CWL runner. Indeed, it will interact with the a deployrd process (e.g. `water-bodies`) on the OGC API endpint, submit a job with the recived inputs, monitor the job for any upcoming event(e.g **running**, **successful**, **failed**), and finally create STAC ItemCollection with assets pointing to the results. 



### How to wrap a step as a CWL CommandLineTool 

The CWL document below shows the `ogc-api-processes-client` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" hl_lines="9-12 49-53" title="cwl-cli/ogc-api-processes-client-cli.cwl"
--8<--
cwl-cli/ogc-api-processes-client-cli.cwl
--8<--
```


Let's break down the key components of this CWL document:

- **`cwlVersion: v1.2`**
   Specifies that this CWL document uses version 1.2 of the CWL specification.

- **`class: CommandLineTool`**
   Indicates that this CWL document defines a command-line tool.

- **`id` and `label`**

   * `id: ogc-api-processes-client` — unique identifier for this tool.
   * `label: Geo API - Processes` — human-readable name.

- **`requirements`**
   Defines the execution environment and runtime features:

   * `InlineJavascriptRequirement` — Allows the use of inline JavaScript expressions in the tool like `$(inputs.xyz)` in arguments.
   * `DockerRequirement` — specifies the Docker container image refrence for execution.
   * `SchemaDefRequirement` — imports custome schemas for input validation:

     * `string_format.yaml`
     * `geojson.yaml`
     * `api-endpoint.yaml`
     * `process.yaml`

- **`inputs`**
   The tool expects three inputs:

   * `api_endpoint`: the OGC API URL (validated against a schema).
   * `execute_request`: JSON file with process parameters. An expample of this JSON file is mentioned below:

        ```
        {
            "inputs": {
                "stac_items": [
                    "https://planetarycomputer.microsoft.com/api/stac/v1/collections/landsat-c2-l2/items/LC08_L2SP_044032_20231208_02_T1",
                    "https://planetarycomputer.microsoft.com/api/stac/v1/collections/landsat-c2-l2/items/LC08_L2SP_043033_20231201_02_T1"
                ],
                "aoi": "-121.399,39.834,-120.74,40.472",
                "epsg": "EPSG:4326",
                "bands": [
                    "green",
                    "nir08"
                ]
            }
        }
        ```
   * `process_id`: identifier of the OGC process to run.

- **`outputs`**
   Defines what the tool produces:

   * `process_output`: a file called `feature-collection.json`.

- **`baseCommand` and `arguments`**

   * `baseCommand: ["ogc-api-processes-client"]` which is the command executed inside Docker.
   * `arguments` — maps CWL inputs to command-line flags:

     * `--api-endpoint` → `$(inputs.api_endpoint.url.value)`
     * `--process-id` → `$(inputs.process_id)`
     * `--execute-request` → `$(inputs.execute_request.path)`
     * `--output` → `feature-collection.json`





