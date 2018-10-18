#!/bin/bash

DIR=$(dirname $0)

TEST_NAME=alpine-virt-3.8.1-x86_64
IMAGE_NAME=image.iso
IMAGE_URL=http://dl-cdn.alpinelinux.org/alpine/v3.8/releases/x86_64/alpine-virt-3.8.1-x86_64.iso

mkdir -p work/$TEST_NAME

cat <<EOF > work/$TEST_NAME/cfg_seed.yaml

packages:
  - bash
  - gdisk
  - lvm
runcmd:
  - [ sh, -c 'echo HELLO WORLD']
  - sudo poweroff
EOF

[ -e "work/$TEST_NAME/$IMAGE_NAME" ] || curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL
bash -xe $DIR/../scripts/qemu-qa-kit-docker-run -W $(pwd)/work/$TEST_NAME -p 2222:22 -- -I /qemu-qa-kit/volume/$IMAGE_NAME -G -n 2 -m 512M
