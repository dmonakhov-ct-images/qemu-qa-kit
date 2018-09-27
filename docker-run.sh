#!/bin/sh

VOL=${PWD}/volume
#IMAGE=qemu-qa-kit:latest
IMAGE=qemu-qa-kit:test
_fail() {
    echo $1
    exit 1
}

[ -e "$VOL" ] || _fail "$VOL not exits"

docker run --rm --device /dev/kvm:/dev/kvm \
       -v $VOL:/opt/qemu-qa-kit/volume \
       $IMAGE \
       qemu-qa-kit-run.sh $@
