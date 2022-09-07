#!/bin/sh

# This script build hidapi including the static library.
# This script will no longer be needed once the upstream patches
# (which add static binaries) are available in Alpine.
# Those patches are already merged and will be available in the
# next version of Alpine.

# fail in case of error
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"

cd "$repo_dir"

# avoid shellcheck error
alpine_version=

# shellcheck source=scripts/version.sh
. "$script_dir/version.sh"

# cleanup in case of error
cleanup () {
    set +e
    rm -rf "$tmp_dir"
    if [ -n "${container:-}" ]; then docker rm "$container"; fi
    docker rmi "$tmp_image" || true

}
trap cleanup EXIT

# these are the script arguments
library="${1}"

# if build_dir is not defined _docker_build is used as default.
build_dir="${build_dir:-_docker_build}"

# tmp_image is the name of the temporary docker image that we use to build
# the alpine package
tmp_image="tezos/opam-repository:$library"
tmp_dir=$(mktemp -dt "tezos.$library.XXXXXXXX")

# the only difference with upstream file is to add `static` build commands.
cp "apk/$library/APKBUILD" "${tmp_dir}/APKBUILD"

# we use a docker to compile the alpine package
cat << EOF > "$tmp_dir/Dockerfile"
FROM alpine:${alpine_version}
ENV PACKAGER "Tezos <ci@tezos.com>"
RUN apk --no-cache add alpine-sdk sudo \
    && apk update \
    && adduser --disabled-password builder \
    && echo 'builder ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder \
    && addgroup builder abuild
USER builder
WORKDIR /home/builder/
COPY * ./
RUN abuild-keygen -a -i -n && abuild -r
EOF

printf "\n### Building %s...\n" "$library"

docker build \
       --cache-from "$tmp_image" \
       -t "$tmp_image" \
       "$tmp_dir"

mkdir -p "$build_dir"

# we copy the result of the compilation outside of the container
container=$(docker create "$tmp_image")
docker cp -L "$container:/etc/apk/keys" "$build_dir"
docker cp -L "$container:/home/builder/packages/home/$(arch)/" "$build_dir"
