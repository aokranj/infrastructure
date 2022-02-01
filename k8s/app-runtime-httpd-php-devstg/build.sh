#!/bin/bash



CUR_DATETIME=`date +%Y%m%d-%H%M%S`
docker build \
    -t app-runtime-httpd-php:devstg-$CUR_DATETIME \
    -t app-runtime-httpd-php:devstg-latest \
    .
