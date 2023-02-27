#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_version="${2:-runtime-build-e2etest-dependencies}"
runtime_test_dependencies_image="${3:-tezos/opam-repository:runtime-build-test-dependencies}"

echo
echo "### Building runtime-build-e2etest-dependencies image"
echo "### (includes: additional js dependencies)"
echo

docker build \
       -f runtime-build-e2etest-dependencies.Dockerfile \
       --build-arg BUILD_IMAGE="${runtime_test_dependencies_image}" \
       -t "$image_name:$image_version" \
       "$repo_dir"
