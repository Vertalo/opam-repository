#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

# shellcheck source=scripts/docker.sh
. "$script_dir"/docker.sh


image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-dependencies}"
image_tag_cache="${3:-}"

echo
echo "### Building runtime-dependencies image"
echo "### (includes: alpine, runtime-linked libraries)"
echo "### (cache from: $image_name:$image_tag_cache, $(docker_cache_disabled_pp))"
echo

docker_build \
       -f runtime-dependencies.Dockerfile \
       --build-arg=BUILDKIT_INLINE_CACHE=1 \
       --cache-from="$image_name:$image_tag_cache" \
       --build-arg BUILD_IMAGE="alpine:${alpine_version}" \
       --label "org.opencontainers.image.base.name=alpine:${alpine_version}" \
       -t "$image_name:$image_tag" \
       "$repo_dir"
