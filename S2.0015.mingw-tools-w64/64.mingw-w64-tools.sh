#!/bin/sh

source ../0_append_distro_path.sh

SNAME=mingw-w64
SVERSION=v9.0.0

# Extract vanilla sources.

decompress()
{

	untar_file ${SNAME}-${SVERSION}.tar.bz2
}

prepare()
{
	:;
}

build()
{

	cd ${X_BUILDDIR}

	# Build mingw-w64 and winpthreads.
	MINGW_PARAM="--disable-lib32 --enable-lib64"
	mv ${SNAME}-${SVERSION} src
	mkdir build dest

	_tools="gendef genlib genidl genpeimg widl" # genstubdll
	local cur=
	for cur in ${_tools}; do
		rm -rf build
		mkdir build
		cd build
		DLLTOOL=llvm-dlltool NM=llvm-nm RANLIB=llvm-ranlib AR=llvm-ar CC=clang CXX=clang++ ../src/mingw-w64-tools/${cur}/configure \
			--build=${X_BUILD} --host=${X_HOST} --target=${X_TARGET} \
			--prefix=${X_BUILDDIR}/dest \
			--with-mangle=${NEW_DISTRO_ROOT} \
			${MINGW_PARAM}
					make -j${JOBS}
					make install
					cd ..
				done
				# https://github.com/msys2/MINGW-packages/issues/7043

	# The headers must be built first. See: https://github.com/StephanTLavavej/mingw-distro/issues/64

	#make $X_MAKE_JOBS all "CFLAGS=-s -O2"
	#make  install

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-tools-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-tools-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-tools-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build
