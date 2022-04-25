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

# TODO: remove
export DOCKER_BUILD_CACHE_FROM='--cache-from=registry.gitlab.com/tezos/opam-repository:runtime-dependencies--amd64--6f7c23ea1c34c3e1d444e0ececb33f8db4f33402'

docker build \
       --file=runtime-dependencies.Dockerfile \
       "${DOCKER_BUILD_CACHE:-}" \
       "${DOCKER_BUILD_CACHE_FROM:-}" \
       --build-arg=BUILD_IMAGE="alpine:${alpine_version}" \
       --build-arg=IMAGE_VERSION="${image_tag}" \
       --tag="$image_name:$image_tag" \
       "$repo_dir"
