#!/bin/sh

DIR=$(dirname $0)
source ${DIR}/0_common.sh

if [ -d ${X_SRCDIR} ] ; then
	echo "${X_SRCDIR} existed"
	exit 1
fi

if [ -d ${X_BUILDDIR} ] ; then
	echo "${X_BUILDDIR} existed"
	exit 1
fi

mkdir -p  ${X_BUILDDIR} && echo "$${X_BUILDDIR} created successfully"
mkdir -p ${X_SRCDIR} && cp -R ${DIR}/* ${X_SRCDIR}/ && echo "${X_SRCDIR} created successfully"

exit 0
