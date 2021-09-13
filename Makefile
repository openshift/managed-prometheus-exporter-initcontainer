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
ifndef CONTAINER_ENGINE
$(error CONTAINER_ENGINE undefined)
endif

default: all

all: docker-build

.PHONY: clean docker-build docker-push build push
clean:
	$(CONTAINER_ENGINE) --config=$(CONTAINER_ENGINE_CONFIG_DIR) rmi $(IMG) $(IMG_LATEST) || true

build: docker-build
docker-build: clean
	$(CONTAINER_ENGINE) --config=$(CONTAINER_ENGINE_CONFIG_DIR) build -t $(IMG) -f Dockerfile .
	$(CONTAINER_ENGINE) --config=$(CONTAINER_ENGINE_CONFIG_DIR) tag $(IMG) $(IMG_LATEST)

push: docker-push
docker-push: build-image
	$(CONTAINER_ENGINE) --config=$(CONTAINER_ENGINE_CONFIG_DIR) push $(IMG)
	$(CONTAINER_ENGINE) --config=$(CONTAINER_ENGINE_CONFIG_DIR) push $(IMG_LATEST)
