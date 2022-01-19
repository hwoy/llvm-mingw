#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

source ../0_append_distro_path.sh


clang --version
