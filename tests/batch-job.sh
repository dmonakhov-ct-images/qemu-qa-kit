#!/bin/bash

DIR=$(dirname $0)

TEST_NAME=bionic-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

mkdir -p work/$TEST_NAME

[ -e "work/$TEST_NAME/$IMAGE_NAME" ] || curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL
$DIR/../docker-run.sh -it -W $(pwd)/work/$TEST_NAME -it --job examples/batch_job
