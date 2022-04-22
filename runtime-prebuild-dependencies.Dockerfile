# runtime + prebuild dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
#
# This image is intended for
# - testing the buildability of tezos opam packages
# - building the runtime-build-dependencies and runtime-build-test-dependencies image

ARG BUILD_IMAGE

# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

# Automatically set if you use Docker buildx
ARG TARGETARCH

# use alpine /bin/ash and set pipefail.
# see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Adds static packages of hidapi and libusb built by `scripts/libusb-hidapi.sh`
# in `runtime-prebuild-dependencies` image.
WORKDIR /
COPY _docker_build/keys /etc/apk/keys/
COPY _docker_build/*/*.apk /tmp

USER root

WORKDIR /tmp

# To verify remote files checksum (prevent tampering)
COPY remote-files.sha256 .

RUN apk --no-cache add \
    autoconf=2.71-r0 \
    automake=1.16.3-r0 \
    bash=5.1.16-r0 \
    binutils=2.35.2-r2 \
    build-base=0.5-r2 \
    ca-certificates=20211220-r0 \
    cargo=1.52.1-r1 \
    coreutils=8.32-r2 \
    curl=7.79.1-r0 \
    eudev-dev=3.2.10-r0 \
    git=2.32.1-r0 \
    jq=1.6-r1 \
    libtool=2.4.6-r7 \
    linux-headers=5.10.41-r0 \
    m4=1.4.18-r2 \
    ncurses-dev=6.2_p20210612-r0 \
    opam=2.0.8-r1 \
    openssh-client=8.6_p1-r3 \
    openssl-dev=1.1.1n-r0 \
    patch=2.7.6-r7 \
    perl=5.32.1-r0 \
    rsync=3.2.3-r4 \
    tar=1.34-r0 \
    unzip=6.0-r9 \
    wget=1.21.1-r1 \
    xz=5.2.5-r1 \
    zlib-static=1.2.12-r0 \
    # Custom packages from `scripts/build-libusb-hidapi.sh`
    hidapi-0.9.0-r2.apk \
    hidapi-dev-0.9.0-r2.apk \
    libusb-1.0.24-r2.apk \
    libusb-dev-1.0.24-r2.apk \
# Install UPX manually to get current multi-arch release
# https://upx.github.io/
 && curl -fsSL https://github.com/upx/upx/releases/download/v3.96/upx-3.96-${TARGETARCH}_linux.tar.xz \
    -o upx-3.96-${TARGETARCH}_linux.tar.xz \
 && sha256sum --check --ignore-missing remote-files.sha256 \
 && tar -xf upx-3.96-${TARGETARCH}_linux.tar.xz \
 && mv upx-3.96-${TARGETARCH}_linux/upx /usr/local/bin/upx \
 && chmod 755 /usr/local/bin/upx \
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos

RUN mkdir ~/.ssh && \
    chmod 700 ~/.ssh && \
    git config --global user.email "ci@tezos.com" && \
    git config --global user.name "Tezos CI" && \
    # FIXME: Bypass CVE-2022-24765 fixed in git 2.30.3, 2.31.2, 2.32.1, 2.34.2, 2.35.2 and later versions
    # https://github.com/git/git/blob/master/Documentation/RelNotes/2.30.3.txt
    git config --global --add safe.directory /builds/tezos/tezos

# FIXME: Optimize layers, make a single COPY
COPY --chown=tezos:nogroup repo opam-repository/
COPY --chown=tezos:nogroup packages opam-repository/packages
COPY --chown=tezos:nogroup \
      packages/ocaml \
      packages/ocaml-config \
      packages/ocaml-base-compiler \
      packages/ocaml-options-vanilla \
      packages/base-bigarray \
      packages/base-bytes \
      packages/base-unix \
      packages/base-threads \
      opam-repository/packages/

WORKDIR /home/tezos/opam-repository

ARG OCAML_VERSION='4.12.1'
RUN opam init --disable-sandboxing --no-setup --yes \
              --compiler ocaml-base-compiler.${OCAML_VERSION} \
              tezos /home/tezos/opam-repository && \
    opam admin cache && \
    opam update && \
    opam install opam-depext && \
    opam depext --update --yes "$(opam list --all --short | grep -v ocaml-option-)" && \
    opam clean

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
