# Describe the process

To describe a process, the OGC API Processes API uses the resource highlighted in the table below:

| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                              | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| **Process description**        | **`/processes/{processID}`**              | **Retrieves detailed information about a specific process.**                    | **Part 1** |
| Process execution              | `/processes/{processID}/execution` (POST) | Executes a process, creating a job.                                             | Part 1     |
| Deploy Process                 | `/processes` (POST)                       | Deploys a new process on the server.                                            | Part 2     |
| Replace Process                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                    | Part 2     |
| EO Application Package         | `/processes/{processID}/package`          | Get the EOAP associated with a deployed process.                                | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}` (DELETE)                  | Cancels and deletes a job.                                                      | Part 1     |


```python
import requests

namespace = "acme"  # Replace with your namespace
ogc_api_endpoint = f"http://zoo-project-dru-service/{namespace}/ogc-api"
```

In the cell below, the user can examine the metadata of a specific process that has already been deployed on the OGC API endpoint.


```python

process_id = "water-bodies"  


# Make a GET request to retrieve the process description
response = requests.get(f"{ogc_api_endpoint}/processes/{process_id}")

# Check if the request was successful
if response.status_code == 200:
    # Parse the JSON response
    process_description = response.json()
    
    # Display the process details
    print(f"Process ID: {process_description.get('id')}")
    print(f"Title: {process_description.get('title')}")
    print(f"Description: {process_description.get('description')}")
    print(f"Version: {process_description.get('version')}")
    print(f"Mutable: {process_description.get('mutable')}")
    
    # Display inputs
    print("\nInputs:")
    for input_id, input_details in process_description.get("inputs", {}).items():
        print(f"  - {input_id}:")
        print(f"    Title: {input_details.get('title')}")
        print(f"    Description: {input_details.get('description')}")
        print(f"    Type: {input_details.get('schema', {}).get('type')}")
        print(f"    Default: {input_details.get('schema', {}).get('default', 'N/A')}")
    
    # Display outputs
    print("\nOutputs:")
    for output_id, output_details in process_description.get("outputs", {}).items():
        print(f"  - {output_id}:")
        print(f"    Title: {output_details.get('title')}")
        print(f"    Description: {output_details.get('description')}")
else:
    print(f"Failed to retrieve process description. Status code: {response.status_code}")
```

    Process ID: water-bodies
    Title: Water bodies detection based on NDWI and otsu threshold
    Description: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items
    Version: 1.0.0
    Mutable: True
    
    Inputs:
      - aoi:
        Title: area of interest
        Description: area of interest as a bounding box
        Type: string
        Default: N/A
      - bands:
        Title: bands used for the NDWI
        Description: bands used for the NDWI
        Type: string
        Default: ['green', 'nir']
      - epsg:
        Title: EPSG code
        Description: EPSG code
        Type: string
        Default: EPSG:4326
      - stac_items:
        Title: Sentinel-2 STAC items
        Description: list of Sentinel-2 COG STAC items
        Type: string
        Default: N/A
    
    Outputs:
      - stac_catalog:
        Title: stac_catalog
        Description: None


## Explanation

**Fetching Process Description:**

The script sends a GET request to the `/processes/{process_id}` endpoint to retrieve the description.

The process ID (e.g., "water-bodies") is used to specify the process for which you want to get the description.

**Displaying Process Details:**

The response is parsed to extract details such as id, title, description, version, and whether the process is mutable.
The script then displays the inputs and outputs associated with the process, including their title, description, and type.

## Understanding the Output

**Process Information:**

- id: Unique identifier for the process.
- title and description: Provide details about the process's functionality.
- version: The version number of the process.
- mutable: Indicates whether the process can be modified or redeployed.

**Inputs and Outputs:**

Lists the parameters needed for the process execution (inputs) and what the process produces (outputs).

Each input has attributes such as title, description, type, and default value.

Outputs describe what will be produced by the process execution.

## Troubleshooting

If the script fails to retrieve the process description, ensure that:
- The ZOO-Project OGC API server is running and accessible.
- The specified process ID is correct and corresponds to an existing process.
- The namespace is set correctly.

## Next Steps

After retrieving the process description, you can:

- Execute the process using the inputs described.
- Monitor the process execution to check its status.
- Retrieve the results once the process execution is complete.

This tutorial provides the necessary steps to retrieve and understand the details of a deployed process using the ZOO-Project's OGC API.
