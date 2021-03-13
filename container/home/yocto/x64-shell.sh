#!/bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

# supress EULA confirmation at setup-environment
EULA=y

cd $SCRIPT_DIR/var-fsl-yocto
source sources/poky/oe-init-build-env build-x64

