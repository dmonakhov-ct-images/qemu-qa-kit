# This Dockerfile creates a kvm-xfstests runtime environment
#
# For reasonable performance one needs to grant access to /dev/kvm
#
# Example usage:
# docker run --device /dev/kvm:/dev/kvm \
#            -v /my-kernel:/tmp tytso/kvm-xfstests \
#	  	 kvm-xfstests --kernel /tmp/vmlinuz smoke
#
# VERSION 0.2
FROM alpine

RUN apk add --no-cache --update \
#	bash \
#	e2fsprogs-libs \
#	e2fsprogs \
#	e2fsprogs-extra \
#	curl \
#	util-linux \
        cdrkit \
	qemu-img \
	qemu-system-x86_64 \
	tar
