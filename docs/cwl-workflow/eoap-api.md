### EOAP API Workflow - Orchestrating CWL CommandLineTools
The **EOAP API Workflow** chains together three main steps — `discovery`, `prepare-execute-request`, and `processes` — to query a STAC API, prepare an OGC API Processes execution request, and finally run the requested process.

It takes the following input parameters:

* a STAC API endpoint
* a STAC search request (query parameters)
* a Processes API endpoint
* an execution request template for OGC API Processes

And produces as outputs:

* the results of the STAC search (search results as a JSON file)
* the process execution result (OGC API Process output as a JSON file)

```mermaid
graph TB
  A[STAC API Endpoint] --> B(("Discovery Step"))
  P[Search Request] --> B
  B --> C1[Search Results]
  C1 --> C2["<font size=2% color='blue'>discovery-output.json</font>"]

  C2 --> D(("Prepare Execute Request"))
  D --> D2["<pre style='text-align:left; color:black;'>
execute_request.json:
{
  inputs:
    - stac_items
    - aoi
    - bands
    - epsg
}
</pre>"]
  D --> D3[process_id.json]
  D2 --> E(("Processes Step"))
  D3 --> E
  R[Processes API Endpoint] --> E

  E --> F[Workflow Output]
  C2 -->F
  F --> I["<font size=2% color='green'>feature-collection.json</font>"] 
  F --> G["<font size=2% color='gray'>discovery-output.json</font>"]
   
  subgraph EOAP Workflow
    B
    C1
    C2
    D
    D2
    D3
    E
  end
```

### Workflow Steps

1. **Discovery Step**
   Uses the provided `stac_api_endpoint` and `search_request` to query a STAC API. The result is saved as `search_output`.
    - Output: `discovery-output.json` — This JSON file contains the results from discovering the STAC endpoint. It is generated using [`stac-api-client.0.1.0.cwl`](https://github.com/eoap/schemas/releases/download/0.1.0/stac-api-client.0.1.0.cwl).
  
2. **Prepare Execute Request Step**
   Combines the initial `execute_request` template with the `search_output` from the discovery step.

   * Extracts STAC item URLs from the search results.
   * Inserts them into the `.inputs.stac_items` field of the execution request.
   * Removes the `process_id` from the request and stores it separately.
   * Outputs:
  
     - `execute_request.json` — the updated request ready to be sent.
     - `process_id.json` — the process identifier.
   
3. **Processes Step**
   Executes the OGC API Process using the `processes_api_endpoint`, the prepared `execute_request.json`, and the `process_id`. The result is stored in `feature-collection.json`.



The CWL Workflow is shown below and the lines highlighted chain the steps:

```yaml linenums="1" title="eoap-api-cli.cwl"
--8<--
cwl-workflows/eoap-api-cli.cwl
--8<--
```

