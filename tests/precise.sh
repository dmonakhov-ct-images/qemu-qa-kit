#!/bin/bash

DIR=$(dirname $0)

TEST_NAME=precise-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

mkdir -p work/$TEST_NAME

cat <<EOF > work/$TEST_NAME/cfg_seed.yaml
repo_update: true
packages:
  - emacs-nox
  - gdisk
  - lvm
runcmd:
  - [ sh, -c 'echo HELLO WORLD']
  - sudo systemctl enable lvm
  - sudo systemctl start lvm
  - sudo poweroff
EOF

[ -e "work/$TEST_NAME/$IMAGE_NAME" ] || curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL
bash -xe ./scripts/qemu-qa-kit-docker-run -W $(pwd)/work/$TEST_NAME -- -G -n 2 -m 512M
