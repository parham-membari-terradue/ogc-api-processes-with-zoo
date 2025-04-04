# OGC API Processes with ZOO-Project

## Background on ZOO-Project
The ZOO-Project is an open-source processing platform introduced in 2009, licensed under the MIT/X11 license. It facilitates integration and communication between existing software components using standards defined by the Open Geospatial Consortium (OGC).

The platform aims to ensure that processing tasks follow the FAIR principles: Findable, Accessible, Interoperable, and Reproducible.

The ZOO-Project supports the "**OGC API - Processes**" - Part 1 (Core) and Part 2 (Deploy, Replace, Undeploy) Standards.

## Background on **OGC API - Processes**

### Introduction to **OGC API - Processes**

The **OGC API - Processes** standard supports the wrapping of computational tasks into executable processes that can be offered by a server through a Web API and be invoked by a client application. It specifies a processing interface for communicating over a RESTful protocol using JavaScript Object Notation (JSON) encodings. The standard builds on concepts from the OGC Web Processing Service (WPS) 2.0 Interface Standard but provides a more modern approach, allowing for interaction with web resources using the OpenAPI specification. Importantly, it does not require implementation of a WPS interface.

### Use Cases for **OGC API - Processes**

Government agencies, private organizations, and academic institutions use the **OGC API - Processes** standard to provide access to geospatial algorithms for processing data, including data from sensors. This distributed approach to processing allows for more capacity to handle large datasets and perform complex computations. The standard facilitates integration into existing software packages and supports scalable workflows for processing geospatial data.

### Overview of "**OGC API - Processes - Part 1 - Core**"

The **OGC API - Processes** - Part 1: Core enables the execution of computational tasks such as raster algebra, geometry buffering, routing, constructive area geometry, and imagery analysis. It supports execution in two modes: synchronous, where the client waits for the execution to complete, and asynchronous, where the server processes the task in the background and the client periodically checks the status.

The table below outlines the main resources defined by the **OGC API - Processes** - Part 1: Core standard:

| **Resource**                   | **Path**                                  | **Purpose**                                                                                   |
|--------------------------------|-------------------------------------------|-----------------------------------------------------------------------------------------------|
| **Landing page**               | `/`                                       | Top-level resource serving as an entry point.                                                 |
| **Conformance declaration**    | `/conformance`                            | Information about the functionality supported by the server.                                  |
| **API Definition**             | `/api`                                    | Metadata about the API itself.                                                                |
| **Process list**               | `/processes`                              | Lists available processes with identifiers and links to descriptions.                         |
| **Process description**        | `/processes/{processID}`                  | Retrieves a process description.                                                              |
| **Process execution**          | `/processes/{processID}/execution` (POST) | Creates and executes a job.                                                                   |
| **Job status info**            | `/jobs/{jobID}`                           | Retrieves information about the status of a job.                                              |
| **Job results**                | `/jobs/{jobID}/results`                   | Retrieves the result(s) of a job.                                                             |
| **Job list**                   | `/jobs`                                   | Retrieves the list of jobs.                                                                   |
| **Job Deletion**               | `/jobs/{jobID}` (DELETE)                  | Cancels and deletes a job.                                                                    |

### Overview of "**OGC API - Processes - Part 2: Deploy, Replace, Undeploy (DRU)**"

The **OGC API - Processes** - Part 2 specification extends the Core standard by defining additional capabilities for managing processes. It allows users to deploy, replace, and undeploy computational processes dynamically. This specification is useful for scenarios where processes need to be updated or removed, providing more flexibility and control over the server's computational tasks.

Here are the new resources introduced in Part 2:

| **Resource**                         | **Path**                                  | **Purpose**                                                                      |
|--------------------------------------|-------------------------------------------|----------------------------------------------------------------------------------|
| **Deploy Process**                   | `/processes` (POST)                       | Deploys a new process on the server.                                             |
| **Replace Process**                  | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                 |
| **Undeploy Process**                 | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                     |
| **Application Package (OGC AppPkg)** | `/processes/{processId}/package`          | Support accessing the OGC Application Package.                                   |

### OGC API - Process resources combining Part 1 and Part 2

| **Resource**                        | **Path**                                  | **Purpose**                                                                     | **Part**   |
|------------------------------------|-------------------------------------------|--------------------------------------------------------------------------------- |------------|
| **Landing page**                   | `/`                                       | Top-level resource serving as an entry point.                                    | Part 1     |
| **Conformance declaration**        | `/conformance`                            | Information about the functionality supported by the server.                     | Part 1     |
| **API Definition**                 | `/api`                                    | Metadata about the API itself.                                                   | Part 1     |
| **Process list**                   | `/processes`                              | Lists available processes with identifiers and links to descriptions.            | Part 1     |
| **Process description**            | `/processes/{processID}`                  | Retrieves detailed information about a specific process.                         | Part 1     |
| **Process execution**              | `/processes/{processID}/execution` (POST) | Executes a process, creating a job.                                              | Part 1     |
| **Deploy Process**                 | `/processes` (POST)                       | Deploys a new process on the server.                                             | Part 2     |
| **Replace Process**                | `/processes/{processID}` (PUT)            | Replaces an existing process with a new version.                                 | Part 2     |
| **Undeploy Process**               | `/processes/{processID}` (DELETE)         | Removes an existing process from the server.                                     | Part 2     |
| **Application Package (OGC AppPkg)** | `/processes/{processId}/package`        | Support accessing the OGC Application Package.                                   | Part 2     |
| **Job status info**                | `/jobs/{jobID}`                           | Retrieves the current status of a job.                                           | Part 1     |
| **Job results**                    | `/jobs/{jobID}/results`                   | Retrieves the results of a job.                                                  | Part 1     |
| **Job list**                       | `/jobs`                                   | Retrieves a list of submitted jobs.                                              | Part 1     |
| **Job deletion**                   | `/jobs/{jobID}` (DELETE)                  | Cancels and deletes a job.                                                       | Part 1     |

### Relation to Other OGC Standards

The **OGC API - Processes** standard modernizes and extends the capabilities offered by the OGC WPS. While the WPS standard provided a standardized interface for accessing computational services, the **OGC API - Processes** standard adopts a resource-oriented approach leveraging the OpenAPI specification. This results in better integration with modern web technologies and programming practices, addressing all the use cases supported by WPS and enabling more flexible and robust processing capabilities.

## Learning Module overview

### Tutorials
This series of tutorials provides a step-by-step guide to using the **OGC API - Processes** standard, covering the core functionalities from listing available processes to accessing the results of executed jobs. Each tutorial is designed to help you understand and implement the standard's capabilities in a practical way. The tutorials are provided with the following Jupyter Notebooks:

1. *Deploy an application package.ipynb*
2. *List the deployed processes.ipynb*
3. *Describe the process.ipynb*
4. *Execute the process and monitor its job execution.ipynb*

### Key Functionalities
Following these tutorials, the user will be able to cover all these key functionalities: 

* **List Available Processes**: Learn how to retrieve the list of processes offered by the server. This step provides an overview of the available computational tasks, including process identifiers, titles, and descriptions.
* **Deployment**: Discover how to deploy a new process, such as a custom application package using Common Workflow Language (CWL). This tutorial explains the encoding options for deployment requests and how to handle deployment responses.
* **Process Description**: Understand how to obtain detailed descriptions of individual processes, including their inputs, outputs, and supported execution modes. This step provides insight into how to configure and execute specific tasks.
* **Execution**: Learn how to execute a process using the `/processes/{processID}/execution` endpoint. The tutorial covers submitting the execution request, passing inputs, and handling different execution modes.
* **Monitor Execution**: Discover how to track the progress of a submitted job. This tutorial explains how to monitor job status, retrieve progress updates, and check for completion.
* **Access Results**: Learn how to retrieve the results of a completed job. The tutorial covers accessing outputs like STAC catalogs or other data formats, allowing you to analyze the processed data.
* **Job Management**: Understand how to manage jobs, including listing all jobs, cancelling running jobs, and deleting completed or failed jobs. This tutorial explains how to maintain the server's job history and resource usage.
