#!/bin/bash

TIMESTAMP=$(date +%Y-%m-%d_%H_%M_%S)
SCRIPT_DIR=$(cd $(dirname $0); pwd)
IMAGE_TOP=$SCRIPT_DIR/var-fsl-yocto/build_fb/tmp/work/imx6ul_var_dart-poky-linux-gnueabi
find $IMAGE_TOP/custom-test-image/1.0-r0/rootfs -type f > log-rootfs-$TIMESTAMP.txt
