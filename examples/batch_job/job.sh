#!/bin/bash -xe

# Load dynamic config
. /mnt/in/job.config

# Run script
echo Hello world
printenv > /mnt/out/results/printenv.log
lsblk  > /mnt/out/results/lsblk.log
lsb_release -a > /mnt/out/results/lsb_release.log
