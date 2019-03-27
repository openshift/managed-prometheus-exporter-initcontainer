SHELL := /bin/bash
include version.mk

IMAGE_URI=quay.io/redhat/managed-prometheus-exporter-initcontainer

VERSION_MAJOR=0
VERSION_MINOR=1

all: build tag push

build:
	docker build . -t $(IMAGE_URI):latest

tag:
	docker tag $(IMAGE_URI):latest $(IMAGE_URI):$(VERSION_FULL)

push:
	docker push $(IMAGE_URI):latest
	docker push $(IMAGE_URI):$(VERSION_FULL)
