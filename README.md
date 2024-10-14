# OGC API Processes with ZOO Project

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![stability-wip](https://img.shields.io/badge/stability-wip-lightgrey.svg)](https://github.com/mkenney/software-guides/blob/master/STABILITY-BADGES.md#work-in-progress)

## Documentation

The webpage of the documentation is https://eoap.github.io/ogc-api-processes-with-zoo/. 

## Bootstrap the module on minikube

Clone the repository: https://github.com/eoap/dev-platform-eoap with:

```
git clone https://github.com/eoap/dev-platform-eoap.git
```

Bootstrap with `skaffold`:

```
cd dev-platform-eoap/ogc-api-processes-with-zoo/
skaffold dev
```

Wait for the deployments to stabilize (2 to 3 minutes).

Open your browser at http://0.0.0.0:8000/

## License

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)