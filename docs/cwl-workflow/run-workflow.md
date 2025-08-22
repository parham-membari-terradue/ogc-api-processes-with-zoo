To invoke the OGC API process, follow these steps:

1. **Define the input parameters in YAML**
   Create a parameter file named `params.yaml`:

   ```yaml linenums="1" title="params.yaml"
   --8<--
   cwl-workflows/params.yaml
   --8<--
   ```

2. **Run the application package**
   Execute the process with `cwltool`:

   ```bash
   cwltool --debug cwl-workflows/eoap-api-cli.cwl#eoap-api cwl-workflows/params.yaml 
   ```

3. **Inspect the results**
   The output is stored as a feature collection:

   ```bash
   cat cwl-workflows/feature-collection.json
   ```

4. **Retrieve one of the generated assets**
   Extract the root link from the feature collection, download the results, and display the directory tree:

   ```bash
   results=$(jq -r '.features[0].links[] | select(.rel=="root") | .href' cwl-workflows/feature-collection.json | sed 's|/catalog.json$|/|')

   aws s3 cp --recursive $results ./results/

   tree results
   ```

---

### Expected output

You should see logs of downloaded files followed by the resulting directory structure. For example:

```text
download: s3://results/.../LC08_L2SP_043033_20231014_02_T1.json to results/.../LC08_L2SP_043033_20231014_02_T1.json
download: s3://results/.../otsu.tif to results/.../otsu.tif
download: s3://results/.../catalog.json to results/catalog.json
download: s3://results/.../collection.json to results/.../collection.json
...

results/
|-- 932544e2-7f54-11f0-bd13-8a8eed839884
|   |-- LC08_L2SP_043033_20231014_02_T1
|   |   |-- LC08_L2SP_043033_20231014_02_T1.json
|   |   `-- otsu.tif
|   |-- LC08_L2SP_044032_20231021_02_T1
|   |   |-- LC08_L2SP_044032_20231021_02_T1.json
|   |   `-- otsu.tif
|   `-- collection.json
`-- catalog.json

3 directories, 6 files
```

