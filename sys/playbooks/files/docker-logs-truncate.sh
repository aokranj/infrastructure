#!/bin/sh

for F in `find /var/lib/docker/containers -type f -name '*.log' -size +1G`; do
    echo -n "" > $F
    echo "Truncated: $F"
done
