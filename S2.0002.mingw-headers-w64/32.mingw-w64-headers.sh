#!/bin/sh

source ../0_append_distro_path_32.sh

SNAME=mingw-w64
SVERSION=v10.0.0

# Extract vanilla sources.

decompress()
{

	untar_file ${SNAME}-${SVERSION}.tar.bz2
}

prepare()
{
	cd patch
	apply_patch_p1 \
		0001-Allow-to-use-bessel-and-complex-functions-without-un.patch \
		0002-DirectX-9-fixes-for-VLC.patch

	cd ..

	cd ${X_BUILDDIR}/${SNAME}-${SVERSION}/mingw-w64-headers
	touch include/windows.*.h include/wincrypt.h include/prsht.h
}

build()
{

	cd ${X_BUILDDIR}

	# Build mingw-w64 and winpthreads.
	MINGW_PARAM="--enable-lib32 --disable-lib64"
	_default_win32_winnt=0x601

	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	CC=clang CXX=clang++ ../src/mingw-w64-headers/configure --build=${X_BUILD} --host=${X_HOST} --target=${X_TARGET} \
		--prefix=${X_BUILDDIR}/dest/${X_TARGET}  \
		--enable-wildcard \
		--with-default-msvcrt=${_default_msvcrt} \
		--enable-shared --enable-static --with-tools=all \
		--enable-sdk=all \
		--disable-dependency-tracking \
		--enable-idl \
		--without-widl \
		--with-default-win32-winnt=${_default_win32_winnt} \
		${MINGW_PARAM}

	# The headers must be built first. See: https://github.com/StephanTLavavej/mingw-distro/issues/64

	make  install

	#make $X_MAKE_JOBS all "CFLAGS=-s -O2"
	#make  install

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-headers-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-headers-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-headers-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build
