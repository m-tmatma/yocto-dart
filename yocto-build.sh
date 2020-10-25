#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
COMMAND=$1

source ${SCRIPT_DIR}/common-variable.sh

HOST_DOCKER_HOME=$SCRIPT_DIR/container/home/yocto
TARGET_HOME=/home/yocto

REMOTE_URL=$(git remote get-url origin)
BRANCH_NAME=$(git name-rev --name-only HEAD | sed "s/\W/_/g")
CONTAINER_NAME=$(basename $REMOTE_URL)--${BRANCH_NAME}--$(basename $SCRIPT_DIR)__$(git rev-parse --short HEAD)__$(date "+%Y%m%d-%H%M%S")

HOST_DOCKER_OPT=$SCRIPT_DIR/container/opt
TARGET_OPT=/opt

HOST_SSTATE_DIR=$HOME/shared/sstate-cache
HOST_DL_DIR=$HOME/shared/downloads
TARGET_SSTATE_DIR=/home/shared/sstate-cache
TARGET_DL_DIR=/home/shared/downloads

mkdir -p $HOST_DOCKER_HOME
mkdir -p $HOST_DOCKER_OPT
mkdir -p $HOST_SSTATE_DIR
mkdir -p $HOST_DL_DIR

docker run --rm -u yocto:yocto \
        --name $CONTAINER_NAME \
	-v $HOST_SSTATE_DIR:$TARGET_SSTATE_DIR \
	-v $HOST_DOCKER_OPT:$TARGET_OPT \
	-v $HOST_DL_DIR:$TARGET_DL_DIR \
	-v $HOST_DOCKER_HOME:$TARGET_HOME \
	-w $TARGET_HOME $DOCKERIMAGE $TARGET_HOME/build-yocto.sh $COMMAND


