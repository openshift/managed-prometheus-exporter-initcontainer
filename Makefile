SHELL := /usr/bin/env bash

# Include project specific values file
# Requires the following variables:
# - IMAGE_REPO
# - IMAGE_NAME
# - VERSION_MAJOR
# - VERSION_MINOR
include project.mk

# Validate variables in project.mk exist
ifndef IMAGE_REPO
$(error IMAGE_REPO is not set; check project.mk file)
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
BUILD_DATE=$(shell date -u +%Y-%m-%d)
CURRENT_COMMIT=$(shell git rev-parse --short=8 HEAD)
VERSION_FULL=v$(VERSION_MAJOR).$(VERSION_MINOR).$(COMMIT_NUMBER)-$(BUILD_DATE)-$(CURRENT_COMMIT)

.PHONY: default
default: build

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
