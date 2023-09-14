#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos/opam-repository}"
tag_suffix="${2:-}"
targetarch="${3:-amd64}"

"$script_dir"/create_docker_image.runtime-dependencies.sh \
             "$image_name" \
             "runtime-dependencies$tag_suffix"

"$script_dir"/create_docker_image.runtime-prebuild-dependencies.sh \
             "$image_name" \
             "runtime-prebuild-dependencies$tag_suffix" \
             "$image_name:runtime-dependencies$tag_suffix" \
             "$targetarch"

"$script_dir"/create_docker_image.runtime-build-dependencies.sh \
             "$image_name" \
             "runtime-build-dependencies$tag_suffix" \
             "$image_name:runtime-prebuild-dependencies$tag_suffix"

"$script_dir"/create_docker_image.runtime-build-test-dependencies.sh \
             "$image_name" \
             "runtime-build-test-dependencies$tag_suffix" \
             "$image_name:runtime-build-dependencies$tag_suffix"

"$script_dir"/create_docker_image.runtime-e2etest-dependencies.sh \
             "$image_name" \
             "runtime-e2etest-dependencies$tag_suffix" \
             "$image_name:runtime-dependencies$tag_suffix" \
             "$image_name:runtime-build-dependencies$tag_suffix"
