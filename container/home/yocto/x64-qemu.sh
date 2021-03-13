#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
source $SCRIPT_DIR/x64-shell.sh

runqemu qemux86-64 nographic
