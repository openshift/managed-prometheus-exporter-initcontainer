#!/bin/sh

if [[ -z "${QUAY_USER}" ]]; then
  echo "QUAY_USER Undefined. Aborting."
  exit 1
fi

if [[ -z "${QUAY_TOKEN}" ]]; then
  echo "QUAY_TOKEN Undefined. Aborting."
  exit 1
fi

make -C $(dirname $0)/.. QUAY_USER="${QUAY_USER}" QUAY_TOKEN="${QUAY_TOKEN}" IMAGE_REPOSITORY=app-sre docker-build docker-push
