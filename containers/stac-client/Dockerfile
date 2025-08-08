FROM docker.io/library/python:3.10-slim@sha256:80619a5316afae7045a3c13371b0ee670f39bac46ea1ed35081d2bf91d6c3dbd

RUN pip install --no-cache-dir pystac-client && \
    python -c "import pystac_client; print(pystac_client.__version__)"

ENTRYPOINT []