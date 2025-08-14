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


def monitoring(client, job_id):
    print(f"\nMonitoring job status (job ID: {job_id})...")
    attempts = 1
    while True:
        status = client.get_status(job_id=job_id)

        if status:
            logger.debug(f"{attempts}. Job status: {status.status}")

            # Check if the job is completed (either successful or failed)
            if status.status in [StatusCode.SUCCESSFUL, StatusCode.FAILED]:
                break
        else:
            print(f"Failed to get job status.")
            break
        attempts += 1
        # Wait for a few seconds before checking again
        time.sleep(10)

    if status and status.status == StatusCode.SUCCESSFUL:
        # print(status)
        print("\nJob completed successfully. Retrieving results...")
        result = client.get_result(job_id=job_id)
        print(result)
        stac_feature_collection = result.get(
            "stac_catalog"
        ).actual_instance.value.oneof_schema_2_validator
        print("STAC item collection:", stac_feature_collection)
        return stac_feature_collection
    else:
        print("\nJob did not complete successfully.")

    