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

	#libcxx-shared
	SHARED=TRUE
	STATIC=FALSE

	CMAKEFLAGS=""
	CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS}"

	cd ${X_BUILDDIR}
	mkdir build.libcxx.shared
	cd build.libcxx.shared

	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${X_BUILDDIR}/dest/${X_TARGET}" \
		-DCMAKE_C_COMPILER=clang \
		-DCMAKE_CXX_COMPILER=clang++ \
		-DCMAKE_CXX_COMPILER_TARGET=${X_TARGET} \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DCMAKE_AR="$NEW_DISTRO_ROOT/bin/llvm-ar" \
		-DCMAKE_RANLIB="$NEW_DISTRO_ROOT/bin/llvm-ranlib" \
		-DLLVM_PATH="$LLVM_PATH" \
		-DLIBCXX_USE_COMPILER_RT=ON \
		-DLIBCXX_HAS_WIN32_THREAD_API=ON \
		-DLIBCXX_ENABLE_SHARED=$SHARED \
		-DLIBCXX_ENABLE_STATIC=$STATIC \
		-DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
		-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=TRUE \
		-DLIBCXX_CXX_ABI=libcxxabi \
		-DLIBCXX_CXX_ABI_INCLUDE_PATHS=../${SNAME}-${SVERSION}/libcxxabi/include \
		-DLIBCXX_CXX_ABI_LIBRARY_PATH=../build.libcxxabi/lib \
		-DLIBCXX_LIBDIR_SUFFIX="" \
		-DLIBCXX_INCLUDE_TESTS=FALSE \
		-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=FALSE \
		$CMAKEFLAGS \
		../${SNAME}-${SVERSION}/libcxx

	$BUILDCMD  generate-cxx-headers

	## libcxxabi

	cd ${X_BUILDDIR}
	mkdir build.libcxxabi
	cd build.libcxxabi

	cmake \
		${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${X_BUILDDIR}/dest/${X_TARGET}" \
		-DCMAKE_C_COMPILER=clang \
		-DCMAKE_CXX_COMPILER=clang++ \
		-DCMAKE_CXX_COMPILER_TARGET=${X_TARGET} \
		-DCMAKE_C_COMPILER_WORKS=TRUE \
		-DCMAKE_CXX_COMPILER_WORKS=TRUE \
		-DLLVM_PATH="$LLVM_PATH" \
		-DCMAKE_AR="$NEW_DISTRO_ROOT/bin/llvm-ar" \
		-DCMAKE_RANLIB="$NEW_DISTRO_ROOT/bin/llvm-ranlib" \
		-DLIBCXXABI_USE_COMPILER_RT=ON \
		-DLIBCXXABI_ENABLE_SHARED=OFF \
		-DLIBCXXABI_LIBCXX_INCLUDES=../build.libcxx.shared/include/c++/v1 \
		-DLIBCXXABI_LIBDIR_SUFFIX="" \
		-DLIBCXX_ENABLE_SHARED=TRUE \
		-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=TRUE \
		$CMAKEFLAGS \
		../${SNAME}-${SVERSION}/libcxxabi

	$BUILDCMD -j${JOBS}
	$BUILDCMD install

	# Cleanup.
	cd ${X_BUILDDIR}
	rm -rf build.libcxx.shared
	mv dest ${SNAME}-libcxxabi-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}
	cd ${SNAME}-libcxxabi-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}

	if [ -d ${X_TARGET}/bin ]
	then
		mv ${X_TARGET}/bin ./bin
	fi

	rm -rf ../${PROJECTNAME}
	mkdir ../${PROJECTNAME}
	mv * ../${PROJECTNAME}
	mv ../${PROJECTNAME} ./
	zip7 ${SNAME}-libcxxabi-${SVERSION}-${X_HOST}-${X_THREAD}-${_default_msvcrt}-${REV}.7z

}

if [ ! -d ${X_BUILDDIR}/${SNAME}-${SVERSION} ]
then

	decompress

	prepare

fi

build
