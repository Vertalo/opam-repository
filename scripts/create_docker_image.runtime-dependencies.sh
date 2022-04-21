#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-dependencies}"

echo
echo "### Building runtime-dependencies image"
echo "### (includes: alpine, runtime-linked libraries)"
echo

docker build \
       -f runtime-dependencies.Dockerfile \
       --build-arg BUILD_IMAGE="alpine@sha256:${alpine_sha256}" \
       --build-arg IMAGE_VERSION="${image_tag}" \
       -t "$image_name:$image_tag" \
       "$repo_dir"
