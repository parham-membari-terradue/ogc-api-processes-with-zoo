# Deploy the Application Package

Deploying an Application Package using the OGC API Processes uses the API resource highlighted in bold in the table below:


| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                              | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| Process description            | `/processes/{processID}`                  | Retrieves detailed information about a specific process.                        | Part 1     |
| Process execution              | `/processes/{processID}/execution` (POST) | Executes a process, creating a job.                                             | Part 1     |
| **Deploy Process**             | **`/processes` (POST)**                   | **Deploys a new process on the server.**                                        | **Part 2** |
| Replace Process                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                    | Part 2     |
| Application Package (OGC AppPkg) | `/processes/{processId}/package`        | Support accessing the OGC Application Package.                                  | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}` (DELETE)                  | Cancels and deletes a job.                                                      | Part 1     |


This resource permits the deployment of the an Application Package and provide two options for the `Content-Type`.

## Content-Type: application/ogcapppkg+json

Provide the reference to an Application Package.

=== "curl"

    ```bash
    curl -X 'POST' \
    'http://localhost:8080/ogc-api/processes?w=water_bodies' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/ogcapppkg+json' \
    -d '{
    "executionUnit": {
        "href": "https://github.com/eoap/mastering-app-package/releases/download/1.0.0/app-water-bodies-cloud-native.1.0.0.cwl",
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
            "href": "https://github.com/eoap/mastering-app-package/releases/download/1.0.0/app-water-bodies-cloud-native.1.0.0.cwl",
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


## Content-Type: application/cwl+yaml

=== "curl"
 

    ```bash
    curl -L https://github.com/eoap/mastering-app-package/releases/download/1.0.0/app-water-bodies-cloud-native.1.0.0.cwl > app-water-bodies-cloud-native.1.0.0.cwl

    curl -X 'POST' \
        'http://localhost:8080/ogc-api/processes?w=water_bodies' \
        -H 'accept: application/json' \
        -H 'Content-Type: application/cwl+yaml' \
        -d @app-water-bodies-cloud-native.1.0.0.cwl
    ```

=== "Python"

    ```python
    import requests

    url = "http://localhost:8080/ogc-api/processes?w=water_bodies"
    headers = {
        "accept": "application/json",
        "Content-Type": "application/cwl+yaml"
    }

    # Read the content of the file
    with open("/path/to/your/file.yaml", "r") as file:
        file_data = file.read()

    # Send the POST request with the file content as the data
    response = requests.post(url, headers=headers, data=file_data)

    # Check if the request was successful
    if response.status_code == 200:
        print("Request successful!")
        print(response.json())  # Print response content as JSON
    else:
        print(f"Request failed with status code {response.status_code}")
        print(response.text)
    ```

## Response 

After executing the deployment request, the server sends back a process summary. The server response includes a Location header that contains the URL for accessing the detailed process description.

Response content example:

```json
{
  "id": "water-bodies",
  "title": "Water bodies detection based on NDWI and otsu threshold",
  "description": "Water bodies detection based on NDWI and otsu threshold",
  "mutable": true,
  "version": "1.4.1",
  "metadata": [
    {
      "role": "https://schema.org/softwareVersion",
      "value": "1.4.1"
    }
  ],
  "outputTransmission": [
    "value",
    "reference"
  ],
  "jobControlOptions": [
    "async-execute",
    "dismiss"
  ],
  "links": [
    {
      "rel": "http://www.opengis.net/def/rel/ogc/1.0/execute",
      "type": "application/json",
      "title": "Execute End Point",
      "href": "http://localhost:8080/ogc-api/processes/water-bodies/execution"
    }
  ]
}
```

Response headers example:

```
connection: Keep-Alive 
 content-type: application/json;charset=UTF-8 
 date: Mon,21 Oct 2024 12:20:48 GMT 
 keep-alive: timeout=5,max=100 
 location: http://localhost:8080/ogc-api/processes/water-bodies 
 server: Apache/2.4.41 (Ubuntu) 
 transfer-encoding: chunked 
 x-also-also-also-powered-by: dru.securityOut 
 x-also-also-powered-by: dru.securityIn 
 x-also-powered-by: jwt.securityIn 
 x-powered-by: ZOO-Project-DRU 
```

## Practice lab

Run the notebook **01 - Deploy an application package**.