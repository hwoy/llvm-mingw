#!/bin/sh
source ../0_append_distro_path_32.sh

SNAME=llvm
SVERSION=13.0.0


# Extract vanilla sources.

apply_patch_p1_llvm() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION}/llvm -p1 < "${_patch}"
	done
}

apply_reverse_patch_p1_llvm() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION}/llvm -R -p1 < "${_patch}"
	done
}

apply_patch_p1_clang() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION}/clang -p1 < "${_patch}"
	done
}

apply_patch_p1_lld() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION}/lld -p1 < "${_patch}"
	done
}



decompress()
{
	unzip -d ${X_BUILDDIR} ${SNAME}org-${SVERSION}.zip

	mv ${X_BUILDDIR}/${SNAME}-project-llvmorg-${SVERSION}  ${X_BUILDDIR}/${SNAME}-${SVERSION}
}

prepare()
{

	cd patch

	apply_patch_p1_llvm \
		"0001-Use-posix-style-path-separators-with-MinGW.patch" \
		"0002-Fix-GetHostTriple-for-mingw-w64-in-msys.patch"

	apply_reverse_patch_p1_llvm \
		"0003-CMake-try-creating-symlink-first-on-windows.patch"

	apply_patch_p1_llvm \
		"0009-export-out-of-tree-mlir-targets.patch"

	apply_patch_p1_clang \
		"0101-Disable-fPIC-errors.patch" \
		"0103-Use-posix-style-path-separators-with-MinGW.patch" \
		"0105-clang-Tooling-Use-Windows-command-lines.patch"

	apply_patch_p1_lld \
		"0304-ignore-new-bfd-options.patch"


	cd ..
}

build()
{

	CMAKE_GENERATOR="Ninja"
	BUILDCMD=ninja

	LLVM_PATH=${X_BUILDDIR}/${SNAME}-${SVERSION}/llvm

	CMAKEFLAGS=""
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS}"

	cd ${X_BUILDDIR}
	mkdir build.compiler-rt
	cd build.compiler-rt

	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${X_BUILDDIR}/dest/lib/clang/$SVERSION" \
		-DCMAKE_C_COMPILER=clang \
		-DCMAKE_CXX_COMPILER=clang++ \
		-DCMAKE_AR="$NEW_DISTRO_ROOT/bin/llvm-ar" \
		-DCMAKE_RANLIB="$NEW_DISTRO_ROOT/bin/llvm-ranlib" \
		-DCMAKE_C_COMPILER_TARGET=${X_TARGET} \
		-DCOMPILER_RT_DEFAULT_TARGET_ONLY=TRUE \
		-DCOMPILER_RT_USE_BUILTINS_LIBRARY=TRUE \
		-DCOMPILER_RT_BUILD_SANITIZERS=OFF \
		$CMAKEFLAGS \
		../${SNAME}-${SVERSION}/compiler-rt/lib/builtins

	$BUILDCMD -j${JOBS}
	$BUILDCMD install


	if [ ! -f ${X_BUILDDIR}/dest/${X_TARGET}/lib/libunwind.a ] && [ ! -f ${X_BUILDDIR}/dest/${X_TARGET}/lib/libunwind.dll.a ]; then
		if [ ! -d  ${X_BUILDDIR}/dest/${X_TARGET}/lib ]; then
			mkdir -p ${X_BUILDDIR}/dest/${X_TARGET}/lib
		fi

		llvm-ar rcs ${X_BUILDDIR}/dest/${X_TARGET}/lib/libunwind.a
	fi


	# Cleanup.
	cd ${X_BUILDDIR}
	mv dest ${SNAME}-compiler-rt-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-compiler-rt-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-compiler-rt-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

if [ ! -d ${X_BUILDDIR}/${SNAME}-${SVERSION} ]
then

	decompress

	prepare

fi

build
