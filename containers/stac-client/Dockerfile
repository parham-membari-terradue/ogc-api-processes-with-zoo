FROM docker.io/library/python:3.10-slim@sha256:80619a5316afae7045a3c13371b0ee670f39bac46ea1ed35081d2bf91d6c3dbd

RUN pip install --no-cache-dir pystac-client && \
    python -c "import pystac_client; print(pystac_client.__version__)"

RUN apt-get update && \
    apt-get install -y curl && \
    curl -L https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-amd64 -o /usr/bin/jq && \
    chmod +x /usr/bin/jq

RUN useradd -u 1001 -r -g 0 -m -d ${HOME} -s /sbin/nologin \
        -c "Default neo User" neo

WORKDIR /home/neo

USER neo

ENTRYPOINT []