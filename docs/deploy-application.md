# Deploy the Application Package







This endpoint permits the deployment of the water_bodies application package.

This time, we can add a request body and set its content type. There are two encodings presented which rely on the same CWL conformance class. They both use the same water_bodies.cwl, but using the OGC Application Package encoding (application/ogcapppkg+json), we can pass the CWL file by reference rather than the file content, when we pick the CWL encoding (application/cwl+yaml).

When we select a content type, the request body text area should get updated and contain a relevant payload for this encoding.

Warning
This is a warning

Warning

If we edit the payload, the text area may not update when selecting a different encoding. In such a case, we can use the Reset button to get it corrected.

After executing the deployment request, the server sends back a process summary similar to the one we received from the previous endpoint. The server response includes a Location header that contains the URL for accessing the detailed process description.

We have two options: go back to the first step and list the available processes (it should contain the deployed process), or move on to the next step and review the process description.