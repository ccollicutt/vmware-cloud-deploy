#!/bin/bash
set -x
GENISO_VERSION=`genisoimage --version`
OVFTOOL_VERSION=`ovftool --version`
TMP_DIR=`mktemp -d`

# Arguments
# TODO: use getopts or something
IN_OVA=`readlink -f $1`
OUT_OVA=$2
USER_DATA=$3
META_DATA=$4
SEED_ISO_NAME="seed.iso"
SEED_ISO_PATH="${TMP_DIR}/${SEED_ISO_NAME}"

# Make the ISO
genisoimage -output ${SEED_ISO_PATH} -volid cidata -joliet -rock ${USER_DATA} ${META_DATA}

# Add the ISO to the OVA
cot add-disk ${SEED_ISO_PATH} ${IN_OVA} -o ${OUT_OVA} -f cloud_data -t cdrom -c ide

# Upload the new OVA
ovftool --overwrite ${OUT_OVA} vi://root:esAsh3m3x9@192.168.1.130