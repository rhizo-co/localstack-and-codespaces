# .devcontainer

The files in this directory define the setup / configuration of GitHub codespace for this repository

## Contents

### build/

The build directory defines the docker image used for the codespace container.

### devcontainer.json

The majority of the condespace configuration is contained in `devcontainer.json`.

To support localstack `devcontainer.json` mounts the docker socket so that the docker cli can be used in the dev container and the localstack docker image is started as a `postStartCommand`.

The full spec for `devcontainer.json` is defined [in the VS Code documentation](https://code.visualstudio.com/docs/remote/devcontainerjson-reference).

### localstack.env

Additional environment variables that are passed to localstack (but not the dev container) can be set in the `localstack.env` file.
