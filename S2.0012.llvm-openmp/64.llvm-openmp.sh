#!/bin/sh
source ../0_append_distro_path.sh

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
	#apply_patch_p1_llvm \
    #"0005-add-pthread-as-system-lib-for-mingw.patch" \
    #"0008-enable-emutls-for-mingw.patch"

	apply_patch_p1_llvm \
    "0009-export-out-of-tree-mlir-targets.patch" \
    "0010-lldb-Fix-building-standalone-LLDB-on-Windows.patch" \
    "0011-MinGW-Don-t-currently-set-visibility-hidden-when-bui.patch" \
    "0012-COFF-Emit-embedded-exclude-symbols-directives-for-hi.patch"

#No clang
	#apply_patch_p1_clang \
	#"0104-link-pthread-with-mingw.patch"

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
	CMAKEFLAGS="$CMAKEFLAGS -DLIBOMP_ASMFLAGS=-m64"

	cd ${X_BUILDDIR}
	mkdir build.llvm-openmp
	cd build.llvm-openmp
	cmake \
        ${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${X_BUILDDIR}/dest \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_RC_COMPILER=llvm-windres \
        -DCMAKE_ASM_MASM_COMPILER=llvm-ml \
        -DCMAKE_AR="llvm-ar" \
        -DCMAKE_RANLIB="llvm-ranlib" \
        -DLIBOMP_ENABLE_SHARED=TRUE \
        $CMAKEFLAGS \
		../${SNAME}-${SVERSION}/openmp

	$BUILDCMD -j${JOBS}
	$BUILDCMD install


	# Cleanup.
	cd ${X_BUILDDIR}
	mv dest ${SNAME}-openmp-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-openmp-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}


	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-openmp-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

if [ ! -d ${X_BUILDDIR}/${SNAME}-${SVERSION} ]
then

	decompress

	prepare

fi

build
