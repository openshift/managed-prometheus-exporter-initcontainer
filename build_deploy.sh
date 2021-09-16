#!/bin/sh

if [[ -z "${QUAY_USER}" ]]; then
  echo "QUAY_USER Undefined. Aborting."
  exit 1
fi

if [[ -z "${QUAY_TOKEN}" ]]; then
  echo "QUAY_TOKEN Undefined. Aborting."
  exit 1
fi

make IMAGE_REPOSITORY=app-sre build push
