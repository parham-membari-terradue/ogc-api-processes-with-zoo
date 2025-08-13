import os
import sys
import click
from loguru import logger
import ogc_api_client
import time
import json
from pprint import pprint
from pystac.item_collection import ItemCollection
from ogc_api_client.api_client import ApiClient, Configuration
from ogc_api_client.api_client_wrapper import ApiClientWrapper
from typing import Dict, Optional
from ogc_api_client.models.status_info import StatusInfo


from .utils import (
    get_headers,
    load_data,
    get_response_types_map,
    monitoring,
)


@click.command(
    short_help="""This project aim to interacts with the Zoo OGC API Processes endpoint.""",
    help="""This project aim to interacts with the Zoo OGC API Processes endpoint.""",
)
@click.option(
    "--api-endpoint",
    "-api",
    "api_endpoint",
    help="OGC API endpoint for Landsat-9 data",
    type=str,
    required=True,
)
@click.option(
    "--process-id",
    "-pid",
    "process_id",
    help="Process ID for the OGC API Processes",
    type=click.Path(),
    required=True,
)
@click.option(
    "--execute-request",
    "-e",
    "execute_request",
    help="OGC API Processes settings for Landsat-9 data",
    type=click.File(mode="r"),
    required=True,
)
@click.option(
    "--output",
    "-o",
    "output",
    help="A list of references to sentinel-2 product",
    type=click.Path(),
    required=True,
    multiple=True,
)
@click.pass_context
def main(ctx, **kwargs):

    logger.info("Start interacting with the Zoo OGC API Processes endpoint...")
    cwd = os.getcwd()
    os.chdir(os.getenv("TMPDIR", "/tmp"))
    ctmp = os.getcwd()
    input_dir = input_tmp_dir = ctmp
    logger.info(f"Current working directory: {cwd}")
    logger.info(f"Temporary directory: {ctmp}")
    ogc_api_endpoint = kwargs.get("api_endpoint")
    process_id = kwargs.get("process_id")
    execute_request = kwargs.get("execute_request")
    output = kwargs.get("output")

    ######################################
    ######################################

    logger.debug("Reading execute request data...")
    data = load_data(execute_request)
    # file_content = execute_request.read()
    pprint(f"Data loaded: {data}")
    # Configure the OGC API client

    logger.info(f"Using OGC API endpoint: {ogc_api_endpoint}")
    configuration = Configuration(
        host=ogc_api_endpoint,
    )
    client = ApiClient(configuration=configuration)
    headers = get_headers()

    # Submit the job to the OGC API Processes endpoint
    response_data = client.rest_client.request(
        "POST",
        f"{ogc_api_endpoint}/processes/{process_id}/execution",
        headers=headers,
        body=data,
    )
    response_data.read()

    content = client.response_deserialize(
        response_data=response_data,
        response_types_map=get_response_types_map(),
    ).data

    if isinstance(content, StatusInfo):
        # Parse the response to get the job ID
        job_id = content.job_id
        logger.info(f"Job submitted successfully. Job ID: {job_id}")
        status_location = next(
            (link.href for link in content.links if link.rel == "monitor"), None
        )
        if not status_location:
            status_location = f"{ogc_api_endpoint}/jobs/{job_id}"

        logger.info(f"Monitor job status at: {status_location}")
    else:
        logger.error(f"Failed to submit job. Status code: {response_data.status}")
        logger.error("Response:", content.text)
        raise ValueError(f"Failed to submit job. Status code: {response_data.status}")

    # Monitor the Job Status
    logger.info(
        "--------------\n--------------\n--------------\nMonitoring job status..."
    )
    monitoring(client, job_id)

    logger.success("Done.")


if __name__ == "__main__":
    main()
