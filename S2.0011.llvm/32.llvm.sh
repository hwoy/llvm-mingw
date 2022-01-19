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
	
	LINK_DYLIB=ON
	ASSERTS=OFF
	TOOLCHAIN_ONLY=OFF

	CMAKEFLAGS=" "
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_C_COMPILER=clang"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_CXX_COMPILER=clang++"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_RC_COMPILER=llvm-windres"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_AR=$NEW_DISTRO_ROOT/bin/llvm-ar"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_RANLIB=$NEW_DISTRO_ROOT/bin/llvm-ranlib"

	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_RTLIB=compiler-rt"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_UNWINDLIB=libunwind"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_CXX_STDLIB=libc++"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_LINKER=lld"
	
	CMAKEFLAGS="$CMAKEFLAGS -DLLVM_USE_LINKER=lld"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS}"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_SYSROOT=${NEW_DISTRO_ROOT}"

	cd ${X_BUILDDIR}
	mkdir build.llvm-stage2
	cd build.llvm-stage2
	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		-DCMAKE_INSTALL_PREFIX=${X_BUILDDIR}/dest \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_ASSERTIONS=$ASSERTS \
		-DLLVM_ENABLE_PROJECTS=${LLVM_PROJECTS} \
		-DLLVM_TARGETS_TO_BUILD="X86" \
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=$TOOLCHAIN_ONLY \
		-DLLVM_LINK_LLVM_DYLIB=$LINK_DYLIB \
		-DLLVM_HOST_TRIPLE=${X_HOST} \
		-DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_DOCS=OFF -DLLVM_ENABLE_TERMINFO=OFF \
		$CMAKEFLAGS \
		../${SNAME}-${SVERSION}/llvm

	$BUILDCMD -j${JOBS}
	$BUILDCMD install



	# Cleanup.
	cd ${X_BUILDDIR}
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage2
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage2


	find -name "*.exe" -type f -print -exec llvm-strip -s {} ";"


	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage2.7z

}

if [ ! -d ${X_BUILDDIR}/${SNAME}-${SVERSION} ]
then

	decompress

	prepare

fi

build


