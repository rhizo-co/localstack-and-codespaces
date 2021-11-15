ARG BASE_IMAGE
FROM ${BASE_IMAGE}


# [Option] Install zsh
ARG INSTALL_ZSH="false"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby CLI instead of the licensed Docker CLI
ARG USE_MOBY="true"
# [Option] Select CLI version
ARG CLI_VERSION="latest"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1
ENV DOCKER_HOST=unix:///var/run/docker-host.sock

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# install common tools & docker
COPY library-scripts/*.sh /tmp/library-scripts/
RUN sudo apt-get update \
    && sudo apt-get install -y ca-certificates \
    && sudo /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && sudo /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "${USE_MOBY}" "${CLI_VERSION}" \
    # Clean up
    && sudo apt-get autoremove -y && sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# install aws cli
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip "awscliv2.zip" \
    && sudo ./aws/install \
    && sudo rm -rf ./aws awscliv2.zip

# install awslocal (localstack client) using pip, but dont stress if we cannot because pip isn't always available
RUN pip3 install awscli-local || pip install aws-cli-local || echo "unable to install awslocal, continuing without it"

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
