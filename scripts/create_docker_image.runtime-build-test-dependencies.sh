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
image_tag="${2:-runtime-build-test-dependencies}"
image_tag_cache="${3:-}"
runtime_build_dependencies_image="${4:-tezos/opam-repository:runtime-build-dependencies}"

echo
echo "### Building runtime-build-test-dependencies image"
echo "### (includes: additional ocaml dependencies, python, nodejs)"
echo "### (cache from: $image_name:$image_tag_cache, $(docker_cache_disabled_pp))"
echo

docker_build \
       -f runtime-build-test-dependencies.Dockerfile \
       --cache-from="$image_name:$image_tag_cache" \
       --build-arg=BUILDKIT_INLINE_CACHE=1 \
       --build-arg BUILD_IMAGE="${runtime_build_dependencies_image}" \
       -t "$image_name:$image_tag" \
       "$repo_dir"
