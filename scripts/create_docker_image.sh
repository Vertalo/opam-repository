#!/bin/sh
set -eu

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos/opam-repository}"
tag_suffix="${2:-}"
tag_cache_suffix="${3:-}"
targetarch="${4:-amd64}"
image_family="${5:-all}"

check_docker_image_family "$image_family"

create_docker_images_runtime() {
	"$script_dir"/create_docker_image.runtime-dependencies.sh \
		"$image_name" \
        "runtime-dependencies$tag_suffix" \
        "runtime-dependencies$tag_cache_suffix"

	"$script_dir"/create_docker_image.runtime-prebuild-dependencies.sh \
		"$image_name" \
        "runtime-prebuild-dependencies$tag_suffix" \
        "runtime-prebuild-dependencies$tag_cache_suffix" \
		"$image_name:runtime-dependencies$tag_suffix" \
		"$targetarch"

	"$script_dir"/create_docker_image.runtime-build-dependencies.sh \
		"$image_name" \
        "runtime-build-dependencies$tag_suffix" \
        "runtime-build-dependencies$tag_cache_suffix" \
		"$image_name:runtime-prebuild-dependencies$tag_suffix"

	"$script_dir"/create_docker_image.runtime-build-test-dependencies.sh \
		"$image_name" \
        "runtime-build-test-dependencies$tag_suffix" \
        "runtime-build-test-dependencies$tag_cache_suffix" \
		"$image_name:runtime-build-dependencies$tag_suffix"

	"$script_dir"/create_docker_image.runtime-e2etest-dependencies.sh \
		"$image_name" \
        "runtime-e2etest-dependencies$tag_suffix" \
        "runtime-e2etest-dependencies$tag_cache_suffix" \
		"$image_name:runtime-dependencies$tag_suffix" \
		"$image_name:runtime-build-dependencies$tag_suffix"
}

create_docker_images_rust_toolchain() {
	"$script_dir"/create_docker_image.rust-toolchain.sh \
		"$image_name" \
        "rust-toolchain$tag_suffix" \
        "rust-toolchain$tag_cache_suffix"
}

case "$image_family" in
    "runtime")
        create_docker_images_runtime

        ;;
    "rust-toolchain")
        create_docker_images_rust_toolchain

        ;;
    "all")
        create_docker_images_runtime
        create_docker_images_rust_toolchain

        ;;
esac
