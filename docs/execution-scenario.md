# Execution scenario

## User personas

The personas will help illustrate the workflow: Alice prepares and deploys the application, while Eric utilizes the deployed service to achieve his objectives.

###Alice – EO Application Developer

Alice is a developer specializing in Earth Observation (EO) applications. 

She creates geospatial processing solutions to analyze satellite data. For this tutorial, Alice has developed an application package for detecting water bodies using an algorithm based on the Normalized Difference Water Index (NDWI) and Otsu thresholding. 

She publishes this application package as a deployable process on an OGC API - Processes server.

### Eric – Data Scientist

Eric is a data scientist interested in using satellite imagery to monitor environmental changes, such as detecting water bodies. 

He discovers Alice’s published application package and decides to use it by following the tutorial steps. 

Eric uses the OGC API - Processes interface to run Alice’s application package on relevant datasets and retrieve results for analysis.

## User Scenarios

### Alice's User Scenario

Alice, an EO application developer, packages her water-bodies detection software as an EO Application Package. She follows these steps to create a deployable solution:

* **Prepare Container Images**: She builds container images that include all execution dependencies for her software.

* **Create CWL CommandLineTool Documents**: Alice wraps her containerized command-line tools using CWL CommandLineTool documents.

* **Orchestrate with a CWL Workflow**: She organizes the CWL CommandLineTool documents into a workflow to execute the process.

* **Test the Application Package**: Alice verifies the application package through various execution scenarios.

This workflow allows Alice to share her EO Application Package for others like Eric to deploy on OGC API - Processes servers.

> Note: See https://eoap.github.io/mastering-app-package/ to learn about this scenario.

### Eric's User Scenario

Eric, a data scientist, wants to analyze satellite imagery to detect water bodies. He learns about Alice's published application package and follows these steps to achieve his goal:

* *Discover Alice’s Application Package*: Eric finds Alice's water-bodies detection application package in a repository or marketplace where it is shared.

* **Deploy the Application**: He deploys Alice’s application package on an OGC API - Processes server, making the process available for execution.

* **List Available Processes**: Eric lists the processes on the server to confirm that the "water-bodies" process is now available.

* **Check Process Details**: He reviews the process's inputs and outputs to understand how to configure the execution.

* **Execute the Process**: Eric submits an execution request with the required parameters, such as area of interest and satellite data.

* **Monitor Execution**: He tracks the job's status to ensure it completes successfully.

* **Access Results**: Once the process finishes, Eric retrieves the outputs (e.g., a STAC catalog) for further analysis.

This workflow allows Eric to effectively utilize Alice’s published application package for detecting water bodies.
