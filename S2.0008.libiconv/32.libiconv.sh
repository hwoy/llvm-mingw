#!/bin/sh
source ../0_append_distro_path_32.sh

SNAME=libiconv
SVERSION=1.16

decompress()
{
	untar_file ${SNAME}-${SVERSION}.tar.gz
}

prepare()
{
	cd patch

	apply_patch_p1 0001-compile-relocatable-in-gnulib.mingw.patch
	apply_patch_p1 0002-fix-cr-for-awk-in-configure.all.patch
	apply_patch_p1 fix-pointer-buf.patch

	cd ..
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
		--enable-static \
		--enable-shared \
		--enable-extra-encodings \
		--enable-relocatable \
		--disable-rpath \
		--enable-silent-rules \
		--enable-nls

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
