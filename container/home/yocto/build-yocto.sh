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
if [ -n "$REMOTE_SOURCE_MIRROR" ]; then
    echo SOURCE_MIRROR_URL = \"$REMOTE_SOURCE_MIRROR\"             >> conf/site.conf

    echo -----------------------------------------------------------
    echo MIRROR_URL is used
    echo $REMOTE_SOURCE_MIRROR
    echo -----------------------------------------------------------
else
    echo SOURCE_MIRROR_URL = \"file:///$TARGET_SOURCE_MIRROR_DIR\" >> conf/site.conf

    echo -----------------------------------------------------------
    echo local mirror is set
    echo $TARGET_SOURCE_MIRROR_DIR
    echo -----------------------------------------------------------
fi
echo INHERIT += \"own-mirrors\"                                >> conf/site.conf

if [ "$ACTION" = "makecache" ]; then
    echo DL_DIR = \"$TARGET_SOURCE_MIRROR_DIR\"                    >> conf/site.conf
    echo BB_GENERATE_MIRROR_TARBALLS = \"1\"                       >> conf/site.conf

    echo -----------------------------------------------------------
    echo makecache $TARGET_SOURCE_MIRROR_DIR
    echo -----------------------------------------------------------
fi

if [ "$ACTION" = "fetch" -o "$ACTION" = "makecache" ]; then
    bitbake meta-toolchain --runall=fetch -f
    bitbake core-image-minimal --runall=fetch -f
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

if [ -n "$REMOTE_SOURCE_MIRROR" ]; then
    echo -----------------------------------------------------------
    echo remote mirror: $REMOTE_SOURCE_MIRROR
    echo -----------------------------------------------------------
else
    echo -----------------------------------------------------------
    echo local cache: target $TARGET_SOURCE_MIRROR_DIR
    echo local cache: host $HOST_SOURCE_MIRROR_URL
    if [ "$ACTION" = "makecache" ]; then
        echo created local cache at $TARGET_SOURCE_MIRROR_DIR
    fi
    echo -----------------------------------------------------------
fi
