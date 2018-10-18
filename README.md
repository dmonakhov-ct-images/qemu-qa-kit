# qemu-qa-kit
QEMU cloud-init qa kit

This utility allow to run jobs with standard cloud-init images. All scripts are packed as docker image.

### Build docker image from scratch
```
docker build -t qemu-qa-kit .
```

## Usage example
## Get execution script from docker container
```
docker run -v $(pwd):/mnt --rm qemu-qa-kit cp -v /qemu-qa-kit/qemu-qa-kit-docker-run /mnt
```

### Download and execute ubuntu-bionic VM in interactive mote (user=root, passws=linux)
```
./tests/bionic-interactive.sh
```
Run basic batch job inside VM
```
./tests/batch-job.sh
<SNIP>
real    0m29.055s
user    0m16.322s
sys     0m9.589s
Results are available at: ./volume/results-201810181452.tar.xz
Log file: ./qemu-qa-kit/volume/logs/log.201810181452
Results : ./qemu-qa-kit/volume/results-201810181452.tar.xz

```
