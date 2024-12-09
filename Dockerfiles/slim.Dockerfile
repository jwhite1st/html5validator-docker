FROM python:3.13.1-slim AS base

RUN mkdir -p /usr/share/man/man1/ \
    && apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -qq python3-pip default-jre

FROM base AS pypi

RUN --mount=type=cache,target=/root/.cache/pip pip --disable-pip-version-check install html5validator

RUN DEBIAN_FRONTEND=noninteractive apt remove -y python3-pip \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

FROM base AS source

ARG GIT_URL=https://github.com/svenkreiss/html5validator.git

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip pip install --disable-pip-version-check wheel setuptools \
    && git clone ${GIT_URL} \
    && cd html5validator \
    && python setup.py install \
    && cd .. \
    && rm -rf html5validator \
    && pip uninstall --yes wheel setuptools

RUN DEBIAN_FRONTEND=noninteractive apt-get purge -y git python3-pip \
    && apt autoremove -y
