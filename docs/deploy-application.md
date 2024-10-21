# Deploy the Application Package

Deployin an Application Package using the OGC API Processes API uses the API resource highlighted in the table below:


| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                              | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| Process description            | `/processes/{processID}`                  | Retrieves detailed information about a specific process.                        | Part 1     |
| Process execution              | `/processes/{processID}/execution`        | Executes a process, creating a job.                                             | Part 1     |
| **Deploy Process**             | **`/processes` (POST)**                   | **Deploys a new process on the server.**                                        | **Part 2** |
| Replace Process                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                    | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}`                           | Cancels and deletes a job.                                                      | Part 1     |


This resource permits the deployment of the an Application Package and provide two options for the `Content-Type`:

=== "curl"

    ```bash
    curl -X 'POST' \
    'http://localhost:8080/ogc-api/processes?w=water_bodies' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/ogcapppkg+json' \
    -d '{
    "executionUnit": {
        "href": "https://github.com/Terradue/ogc-eo-application-package-hands-on/releases/download/1.5.0/app-water-bodies-cloud-native.1.5.0.cwl",
        "type": "application/cwl"
    }
    }'
    ```

=== "Python"

    ```python
    import requests

    url = "http://localhost:8080/ogc-api/processes?w=water_bodies"
    headers = {
        "accept": "application/json",
        "Content-Type": "application/ogcapppkg+json"
    }
    data = {
        "executionUnit": {
            "href": "https://github.com/Terradue/ogc-eo-application-package-hands-on/releases/download/1.5.0/app-water-bodies-cloud-native.1.5.0.cwl",
            "type": "application/cwl"
        }
    }

    response = requests.post(url, headers=headers, json=data)

    # Check if the request was successful
    if response.status_code == 200:
        print("Request successful!")
        print(response.json())  # Print response content as JSON
    else:
        print(f"Request failed with status code {response.status_code}")
        print(response.text)
    ```

This time, we can add a request body and set its content type. There are two encodings presented which rely on the same CWL conformance class. They both use the same water_bodies.cwl, but using the OGC Application Package encoding (application/ogcapppkg+json), we can pass the CWL file by reference rather than the file content, when we pick the CWL encoding (application/cwl+yaml).

When we select a content type, the request body text area should get updated and contain a relevant payload for this encoding.

Warning
This is a warning

Warning

If we edit the payload, the text area may not update when selecting a different encoding. In such a case, we can use the Reset button to get it corrected.

After executing the deployment request, the server sends back a process summary similar to the one we received from the previous endpoint. The server response includes a Location header that contains the URL for accessing the detailed process description.

We have two options: go back to the first step and list the available processes (it should contain the deployed process), or move on to the next step and review the process description.