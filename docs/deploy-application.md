# Deploy the Application Package

Deploying an Application Package using the OGC API Processes API uses the API resource highlighted in the table below:


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
| EO Application Package         | `/processes/{processID}/package`          | Get the EOAP associated with a deployed process.                                | Part 2     |
| Job status info                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                          | Part 1     |
| Job results                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                 | Part 1     |
| Job list                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                             | Part 1     |
| Job deletion                   | `/jobs/{jobID}` (DELETE)                  | Cancels and deletes a job.                                                      | Part 1     |


This resource permits the deployment of the an Application Package and provide two options for the `Content-Type`.

## Hands-on - Deploy the water_bodies Application Package

**Encoding Options**

The deployment can use two encodings that are based on the same CWL conformance class. Both methods utilize the same water_bodies.cwl file, but the way the file is provided differs:
- OGC Application Package Encoding (application/ogcapppkg+json): This method allows you to reference the CWL file by providing its location, rather than including the file's content in the request.
- CWL Encoding (application/cwl+yaml): This method requires the CWL file content to be included directly in the request body.

**Request Configuration**

When selecting a content type, the request body text area updates to contain a relevant payload template for that encoding.
Warning: If the payload is manually edited, switching to a different encoding may not refresh the text area. In this case, the Reset button can be used to restore the appropriate template.

**Server Response**

After executing the deployment request, the server responds with a process summary similar to the one obtained from the previous process listing endpoint.
The server’s response includes a Location header containing the URL to access the detailed process description.

**Next Steps** 

You can either:
- Return to the list of available processes to verify the newly deployed process.
- Proceed to the next step to review the process description in detail

## Setup

Lists available processes in the `acme` namespace.

> **_NOTE:_**: if the `acme` namespace does not exist, ZOO Project will create it.


```python
import requests
import json
import yaml
import time
import os
import sys
from loguru import logger
from pystac.item_collection import ItemCollection
from pprint import pprint
namespace = "acme"

ogc_api_endpoint = f"http://zoo-project-dru-service/{namespace}/ogc-api"

r = requests.get(f"{ogc_api_endpoint}/processes")

r.status_code
```




    200




If the application package was deployed previously, delete it.


```python
def undeploy(process_id):

    r = requests.delete(f"{ogc_api_endpoint}/processes/{process_id}")

    return r

app_package_entry_point = "water-bodies"

r = undeploy(app_package_entry_point)

r.status_code
```




    404



## OGC Application Package Encoding (application/ogcapppkg+json)

OGC Application Package Encoding (application/ogcapppkg+json): This method allows you to reference the CWL file by providing its location, rather than including the file's content in the request.


```python
app_package_entry_point = "water-bodies"
def app_package_deployment(app_package_entry_point, app_package_url):  
  headers = {"accept": "application/json", 
          "Content-Type": "application/ogcapppkg+json"}
  response = requests.post(
      
      f"{ogc_api_endpoint}/processes/?w={app_package_entry_point}",
      headers=headers,
      json = {
        "executionUnit": {
          "href": app_package_url,
          "type": "application/cwl"
        }
      }
  )
  return response

def check_app_package_deployment(app_package_entry_point):
    r = requests.get(f"{ogc_api_endpoint}/processes/")
   
    if r.status_code == 200:
        # Parse the JSON response
        all_processes = r.json()
        for process in all_processes.get("processes", []):
          if process.get("id") in [app_package_entry_point]:
              logger.info(f"Application package {app_package_entry_point} is already deployed.")
              return True
          else:
              logger.warning(f"{app_package_entry_point} still not deployed.")
              return False
    else:
        logger.error(f"Failed to retrieve processes. Status code: {r.status_code}")
        sys.exit(1)

def get_latest_application_package_version(repository_owner, repo_name):

    url = f"https://api.github.com/repos/{repository_owner}/{repo_name}/releases/latest"
    response = requests.get(url)
    response.raise_for_status()  # raise error if request failed

    latest_tag = response.json().get("tag_name")
    return latest_tag
```


```python
app_package_entry_point = "water-bodies"
is_package_deployed = check_app_package_deployment(app_package_entry_point)
repo_name = "mastering-app-package"
repository_owner = os.environ.get("REPOSITORY_OWNER", "eoap")
latest_application_package_version = get_latest_application_package_version(repository_owner, repo_name)
logger.info(f"Latest version is:  {latest_application_package_version}")
app_package_url = f"https://github.com/{repository_owner}/mastering-app-package/releases/download/{latest_application_package_version}/app-water-bodies-cloud-native.{latest_application_package_version}.cwl"
if not is_package_deployed:
    
    response= app_package_deployment(app_package_entry_point, app_package_url)
    pprint(response.json())
```

    [32m2025-08-20 13:40:19.690[0m | [33m[1mWARNING [0m | [36m__main__[0m:[36mcheck_app_package_deployment[0m:[36m29[0m - [33m[1mwater-bodies still not deployed.[0m
    [32m2025-08-20 13:40:19.985[0m | [1mINFO    [0m | [36m__main__[0m:[36m<module>[0m:[36m6[0m - [1mLatest version is:  1.1.1[0m


    {'description': 'Water bodies detection based on NDWI and otsu threshold '
                    'applied to Sentinel-2 COG STAC items',
     'id': 'water-bodies',
     'jobControlOptions': ['async-execute', 'dismiss'],
     'links': [{'href': 'http://localhost:8080/acme/ogc-api/processes/water-bodies/execution',
                'rel': 'http://www.opengis.net/def/rel/ogc/1.0/execute',
                'title': 'Execute End Point',
                'type': 'application/json'}],
     'metadata': [{'role': 'https://schema.org/softwareVersion', 'value': '1.1.1'},
                  {'role': 'https://schema.org/author',
                   'value': {'@context': 'https://schema.org',
                             '@type': 'Person',
                             's.affiliation': 'ACME',
                             's.email': 'jane.doe@acme.earth',
                             's.name': 'Jane Doe'}}],
     'mutable': True,
     'outputTransmission': ['value', 'reference'],
     'title': 'Water bodies detection based on NDWI and otsu threshold',
     'version': '1.1.1'}



```python
dict(response.headers)
```




    {'Date': 'Wed, 20 Aug 2025 13:40:19 GMT',
     'Server': 'Apache/2.4.41 (Ubuntu)',
     'X-Powered-By': 'ZOO-Project-DRU',
     'X-Also-Powered-By': 'jwt.securityIn',
     'X-Also-Also-Powered-By': 'dru.securityIn',
     'Location': 'http://localhost:8080/acme/ogc-api/processes/water-bodies',
     'Keep-Alive': 'timeout=5, max=100',
     'Connection': 'Keep-Alive',
     'Transfer-Encoding': 'chunked',
     'Content-Type': 'application/json;charset=UTF-8'}



## CWL Encoding (application/cwl+yaml)

This method requires the CWL file content to be included directly in the request body.

If the application package was deployed previously, delete it.


```python
app_package_entry_point = "water-bodies"

r = undeploy(app_package_entry_point)
r.status_code
```




    204



Download the application package from https://github.com/eoap/mastering-app-package/releases/download/1.0.0/app-water-bodies-cloud-native.1.0.0.cwl


```python
r = requests.get(app_package_url)

app_package_content  = yaml.safe_load(r.content)

app_package_content
```




    {'cwlVersion': 'v1.0',
     '$namespaces': {'s': 'https://schema.org/'},
     's:softwareVersion': '1.1.1',
     'schemas': ['http://schema.org/version/9.0/schemaorg-current-http.rdf'],
     '$graph': [{'class': 'Workflow',
       'id': 'water-bodies',
       'label': 'Water bodies detection based on NDWI and otsu threshold',
       'doc': 'Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items',
       'requirements': [{'class': 'ScatterFeatureRequirement'},
        {'class': 'SubworkflowFeatureRequirement'}],
       'inputs': {'aoi': {'label': 'area of interest',
         'doc': 'area of interest as a bounding box',
         'type': 'string'},
        'epsg': {'label': 'EPSG code',
         'doc': 'EPSG code',
         'type': 'string',
         'default': 'EPSG:4326'},
        'stac_items': {'label': 'Sentinel-2 STAC items',
         'doc': 'list of Sentinel-2 COG STAC items',
         'type': 'string[]'},
        'bands': {'label': 'bands used for the NDWI',
         'doc': 'bands used for the NDWI',
         'type': 'string[]',
         'default': ['green', 'nir']}},
       'outputs': [{'id': 'stac_catalog',
         'outputSource': ['node_stac/stac_catalog'],
         'type': 'Directory'}],
       'steps': {'node_water_bodies': {'run': '#detect_water_body',
         'in': {'item': 'stac_items',
          'aoi': 'aoi',
          'epsg': 'epsg',
          'bands': 'bands'},
         'out': ['detected_water_body'],
         'scatter': 'item',
         'scatterMethod': 'dotproduct'},
        'node_stac': {'run': '#stac',
         'in': {'item': 'stac_items',
          'rasters': {'source': 'node_water_bodies/detected_water_body'}},
         'out': ['stac_catalog']}}},
      {'class': 'Workflow',
       'id': 'detect_water_body',
       'label': 'Water body detection based on NDWI and otsu threshold',
       'doc': 'Water body detection based on NDWI and otsu threshold',
       'requirements': [{'class': 'ScatterFeatureRequirement'}],
       'inputs': {'aoi': {'doc': 'area of interest as a bounding box',
         'type': 'string'},
        'epsg': {'doc': 'EPSG code', 'type': 'string', 'default': 'EPSG:4326'},
        'bands': {'doc': 'bands used for the NDWI', 'type': 'string[]'},
        'item': {'doc': 'STAC item', 'type': 'string'}},
       'outputs': [{'id': 'detected_water_body',
         'outputSource': ['node_otsu/binary_mask_item'],
         'type': 'File'}],
       'steps': {'node_crop': {'run': '#crop',
         'in': {'item': 'item', 'aoi': 'aoi', 'epsg': 'epsg', 'band': 'bands'},
         'out': ['cropped'],
         'scatter': 'band',
         'scatterMethod': 'dotproduct'},
        'node_normalized_difference': {'run': '#norm_diff',
         'in': {'rasters': {'source': 'node_crop/cropped'}},
         'out': ['ndwi']},
        'node_otsu': {'run': '#otsu',
         'in': {'raster': {'source': 'node_normalized_difference/ndwi'}},
         'out': ['binary_mask_item']}}},
      {'class': 'CommandLineTool',
       'id': 'crop',
       'requirements': {'InlineJavascriptRequirement': {},
        'EnvVarRequirement': {'envDef': {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'PYTHONPATH': '/app'}},
        'ResourceRequirement': {'coresMax': 1, 'ramMax': 512}},
       'hints': {'DockerRequirement': {'dockerPull': 'ghcr.io/parham-membari-terradue/mastering-app-package/crop@sha256:0fc019633a1968a611a07f335ddcc9a478f6971c72757a57e060423fae57473e'}},
       'baseCommand': ['python', '-m', 'app'],
       'arguments': [],
       'inputs': {'item': {'type': 'string',
         'inputBinding': {'prefix': '--input-item'}},
        'aoi': {'type': 'string', 'inputBinding': {'prefix': '--aoi'}},
        'epsg': {'type': 'string', 'inputBinding': {'prefix': '--epsg'}},
        'band': {'type': 'string', 'inputBinding': {'prefix': '--band'}}},
       'outputs': {'cropped': {'outputBinding': {'glob': '*.tif'},
         'type': 'File'}}},
      {'class': 'CommandLineTool',
       'id': 'norm_diff',
       'requirements': {'InlineJavascriptRequirement': {},
        'EnvVarRequirement': {'envDef': {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'PYTHONPATH': '/app'}},
        'ResourceRequirement': {'coresMax': 1, 'ramMax': 512}},
       'hints': {'DockerRequirement': {'dockerPull': 'ghcr.io/parham-membari-terradue/mastering-app-package/norm_diff@sha256:e46491095215833722db2c3d3c24feae381c1008981ae3508973b6aa1f5a880a'}},
       'baseCommand': ['python', '-m', 'app'],
       'arguments': [],
       'inputs': {'rasters': {'type': 'File[]', 'inputBinding': {'position': 1}}},
       'outputs': {'ndwi': {'outputBinding': {'glob': '*.tif'}, 'type': 'File'}}},
      {'class': 'CommandLineTool',
       'id': 'otsu',
       'requirements': {'InlineJavascriptRequirement': {},
        'EnvVarRequirement': {'envDef': {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'PYTHONPATH': '/app'}},
        'ResourceRequirement': {'coresMax': 1, 'ramMax': 512}},
       'hints': {'DockerRequirement': {'dockerPull': 'ghcr.io/parham-membari-terradue/mastering-app-package/otsu@sha256:f026bcac96c9bf1ce486855ea6e8fd27ccc501e82dbc6837021c32d9708d097a'}},
       'baseCommand': ['python', '-m', 'app'],
       'arguments': [],
       'inputs': {'raster': {'type': 'File', 'inputBinding': {'position': 1}}},
       'outputs': {'binary_mask_item': {'outputBinding': {'glob': '*.tif'},
         'type': 'File'}}},
      {'class': 'CommandLineTool',
       'id': 'stac',
       'requirements': {'InlineJavascriptRequirement': {},
        'EnvVarRequirement': {'envDef': {'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'PYTHONPATH': '/app'}},
        'ResourceRequirement': {'coresMax': 1, 'ramMax': 512}},
       'hints': {'DockerRequirement': {'dockerPull': 'ghcr.io/parham-membari-terradue/mastering-app-package/stac@sha256:c687a9f18ebb9352a150bb7ac2d687ec9e08e2f4ef2519da342012895dbb693e'}},
       'baseCommand': ['python', '-m', 'app'],
       'arguments': [],
       'inputs': {'item': {'type': {'type': 'array',
          'items': 'string',
          'inputBinding': {'prefix': '--input-item'}}},
        'rasters': {'type': {'type': 'array',
          'items': 'File',
          'inputBinding': {'prefix': '--water-body'}}}},
       'outputs': {'stac_catalog': {'outputBinding': {'glob': '.'},
         'type': 'Directory'}}}],
     's:codeRepository': {'URL': 'https://github.com/parham-membari-terradue/mastering-app-package.git'},
     's:author': [{'class': 's:Person',
       's.name': 'Jane Doe',
       's.email': 'jane.doe@acme.earth',
       's.affiliation': 'ACME'}]}




```python
def app_package_deployment_cwl_encoding(app_package_entry_point, app_package_content):  
  
    headers = {"accept": "application/json", 
            "Content-Type": "application/cwl+yaml"}

    response = requests.post(
        f"{ogc_api_endpoint}/processes?w={app_package_entry_point}",
        headers=headers,
        json=app_package_content
    )
    print(response.status_code)
    return response
```


```python
app_package_entry_point = "water-bodies"
is_package_deployed = check_app_package_deployment(app_package_entry_point)
if not is_package_deployed:
    response = app_package_deployment_cwl_encoding(app_package_entry_point, app_package_content)
    pprint(response.json())
```

    [32m2025-08-20 13:40:49.695[0m | [33m[1mWARNING [0m | [36m__main__[0m:[36mcheck_app_package_deployment[0m:[36m29[0m - [33m[1mwater-bodies still not deployed.[0m


    201
    {'description': 'Water bodies detection based on NDWI and otsu threshold '
                    'applied to Sentinel-2 COG STAC items',
     'id': 'water-bodies',
     'jobControlOptions': ['async-execute', 'dismiss'],
     'links': [{'href': 'http://localhost:8080/acme/ogc-api/processes/water-bodies/execution',
                'rel': 'http://www.opengis.net/def/rel/ogc/1.0/execute',
                'title': 'Execute End Point',
                'type': 'application/json'}],
     'metadata': [{'role': 'https://schema.org/softwareVersion', 'value': '1.1.1'},
                  {'role': 'https://schema.org/author',
                   'value': {'@context': 'https://schema.org',
                             '@type': 'Person',
                             's.affiliation': 'ACME',
                             's.email': 'jane.doe@acme.earth',
                             's.name': 'Jane Doe'}}],
     'mutable': True,
     'outputTransmission': ['value', 'reference'],
     'title': 'Water bodies detection based on NDWI and otsu threshold',
     'version': '1.1.1'}



```python
dict(response.headers)
```




    {'Date': 'Wed, 20 Aug 2025 13:40:49 GMT',
     'Server': 'Apache/2.4.41 (Ubuntu)',
     'X-Powered-By': 'ZOO-Project-DRU',
     'X-Also-Powered-By': 'jwt.securityIn',
     'X-Also-Also-Powered-By': 'dru.securityIn',
     'Location': 'http://localhost:8080/acme/ogc-api/processes/water-bodies',
     'Keep-Alive': 'timeout=5, max=100',
     'Connection': 'Keep-Alive',
     'Transfer-Encoding': 'chunked',
     'Content-Type': 'application/json;charset=UTF-8'}



**Next Steps** 

You can either:
- Return to the list of available processes to verify the newly deployed process.
- Proceed to the next step to review the process description in detail
