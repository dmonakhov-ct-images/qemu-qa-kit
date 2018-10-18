TEST_NAME=alpine-virt-3.8.1-x86_64
IMAGE_NAME=image.iso
IMAGE_URL=http://dl-cdn.alpinelinux.org/alpine/v3.8/releases/x86_64/alpine-virt-3.8.1-x86_64.iso
mkdir -p work/$TEST_NAME
curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL

TEST_NAME=bionic-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
mkdir -p work/$TEST_NAME
curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL

TEST_NAME=precise-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img
mkdir -p work/$TEST_NAME
curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL

TEST_NAME=trusty-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
mkdir -p work/$TEST_NAME
curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL

TEST_NAME=xenial-server-cloudimg-amd64
IMAGE_NAME=image.qcow2
IMAGE_URL=http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
mkdir -p work/$TEST_NAME
curl -o work/$TEST_NAME/$IMAGE_NAME $IMAGE_URL
