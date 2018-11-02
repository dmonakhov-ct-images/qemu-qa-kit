#!/bin/bash -xe

set -e
# Load dynamic config
echo /mnt/in/job.config
cat /mnt/in/job.config

. /mnt/in/job.config

# Run script
echo Hello world
echo "external JOB_ARG1: $JOB_ARG1"
printenv > /mnt/out/results/printenv.log
lsblk  > /mnt/out/results/lsblk.log
lsb_release -a > /mnt/out/results/lsb_release.log
