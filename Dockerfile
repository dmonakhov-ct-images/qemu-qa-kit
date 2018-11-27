# This Dockerfile creates a qemu-kvm runtime environment
#
# For reasonable performance one needs to grant access to /dev/kvm
#
# Example usage:
# docker run --device /dev/kvm:/dev/kvm \
#            -v /tmp/volume:/opt/qemu-qa-kit/volume \
#	  	 qemu-qa-kit /opt/qemu-qa-kit/volume/img
#
# VERSION 0.1
FROM alpine

RUN apk add --no-cache --update \
	bash \
#	e2fsprogs-libs \
#	e2fsprogs \
	e2fsprogs-extra \
	curl \
#	util-linux \
        cdrkit \
	qemu-img \
	qemu-system-x86_64 \
	tar \
	xz && \
	mkdir -p /qemu-qa-kit/volume

COPY scripts /qemu-qa-kit
COPY examples /qemu-qa-kit/examples
ENV PATH="/qemu-qa-kit:${PATH}"
