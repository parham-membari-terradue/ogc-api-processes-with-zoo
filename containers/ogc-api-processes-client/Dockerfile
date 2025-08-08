FROM docker.io/library/python:3.10-slim@sha256:80619a5316afae7045a3c13371b0ee670f39bac46ea1ed35081d2bf91d6c3dbd

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir git+https://github.com/EOEPCA/ogc-api-client@develop#subdirectory=src && \
    python -c "import ogc_api_client; print(ogc_api_client.__version__)"

RUN cat > /usr/bin/ogc-api-processes-client <<'EOF'
#!/usr/bin/env sh
echo "$@"
echo "$@" > feature-collection.json
EOF
RUN chmod +x /usr/bin/ogc-api-processes-client

ENTRYPOINT []