# Project specific values
IMAGE_REGISTRY ?= quay.io
IMAGE_REPOSITORY ?= $(USER)
IMAGE_NAME=managed-prometheus-exporter-initcontainer

VERSION_MAJOR=0
VERSION_MINOR=1

CONTAINER_ENGINE=$(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)

#TODO: Fix for podman?
CONTAINER_ENGINE_CONFIG_DIR=.docker

# Generate version and tag information from inputs
COMMIT_NUMBER=$(shell git rev-list `git rev-list --parents HEAD | egrep "^[a-f0-9]{40}$$"`..HEAD --count)
CURRENT_COMMIT=$(shell git rev-parse --short=8 HEAD)
VERSION_FULL=$(VERSION_MAJOR).$(VERSION_MINOR).$(COMMIT_NUMBER)-$(CURRENT_COMMIT)

IMG ?= $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY)/$(IMAGE_NAME):$(VERSION_FULL)
IMG_LATEST ?= $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY)/$(IMAGE_NAME):latest
