ARG DEBVER=bookworm
ARG FFREF=fd61687e1aa60acb669bbf227eceeac6b6ae6f3b

#======================================================================
FROM debian:$DEBVER-slim as build-ffmpeg

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade

# dependencies for fetching & building ffmpeg-static
RUN apt-get install --yes --no-install-recommends \
    bzip2 \
    ca-certificates \
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

RUN ./build.sh nasm && \
    ./build.sh x264 && \
    ./build.sh ffmpeg
RUN find build \( -name ffmpeg -o -name ffprobe \) \
    -type f |xargs cp --target-directory /usr/local/bin

#======================================================================
FROM debian:$DEBVER-slim

COPY --from=build-ffmpeg /usr/local/bin/ff* /usr/local/bin/
