#! /usr/bin/env bash
#
#
set -ex

./build.sh nasm
./build.sh x264
./build.sh ffmpeg
