# runtime + build + test dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
# - opam test-dependencies (aclotest, crowbar, etc.)
# - python and python libraries for tests executed in python
# - nvm for javascript backend testing
#
# This image is intended for
# - running the CI tests of tezos

ARG BUILD_IMAGE

# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

# use alpine /bin/ash and set pipefail.
# see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

USER root

WORKDIR /tmp

# To verify remote files checksum (prevent tampering)
COPY remote-files.sha256 .

# hadolint ignore=DL3018,SC2046
RUN apk --no-cache add \
        libffi-dev=3.3-r2 \
        py3-pip=20.3.4-r1 \
        py3-sphinx=3.5.4-r0 \
        py3-sphinx_rtd_theme=0.4.3-r4 \
        python3-dev=3.9.5-r2 \
 # Install shellcheck manually to get current multi-arch release
 # https://www.shellcheck.net/
 && curl -fsSL https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.$(arch).tar.xz \
    -o shellcheck-v0.8.0.linux.$(arch).tar.xz \
 && sha256sum --check --ignore-missing remote-files.sha256 \
 && tar -xf shellcheck-v0.8.0.linux.$(arch).tar.xz \
 && mv shellcheck-v0.8.0/shellcheck /usr/local/bin/shellcheck \
 && chmod 755 /usr/local/bin/shellcheck \
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos

### Begin Javascript env setup as tezos user
COPY nodejs nodejs
RUN bash nodejs/install-nvm.sh
### End Javascript env setup

### Begin Python setup
# Deactivate rust-crypto build until we update rust
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
# Install poetry (https://github.com/python-poetry/poetry)
RUN pip3 --no-cache-dir install --user poetry==1.0.10

# Required to have poetry in the path in the CI
ENV PATH="/home/tezos/.local/bin:${PATH}"

# Copy poetry files to install the dependencies in the docker image
COPY poetry.lock poetry.lock
COPY pyproject.toml pyproject.toml

# Poetry will create the virtual environment in $(pwd)/.venv.
# The containers running this image can load the virtualenv with
# $(pwd)/.venv/bin/activate and do not require to run `poetry install`
# It speeds up the Tezos CI and simplifies the .gitlab-ci.yml file
# by avoiding duplicated poetry setup checks.
RUN poetry config virtualenvs.in-project true && \
    poetry install
### End Python setup
