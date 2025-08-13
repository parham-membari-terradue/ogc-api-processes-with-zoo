import os
import sys
from loguru import logger
import ogc_api_client
import time
import json
import yaml
from typing import Dict, Union, TextIO, Optional


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
    if isinstance(data, dict) and "inputs" in data:
        return data["inputs"]
    return data


