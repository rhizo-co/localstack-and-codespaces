# Codespaces devcontainer docker image.

## Contents

This directory contains the source used by codespaces to build the docker image that the codespaces container will use.

The dockerfile and scripts are copied from https://github.com/microsoft/vscode-dev-containers/tree/main/containers/docker-from-docker/.devcontainer/library-scripts

### Dockerfile

The dockerfile defines the docker image. It installs a docker client and attempts to ensure that the codespaces user has the necessary permissions to use docker.

### library-scripts/

The `library-scripts/` directory contains bash scripts that are used in the Dockerfile. These scripts are used during image build but are not present in the container at runtime. 
