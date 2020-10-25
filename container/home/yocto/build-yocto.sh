#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
COMMAND=$1

# supress EULA confirmation at setup-environment
EULA=y

if [ "$COMMAND" = "fetch" ]; then
    BITBAKE_ARG='--runall=fetch -k'
    RUN_INSTALL_TOOLCHAIN=
else
    BITBAKE_ARG=
    RUN_INSTALL_TOOLCHAIN=y
fi

cd $SCRIPT_DIR/var-fsl-yocto
MACHINE=imx6ul-var-dart DISTRO=fsl-imx-fb . var-setup-release.sh -b build_fb
#MACHINE=imx6ul-var-dart DISTRO=fsl-framebuffer . var-setup-release.sh build_fb

TARGET_SSTATE_DIR=/home/shared/sstate-cache
TARGET_DL_DIR=/home/shared/downloads

rm -f conf/site.conf
cat $SCRIPT_DIR/site.conf >> conf/site.conf
if [ -e "$TARGET_SSTATE_DIR" ] ; then
    echo SSTATE_DIR=\"$TARGET_SSTATE_DIR\" >> conf/site.conf
fi
if [ -e "$TARGET_DL_DIR" ] ; then
    echo DL_DIR=\"$TARGET_DL_DIR\" >> conf/site.conf
fi

bitbake meta-toolchain $BITBAKE_ARG

if [ "$RUN_INSTALL_TOOLCHAIN" = "y" ]; then
    #./tmp/deploy/sdk/fsl-framebuffer-glibc-x86_64-meta-toolchain-armv7at2hf-neon-toolchain-2.6.2.sh -y
    #./tmp/deploy/sdk/fsl-imx-fb-glibc-x86_64-meta-toolchain-cortexa7t2hf-neon-toolchain-5.4-zeus.sh -y
    find ./tmp/deploy/sdk -name *.sh | xargs -n 1 -I "{}" sh -c "{} -y"
fi

bitbake core-image-minimal $BITBAKE_ARG
