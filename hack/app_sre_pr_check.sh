#!/bin/sh

make -C $(dirname $0)/.. IMAGE_REPOSITORY=app-sre docker-build
