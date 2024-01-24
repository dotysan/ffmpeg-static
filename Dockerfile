ARG PYVER=3.12
ARG GDVER=3.8.3
ARG DEBVER=bookworm
ARG FFREF=28d3801ff9d5c2108097b0c4e180656d791455fe
# old October ffmpeg 6.0 above works but not 6.1.1 below, why?
# ARG FFREF=2bc779fc5fd247c84d2bd7c1a2ce2bba5e90ae38
# TODO: set GDVER from redirect header https://github.com/OSGeo/gdal/releases/latest

#======================================================================
FROM debian:$DEBVER-slim as build-ffmpeg

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade

# dependencies for fetching & building ffmpeg-static
RUN apt-get install --yes --no-install-recommends \
    bzip2 \
    ca-certificates \
    # cmake is only needed for srt
    cmake \
    g++ \
    git \
    libssl-dev \
    make \
    pkgconf \
    tcl \
    wget \
    && rm -rf /var/lib/apt/lists/*

ARG FFREF
RUN git clone --depth 1 --branch fireview --single-branch \
    https://github.com/dotysan/ffmpeg-static && \
    cd ffmpeg-static && git fetch --depth 1 origin $FFREF \
    && git checkout FETCH_HEAD

WORKDIR /ffmpeg-static

# temp hack to appease build.sh calling `tput colors` without -T or $TERM
ENV TERM xterm-256color

RUN ./build.sh srt && \
    ./build.sh nasm && \
    ./build.sh x264 && \
    ./build.sh ffmpeg
RUN find build \( -name ffmpeg -o -name ffprobe \) \
    -type f |xargs cp --target-directory /usr/local/bin

#======================================================================
FROM debian:$DEBVER-slim

COPY --from=build-ffmpeg /usr/local/bin/ff* /usr/local/bin/
