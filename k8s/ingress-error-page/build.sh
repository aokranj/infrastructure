#!/bin/bash



CUR_DATETIME=`date +%Y%m%d-%H%M%S`
docker build \
    -t ingress-error-page:$CUR_DATETIME \
    -t ingress-error-page:latest \
    .
