#!/bin/sh

DIR=$(dirname $0)

wget -P ${DIR} --tries=10 -c -i ${DIR}/wget.txt

mv "${DIR}/gcc-releases-gcc-7.3.0.tar.bz2@path=libssp" ${DIR}/libssp-7.3.0.tar.bz2
