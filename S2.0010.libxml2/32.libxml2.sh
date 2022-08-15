#!/bin/sh
source ../0_append_distro_path_32.sh

SNAME=libxml2
SVERSION=2.9.14

decompress()
{
	untar_file ${SNAME}-${SVERSION}.tar.xz
}

prepare()
{
	cp -fHv pathtools.[ch] ${X_BUILDDIR}/${SNAME}-${SVERSION}

	cd patch

	apply_patch_p1 \
    0015-fix-unused-parameters-warning.all.patch \
    0016-WARNING-to-be-fixed.all.patch \
    0019-unused-flags.all.patch \
    0020-fix-warnings.patch \
    0023-fix-sitedir-detection.mingw.patch \
    0026-mingw-relocate.patch \
    0030-pkgconfig-add-Cflags-private.patch \
    libxml2-disable-version-script.patch

  # https://gitlab.gnome.org/GNOME/libxml2/-/issues/64
  # https://github.com/msys2/MINGW-packages/issues/7955
  apply_patch_p1 \
	  0027-decoding-segfault.patch
	  
  # https://github.com/msys2/MINGW-packages/issues/10577
  apply_patch_p1 \
    0029-xml2-config-win-paths.patch

  cd ..

  cd ${X_BUILDDIR}/${SNAME}-${SVERSION}
  libtoolize --copy --force
  aclocal
  automake --add-missing
  autoconf

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
		--with-zlib=${NEW_DISTRO_ROOT} \
		--with-lzma=${NEW_DISTRO_ROOT} \
		--without-python \
		--with-modules \
		--enable-static \
		--enable-shared \
		--with-threads=win32 \

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
