#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

source ../0_append_distro_path.sh

rm -rf ${NEW_DISTRO_ROOT}

source ../0_append_distro_path_32.sh

rm -rf ${NEW_DISTRO_ROOT}

rm -rf ${X_SRCDIR}

rm -rf ${X_BUILDDIR}

rm -rf ${X_BASEDIR}

