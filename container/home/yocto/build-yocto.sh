#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
ACTION=$1
if [ -z "$ACTION" ]; then
    ACTION=build
fi

# supress EULA confirmation at setup-environment
EULA=y

cd $SCRIPT_DIR/var-fsl-yocto
MACHINE=imx6ul-var-dart DISTRO=fsl-imx-fb . var-setup-release.sh -b build_fb
#MACHINE=imx6ul-var-dart DISTRO=fsl-framebuffer . var-setup-release.sh build_fb

# TARGET_SSTATE_DIR=/home/shared/sstate-cache
# TARGET_DL_DIR=/home/shared/downloads
TARGET_SOURCE_MIRROR_DIR=/home/shared/SOURCE_MIRROR_URL
rm -f conf/site.conf
# if [ -e "$TARGET_SSTATE_DIR" ] ; then
#     echo SSTATE_DIR=\"$TARGET_SSTATE_DIR\" >> conf/site.conf
# fi
# if [ -e "$TARGET_DL_DIR" ] ; then
#     echo DL_DIR=\"$TARGET_DL_DIR\" >> conf/site.conf
# fi
echo SOURCE_MIRROR_URL = \"file:///$TARGET_SOURCE_MIRROR_DIR\" >> conf/site.conf
echo INHERIT += \"own-mirrors\"                                >> conf/site.conf

if [ "$ACTION" = "makecache" ]; then
    echo DL_DIR = \"$TARGET_SOURCE_MIRROR_DIR\"                    >> conf/site.conf
    echo BB_GENERATE_MIRROR_TARBALLS = \"1\"                       >> conf/site.conf
fi

if [ "$ACTION" = "fetch" -o "$ACTION" = "makecache" ]; then
    bitbake meta-toolchain --runall=fetch
    bitbake core-image-minimal --runall=fetch
elif [ "$ACTION" = "build" ]; then
    bitbake meta-toolchain
    #./tmp/deploy/sdk/fsl-framebuffer-glibc-x86_64-meta-toolchain-armv7at2hf-neon-toolchain-2.6.2.sh -y
    #./tmp/deploy/sdk/fsl-imx-fb-glibc-x86_64-meta-toolchain-cortexa7t2hf-neon-toolchain-5.4-zeus.sh -y

    bitbake core-image-minimal
else
	echo usage:
	echo $0 build
	echo $0 fetch
	echo $0 makecache
	exit 1
fi
