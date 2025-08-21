# List the deployed processes

To list the deployed processes, OGC API Processes API uses the resource highlighted in the table below:

| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| **Process list**               | **`/processes`**                          | **Lists available processes with identifiers and links to descriptions.**       | **Part 1** |
| Process description            | `/processes/{processID}`                  | Retrieves detailed information about a specific process.                        | Part 1     |
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
import json

namespace = "acme"

ogc_api_endpoint = f"http://zoo-project-dru-service/{namespace}/ogc-api"

response = requests.get(f"{ogc_api_endpoint}/processes")


```

In the cell below, the user will explore the number of deployed processes available on the OGC API endpoint, along with their associated metadata.


```python
# Check if the request was successful
if response.status_code == 200:
    # Parse the JSON response
    processes = response.json()
    
    # Display the number of processes available
    print(f"Number of available processes: {processes.get('numberTotal', 0)}")
    
    # Iterate through each process and print its details
    for process in processes.get("processes", []):
        if process.get("id") in ["echo"]:
            print(f"\nProcess ID: {process.get('id')} - skipped (ZOO Project uses this process for conformance testing)")
            continue
        print(f"\nProcess ID: {process.get('id')}")
        print(f"Title: {process.get('title')}")
        print(f"Description: {process.get('description')}")
        print(f"Version: {process.get('version')}")
        print(f"Mutable: {process.get('mutable')}")
        print(f"Job Control Options: {process.get('jobControlOptions')}")
        print(f"Output Transmission: {process.get('outputTransmission')}")
        
        # Print available links for the process
        for link in process.get("links", []):
            print(f"Link: {link.get('title')} - {link.get('href')}")
else:
    print(f"Failed to list processes. Status code: {response.status_code}")
```

    Number of available processes: 2
    
    Process ID: echo - skipped (ZOO Project uses this process for conformance testing)
    
    Process ID: water-bodies
    Title: Water bodies detection based on NDWI and otsu threshold
    Description: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items
    Version: 1.0.0
    Mutable: True
    Job Control Options: ['async-execute', 'dismiss']
    Output Transmission: ['value', 'reference']
    Link: Process Description - http://localhost:8080/acme/ogc-api/processes/water-bodies


## Explanation

**Fetching Available Processes:**

The `/processes` endpoint is used to list all processes.

The response is parsed to extract information about each process.

**Displaying Process Details:**

For each process, the script displays the id, title, description, version, whether the process is mutable, the jobControlOptions, and outputTransmission options.

Links related to the process (e.g., process description or execution endpoint) are also displayed.

**Understanding the Output**

Process ID: Unique identifier for the process.
Title and Description: Provide information about the process functionality.
Version: Indicates the process version.
Mutable: If True, the process can be modified or redeployed.
Job Control Options: Specifies how the process can be executed (e.g., synchronously, asynchronously, or dismissed).
Output Transmission: Indicates the methods available for retrieving process results.
Links: URLs to access more information about the process, such as its description or execution endpoint.

**Next Steps**

Once you have listed the processes, you can proceed with:

- Viewing process details using the links provided in the output.
- Deploying new processes if needed.
- Executing available processes to perform geospatial tasks.

This tutorial provides a basic way to list processes and gather information, forming the foundation for more complex interactions with the ZOO-Project's OGC API.
