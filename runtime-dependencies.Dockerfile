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
FROM alpine@sha256:06b5d462c92fc39303e6363c65e074559f8d6b1363250027ed5053557e3398c5

# Metadata
LABEL org.label-schema.vendor="Nomadic Labs" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.name="Tezos" \
      org.label-schema.description="Tezos node" \
      org.label-schema.vcs-url="https://gitlab.com/tezos/tezos" \
      org.label-schema.docker.schema-version="1.0" \
      distro.style="apk" \
      distro="alpine" \
      distro.long="alpine-$alpine_version" \
      operatingsystem="linux"

USER root

COPY ./zcash-params/sapling-output.params ./zcash-params/sapling-spend.params /usr/share/zcash-params/

# hadolint ignore=DL3018
RUN apk --no-cache add \
    gcc \
    gmp \
    hidapi \
    libc-dev \
    libev \
    libffi \
    sudo

RUN adduser -S tezos && \
    echo 'tezos ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/tezos && \
    chmod 440 /etc/sudoers.d/tezos && \
    chown root:root /etc/sudoers.d/tezos && \
    sed -i.bak 's/^Defaults.*requiretty//g' /etc/sudoers && \
    mkdir -p /var/run/tezos/node /var/run/tezos/client && \
    chown -R tezos /var/run/tezos

USER tezos
ENV USER=tezos

WORKDIR /home/tezos
