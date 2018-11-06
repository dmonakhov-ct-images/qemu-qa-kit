#!/bin/bash

set -e

_fail(){
    echo $1
    exit 1
}
DIR=$(realpath $(dirname $0))
VOL_DIR="/qemu-qa-kit/volume"
BASE_IMAGE="$VOL_DIR/image.qcow2"
CI_IMAGE="$VOL_DIR/cfg_seed.iso"
AUTHORIZED_KEY_FILE=$VOL_DIR/ssh_authorized_keys
CFG_FOOTER=$VOL_DIR/cfg_seed.yaml
LOG_DIR=$VOL_DIR/logs
MEM=1024
NUM_CPU=2
MACHINE="pc-q35-2.8"
PORT_FORWARD=",hostfwd=tcp::22-:22"
RUN_ID=$(date +%Y%m%d%H%M)
CONSOLE=" -serial mon:stdio"
#CONSOLE=" -chardev stdio,id=console,signal=off -serial chardev:console"
TMPDIR=$(mktemp -d)

_prep_image()
{
    local img=$1
    local clean=${2:-Y}
    local size=${3:-10G}
    local fmt=${4:-qcow2}

    [ "$clear" == "Y" ] && [ -e $img ] && unlink $img
    qemu-img create -f $fmt $img $size
}

_prep_job_data()
{
    local in_dir=$1
    local in_img=$2
    local out_img=$3

    if [ -e ${in_dir}/job_seed.yaml ]
    then
	job_seed=${in_dir}/job_seed.yaml
    else
	job_seed=$DIR/examples/job_seed.yaml
    fi

    touch $TMPDIR/job.config
    for env in $JOB_ARGS
    do
	echo "$env" >> $TMPDIR/job.config
    done
    tar  -vc -C $(dirname $job_seed) $(basename $job_seed) \
	 -C $in_dir . \
	 -C $TMPDIR job.config > $in_img

    _prep_image $out_img Y 10G raw
    mkfs.ext4 -qF $out_img

    JOB_DEV="$JOB_DEV -drive format=raw,file=$VOL_DIR/disks/job_in.img,if=ide,snapshot=on"
    JOB_DEV="$JOB_DEV -drive format=raw,file=$VOL_DIR/disks/job_out.img,if=ide"

    echo "Job mode requested: Force cloud-init image $CI_IMAGE generation"
    GEN_CI_IMAGE=t
    CFG_FOOTER=$job_seed
}

_get_job_results()
{
    local img=$1
    local resultfile=$2

    debugfs -R "dump /results.tar.xz $resultfile" $img
}


_usage(){
    [ -z "$1" ] || echo $1
    echo "Usage: $0 "
    echo "	-I: base_image default: $BASE_IMAGE"
    echo "	-G: Generate cloud init image, default: False"
    echo "	-C: cloud-init image default: $CI_IMAGE"
    echo "      -K: ssh_authorized key file default: $AUTHORIZED_KEY_FILE"
    echo "      -F: cloud-init-footer file default: $CFG_FOOTER"
    echo "	-n: num_cpu default: $NUM_CPU"
    echo "	-m: memory default: ${MEM}m"
    echo "	-M: emulate machine default: $MACHINE"
    echo "	-L: qemu-kvm execution log dir, default: $LOG_DIR"
    echo "	--keep: keep temporal data"
    echo "	-U: Unpack results archive"
    echo "	-p: port_forward_opts default: $PORT_FORWARD"
    echo "	--job/-J: Directory with batch job configuration, see $DIR/examples/batch_job"
    echo "	--job-arg: Job arguments, will be available inside vm at /mnt/in/job.config file example: MY_VAR=my-key"
    echo "	--run-id: Run environment id, default is generated as: ${RUN_ID}"
    echo "	--: delimiter, pass all options after this to qemu-kvm"
    exit 1
}

while (( $# >= 1 )); do
    case "$1" in
	-I) shift
	    BASE_IMAGE=$1
	    ;;
	-G)
	    GEN_CI_IMAGE=t
	    ;;
	-C) shift
	    CI_IMAGE=$1
	    ;;
	-K) shift
	    AUTHORIZED_KEY_FILE=$1
	    ;;
	--keep)
	    KEEP_TMP='Y'
	    ;;
	-F) shift
	    CFG_FOOTER=$1
	    ;;
	-n) shift
	    NUM_CPU=$1
	    ;;
	-p) shift
	    PORT_FORWARD=",hostfwd=$1"
	    ;;
	--no-hostfwd)
	    PORT_FORWARD=""
	    ;;
	-U)
	    UNPACK_RESFILE='Y'
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
	-J|--job) shift
		  JOB="$1"
		  ;;
	--job-arg) shift
		   JOB_ARGS="$JOB_ARGS $1"
		   ;;
	--run-id) shift
	    RUN_ID="$1"
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

mkdir -m 777 -p $VOL_DIR/disks

[ -z "$BASE_IMAGE" ] && _fail "Usage: $0 <IMAGE_NAME> <list of quemu opts>"
[ -e "$BASE_IMAGE" ] || _usage "Cant open image $BASE_IMAGE"
if [ ! -z "$JOB" ];then
    [ -d "$JOB" ] || _usage "Job directory: $JOB not found"
    _prep_job_data $JOB $VOL_DIR/disks/job_in.img $VOL_DIR/disks/job_out.img
fi

if [ ! -e "$CI_IMAGE" ]
then
    echo "$CI_IMAGE not exists, forge generation"
    GEN_CI_IMAGE=t
fi
[ ! -z "$GEN_CI_IMAGE" ] && $DIR/cloud-init-gen.sh ${RUN_ID} $CI_IMAGE $AUTHORIZED_KEY_FILE $CFG_FOOTER

mkdir -m 777 -p $LOG_DIR
LOGFILE="$LOG_DIR/log.${RUN_ID}"
touch $LOGFILE
chmod 666 $LOGFILE
ln -sf $(basename $LOGFILE) $LOG_DIR/log.latest
time qemu-system-x86_64 -enable-kvm \
     -machine $MACHINE \
     -m $MEM  \
     -net nic -net user$PORT_FORWARD \
     -drive file=$BASE_IMAGE,if=ide,snapshot=on \
     -cdrom $CI_IMAGE \
     $JOB_DEV \
     $XDEV \
     -vga none -nographic \
     $CONSOLE \
     $@ | tee $LOGFILE

if [ ! -z "$JOB" ]
then
    RESFILE=$VOL_DIR/results-${RUN_ID}.tar.xz
    _get_job_results $VOL_DIR/disks/job_out.img $RESFILE
    ln -sf $(basename $RESFILE) $VOL_DIR/results-latest.tar.xz
    chmod 666 $RESFILE
    echo "Results are available at: $RESFILE"
    if [ ! -z "$UNPACK_RESFILE" ]
    then
	[ -d $VOL_DIR/results ] && rm -rf $VOL_DIR/results
	tar Jxf $RESFILE -C $VOL_DIR
	echo "Unpacked results are available at: $VOL_DIR/results"
    fi
    [ -z "$KEEP_TMP" ]  && rm -rf $VOL_DIR/disks/job_in.img $VOL_DIR/disks/job_out.img
fi
rm -rf $TMPDIR
