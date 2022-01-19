#!/bin/sh

source ../0_append_distro_path.sh

SNAME=zlib
SVERSION=1.2.11

decompress()
{
	untar_file ${SNAME}-${SVERSION}.tar.xz
}

prepare()
{
	cd patch

	apply_patch_p1 01-zlib-1.2.11-1-buildsys.mingw.patch
	apply_patch_p2 03-dont-put-sodir-into-L.mingw.patch
	apply_patch_p1 04-fix-largefile-support.patch

	cd ..
}

build()
{

	CMAKE_GENERATOR="Ninja"
	BUILDCMD=ninja

	cd ${X_BUILDDIR}
	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		"-DCMAKE_BUILD_TYPE=Release" \
		"-DCMAKE_C_FLAGS=-O2 -DTOO_FAR=32767" \
		"-DCMAKE_INSTALL_PREFIX=${NEW_DISTRO_ROOT}" \
		${X_BUILDDIR}/src

	$BUILDCMD -j${JOBS}
	DESTDIR=${X_BUILDDIR}/dest $BUILDCMD  install

	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build
