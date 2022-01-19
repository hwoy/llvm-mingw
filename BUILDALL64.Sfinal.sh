#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}


cd utils

source ../0_append_distro_path.sh
cd ..

sh utils/INSTALL.sh ${STAGE2} ${STAGE2}/output

sh utils/PACKDIR.sh ${STAGE2}/output ${X_SRCDIR}/${PROJ}-${X_TARGET}-${X_THREAD}-${_default_msvcrt}-${REV}

rm -rf ${STAGE2}/output

rm -rf ${X_BUILDDIR}/*
