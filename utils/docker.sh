#!/bin/bash
#
set -ex

# Environment

export AOSP_VOL=/home/android_source/
export AOSP_EXTRA_ARGS="-v $(cd $(dirname $0) && pwd -P)/$(basename $0):/usr/local/bin/run.sh:ro"
export AOSP_IMAGE="kylemanna/aosp:7.0-nougat"

# Override from environment

AOSP_IMAGE=${AOSP_IMAGE:-kylemanna/aosp}
AOSP_ARGS=${AOSP_ARGS:---rm -it}

AOSP_VOL=${AOSP_VOL:-~/aosp-root}
AOSP_VOL=${AOSP_VOL%/} # Trim trailing slash if needed
AOSP_VOL_AOSP=${AOSP_VOL_AOSP:-$AOSP_VOL/aosp}
AOSP_VOL_AOSP=${AOSP_VOL_AOSP%/} # Trim trailing slash if needed
AOSP_VOL_CCACHE=${AOSP_VOL_CCACHE:-$AOSP_VOL/ccache}
AOSP_VOL_CCACHE=${AOSP_VOL_CCACHE%/} # Trim trailing slash if needed

# Convenience function
function aosp_create_dir_if_needed {
  directory=$1
  msg="aosp: Checking if $directory exists"
  echo "$msg"
  if [ ! -d "$directory" ]; then
    echo "$msg - unexistent"
    msg="Creating $directory"
    echo "$msg"
    mkdir -p $directory
  fi
  echo "$msg - ok"
}

# Create AOSP_VOL_AOSP
aosp_create_dir_if_needed $AOSP_VOL_AOSP
aosp_create_dir_if_needed $AOSP_VOL_CCACHE

uid=$(id -u)

# Set uid and gid to match host current user as long as NOT root
if [ $uid -ne "0" ]; then
    AOSP_HOST_ID_ARGS="-e USER_ID=$uid -e GROUP_ID=$(id -g)"
fi

if [ -S "$SSH_AUTH_SOCK" ]; then
    SSH_AUTH_ARGS="-v $SSH_AUTH_SOCK:/tmp/ssh_auth -e SSH_AUTH_SOCK=/tmp/ssh_auth"
fi

echo ""

# Custom docker ENTRYPOINT
ENTRYPOINT_CUSTOM="-v $(cd $(dirname $0) && pwd -P)/docker_entrypoint_custom.sh:/root/docker_entrypoint.sh"

docker run $AOSP_ARGS $AOSP_HOST_ID_ARGS $SSH_AUTH_ARGS $AOSP_EXTRA_ARGS $ENTRYPOINT_CUSTOM \
    -v "$AOSP_VOL_AOSP:/aosp" -v "$AOSP_VOL_CCACHE:/tmp/ccache" \
    $AOSP_IMAGE
