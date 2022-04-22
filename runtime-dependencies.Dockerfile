# runtime dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
#
# This image is intended for
# - distributing the tezos binaries in
# - building the runtime-prebuild-dependencies, runtime-build-dependencies, and runtime-build-test-dependencies images

ARG BUILD_IMAGE

# alpine:3.14 pinned 2022-04-21
FROM alpine@sha256:06b5d462c92fc39303e6363c65e074559f8d6b1363250027ed5053557e3398c5

# Metadata
LABEL org.label-schema.vendor="Nomadic Labs" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.name="Tezos" \
      org.label-schema.description="Tezos node" \
      org.label-schema.vcs-url=https://gitlab.com/tezos/tezos \
      org.label-schema.docker.schema-version="1.0" \
      distro.style="apk" \
      distro="alpine" \
      distro.long="alpine-3.14" \
      operatingsystem="linux"

USER root

RUN apk --no-cache add \
    gcc=10.3.1_git20210424-r2 \
    gmp=6.2.1-r1 \
    hidapi=0.9.0-r2 \
    libc-dev=0.7.2-r3 \
    libev=4.33-r0 \
    libffi=3.3-r2 \
    sudo=1.9.7_p1-r1

COPY zcash-params /usr/share/zcash-params

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
