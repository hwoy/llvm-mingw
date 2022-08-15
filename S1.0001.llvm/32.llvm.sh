#!/bin/sh
source ../0_append_distro_path_32.sh

SNAME=llvm
SVERSION=14.0.6


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

apply_patch_p1_extra() {
	for _patch in "$@"
	do
		patch -d ${X_BUILDDIR}/${SNAME}-${SVERSION}/clang-tools-extra -p1 < "${_patch}"
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
    "0002-Fix-GetHostTriple-for-mingw-w64-in-msys.patch" \
    "0003-Revert-CMake-try-creating-symlink-first-on-windows.patch"
	
#No clang
	apply_patch_p1_llvm \
    "0005-add-pthread-as-system-lib-for-mingw.patch" \
    "0008-enable-emutls-for-mingw.patch"

	apply_patch_p1_llvm \
    "0009-export-out-of-tree-mlir-targets.patch" \
    "0010-lldb-Fix-building-standalone-LLDB-on-Windows.patch" \
    "0011-MinGW-Don-t-currently-set-visibility-hidden-when-bui.patch" \
    "0012-COFF-Emit-embedded-exclude-symbols-directives-for-hi.patch"

#No clang
	apply_patch_p1_clang \
	"0104-link-pthread-with-mingw.patch"

	apply_patch_p1_lld \
    "0304-ignore-new-bfd-options.patch" \
    "0301-LLD-COFF-Add-support-for-a-new-mingw-specific-embedd.patch" \
    "0302-LLD-MinGW-Implement-the-exclude-symbols-option.patch"


	apply_patch_p1_extra \
	"0405-Do-not-try-to-build-CTTestTidyModule-for-Windows-with-dylibs.patch"

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

	CMAKEFLAGS=""
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_C_COMPILER=$X_HOST-gcc"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_CXX_COMPILER=$X_HOST-g++"
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_RC_COMPILER=$X_HOST-windres"

	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_RTLIB=compiler-rt"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_UNWINDLIB=libunwind"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_CXX_STDLIB=libc++"
	CMAKEFLAGS="$CMAKEFLAGS -DCLANG_DEFAULT_LINKER=lld"

	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS}"

	cd ${X_BUILDDIR}
	mkdir build.llvm-stage1
	cd build.llvm-stage1
	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		-DCMAKE_INSTALL_PREFIX=${X_BUILDDIR}/dest \
		-DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_ASSERTIONS=$ASSERTS \
		-DLLVM_ENABLE_PROJECTS="clang;lld" \
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
	mv dest ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage1
	cd ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage1


	find -name "*.exe" -type f -print -exec strip -s {} ";"


	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}-stage1.7z

}

if [ ! -d ${X_BUILDDIR}/${SNAME}-${SVERSION} ]
then

	decompress

	prepare

fi

build
