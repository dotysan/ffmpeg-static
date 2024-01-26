ARG DEBVER=bookworm

#======================================================================
FROM debian:$DEBVER-slim as build-ffmpeg

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade

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
COPY scripts scripts
COPY patches patches

RUN ./build.sh nasm
RUN ./build.sh x264
RUN ./build.sh ffmpeg
RUN find build \( -name ffmpeg -o -name ffprobe \) \
    -type f |xargs cp --target-directory /usr/local/bin

COPY ffinfo.sh /usr/local/bin/
RUN ffinfo.sh

#======================================================================
FROM debian:$DEBVER-slim

COPY --from=build-ffmpeg /usr/local/bin/ff* /usr/local/bin/
