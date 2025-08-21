# Execute the process and monitor the execution

To submit an execution request of a deployed process and monitor it, the OGC API Processes API uses the resource highlighted in the table below:

| **Resource**                   | **Path**                                     | **Purpose**                                                                     | **Part**   |
|--------------------------------|----------------------------------------------|---------------------------------------------------------------------------------|------------|
| Landing page                   | `/`                                          | Top-level resource serving as an entry point.                                   | Part 1     |
| Conformance declaration        | `/conformance`                               | Information about the functionality supported by the server.                    | Part 1     |
| API Definition                 | `/api`                                       | Metadata about the API itself.                                                  | Part 1     |
| Process list                   | `/processes`                                 | Lists available processes with identifiers and links to descriptions.           | Part 1     |
| Process description            | `/processes/{processID}`                     | Retrieves detailed information about a specific process.                        | Part 1     |
| **Process execution**          | **`/processes/{processID}/execution`(POST)** | **Executes a process, creating a job.**                                         | **Part 1** |
| Deploy Process                 | `/processes` (POST)                          | Deploys a new process on the server.                                            | Part 2     |
| Replace Process                | `/processes/{processID}` (PUT)               | Replaces an existing process with a new version.                                | Part 2     |
| Undeploy Process               | `/processes/{processID}` (DELETE)            | Removes an existing process from the server.                                    | Part 2     |
| EO Application Package         | `/processes/{processID}/package`             | Get the EOAP associated with a deployed process.                                | Part 2     |
| **Job status info**            | **`/jobs/{jobID}`**                          | **Retrieves the current status of a job.**                                      | **Part 1** |
| **Job results**                | **`/jobs/{jobID}/results`**                  | **Retrieves the results of a job.**                                             | **Part 1** |
| Job list                       | `/jobs`                                      | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}` (DELETE)                     | Cancels and deletes a job.                                                      | Part 1     |


```python
import os
from pprint import pprint
import requests
import time
import json
from pystac.item_collection import ItemCollection
from urllib.parse import urljoin, urlparse
from ogc_api_client.api_client import Configuration
from ogc_api_client.api_client_wrapper import ApiClientWrapper
from ogc_api_client.models.status_info import StatusInfo, StatusCode
from typing import Dict, Optional
from fs_s3fs import S3FS
from loguru import logger
import rasterio


namespace = "acme"

ogc_api_endpoint = f"http://zoo-project-dru-service/{namespace}/ogc-api"
```

Define the input data for the execution:


```python
data = {
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

In the cell below, the user will configure the API client settings and initialize a client object using [ApiClientWrapper](https://github.com/EOEPCA/ogc-api-client/blob/d7159a3f70e5f283ccb7d585702ec40d5a49c006/src/ogc_api_client/api_client_wrapper.py#L29C7-L29C23). A request header will also be specified.



```python
configuration = Configuration(
    host=ogc_api_endpoint,
)
client = ApiClientWrapper(configuration=configuration)

headers = {
    "accept": "*/*",
    "Prefer": "respond-async;return=representation",
    "Content-Type": "application/json"
}
```

Submit a water-bodies detection job to the OGC API endpoint and retrieve the job ID for monitoring


```python
process_id = "water-bodies"  # Replace with your process ID if different

# Submit the processing request
content = client.execute_simple(process_id=process_id, execute=data, _headers=headers)
pprint(content)
if isinstance(content, StatusInfo):
    # Parse the response to get the job ID
    job_id = content.job_id
    print(f"Job submitted successfully. Job ID: {job_id}")
    status_location = next((link.href for link in content.links if link.rel == 'monitor'), None)
    if not status_location:
        status_location = f"{ogc_api_endpoint}/jobs/{job_id}"
                           
    print(f"Monitor job status at: {status_location}")
else:
    print(f"Failed to submit job. Status code: {content.status}")
    print("Response:", content.text)
    raise ValueError(f"Failed to submit job. Status code: {content.status}")
```

    Job submitted successfully. Job ID: 68046976-7dcb-11f0-90ac-2a20aea25780
    Monitor job status at: http://zoo-project-dru-service/acme/ogc-api/jobs/68046976-7dcb-11f0-90ac-2a20aea25780


Monitor the Job Status


```python
print(f"\nMonitoring job status (job ID: {job_id})...")

while True:
    status = client.get_status(job_id=job_id)

    if status:
        print(f"Job status: {status.status}")
        
        # Check if the job is completed (either successful or failed)
        if status.status in [StatusCode.SUCCESSFUL, StatusCode.FAILED]:
            break
    else:
        print(f"Failed to get job status.")
        break
    
    # Wait for a few seconds before checking again
    time.sleep(10)

if status and status.status == StatusCode.SUCCESSFUL:
    # print(status)
    print("\nJob completed successfully. Retrieving results...")
    result = client.get_result(job_id=job_id)
    print(result)
    stac_feature_collection = result.get("stac_catalog").actual_instance.value.oneof_schema_2_validator
    print("STAC item collection:", stac_feature_collection)
else:
    print("\nJob did not complete successfully.")
```

    
    Monitoring job status...
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: running
    Job status: successful
    
    Job completed successfully. Retrieving results...
    STAC Catalog URI: {'type': 'FeatureCollection', 'features': [{'type': 'Feature', 'stac_version': '1.0.0', 'id': 'LC08_L2SP_044032_20231208_02_T1', 'properties': {'proj:epsg': 32610, 'proj:geometry': {'type': 'Polygon', 'coordinates': [[[636975.0, 4410555.0], [691605.0, 4410555.0], [691605.0, 4482615.0], [636975.0, 4482615.0], [636975.0, 4410555.0]]]}, 'proj:bbox': [636975.0, 4410555.0, 691605.0, 4482615.0], 'proj:shape': [2402, 1821], 'proj:transform': [30.0, 0.0, 636975.0, 0.0, -30.0, 4482615.0, 0.0, 0.0, 1.0], 'datetime': '2023-12-08T18:45:23.598169Z'}, 'geometry': {'type': 'Polygon', 'coordinates': [[[-121.39922829056682, 39.83396419450036], [-120.76118304700903, 39.82340258564599], [-120.73977187420928, 40.47213091315636], [-121.38391140352763, 40.482936393990066], [-121.39922829056682, 39.83396419450036]]]}, 'links': [{'rel': 'collection', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/collection.json', 'type': 'application/json', 'title': 'Processing results'}, {'rel': 'root', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/catalog.json', 'type': 'application/json'}, {'rel': 'self', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_044032_20231208_02_T1/LC08_L2SP_044032_20231208_02_T1.json', 'type': 'application/json'}, {'rel': 'parent', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/collection.json', 'type': 'application/json', 'title': 'Processing results'}], 'assets': {'data': {'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_044032_20231208_02_T1/otsu.tif', 'type': 'image/tiff; application=geotiff', 'raster:bands': [{'data_type': 'uint8', 'scale': 1.0, 'offset': 0.0, 'sampling': 'area', 'nodata': 0.0, 'statistics': {'mean': 1.0, 'minimum': 1, 'maximum': 1, 'stddev': 0.0, 'valid_percent': 60.46467784749034}, 'histogram': {'count': 11, 'min': 0.5, 'max': 1.5, 'buckets': [0, 0, 0, 0, 0, 481086, 0, 0, 0, 0]}}], 'storage:platform': 'eoap', 'storage:requester_pays': False, 'storage:tier': 'Standard', 'storage:region': 'us-east-1', 'storage:endpoint': 'http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566', 'roles': ['data', 'visual']}}, 'bbox': [-121.39922829056682, 39.82340258564599, -120.73977187420928, 40.482936393990066], 'stac_extensions': ['https://stac-extensions.github.io/projection/v1.1.0/schema.json', 'https://stac-extensions.github.io/raster/v1.1.0/schema.json'], 'collection': '68046976-7dcb-11f0-90ac-2a20aea25780'}, {'type': 'Feature', 'stac_version': '1.0.0', 'id': 'LC08_L2SP_043033_20231201_02_T1', 'properties': {'proj:epsg': 32610, 'proj:geometry': {'type': 'Polygon', 'coordinates': [[[636975.0, 4410555.0], [691605.0, 4410555.0], [691605.0, 4425015.0], [636975.0, 4425015.0], [636975.0, 4410555.0]]]}, 'proj:bbox': [636975.0, 4410555.0, 691605.0, 4425015.0], 'proj:shape': [482, 1821], 'proj:transform': [30.0, 0.0, 636975.0, 0.0, -30.0, 4425015.0, 0.0, 0.0, 1.0], 'datetime': '2023-12-01T18:39:41.392050Z'}, 'geometry': {'type': 'Polygon', 'coordinates': [[[-121.39922829056682, 39.83396419450036], [-120.76118304700903, 39.82340258564599], [-120.75694206934209, 39.95358698004168], [-121.3961944444915, 39.96419715990018], [-121.39922829056682, 39.83396419450036]]]}, 'links': [{'rel': 'collection', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/collection.json', 'type': 'application/json', 'title': 'Processing results'}, {'rel': 'root', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/catalog.json', 'type': 'application/json'}, {'rel': 'self', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_043033_20231201_02_T1/LC08_L2SP_043033_20231201_02_T1.json', 'type': 'application/json'}, {'rel': 'parent', 'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/collection.json', 'type': 'application/json', 'title': 'Processing results'}], 'assets': {'data': {'href': 's3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_043033_20231201_02_T1/otsu.tif', 'type': 'image/tiff; application=geotiff', 'raster:bands': [{'data_type': 'uint8', 'scale': 1.0, 'offset': 0.0, 'sampling': 'area', 'nodata': 0.0, 'statistics': {'mean': 1.0, 'minimum': 1, 'maximum': 1, 'stddev': 0.0, 'valid_percent': 12.31976677389706}, 'histogram': {'count': 11, 'min': 0.5, 'max': 1.5, 'buckets': [0, 0, 0, 0, 0, 34314, 0, 0, 0, 0]}}], 'storage:platform': 'eoap', 'storage:requester_pays': False, 'storage:tier': 'Standard', 'storage:region': 'us-east-1', 'storage:endpoint': 'http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566', 'roles': ['data', 'visual']}}, 'bbox': [-121.39922829056682, 39.82340258564599, -120.75694206934209, 39.96419715990018], 'stac_extensions': ['https://stac-extensions.github.io/projection/v1.1.0/schema.json', 'https://stac-extensions.github.io/raster/v1.1.0/schema.json'], 'collection': '68046976-7dcb-11f0-90ac-2a20aea25780'}], 'id': '68046976-7dcb-11f0-90ac-2a20aea25780'}


Creating ItemCollection 


```python
stac_items = ItemCollection.from_dict(stac_feature_collection).items
```

## Exploit the results


```python

for item in stac_items:

    print(item.get_assets()["data"].href)
    print(json.dumps(item.get_assets()["data"].to_dict(), sort_keys=True, indent=4))
```

    s3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_044032_20231208_02_T1/otsu.tif
    {
        "href": "s3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_044032_20231208_02_T1/otsu.tif",
        "raster:bands": [
            {
                "data_type": "uint8",
                "histogram": {
                    "buckets": [
                        0,
                        0,
                        0,
                        0,
                        0,
                        481086,
                        0,
                        0,
                        0,
                        0
                    ],
                    "count": 11,
                    "max": 1.5,
                    "min": 0.5
                },
                "nodata": 0.0,
                "offset": 0.0,
                "sampling": "area",
                "scale": 1.0,
                "statistics": {
                    "maximum": 1,
                    "mean": 1.0,
                    "minimum": 1,
                    "stddev": 0.0,
                    "valid_percent": 60.46467784749034
                }
            }
        ],
        "roles": [
            "data",
            "visual"
        ],
        "storage:endpoint": "http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566",
        "storage:platform": "eoap",
        "storage:region": "us-east-1",
        "storage:requester_pays": false,
        "storage:tier": "Standard",
        "type": "image/tiff; application=geotiff"
    }
    s3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_043033_20231201_02_T1/otsu.tif
    {
        "href": "s3://results/68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_043033_20231201_02_T1/otsu.tif",
        "raster:bands": [
            {
                "data_type": "uint8",
                "histogram": {
                    "buckets": [
                        0,
                        0,
                        0,
                        0,
                        0,
                        34314,
                        0,
                        0,
                        0,
                        0
                    ],
                    "count": 11,
                    "max": 1.5,
                    "min": 0.5
                },
                "nodata": 0.0,
                "offset": 0.0,
                "sampling": "area",
                "scale": 1.0,
                "statistics": {
                    "maximum": 1,
                    "mean": 1.0,
                    "minimum": 1,
                    "stddev": 0.0,
                    "valid_percent": 12.31976677389706
                }
            }
        ],
        "roles": [
            "data",
            "visual"
        ],
        "storage:endpoint": "http://eoap-zoo-project-localstack.eoap-zoo-project.svc.cluster.local:4566",
        "storage:platform": "eoap",
        "storage:region": "us-east-1",
        "storage:requester_pays": false,
        "storage:tier": "Standard",
        "type": "image/tiff; application=geotiff"
    }


In the cell below, the user opens a GeoTIFF file produced by the `water-bodies` job using `rasterio`


```python
region_name = os.environ.get("AWS_DEFAULT_REGION")
endpoint_url = os.environ.get("AWS_ENDPOINT_URL", "http://eoap-zoo-project-localstack:4566")
aws_access_key_id = os.environ.get("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.environ.get("AWS_SECRET_ACCESS_KEY")
region_name, endpoint_url, aws_access_key_id, aws_secret_access_key

# Extract image name using os.path.basename
full_path = item.get_assets()["data"].href
parsed_url = urlparse(full_path)

# Extract the bucket name from the "netloc" part
bucket_name = parsed_url.netloc

# Extract the full path (excluding 's3://bucket_name')
full_path = parsed_url.path.lstrip("/")

# Extract image name using os.path.basename
image_name = os.path.basename(full_path)
# Extract directory path using os.path.dirname
dir_path = os.path.dirname(full_path)
fs_opener = S3FS(
        bucket_name="results",
        dir_path=dir_path,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        endpoint_url=endpoint_url,
        region=region_name,
    )

if fs_opener.region:
    pass
else:
    logger.error(
        "File system opener is not configurated properly to open file from s3 bucket"
    )

with rasterio.open(image_name, opener=fs_opener.open) as src:
    profile = src.profile
    print(profile)
```

    68046976-7dcb-11f0-90ac-2a20aea25780/68046976-7dcb-11f0-90ac-2a20aea25780/LC08_L2SP_044032_20231208_02_T1/otsu.tif
    {'driver': 'GTiff', 'dtype': 'uint8', 'nodata': 0.0, 'width': 1821, 'height': 2402, 'count': 1, 'crs': CRS.from_wkt('PROJCS["WGS 84 / UTM zone 10N",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4326"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-123],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","32610"]]'), 'transform': Affine(30.0, 0.0, 636975.0,
           0.0, -30.0, 4482615.0), 'blockxsize': 512, 'blockysize': 512, 'tiled': True, 'compress': 'lzw', 'interleave': 'band'}


Inspecting the job result using cli


```python
!aws s3 ls s3://results/{job_id}/{job_id}/{os.path.basename(data["inputs"]["stac_items"][0])}/
```

    2025-08-20 13:42:57       3447 LC08_L2SP_044032_20231208_02_T1.json
    2025-08-20 13:42:57     406547 otsu.tif

