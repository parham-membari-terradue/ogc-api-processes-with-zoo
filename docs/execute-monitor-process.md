# Execute the process and monitor the execution

To submit an execution request of a deployed process and monitor it, the OGC API Processes API uses the resource highlighted in bold in the table below:

| **Resource**                   | **Path**                                     | **Purpose**                                                                     | **Part**   |
|--------------------------------|----------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                          | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                               | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                       | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                                 | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| Process description            | `/processes/{processID}`                     | Retrieves detailed information about a specific process.                        | Part 1     |
| **Process execution**          | **`/processes/{processID}/execution`**(POST) | **Executes a process, creating a job.**                                         | **Part 1** |
| Deploy Process                 | `/processes` (POST)                          | Deploys a new process on the server.                                            | Part 2     |
| Replace Process                | `/processes/{processID}` (PUT)               | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)            | Removes an existing process from the server.                                    | Part 2     |
| Application Package (OGC AppPkg) | `/processes/{processId}/package`           | Support accessing the OGC Application Package.                                  | Part 2     |
| **Job status info**            | **`/jobs/{jobID}`**                          | **Retrieves the current status of a job.**                                      | **Part 1** |
| **Job results**                | **`/jobs/{jobID}/results`**                  | **Retrieves the results of a job.**                                             | **Part 1** |
| Job list                       | `/jobs`                                      | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}` (DELETE)                     | Cancels and deletes a job.                                                      | Part 1     |

## Execution

Using the endpoint **`/processes/{processID}/execution`**, the serve will execute the *{processID}* process. It leads to the creation of a `job`. 

The `job` is the entity that identifies the process execution.

After the execution request is sent to the server, the server creates an unique identifier, `jobID`, for the job called. 

The server returns a status code of `201` along with a `Location` header that contains the URL to the job status. 

The information received in the response body matches the process summary that can be obtained by using the process list endpoint (`/processes/{processID}`).

=== "curl"

    ```bash
    curl -X 'POST' \
        'http://localhost:8080/acme/ogc-api/processes/water-bodies/execution' \
        -H 'accept: application/json' \
        -H 'Prefer: respond-async;return=representation' \
        -H 'Content-Type: application/json' \
        -d '{
        "inputs": {
            "stac_items": [
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A",
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20220524_0_L2A"
            ],
            "aoi": "-121.399,39.834,-120.74,40.472",
            "epsg": "EPSG:4326",
            "bands": [
            "green",
            "nir"
            ]
        }
        }'
    ```

=== "Python"

    ```python
    data = {
        "inputs": {
            "stac_items": [
                "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A",
                "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20220524_0_L2A"
            ],
            "aoi": "-121.399,39.834,-120.74,40.472",
            "epsg": "EPSG:4326",
            "bands": [
                "green",
                "nir"
            ]
        }
    }

    headers = {
        "accept": "*/*",
        "Prefer": "respond-async;return=representation",
        "Content-Type": "application/json"
    }

    process_id = "water-bodies" 

    # Submit the processing request
    response = requests.post(f"{ogc_api_endpoint}/processes/{process_id}/execution", headers=headers, json=data)
    ```

### Response body and headers

=== "Response body"

    Below an example of the response body

    ```json
    {
    "jobID": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308",
    "type": "process",
    "processID": "water-bodies",
    "created": "2024-10-22T04:18:54.378Z",
    "started": "2024-10-22T04:18:54.378Z",
    "updated": "2024-10-22T04:18:54.378Z",
    "status": "running",
    "message": "ZOO-Kernel accepted to run your service!",
    "links": [
        {
        "title": "Status location",
        "rel": "monitor",
        "type": "application/json",
        "href": "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
        }
    ]
    }
    ```

=== "Response headers"

    Below an example of the response headers

    ```
    connection: Keep-Alive 
    content-type: application/json;charset=UTF-8 
    date: Tue,22 Oct 2024 04:18:54 GMT 
    keep-alive: timeout=5,max=100 
    location: http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308 
    preference-applied: respond-async;return=representation 
    server: Apache/2.4.41 (Ubuntu) 
    transfer-encoding: chunked 
    x-also-also-also-powered-by: dru.securityOut 
    x-also-also-powered-by: dru.securityIn 
    x-also-powered-by: jwt.securityIn 
    x-powered-by: ZOO-Project-DRU 
    ```

## Monitor the execution

With the help of the unique job identifier `{jobID}`, the execution process can be monitored. 

The endpoint `/jobs/{jobID}` keeps track of the job `{jobID}` progress.

This endpoint provides access to information about the job. As defined in the schema, the information should contain at least a `type` (`process`), a `jobId`, and a `status`.

This `status` is one of the following values: `accepted`, `running`, `successful`, `failed`, `dismissed`.

The job progress is monitored using the `progress` field, current step using `message`, and check service runtime using `created`, `started`, `updated`, and potentially `finished`.
 
Optionally, the JSON object returned can contain links. 

Upon running the process, the server returns the current status as a single link. At the end of execution, another link should be available and include a URL to the results, identified by the relation 'http://www.opengis.net/def/rel/ogc/1.0/results'.

In the ZOO-Project-DRU implementation, links to the log files of every step of the Application Package CWL workflow execution were added.


=== "curl"

    ```bash
    curl -X 'GET' \
        'http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308' \
        -H 'accept: application/json'
    ```

=== "Python"

    ```python
    job_url = "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
    
    headers = {"accept": "application/json"}

    status_response = requests.get(job_url, headers=headers)
    
    ```

### Response body

Below an example of the response body.

=== "Status running"

    ```json
    {
        "progress": 23,
        "jobID": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308",
        "type": "process",
        "processID": "water-bodies",
        "created": "2024-10-22T04:18:54.378Z",
        "started": "2024-10-22T04:18:54.378Z",
        "updated": "2024-10-22T04:19:41.546Z",
        "status": "running",
        "message": "execution submitted",
        "links": [
            {
            "title": "Status location",
            "rel": "monitor",
            "type": "application/json",
            "href": "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
            }
        ]
    }
    ```

=== "Status successful"

    ```json
    {
        "jobID": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308",
        "type": "process",
        "processID": "water-bodies",
        "created": "2024-10-22T04:18:54.378Z",
        "started": "2024-10-22T04:18:54.378Z",
        "finished": "2024-10-22T04:22:25.175Z",
        "updated": "2024-10-22T04:22:25.018Z",
        "status": "successful",
        "message": "ZOO-Kernel successfully run your service!",
        "links": [
            {
            "title": "Status location",
            "rel": "monitor",
            "type": "application/json",
            "href": "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
            },
            {
            "title": "Result location",
            "rel": "http://www.opengis.net/def/rel/ogc/1.0/results",
            "type": "application/json",
            "href": "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/results"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_crop_2.log",
            "title": "Tool log node_crop_2.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_crop.log",
            "title": "Tool log node_crop.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_crop_3.log",
            "title": "Tool log node_crop_3.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_normalized_difference.log",
            "title": "Tool log node_normalized_difference.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_crop_4.log",
            "title": "Tool log node_crop_4.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_otsu.log",
            "title": "Tool log node_otsu.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_normalized_difference_2.log",
            "title": "Tool log node_normalized_difference_2.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_otsu_2.log",
            "title": "Tool log node_otsu_2.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_stac.log",
            "title": "Tool log node_stac.log",
            "rel": "related",
            "type": "text/plain"
            },
            {
            "href": "http://localhost:8080/acme/temp/water-bodies-bfafdb8e-902c-11ef-a29c-8e55bd0a3308/node_stage_out.log",
            "title": "Tool log node_stage_out.log",
            "rel": "related",
            "type": "text/plain"
            }
        ]
        }
    ```

## Get the execution results 

Once the execution process is complete, the job `{jobID}` results are accessed using the endpoint `/jobs/{jobId}/results`. 

=== "curl"

    ```bash
    curl -X 'GET' \
    'http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/results' \
    -H 'accept: application/json'
    ```

=== "Python"

    ```python
    results_url = "http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/results"
    
    headers = {"accept": "application/json"}

    response = requests.get(results_url, headers=headers)
    ```

### Response body 

```json
{
  "stac_catalog": {
    "value": {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "stac_version": "1.0.0",
          "id": "S2B_10TFK_20210713_0_L2A",
          "properties": {
            "proj:epsg": 32610,
            "proj:geometry": {
              "type": "Polygon",
              "coordinates": [
                [
                  [
                    636990,
                    4410550
                  ],
                  [
                    691590,
                    4410550
                  ],
                  [
                    691590,
                    4482600
                  ],
                  [
                    636990,
                    4482600
                  ],
                  [
                    636990,
                    4410550
                  ]
                ]
              ]
            },
            "proj:bbox": [
              636990,
              4410550,
              691590,
              4482600
            ],
            "proj:shape": [
              7205,
              5460
            ],
            "proj:transform": [
              10,
              0,
              636990,
              0,
              -10,
              4482600,
              0,
              0,
              1
            ],
            "proj:projjson": {
              "$schema": "https://proj.org/schemas/v0.7/projjson.schema.json",
              "type": "ProjectedCRS",
              "name": "WGS 84 / UTM zone 10N",
              "base_crs": {
                "name": "WGS 84",
                "datum": {
                  "type": "GeodeticReferenceFrame",
                  "name": "World Geodetic System 1984",
                  "ellipsoid": {
                    "name": "WGS 84",
                    "semi_major_axis": 6378137,
                    "inverse_flattening": 298.257223563
                  }
                },
                "coordinate_system": {
                  "subtype": "ellipsoidal",
                  "axis": [
                    {
                      "name": "Geodetic latitude",
                      "abbreviation": "Lat",
                      "direction": "north",
                      "unit": "degree"
                    },
                    {
                      "name": "Geodetic longitude",
                      "abbreviation": "Lon",
                      "direction": "east",
                      "unit": "degree"
                    }
                  ]
                },
                "id": {
                  "authority": "EPSG",
                  "code": 4326
                }
              },
              "conversion": {
                "name": "UTM zone 10N",
                "method": {
                  "name": "Transverse Mercator",
                  "id": {
                    "authority": "EPSG",
                    "code": 9807
                  }
                },
                "parameters": [
                  {
                    "name": "Latitude of natural origin",
                    "value": 0,
                    "unit": "degree",
                    "id": {
                      "authority": "EPSG",
                      "code": 8801
                    }
                  },
                  {
                    "name": "Longitude of natural origin",
                    "value": -123,
                    "unit": "degree",
                    "id": {
                      "authority": "EPSG",
                      "code": 8802
                    }
                  },
                  {
                    "name": "Scale factor at natural origin",
                    "value": 0.9996,
                    "unit": "unity",
                    "id": {
                      "authority": "EPSG",
                      "code": 8805
                    }
                  },
                  {
                    "name": "False easting",
                    "value": 500000,
                    "unit": "metre",
                    "id": {
                      "authority": "EPSG",
                      "code": 8806
                    }
                  },
                  {
                    "name": "False northing",
                    "value": 0,
                    "unit": "metre",
                    "id": {
                      "authority": "EPSG",
                      "code": 8807
                    }
                  }
                ]
              },
              "coordinate_system": {
                "subtype": "Cartesian",
                "axis": [
                  {
                    "name": "Easting",
                    "abbreviation": "",
                    "direction": "east",
                    "unit": "metre"
                  },
                  {
                    "name": "Northing",
                    "abbreviation": "",
                    "direction": "north",
                    "unit": "metre"
                  }
                ]
              },
              "id": {
                "authority": "EPSG",
                "code": 32610
              }
            },
            "proj:wkt2": "PROJCS[\"WGS 84 / UTM zone 10N\",GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-123],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"32610\"]]",
            "datetime": "2021-07-13T19:03:24Z"
          },
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [
                  -121.39905410179915,
                  39.833916743259095
                ],
                [
                  -120.76135965075635,
                  39.82336095080461
                ],
                [
                  -120.73995321724426,
                  40.471999341669175
                ],
                [
                  -121.38373773482932,
                  40.482798837728375
                ],
                [
                  -121.39905410179915,
                  39.833916743259095
                ]
              ]
            ]
          },
          "links": [
            {
              "rel": "collection",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/collection.json",
              "type": "application/json",
              "title": "Processing results"
            },
            {
              "rel": "root",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/catalog.json",
              "type": "application/json"
            },
            {
              "rel": "self",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/S2B_10TFK_20210713_0_L2A/S2B_10TFK_20210713_0_L2A.json",
              "type": "application/json"
            },
            {
              "rel": "parent",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/collection.json",
              "type": "application/json",
              "title": "Processing results"
            }
          ],
          "assets": {
            "data": {
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/S2B_10TFK_20210713_0_L2A/otsu.tif",
              "type": "image/tiff; application=geotiff",
              "storage:platform": "eoap",
              "storage:requester_pays": false,
              "storage:tier": "Standard",
              "storage:region": "us-east-1",
              "storage:endpoint": "http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566",
              "roles": [
                "data",
                "visual"
              ]
            }
          },
          "bbox": [
            -121.39905410179915,
            39.82336095080461,
            -120.73995321724426,
            40.482798837728375
          ],
          "stac_extensions": [
            "https://stac-extensions.github.io/projection/v1.1.0/schema.json"
          ],
          "collection": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
        },
        {
          "type": "Feature",
          "stac_version": "1.0.0",
          "id": "S2A_10TFK_20220524_0_L2A",
          "properties": {
            "proj:epsg": 32610,
            "proj:geometry": {
              "type": "Polygon",
              "coordinates": [
                [
                  [
                    636990,
                    4410550
                  ],
                  [
                    691590,
                    4410550
                  ],
                  [
                    691590,
                    4482600
                  ],
                  [
                    636990,
                    4482600
                  ],
                  [
                    636990,
                    4410550
                  ]
                ]
              ]
            },
            "proj:bbox": [
              636990,
              4410550,
              691590,
              4482600
            ],
            "proj:shape": [
              7205,
              5460
            ],
            "proj:transform": [
              10,
              0,
              636990,
              0,
              -10,
              4482600,
              0,
              0,
              1
            ],
            "proj:projjson": {
              "$schema": "https://proj.org/schemas/v0.7/projjson.schema.json",
              "type": "ProjectedCRS",
              "name": "WGS 84 / UTM zone 10N",
              "base_crs": {
                "name": "WGS 84",
                "datum": {
                  "type": "GeodeticReferenceFrame",
                  "name": "World Geodetic System 1984",
                  "ellipsoid": {
                    "name": "WGS 84",
                    "semi_major_axis": 6378137,
                    "inverse_flattening": 298.257223563
                  }
                },
                "coordinate_system": {
                  "subtype": "ellipsoidal",
                  "axis": [
                    {
                      "name": "Geodetic latitude",
                      "abbreviation": "Lat",
                      "direction": "north",
                      "unit": "degree"
                    },
                    {
                      "name": "Geodetic longitude",
                      "abbreviation": "Lon",
                      "direction": "east",
                      "unit": "degree"
                    }
                  ]
                },
                "id": {
                  "authority": "EPSG",
                  "code": 4326
                }
              },
              "conversion": {
                "name": "UTM zone 10N",
                "method": {
                  "name": "Transverse Mercator",
                  "id": {
                    "authority": "EPSG",
                    "code": 9807
                  }
                },
                "parameters": [
                  {
                    "name": "Latitude of natural origin",
                    "value": 0,
                    "unit": "degree",
                    "id": {
                      "authority": "EPSG",
                      "code": 8801
                    }
                  },
                  {
                    "name": "Longitude of natural origin",
                    "value": -123,
                    "unit": "degree",
                    "id": {
                      "authority": "EPSG",
                      "code": 8802
                    }
                  },
                  {
                    "name": "Scale factor at natural origin",
                    "value": 0.9996,
                    "unit": "unity",
                    "id": {
                      "authority": "EPSG",
                      "code": 8805
                    }
                  },
                  {
                    "name": "False easting",
                    "value": 500000,
                    "unit": "metre",
                    "id": {
                      "authority": "EPSG",
                      "code": 8806
                    }
                  },
                  {
                    "name": "False northing",
                    "value": 0,
                    "unit": "metre",
                    "id": {
                      "authority": "EPSG",
                      "code": 8807
                    }
                  }
                ]
              },
              "coordinate_system": {
                "subtype": "Cartesian",
                "axis": [
                  {
                    "name": "Easting",
                    "abbreviation": "",
                    "direction": "east",
                    "unit": "metre"
                  },
                  {
                    "name": "Northing",
                    "abbreviation": "",
                    "direction": "north",
                    "unit": "metre"
                  }
                ]
              },
              "id": {
                "authority": "EPSG",
                "code": 32610
              }
            },
            "proj:wkt2": "PROJCS[\"WGS 84 / UTM zone 10N\",GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-123],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"32610\"]]",
            "datetime": "2022-05-24T19:03:29Z"
          },
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              [
                [
                  -121.39905410179915,
                  39.833916743259095
                ],
                [
                  -120.76135965075635,
                  39.82336095080461
                ],
                [
                  -120.73995321724426,
                  40.471999341669175
                ],
                [
                  -121.38373773482932,
                  40.482798837728375
                ],
                [
                  -121.39905410179915,
                  39.833916743259095
                ]
              ]
            ]
          },
          "links": [
            {
              "rel": "collection",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/collection.json",
              "type": "application/json",
              "title": "Processing results"
            },
            {
              "rel": "root",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/catalog.json",
              "type": "application/json"
            },
            {
              "rel": "self",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/S2A_10TFK_20220524_0_L2A/S2A_10TFK_20220524_0_L2A.json",
              "type": "application/json"
            },
            {
              "rel": "parent",
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/collection.json",
              "type": "application/json",
              "title": "Processing results"
            }
          ],
          "assets": {
            "data": {
              "href": "s3://results/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/bfafdb8e-902c-11ef-a29c-8e55bd0a3308/S2A_10TFK_20220524_0_L2A/otsu.tif",
              "type": "image/tiff; application=geotiff",
              "storage:platform": "eoap",
              "storage:requester_pays": false,
              "storage:tier": "Standard",
              "storage:region": "us-east-1",
              "storage:endpoint": "http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566",
              "roles": [
                "data",
                "visual"
              ]
            }
          },
          "bbox": [
            -121.39905410179915,
            39.82336095080461,
            -120.73995321724426,
            40.482798837728375
          ],
          "stac_extensions": [
            "https://stac-extensions.github.io/projection/v1.1.0/schema.json"
          ],
          "collection": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
        }
      ],
      "id": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308"
    }
  }
}
```


## Delete a job

The endpoint `/jobs/{jobId}` can be used to terminate the job.

=== "curl"

    ```bash
    curl -X 'DELETE' \
        'http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308' \
        -H 'accept: application/json'
    ```

=== "Python"

    ```python
    import requests

    url = 'http://localhost:8080/acme/ogc-api/jobs/bfafdb8e-902c-11ef-a29c-8e55bd0a3308'
    headers = {'accept': 'application/json'}

    response = requests.delete(url, headers=headers)

    # Check the response status code
    if response.status_code == 204:
        print("Job deleted successfully.")
    else:
        print(f"Failed to delete job. Status code: {response.status_code}, Response: {response.text}")
    ```

### Response body

```json
{
  "jobID": "bfafdb8e-902c-11ef-a29c-8e55bd0a3308",
  "status": "dismissed",
  "message": "ZOO-Kernel successfully dismissed your service!",
  "links": [
    {
      "title": "The job list for the current process",
      "rel": "parent",
      "type": "application/json",
      "href": "http://localhost:8080/acme/ogc-api/jobs"
    }
  ],
  "type": "process",
  "processID": "water-bodies",
  "created": "2024-10-22T04:18:54.378Z",
  "started": "2024-10-22T04:18:54.378Z",
  "finished": "2024-10-22T04:22:25.175Z",
  "updated": "2024-10-22T04:22:25.018Z"
}
```

## Practice lab

Run the notebook **04 - Execute the process and monitor its job execution.ipynb**.