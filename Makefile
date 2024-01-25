SHELL:=/usr/bin/env bash

TAG:=$(notdir $(CURDIR))

.PHONY: run build

run: build
	docker run --rm -it $(TAG)

build:
	docker build --progress=plain --tag $(TAG) .
