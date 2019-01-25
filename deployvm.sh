#!/bin/bash

# Temp directory to store modified OVA
TMP_DIR=`mktemp -d`
trap "{ rm -rf $TMP_DIR; }" EXIT

function print_help {	
  echo "Options:"
  echo "  -ova,--ova=<ova file>             - required - The seed OVA file"
  echo "  -meta,--metadata=<meta-data file> - required - The meta-data file for cloudinit"
  echo "  -user,--userdata=<user-data file> - required - The user-data file for cloudinit"
  echo "  -name,--name=<instance name>      - optional - The name the instance will be given in VMWare"
  echo "  -server,--server=<IP or hostname> - optional - ESXi Server IP or hostname"
  echo "  -username,--username=<username>   - optional - ESXi Username"
  echo "  -pass,--password=<password>       - optional - ESXi Password"
}

function check_arg {
    [ -z "$1" ] && echo "$2" && print_help && exit 1
}

# $1 = tool name
# $2 = command to check exists
function check_tool {
  echo "Checking for ${1} by running \"${2}\"..."
  $2
  if [ $? -eq 0 ]; then
    echo OK
  else
    echo Command failed - looks like you need to install $1
  fi
}

GENISO_CHECK_CMD="genisoimage -version"
OVFTOOL_CHECK_CMD="ovftool --version"
COT_CHECK_CMD="cot --version"
TMP_DIR=`mktemp -d`
SEED_ISO_NAME="seed.iso"
SEED_ISO_PATH="${TMP_DIR}/${SEED_ISO_NAME}"

for i in "$@"
do
case $i in
  -ova=*|--ova=*)
  IN_OVA="${i#*=}"
  IN_OVA=`readlink -f ${IN_OVA}`
  shift # past argument=value
  ;;
  -meta=*|--metadata=*)
  META_DATA="${i#*=}"
    shift # past argument=value
  ;;
  -user=*|--userdata=*)
  USER_DATA="${i#*=}"
  shift # past argument=value
  ;;
  -name=*|--instancename=*)
  INSTANCE_NAME="${i#*=}"
  shift # past argument=value
  ;;
  -server=*|--server=*)
  SERVER="${i#*=}"
  shift # past argument=value
  ;;
  -username=*|--username=*)
  VUSER="${i#*=}"
  shift # past argument=value
  ;;
  -pass=*|--password=*)
  PASS="${i#*=}"
  shift # past argument=value
  ;;
  *)
    #Unknown option
    echo "Unknown option ${i}"
    print_help
  ;;
esac
done

# Check that mandatory args are present
check_arg "$IN_OVA" "The OVA must be specified"
check_arg "$META_DATA" "The meta-data file must be specified"
check_arg "$USER_DATA" "The meta-data file must be specified"
check_arg "$SERVER" "The server must be specified"

# Build necessary args from options
if [ ! -z "$VUSER" ] || [ ! -z "$PASS" ]; then
  CREDS="${VUSER}:${PASS}@"
fi
if [ -z "$INSTANCE_NAME" ]; then
  filename=$(basename -- "$IN_OVA")
  INSTANCE_NAME="${filename%.*}"-`date +%s%3N`.ova
else
  INSTANCE_NAME=${INSTANCE_NAME}.ova
fi  

# Check for tools that we need
check_tool "genisoimage" "${GENISO_CHECK_CMD}"
check_tool "VMWare OVF Tool (ovftool)" "${OVFTOOL_CHECK_CMD}"
check_tool "Common OVF Tool (cot)" "${COT_CHECK_CMD}"

set -x
# Make the ISO
genisoimage -output ${SEED_ISO_PATH} -volid cidata -joliet -rock ${USER_DATA} ${META_DATA}

# Add the ISO to the OVA
cot add-disk ${SEED_ISO_PATH} ${IN_OVA} -o ${TMP_DIR}/${INSTANCE_NAME} -f cloud_data -t cdrom -c ide

# Upload the new OVA
ovftool --overwrite ${TMP_DIR}/${INSTANCE_NAME} vi://${CREDS}${SERVER}


