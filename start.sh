#!/bin/bash

# Do CTRL+D whilst in the container to exit, or just write 'exit'.

IMG_NAME=kaleidescope-rust

docker build -t $IMG_NAME .
STATUS=$?

if [ $STATUS -eq 0 ]; then
    docker run -it --rm $IMG_NAME
else
    echo "ERROR: Couldn't build a new image. (Exit status: $STATUS)"
fi
