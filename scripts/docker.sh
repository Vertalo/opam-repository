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

docker_cache_disabled() {
    [ "${DOCKER_NO_CACHE:-}" = "1" ] ||
        echo "${CI_MERGE_REQUEST_LABELS:-}" \
            | grep -q '(?:^|[,])ci--no-cache(?:$|[,])'
}

docker_cache_disabled_pp() {
   if docker_cache_disabled ; then
        echo "docker cache: disabled"
    else
        echo "docker cache: enabled"
    fi
}

# Build with the '--no-cache' Docker build flag if DOCKER_NO_CACHE is set
# to 1 or if the comma-separated list CI_MERGE_REQUEST_LABELS contains
# 'ci--no-cache'.
docker_build() {
    if docker_cache_disabled ; then
        docker build --no-cache "$@"
    else
        docker build "$@"
    fi
}
