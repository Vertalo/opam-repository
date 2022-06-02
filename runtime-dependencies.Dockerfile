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
# Prepare sudo, ssh and git configuration
RUN echo 'tezos:x:1000:tezos' >> /etc/group \
 && echo 'tezos:x:1000:1000:tezos:/home/tezos:/bin/sh' >> /etc/passwd \
 && echo 'tezos:!::0:::::' >> /etc/shadow \
 && mkdir -pv /home/tezos/.ssh /run/tezos/client /run/tezos/node \
 && chown -R tezos:tezos /home/tezos /run/tezos \
 && chmod 700 /home/tezos/.ssh \
 && mkdir -pv /etc/sudoers.d \
 && echo 'tezos ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/tezos \
 && chmod 440 /etc/sudoers.d/tezos

COPY --chown=tezos:tezos tezos.gitconfig /home/tezos/.gitconfig

COPY ./zcash-params/sapling-output.params ./zcash-params/sapling-spend.params /usr/share/zcash-params/

# hadolint ignore=DL3018
RUN apk --no-cache add \
    binutils \
    gcc \
    gmp \
    hidapi \
    libc-dev \
    libev \
    libffi \
    sudo

USER tezos
ENV USER=tezos
WORKDIR /home/tezos
