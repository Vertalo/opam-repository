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
image_tag="${2:-rust-toolchain}"
image_tag_cache="${3:-}"

echo
echo "### Building rust-toolchain image"
echo "### (includes: rust toolchain)"
echo "### (cache from: $image_name:$image_tag_cache, $(docker_cache_disabled_pp))"
echo

docker_build \
       -f rust-toolchain.Dockerfile \
       --cache-from="$image_name:$image_tag_cache" \
       --build-arg=BUILDKIT_INLINE_CACHE=1 \
       -t "$image_name:$image_tag" \
       "$repo_dir"
