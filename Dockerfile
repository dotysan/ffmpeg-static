ARG DEBVER=bookworm

#======================================================================
FROM debian:$DEBVER-slim as build-ffmpeg

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade --yes

# dependencies for fetching & building ffmpeg-static
RUN apt-get install --yes --no-install-recommends \
    bzip2 \
    ca-certificates \
    g++ \
    make \
    patch \
    pkgconf \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ffmpeg-static
COPY build.sh .
COPY scripts/common.inc scripts/

COPY scripts/nasm scripts/
RUN ./build.sh nasm

COPY scripts/libx264 scripts/
RUN ./build.sh x264

COPY scripts/ffmpeg scripts/
COPY patches patches
RUN ./build.sh ffmpeg

RUN find build -type f -name ffmpeg |xargs ls -t | \
    sed 1q |xargs cp --target-directory /usr/local/bin

COPY ffinfo.sh /usr/local/bin/
RUN ffinfo.sh

#======================================================================
FROM debian:$DEBVER-slim

COPY --from=build-ffmpeg /usr/local/bin/ff* /usr/local/bin/
