SHELL := /usr/bin/env bash

# Include project specific values file
# Requires the following variables:
# - IMAGE_REGISTRY
# - IMAGE_REPOSITORY
# - IMAGE_NAME
# - VERSION_MAJOR
# - VERSION_MINOR
include project.mk

# Validate variables in project.mk exist
ifndef IMAGE_REGISTRY
$(error IMAGE_REGISTRY is not set; check project.mk file)
endif
ifndef IMAGE_REPOSITORY
$(error IMAGE_REPOSITORY is not set; check project.mk file)
endif
ifndef IMAGE_NAME
$(error IMAGE_NAME is not set; check project.mk file)
endif
ifndef VERSION_MAJOR
$(error VERSION_MAJOR is not set; check project.mk file)
endif
ifndef VERSION_MINOR
$(error VERSION_MINOR is not set; check project.mk file)
endif

# Generate version and tag information from inputs
COMMIT_NUMBER=$(shell git rev-list `git rev-list --parents HEAD | egrep "^[a-f0-9]{40}$$"`..HEAD --count)
CURRENT_COMMIT=$(shell git rev-parse --short=8 HEAD)
VERSION_FULL=$(VERSION_MAJOR).$(VERSION_MINOR).$(COMMIT_NUMBER)-$(CURRENT_COMMIT)

IMG ?= $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY)/$(IMAGE_NAME):$(VERSION_FULL)
IMG_LATEST ?= $(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY)/$(IMAGE_NAME):latest


.PHONY: default
default: build

.PHONY: all
all: build tag push

.PHONY: clean
clean:
	docker rmi $(IMG) -f
	docker rmi $(IMG_LATEST) -f

.PHONY: build
build:
	docker build --pull --build-arg UPSTREAMORG=$(IMAGE_REPOSITORY) -t $(IMG) .
	docker tag $(IMG) $(IMG_LATEST)

.PHONY: push
push:
	docker push $(IMG)
	docker push $(IMG_LATEST
