#!/bin/sh -x

tmpdir=$(mktemp -d)
VOL_DIR="/qemu-qa-kit/volume"
DATE=$(date +%Y%m%d%H%M)

TAG=${1:-$DATE}
CI_IMAGE=${2:-$VOL_DIR/cfg_seed.iso}
AUTHORIZED_KEY_FILE={$3:-$VOL_DIR/ssh_authorized_keys}
CFG_FOOTER=${4:-$VOL_DIR/cfg_seed.yaml}
[ -e "$AUTHORIZED_KEY_FILE" ] &&  AUTHORIZED_KEY=$(cat $AUTHORIZED_KEY_FILE)

INSTANCE_ID=id-$TAG
INSTANCE_HOSTNAME=qemu-qa-kit-$TAG


cat <<EOF > $tmpdir/user-data
#cloud-config
debug: True
disable_root: False
ssh_deletekeys: False
ssh_pwauth: True
ssh_authorized_keys:
  - ${AUTHORIZED_KEY}
  
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
[ -e "$CFG_FOOTER" ] && cat $CFG_FOOTER >> $tmpdir/user-data

cat <<EOF > $tmpdir/meta-data
instance-id: ${INSTANCE_ID}
local-hostname: ${INSTANCE_HOSTNAME}
EOF

# generate the seed images
genisoimage -output $CI_IMAGE -volid cidata -joliet -rock $tmpdir/

rm -rf $tmpdir

