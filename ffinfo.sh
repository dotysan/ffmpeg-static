#! /usr/bin/env bash
#
set -e

main() {
    ffinfo |lessorcat
}

ffinfo() {
    ffmpeg -version
    echo
    ffmpeg -hide_banner -protocols
    echo
    ffmpeg -hide_banner -formats
    echo
    ffmpeg -hide_banner -filters
    echo
    ffmpeg -hide_banner -codecs
}

lessorcat() {
    if ! hash less >/dev/null
    then cat
    elif [ -t 1 ]
    then less
    else cat
    fi
}

main
exit 0
