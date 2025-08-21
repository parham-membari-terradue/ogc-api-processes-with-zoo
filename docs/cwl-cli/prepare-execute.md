### Goal 

Wrap the `prepare-execute-request` step as a Common Workflow Language CommandLineTool and execute it with a CWL runner. Indeed, it prepare the execute request JSON file for OGC API Processes based on search results 



### How to wrap a step as a CWL CommandLineTool 

The CWL document below shows the `prepare-execute-request` step wrapped as a CWL CommandLineTool:

```yaml linenums="1" hl_lines="9-12 49-53" title="cwl-cli/prepare-execute-request-cli.cwl"
--8<--
cwl-cli/prepare-execute-request-cli.cwl
--8<--
```


Let's break down the key components of this CWL document:

* **`cwlVersion: v1.2`**: Specifies the version of the CWL specification that this document follows.

* **`class: CommandLineTool`**: Indicates that this CWL document defines a command-line tool.

* **`id: prepare-execute-request`**: Provides a unique identifier for this tool, which can be referenced in workflows.

* **`arguments`**: This section is empty, meaning there are no additional command-line arguments specified here. The tool receives its arguments via the input parameters.

* **`baseCommand`**: Defines the base command to be executed. In this case, it's running a bash script: `["/bin/bash", "run.sh"]`.

* **`requirements`**: Specifies the requirements and dependencies of the tool:

  * **`InlineJavascriptRequirement`**: Allows the use of inline JavaScript expressions in the tool.
  * **`SchemaDefRequirement`**: Ensures that specific types are defined and validated according to the referenced schemas. Custom types allow for reuse and better validation. [Learn more](https://www.commonwl.org/user_guide/topics/custom-types.html).
  * **`NetworkAccess`**: Specifies that the tool requires outgoing network access. Only needed for `cwlVersion: v1.2`; in `v1.0` this is supported by default.
  * **`InitialWorkDirRequirement`**: Defines files that must be staged before running the tool. Specifically:

    * Creates `input_execute_request.json` containing the contents of `inputs.in_execute_request` converted to a pretty-printed JSON string:

    ```yaml
    listing:
    - entryname: input_execute_request.json
      entry: |-
          ${ return JSON.stringify(inputs.in_execute_request, null, 2); }
    ```

    * Creates `process_id.json` containing only the `process_id` from `inputs.in_execute_request`, also formatted as pretty-printed JSON:

    ```yaml
    listing:
    - entryname: process_id.json
      entry: |-
          ${ return JSON.stringify(inputs.in_execute_request.process_id, null, 2); }
    ```

    * Creates `run.sh`, which performs the following actions when executed:

      1. Extracts STAC item URLs from the `search_results` JSON file and saves them to `stac_items.json`.
      2. Deletes the `process_id` from `input_execute_request.json` and injects the extracted STAC items into the `.inputs.stac_items` field.
      3. Outputs the resulting `execute_request.json`, which can then be used as input for subsequent workflow steps.

* **`inputs`**: Defines the input parameters for the tool.

  * `in_execute_request`: OGC API Processes settings (e.g., for Sentinel2/Landsat-9 data).
  * `search_results`: Discovery results from the prior step, provided as a file.

* **`outputs`**: Defines the outputs produced by the tool.

  * `execute_request`: The final JSON request prepared for execution. An expample of this JSON file is mentioned below:
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
  * `process_id`: The original process identifier, preserved for reference.
