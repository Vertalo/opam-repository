#!/bin/sh

# Base docker image
export alpine_version='3.16'

# Installed via apk cargo in runtime-prebuild-dependencies.Dockerfile
export cargo_version='1.60.0'

# Installed via apk rust in runtime-prebuild-dependencies.Dockerfile
export rust_version='1.60.0'

# Installed via apk rust in runtime-prebuild-dependencies.Dockerfile
export opam_version='2.1.2'

# Installed via opam in runtime-prebuild-dependencies.Dockerfile
export ocaml_version='4.14.1'

# Installed via apk python3-dev in runtime-build-test-dependencies.Dockerfile
export python_version='3.10.10'

# Installed via apk in runtime-build-test-dependencies.Dockerfile
export poetry_version='1.1.13'
