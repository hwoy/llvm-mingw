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
	apply_patch_p1 Define-__-de-register_frame_info-in-fake-libgcc_s.patch
	cd ..

	cd ${X_BUILDDIR}/mingw-w64-${SVERSION}/mingw-w64-libraries/winpthreads
	autoreconf -vfi
}

build()
{

	cd ${X_BUILDDIR}

	# Build mingw-w64 and winpthreads.
	MINGW_PARAM="--enable-lib32 --disable-lib64"
	
	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	DLLTOOL=llvm-dlltool NM=llvm-nm RANLIB=llvm-ranlib AR=llvm-ar CC=clang CXX=clang++ ../src/mingw-w64-libraries/winpthreads/configure \
		--build=${X_BUILD} --host=${X_HOST} --target=${X_TARGET} \
		--prefix=${X_BUILDDIR}/dest/${X_TARGET} \
		--enable-static \
		--enable-shared \
		${MINGW_PARAM} \
		"CPPFLAGS=-D__USE_MINGW_ANSI_STDIO=1"

	# https://github.com/msys2/MINGW-packages/issues/7043

	# The headers must be built first. See: https://github.com/StephanTLavavej/mingw-distro/issues/64
	make -j${JOBS}
	make  install

	#make $X_MAKE_JOBS all "CFLAGS=-s -O2"
	#make  install

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-winpthreads-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-winpthreads-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	
	if [ -d ${X_TARGET}/bin ]
	then
		mv ${X_TARGET}/bin ./bin
	fi

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-winpthreads-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build

