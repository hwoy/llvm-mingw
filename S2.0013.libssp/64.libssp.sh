#!/bin/sh
source ../0_append_distro_path.sh

SNAME=libssp
SVERSION=7.3.0

decompress()
{
	untar_file ${SNAME}-${SVERSION}.tar.bz2
}

prepare()
{
	mv ${X_BUILDDIR}/gcc-releases-gcc-${SVERSION}-${SNAME} ${X_BUILDDIR}/${SNAME}-${SVERSION}
	cp -f libssp-Makefile ${X_BUILDDIR}/${SNAME}-${SVERSION}/${SNAME}/Makefile

	cd ${X_BUILDDIR}
	cd ${SNAME}-${SVERSION}/${SNAME}

	# gcc/libssp's configure script runs checks for flags that clang doesn't
	# implement. We actually just need to set a few HAVE defines and compile
	# the .c sources.

	cp -f config.h.in config.h
	for i in HAVE_FCNTL_H HAVE_INTTYPES_H HAVE_LIMITS_H HAVE_MALLOC_H \
		HAVE_MEMMOVE HAVE_MEMORY_H HAVE_MEMPCPY HAVE_STDINT_H HAVE_STDIO_H \
		HAVE_STDLIB_H HAVE_STRINGS_H HAVE_STRING_H HAVE_STRNCAT HAVE_STRNCPY \
		HAVE_SYS_STAT_H HAVE_SYS_TYPES_H HAVE_UNISTD_H HAVE_USABLE_VSNPRINTF \
		HAVE_HIDDEN_VISIBILITY; do
			cat config.h | sed 's/^#undef '$i'$/#define '$i' 1/' > tmp
			mv -f tmp config.h
		done
		cat ssp/ssp.h.in | sed 's/@ssp_have_usable_vsnprintf@/define/' > ssp/ssp.h
	}

build()
{
	cd ${X_BUILDDIR}
	mv ${SNAME}-${SVERSION} src
	mkdir build dest
	cd build

	make -f ../src/${SNAME}/Makefile

	mkdir -p ${X_BUILDDIR}/dest/{bin,lib}
	cp -f *.a "${X_BUILDDIR}/dest/lib"
	cp -f *.dll "${X_BUILDDIR}/dest/bin"

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build src
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}


	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

decompress

prepare

build
