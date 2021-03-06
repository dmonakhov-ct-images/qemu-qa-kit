#!/bin/bash

DIR=$(dirname $0)

TEST_NAME=bionic-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

mkdir -p work/$TEST_NAME
cat <<EOF > work/$TEST_NAME/cfg_seed.yaml
repo_update: true
packages:
  - emacs-nox
  - gdisk
  - lvm
EOF

[ -e "work/$TEST_NAME/$IMAGE_NAME" ] || curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL
bash -xe $DIR/../scripts/qemu-qa-kit-docker-run -it -W $(pwd)/work/$TEST_NAME -- -G -n 2 -m 512M
