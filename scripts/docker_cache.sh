#!/bin/bash
set -eu

## CI only script: return image to use as Docker build option --cache-from

error() {
  echo "WARNING: Failed to pull Docker image 'runtime-build-test-dependencies' to get cached layers"
  exit 0
}

trap error ERR

# Default: GitLab container registry
image_name="${1:-registry.gitlab.com/tezos/opam-repository}"

# Pull from private AWS ECR inside Nomadic Labs' infrastructure
if [ -n "${AWS_ECR:-}" ]
then
  image_name="${AWS_ECR}/${CI_PROJECT_PATH}"
fi

# Default: fetch value from variable build_deps_image_version
# https://gitlab.com/tezos/tezos/-/blob/master/.gitlab/ci/templates.yml#L3
if [ -z "${2:-}" ]
then
  commit_sha=$(curl -fsSL https://gitlab.com/tezos/tezos/-/raw/master/.gitlab/ci/templates.yml | grep 'build_deps_image_version: ' | cut -d' ' -f4)
  tag_suffix="--${commit_sha}"
else
  tag_suffix="${2}"
fi

echo "${image_name}:runtime-build-test-dependencies${tag_suffix}"
