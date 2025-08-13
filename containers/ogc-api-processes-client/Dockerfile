# Stage 1: Build stage
FROM rockylinux:9.3-minimal AS build

# Install necessary build tools
RUN microdnf install -y curl tar && \
    microdnf clean all

# Download the hatch tar.gz file from GitHub
RUN curl -L https://github.com/pypa/hatch/releases/latest/download/hatch-x86_64-unknown-linux-gnu.tar.gz -o /tmp/hatch-x86_64-unknown-linux-gnu.tar.gz

# Extract the hatch binary
RUN tar -xzf /tmp/hatch-x86_64-unknown-linux-gnu.tar.gz -C /tmp/

# Stage 2: Final stage
FROM rockylinux:9

# Install runtime dependencies
RUN dnf install -y --nodocs which expat && \
    dnf clean all

# Set up a default user and home directory
ENV HOME=/home/ogc

# Create a user with UID 1001, group root, and a home directory
RUN useradd -u 1001 -r -g 0 -m -d ${HOME} -s /sbin/nologin \
        -c "Default ogc User" ogc && \
    mkdir -p /code && \
    mkdir -p /prod && \
    chown -R 1001:0 /code && \
    chmod g+rwx ${HOME} /code

# Copy the hatch binary from the build stage
COPY --from=build /tmp/hatch /usr/bin/hatch

# Ensure the hatch binary is executable
RUN chmod +x /usr/bin/hatch

# Install runtime dependencies
RUN dnf install -y which jq git && \
    dnf clean all


# Copy the application files into the /code directory
COPY --chown=1001:0 . /code

ARG STARS_VERSION

RUN if [[ -n "$STARS_VERSION" ]] ; then dnf install -y https://github.com/Terradue/Stars/releases/download/$STARS_VERSION/Stars.$STARS_VERSION.linux-x64.rpm; Stars --help;  fi 

# Switch to the non-root user
USER ogc
WORKDIR /code

# Set up virtual environment paths
ENV VIRTUAL_ENV=/code/envs/ogc
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Prune any existing environments and create a new production environment
RUN hatch env prune && \
    hatch env create prod && \
    hatch run prod:ogc-api-processes-client --help && \
    chmod +rx -R /code/envs/ogc && \
    chmod +rx -R /home/ogc && \
    rm -fr /code/.git /code/.pytest_cache


WORKDIR /code

# Set the default command to run when the container starts
CMD ["ogc-api-processes-client"]
