#!/bin/bash -x

set -e

_fail(){
    echo $1
    exit 1
}
DIR=$(realpath $(dirname $0))

VOL_DIR="/qemu-qa-kit/volume"
BASE_IMAGE="$VOL_DIR/image.qcow2"
CI_IMAGE="$VOL_DIR/cfg_seed.iso"
LOG_DIR=$VOL_DIR/logs
MEM=1024
NUM_CPU=2
MACHINE="pc-q35-2.8"
PORT_FORWARD="tcp::2222-:22"
DATE=$(date +%Y%m%d%H%M)

_usage(){
    [ -z "$1" ] || echo $1
    echo "Usage: $0 "
    echo "	-I: base_image default: $BASE_IMAGE"
    echo "	-C: cloud-init image default: $CI_IMAGE"
    echo "	-G: Generate cloud init image, default: False"
    echo "	-n: num_cpu default: $NUM_CPU"
    echo "	-m: memory default: ${MEM}m"
    echo "	-M: emulate machine default: $MACHINE"
    echo "	-L: qemu-kvm execution log dir, default: $LOG_DIR"
    echo "	-p: port_forward_opts default: $PORT_FORWARD"
    echo "	--: delimiter, pass all options after this to qemu-kvm"
    exit 1
}
echo "Enter opts $# : all opts:$@"

while (( $# >= 1 )); do
    echo "loop opts $# : all opts:$@, handle: $1"
    case "$1" in
	-I) shift
	    BASE_IMAGE=$1
	    ;;
	-C) shift
	    CI_IMAGE=$1
	    ;;
	-G)
	    GEN_CI_IMAGE=t
	    ;;
	-n) shift
	    NUM_CPU=$1
	    ;;
	-p) shift
	    PORT_FORWARD="$1"
	    ;;
	-L) shift
	    LOG_DIR="$1"
	    ;;
	-M) shift
	    MACHINE=$1
	    ;;
	-m) shift
	    case "$1" in
		*[mM])
		    MEM=$(echo "$1" | sed -e 's/[mM]$//')
		    ;;
		*[gG])
		    temparg=$(echo "$1" | sed -e 's/[gG]$//')
		    MEM=$(expr "$temparg" \* 1024)
		    unset temparg
		    ;;
		*)
		    MEM="$1"
		    ;;
	    esac
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo 1>&2 "Invalid option: \"$1\""
	    _usage
	    ;;
	-h|--help)
	    _usage
	    ;;
    esac
    shift
done

[ -z "$BASE_IMAGE" ] && _fail "Usage: $0 <IMAGE_NAME> <list of quemu opts>"
[ -e "$BASE_IMAGE" ] || _usage "Cant open image $BASE_IMAGE"

if [ ! -e "$CI_IMAGE" ]
then
    echo "$CI_IMAGE not exists, forge generation"
    GEN_CI_IMAGE=t
fi
[ ! -z "$GEN_CI_IMAGE" ] && $DIR/cloud-init-gen.sh $DATE

mkdir -p $LOG_DIR
LOGFILE="$LOG_DIR/log.$DATE"
touch $LOGFILE
ln -sf $LOGFILE $LOG_DIR/log.latest

time qemu-system-x86_64 \
     -snapshot \
     -machine $MACHINE \
     -m $MEM  \
    -net nic -net user,hostfwd=$PORT_FORWARD \
    -drive file=$BASE_IMAGE,if=virtio \
    -cdrom $CI_IMAGE \
    -nographic \
    $@ | tee $LOGFILE

