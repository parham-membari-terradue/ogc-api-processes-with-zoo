# Describe the process

To describe a process, the OGC API Processes API uses the resource highlighted in the table below:

| **Resource**                   | **Path**                                  | **Purpose**                                                                     | **Part**   |
|--------------------------------|-------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                       | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                            | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                    | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                              | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| **Process description**        | **`/processes/{processID}`**              | **Retrieves detailed information about a specific process.**                    | **Part 1** |
| Process execution              | `/processes/{processID}/execution`        | Executes a process, creating a job.                                             | Part 1     |
| Deploy Process                 | `/processes` (POST)                       | Deploys a new process on the server.                                            | Part 2     |
| Replace Process                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                    | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}`                           | Cancels and deletes a job.                                                      | Part 1     |

The process description contains information about inputs and outputs and a link to the execution endpoint for the process. 

The _OGC API Processes - Core_ does not mandate the use of a specific process description to specify the interface of a process. That said, the _OGC API Processes - Core_ requirements class makes the following recommendation:

| Implementations SHOULD consider supporting the OGC process description.

For more information, see OGC 18-062r2 <a rel="noopener noreferrer" target="_blank" href="https://docs.ogc.org/is/18-062r2/18-062r2.html#sc_process_list">Section 7.10</a>.

The conformance class `ogc-process-description` is supported, meaning the server will provide a standard process description that contains the list and detailed description of every input and output. 

The input for a process can be either single-valued or multi-valued, meaning you can pass one or more values for a given input. 

Every input has `minOccurs` and `maxOccurs` attributes. If there are no `minOccurs` attributes, it means that the value is 1, and that the input is required to execute the process. 

Inputs may be optional, indicated by a `minOccurs` of 0. If there are no `maxOccurs`, the default value 1 applies, and the input can take only one value. 

If `maxOccurs` is greater than 1, the input can be an array of multiple items.

## Response example


```json
{
  "id": "water-bodies",
  "title": "Water bodies detection based on NDWI and otsu threshold",
  "description": "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items",
  "mutable": true,
  "version": "1.0.0",
  "metadata": [
    {
      "role": "https://schema.org/softwareVersion",
      "value": "1.0.0"
    },
    {
      "role": "https://schema.org/author",
      "value": {
        "@context": "https://schema.org",
        "@type": "Person",
        "s.name": "Jane Doe",
        "s.email": "jane.doe@acme.earth",
        "s.affiliation": "ACME"
      }
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
      "href": "http://localhost:8080/acme/ogc-api/processes/water-bodies/execution"
    }
  ],
  "inputs": {
    "aoi": {
      "title": "area of interest",
      "description": "area of interest as a bounding box",
      "schema": {
        "type": "string"
      }
    },
    "bands": {
      "title": "bands used for the NDWI",
      "description": "bands used for the NDWI",
      "schema": {
        "type": "string",
        "default": "['green', 'nir']"
      }
    },
    "epsg": {
      "title": "EPSG code",
      "description": "EPSG code",
      "schema": {
        "type": "string",
        "default": "EPSG:4326",
        "nullable": true
      }
    },
    "stac_items": {
      "title": "Sentinel-2 STAC items",
      "description": "list of Sentinel-2 COG STAC items",
      "schema": {
        "type": "string"
      }
    }
  },
  "outputs": {
    "stac_catalog": {
      "title": "stac_catalog",
      "description": "None",
      "extended-schema": {
        "oneOf": [
          {
            "allOf": [
              {
                "$ref": "http://zoo-project.org/dl/link.json"
              },
              {
                "type": "object",
                "properties": {
                  "type": {
                    "enum": [
                      "application/json"
                    ]
                  }
                }
              }
            ]
          },
          {
            "type": "object",
            "required": [
              "value"
            ],
            "properties": {
              "value": {
                "oneOf": [
                  {
                    "type": "object"
                  }
                ]
              }
            }
          }
        ]
      },
      "schema": {
        "oneOf": [
          {
            "type": "object"
          }
        ]
      }
    }
  }
}
```

## Practice lab

Run the notebook **03 - Describe the process**.