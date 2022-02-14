#!/bin/bash



CUR_DATETIME=`date +%Y%m%d-%H%M%S`
docker build \
    -t aokranj/mariadb:10.5-$CUR_DATETIME \
    -t aokranj/mariadb:10.5-latest \
    .
