
export X_DISTRO_BIN=$X_DISTRO_ROOT/bin
export X_DISTRO_INC=$X_DISTRO_ROOT/include
export X_DISTRO_LIB=$X_DISTRO_ROOT/lib

export PATH=$X_DISTRO_BIN:$PATH

export X_BASEDIR=/c/Temp/MinGW-Base
export X_SRCDIR=${X_BASEDIR}/Sources
export X_BUILDDIR=${X_BASEDIR}/Builds


JOBS=${NUMBER_OF_PROCESSORS}


STAGE1=${X_SRCDIR}/${X_TARGET}-${X_THREAD}-${_default_msvcrt}-${REV}-STAGE1

STAGE2=${X_SRCDIR}/${X_TARGET}-${X_THREAD}-${_default_msvcrt}-${REV}-STAGE2

apply_patch_p2() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -p2 < "${_patch}"
	done
}

apply_patch_p1() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -p1 < "${_patch}"
	done
}

apply_patch_p0() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -p0 < "${_patch}"
	done
}

apply_reverse_patch_p2() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -R -p2 < "${_patch}"
	done
}

apply_reverse_patch_p1() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -R -p1 < "${_patch}"
	done
}

apply_reverse_patch_p0() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION} -R -p0 < "${_patch}"
	done
}

function untar_file {
	tar  --directory=${X_BUILDDIR} -xvf $*
}

function zip7
{
	7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on "../$1" *
}

del_file_exists() {
	for _fname in "$@"
	do
		if [ -f ${_fname} ]; then
			rm -rf ${_fname}
		fi
	done
}
