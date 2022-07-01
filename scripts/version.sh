#!/bin/sh

# Base docker image
export alpine_version='3.15'

# Installed via apk cargo in runtime-prebuild-dependencies.Dockerfile
export cargo_version='1.56.0'

# Installed via apk rust in runtime-prebuild-dependencies.Dockerfile
export rust_version='1.56.1'

# Installed via apk opam in runtime-prebuild-dependencies.Dockerfile
export opam_version='2.0.8'

# Installed via opam with argument OCAML_VERSION in runtime-prebuild-dependencies.Dockerfile
export ocaml_version='4.14.0'

# Installed via apk python3-dev in runtime-build-test-dependencies.Dockerfile
export python_version='3.9.7'

# Installed via pip in runtime-build-test-dependencies.Dockerfile
export poetry_version='1.0.10'
