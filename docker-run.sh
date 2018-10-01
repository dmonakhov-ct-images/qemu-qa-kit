#!/bin/bash

VOL=${PWD}/volume

IMAGE=qemu-qa-kit
_fail() {
    echo $1
    exit 1
}

_usage(){
    [ -z "$1" ] || echo $1
    echo "Usage: $0 "
    echo "	-W: mount DIR inside container at /qemu-qa-kit/volume, default: $VOL"
    echo "	-p: port forward for docker, example [2222:22] forward 22-container's port to host:2222" 
    echo "	--: delimiter, pass all options to qemu-qa-kit-run.sh"
    exit 1
}

OPTS=""
while (( $# >= 1 )); do
    case "$1" in
	-N) shift
	     IMAGE=$1
	     ;;
	-W) shift
	     VOL=$1
	     ;;
	-p) shift
	    OPTS="-p $1"
	     ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo 1>&2 "Invalid option: \"$1\""
	    _usage
	    ;;
	-h|--help)
	    _usage
	    ;;
    esac
    shift
done

[ -e "$VOL" ] || _usage "Volume directory: $VOL not found"

docker inspect  qemu-qa-kit $IMAGE
docker run --rm --device /dev/kvm:/dev/kvm \
       -v $VOL:/qemu-qa-kit/volume $OPTS \
       $IMAGE \
       qemu-qa-kit-run.sh $@
