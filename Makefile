SHELL := /usr/bin/env bash
include version.mk

IMAGE_REPO=quay.io/openshift-sre
IMAGE_NAME=managed-prometheus-exporter-initcontainer

VERSION_MAJOR=0
VERSION_MINOR=1

# VERSION_FULL is generated in version.mk and requires input VERSION_MAJOR and VERSION_MINOR

.PHONY: all
all: build tag push

.PHONY: clean
clean:
	docker rmi $(IMAGE_REPO)/$(IMAGE_NAME):latest -f

.PHONY: build
build:
	docker build --pull . -t $(IMAGE_REPO)/$(IMAGE_NAME):$(VERSION_FULL)

.PHONY: tag
tag:
	docker tag $(IMAGE_REPO)/$(IMAGE_NAME):$(VERSION_FULL) $(IMAGE_REPO)/$(IMAGE_NAME):latest

.PHONY: push
push:
	docker push $(IMAGE_REPO)/$(IMAGE_NAME):$(VERSION_FULL)
	docker push $(IMAGE_REPO)/$(IMAGE_NAME):latest
