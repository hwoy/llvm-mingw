#!/bin/sh
source ../0_append_distro_path.sh

SNAME=xz
SVERSION=5.2.5

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
	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	DLLTOOL=llvm-dlltool NM=llvm-nm RANLIB=llvm-ranlib AR=llvm-ar CC=clang CXX=clang++ ../src/configure \
		--build=${X_BUILD} \
		--host=${X_HOST} \
		--target=${X_TARGET} \
		--prefix=${NEW_DISTRO_ROOT} \
		--disable-rpath \
		--disable-lzma-links

	make -j${JOBS}
	DESTDIR=${X_BUILDDIR}/dest make install

	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	#remove binary
	mv c ../dest
	cd ../
	rm -rf ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	rm -rf bin/*.exe
	
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build
