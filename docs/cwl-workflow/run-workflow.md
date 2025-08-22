The user can invoke the OGC API's process following steps below:
- Create input parameter in YAML format:
```yaml linenums="1" title="params.yaml"
--8<--
cwl-workflows/eoap-api.yaml
--8<--
```  
- Run the application package:
```
cwltool --debug cwl-workflows/eoap-api-cli.cwl#eoap-api cwl-workflows/eoap-api.yaml 
```
- Inspect the results:
```
cat cwl-workflows/featre-collection.json
```
- Access to one the assets in the `featre-collection.json`
```
results=$(jq -r '.features[0].links[] | select(.rel=="root") | .href' cwl-workflows/feature-collection.json | sed 's|/catalog.json$|/|')

aws s3 cp --recursive $results ./results/

tree results
```

The expected output is like below:
```
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_043033_20231014_02_T1/LC08_L2SP_043033_20231014_02_T1.json to results/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_043033_20231014_02_T1/LC08_L2SP_043033_20231014_02_T1.json
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_044032_20231021_02_T1/LC08_L2SP_044032_20231021_02_T1.json to results/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_044032_20231021_02_T1/LC08_L2SP_044032_20231021_02_T1.json
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_043033_20231014_02_T1/otsu.tif to results/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_043033_20231014_02_T1/otsu.tif
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/catalog.json to results/catalog.json
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/932544e2-7f54-11f0-bd13-8a8eed839884/collection.json to results/932544e2-7f54-11f0-bd13-8a8eed839884/collection.json
download: s3://results/932544e2-7f54-11f0-bd13-8a8eed839884/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_044032_20231021_02_T1/otsu.tif to results/932544e2-7f54-11f0-bd13-8a8eed839884/LC08_L2SP_044032_20231021_02_T1/otsu.tif

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