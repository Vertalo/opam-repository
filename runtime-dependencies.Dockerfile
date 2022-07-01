# runtime dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
#
# This image is intended for
# - distributing the tezos binaries in
# - building the runtime-prebuild-dependencies, runtime-build-dependencies, and runtime-build-test-dependencies images

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

# Use alpine /bin/ash and set shell options
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Open Container Initiative
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="contact@nomadic-labs.com" \
      org.opencontainers.image.description="Octez - GitLab CI docker image" \
      org.opencontainers.image.documentation="https://tezos.gitlab.io/" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.com/tezos/opam-repository" \
      org.opencontainers.image.title="runtime-dependencies" \
      org.opencontainers.image.url="https://gitlab.com/tezos/tezos" \
      org.opencontainers.image.vendor="Nomadic Labs"

USER root

# Create a static system group and system user (no password + login shell)
# Prepare sudo, ssh and run
RUN echo 'tezos:x:1000:tezos' >> /etc/group \
 && echo 'tezos:x:1000:1000:tezos:/home/tezos:/bin/sh' >> /etc/passwd \
 && echo 'tezos:!::0:::::' >> /etc/shadow \
 && mkdir -pv /home/tezos/.ssh /run/tezos/client /run/tezos/node \
 && chown -R tezos:tezos /home/tezos /run/tezos \
 && chmod 700 /home/tezos/.ssh \
 && mkdir -pv /etc/sudoers.d \
 && echo 'tezos ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/tezos \
 && chmod 440 /etc/sudoers.d/tezos

# Sapling parameters
COPY ./zcash-params/sapling-output.params ./zcash-params/sapling-spend.params /usr/share/zcash-params/

# To allow installing custom Nomadic APKs
COPY ./apk/nomadic.rsa.pub /etc/apk/keys/

# Git configuration
# Verify remote files checksum (prevent tampering)
COPY --chown=tezos:tezos .gitconfig remote-files.sha512 /home/tezos/

WORKDIR /tmp

# Automatically set if you use Docker buildx
ARG TARGETARCH
COPY ./apk/${TARGETARCH}/ .

# hadolint ignore=DL3018,DL3003
RUN apk add --no-cache \
    binutils \
    ca-certificates \
    coreutils \
    libusb-dev \
    gcc \
    gmp-dev \
    libc-dev \
    libev-dev \
    libffi-dev \
    sudo \
 # Custom hidapi-dev APK with both shared and static libaries
    ./hidapi-0.11.2-r1.apk \
    ./hidapi-dev-0.11.2-r1.apk \
 # Cleanup
 && rm -rf /tmp/*

USER tezos
ENV USER=tezos
WORKDIR /home/tezos
