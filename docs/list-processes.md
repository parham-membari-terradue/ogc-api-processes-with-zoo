# List the available and deployed processes

To list the available and deployed processes, OGC API Processes API uses the resource highlighted in bold in the table below:

| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| **Process list**               | **`/processes`**                          | **Lists available processes with identifiers and links to descriptions.**       | **Part 1** |
| Process description            | `/processes/{processID}`                  | Retrieves detailed information about a specific process.                        | Part 1     |
| Process execution              | `/processes/{processID}/execution`        | Executes a process, creating a job.                                             | Part 1     |
| Deploy Process                 | `/processes` (POST)                       | Deploys a new process on the server.                                            | Part 2     |
| Replace Process                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                    | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}`                           | Cancels and deletes a job.                                                      | Part 1     |


The list of processes contains a summary of each process the OGC API - Processes offers, including the link to a more detailed description of the process.

For more information, see OGC 18-062r2 <a rel="noopener noreferrer" target="_blank" href="https://docs.ogc.org/is/18-062r2/18-062r2.html#sc_process_list">Section 7.9</a>.

=== "curl"

    ```bash
    curl -X 'GET' \
        'http://localhost:8080/ogc-api/processes?limit=1000' \
        -H 'accept: application/json'
    ```

=== "Python"

    ```python
    import requests

    ogc_api_endpoint = "http://localhost:8080/ogc-api"

    response = requests.get(f"{ogc_api_endpoint}/processes")    
    ```

## Practice lab

Run the notebook **02 - List the deployed processes**.