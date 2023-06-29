# runtime + build + test dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
# - opam test-dependencies (alcotest, etc.)
# - python and python libraries for tests executed in python
# - nvm for javascript backend testing
#
# This image is intended for
# - running the CI tests of tezos

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-build-test-dependencies"

# SHELL already set in runtime-dependencies

USER root

WORKDIR /tmp

# hadolint ignore=DL3018,SC2046
RUN apk --no-cache add \
        python3-dev \
        poetry \
 # Install shellcheck manually to get current multi-arch release
 # https://www.shellcheck.net/
 && curl -fsSL https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.$(arch).tar.xz \
    -o shellcheck-v0.8.0.linux.$(arch).tar.xz \
 && sha512sum --check --ignore-missing /home/tezos/remote-files.sha512 \
 && rm /home/tezos/remote-files.sha512 \
 && tar -xf shellcheck-v0.8.0.linux.$(arch).tar.xz \
 && mv shellcheck-v0.8.0/shellcheck /usr/local/bin/shellcheck \
 && chmod 755 /usr/local/bin/shellcheck \
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos

### Javascript env setup as tezos user

# TODO: https://gitlab.com/tezos/tezos/-/issues/5026
# The js dependencies could be downloaded from tezos/tezos and installed
# here.

COPY --chown=tezos:tezos nodejs/install-nvm.sh /tmp/install-nvm.sh
RUN /tmp/install-nvm.sh \
 && rm -rf /tmp/*

### Python setup

# Required to have poetry in the path in the CI
ENV PATH="/home/tezos/.local/bin:${PATH}"

# Copy poetry files to install the dependencies in the docker image
COPY --chown=tezos:tezos ./poetry.lock ./pyproject.toml ./

# Poetry will create the virtual environment in $(pwd)/.venv.
# The containers running this image can load the virtualenv with
# $(pwd)/.venv/bin/activate and do not require to run `poetry install`
# It speeds up the Tezos CI and simplifies the .gitlab-ci.yml file
# by avoiding duplicated poetry setup checks.
RUN poetry config virtualenvs.in-project true \
 && poetry install \
 && rm -rf /tmp/* /home/tezos/.cache/pip /home/tezos/.cache/pypoetry

# ENTRYPOINT and CMD already set in runtime-prebuild-dependencies
