import os
import sys
from loguru import logger
import ogc_api_client
import time
import json
import yaml
import requests
from typing import Dict, Union, TextIO, Optional
from ogc_api_client.api.status_api import StatusApi
from ogc_api_client.api.result_api import ResultApi
from ogc_api_client.models.status_info import StatusCode


def get_headers():
    headers = {
        "accept": "*/*",
        "Prefer": "respond-async;return=representation",
        "Content-Type": "application/json",
    }
    return headers


def get_response_types_map() -> Dict[str, Optional[str]]:
    response_types = {
        "200": "Execute200Response",
        "201": "StatusInfo",
        "404": "Exception",
        "500": "Exception",
    }
    return response_types


def load_data(file_input: Union[str, TextIO]) -> Dict:
    """
    Load data from a JSON or YAML file.

    :param file_input: Path to the file (string) or an open file object.
    :return: Parsed data as a dictionary.
    """
    # If it's a file object, get name & read
    if hasattr(file_input, "read"):
        file_path = getattr(file_input, "name", "<unknown>")
        content = file_input.read()
    else:
        file_path = file_input
        if not os.path.exists(file_path):
            logger.error(f"File {file_path} does not exist.")
            sys.exit(1)
        with open(file_path, "r") as f:
            content = f.read()

    try:
        if file_path.lower().endswith((".yaml", ".yml")):
            data = yaml.safe_load(content)
        else:
            data = json.loads(content)
    except Exception as e:
        logger.error(f"Error parsing {file_path}: {e}")
        sys.exit(1)

    # Optional: extract "inputs" if exists
    
    return data


def monitoring(ogc_api_endpoint, job_id):
    job_url = f"{ogc_api_endpoint}/jobs/{job_id}"

    headers = {"accept": "application/json"}

    while True:
        status_response = requests.get(job_url, headers=headers)
        if status_response.status_code == 200:
            job_status = status_response.json().get("status")
            print(f"Job status: {job_status}")
            
            # Check if the job is completed (either successful or failed)
            if job_status in ["successful", "failed"]:
                break
        else:
            print(f"Failed to get job status. Status code: {status_response.status_code}")
            break
        
        # Wait for a few seconds before checking again
        time.sleep(10)

    # Step 4: Retrieve the Job Results if Successful
    if job_status == "successful":
        print("\nJob completed successfully. Retrieving results...")
        results_url = f"{ogc_api_endpoint}/jobs/{job_id}/results"
        results_response = requests.get(results_url, headers=headers)
        
        if results_response.status_code == 200:
            results = results_response.json()
            stac_catalog_uri = results.get("stac_catalog", {}).get("value")
            print("STAC Catalog URI:", stac_catalog_uri)
            return stac_catalog_uri
        else:
            print(f"Failed to retrieve job results. Status code: {results_response.status_code}")
    else:
        print("\nJob did not complete successfully.")
    
