#!/bin/sh

tmpdir=$(mktemp -d)


ROOT_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeIY94CLqpCapdzsMSbWmax1HUDdnrOJGH4rzMutJIG robot-dmon-ci@dmws.yandex.net"

INSTANCE_ID=id-123
INSTANCE_HOSTNAME=test-host
RUNSCRIPT=cloud-init-runscript

cat <<EOF > $tmpdir/user-data
#cloud-config
debug: True
disable_root: False
ssh_deletekeys: False
ssh_pwauth: True
ssh_authorized_keys:
  - ${ROOT_SSH_KEY}
  
# users:
#   - name: clouduser
#     gecos: User
#     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
#     groups: users
#     ssh_pwauth: True
#     ssh-authorized-keys:
#       - ssh-rsa XXXXXX
chpasswd:
  list: |
    root:linux
  expire: False
EOF
[ -e "$RUNSCRIPT" ] && cat $RUNSCRIPT >> $tmpdir/user-data

cat <<EOF > $tmpdir/meta-data
instance-id: ${INSTANCE_ID}
local-hostname: ${INSTANCE_HOSTNAME}
EOF

# generate the seed images

#genisoimage -output seed.img -volid cidata -joliet -rock $tmpdir/
genisoimage -output seed.iso -volid cidata -joliet -rock $tmpdir/
# for vfat
#truncate --size 2M seed-vfat.img
#mkfs.vfat -n cidata seed-vfat.img
#mcopy -oi seed-vfat.img $tmpdir/user-data $tmpdir/meta-data ::

rm -rf $tmpdir

# then try:
# qemu-system-x86_64 -m 512  -net nic -net user,hostfwd=tcp::2222-:22 -drive file=SLE12-Base.qcow2,if=virtio -drive file=seed.img,if=virtio
#qemu-system-x86_64 -m 512  -net nic -net user,hostfwd=tcp::2222-:22 -drive file=SLE12-Base.qcow2,if=virtio -drive file=seed.img,if=virtio
#qemu-kvm -name atomic-cloud-host -m 768 -hda fedora-atomic-rawhide-20141008.0.qcow2 -cdrom atomic01-cidata.iso -netdev bridge,br=virbr0,id=net0 -device virtio-net-pci,netdev=net0 -display sdl

