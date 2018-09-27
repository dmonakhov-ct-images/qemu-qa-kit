#!/bin/bash

# qemu-system-x86_64 -m 512  -net nic -net user,hostfwd=tcp::2222-:22 -drive file=SLE12-Base.qcow2,if=virtio -drive file=seed.img,if=virtio

function _fail(){
    echo $1
    exit 1
}

IMG_NAME=$1

[ -z "$IMG_NAME" ] && _fail "Usage: $s [IMAGE_NAME]"
kvm -snapshot \
    -m 1024  \
    -net nic -net user,hostfwd=tcp::2222-:22 \
    -drive file=$1,if=virtio \
    -cdrom seed.iso \
    -nographic
    #-display sdl

#qemu-kvm -name test -m 768 -hda fedora-atomic-rawhide-20141008.0.qcow2 -cdrom seed.iso -netdev bridge,br=virbr0,id=net0 -device virtio-net-pci,netdev=net0 -display sdl

