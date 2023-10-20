#!/bin/sh

## Sourceable file with common variables for other scripts related to docker images

export docker_images='runtime-dependencies runtime-prebuild-dependencies runtime-build-dependencies runtime-build-test-dependencies runtime-e2etest-dependencies rust-toolchain'

export docker_architectures='amd64 arm64'

check_docker_image_family() {
    family="$1"
    case "$family" in
        all | rust-toolchain | runtime)

            ;;
        *)

            echo "Unknown image family: ${family}, should be one of 'runtime', 'rust-toolchain' or 'all'"
            exit 1
    esac
}

docker_images_family() {
	family="$1"
    if [ "$family" = "all" ]; then
        echo "$docker_images"
    else
        # filter on family
        echo "$docker_images" | tr " " "\n" | grep "^${family}"
    fi
}
