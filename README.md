# qemu-qa-kit
QEMU cloud-init qa kit

This utility allow to run jobs with standard cloud-init images. All scripts are packed as docker image.

###Build docker image from scratch
```
docker build -t qemu-qa-kit .
```

Build docker image
## Usage example
### Download and execute ubuntu-bionic VM in interactive mote (user=root, passws=linux)
```
./tests/bionic-interactive.sh
```
Run basic batch job inside VM
```
./tests/batch-job.sh
```
