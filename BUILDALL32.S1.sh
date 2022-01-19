#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

cat 0_append_distro_path_32.sh | grep "#export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}" || sed 's/export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}/#export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}/1' 0_append_distro_path_32.sh -i

cd utils

source ../0_append_distro_path_32.sh
source ../BUILD_COMMON.sh
cd ..


rm -rf ${STAGE1}
mkdir -p ${STAGE1}

buildpkg S1.0001.llvm 32.llvm.sh ${STAGE1}


