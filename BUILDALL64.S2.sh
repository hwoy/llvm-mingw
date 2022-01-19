#!/bin/sh

DIR=$(dirname $0)

cd ${DIR}

cat 0_append_distro_path.sh | grep "#export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}" && sed 's/#export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}/export X_DISTRO_ROOT=${NEW_DISTRO_ROOT}/1' 0_append_distro_path.sh -i

cd utils
source ../0_append_distro_path.sh
source ../BUILD_COMMON.sh
cd ..

rm -rf ${STAGE2}
mkdir -p ${STAGE2}


buildpkg S2.0001.llvm-compiler-rt 64.llvm-compiler-rt.sh ${STAGE2}

buildpkg S2.0002.mingw-headers-w64 64.mingw-w64-headers.sh ${STAGE2}

buildpkg S2.0003.mingw-crt-w64 64.mingw-w64-crt.sh ${STAGE2}

buildpkg S2.0003.mingw-winpthreads-w64 64.mingw-w64-winpthreads.sh ${STAGE2}

buildpkg S2.0004.llvm-libunwind 64.llvm-libunwind.sh ${STAGE2}

buildpkg S2.0005.llvm-libcxxabi 64.llvm-libcxxabi.sh ${STAGE2}

buildpkg S2.0006.llvm-libcxx 64.llvm-libcxx.sh ${STAGE2}

buildpkg S2.0007.zlib 64.zlib.sh ${STAGE2}

buildpkg S2.0008.libiconv 64.libiconv.sh ${STAGE2}

buildpkg S2.0009.xz 64.xz.sh ${STAGE2}

buildpkg S2.0010.libxml2 64.libxml2.sh ${STAGE2}

buildpkg S2.0011.llvm 64.llvm.sh ${STAGE2}

buildpkg S2.0012.llvm-openmp 64.llvm-openmp.sh ${STAGE2}

buildpkg S2.0013.libssp 64.libssp.sh ${STAGE2}

buildpkg S2.0014.mingw-libmangle-w64 64.mingw-w64-libmangle.sh ${STAGE2}

buildpkg S2.0015.mingw-tools-w64 64.mingw-w64-tools.sh ${STAGE2}

buildpkg S2.0016.mingw-winstorecompat-w64 64.mingw-w64-winstorecompat.sh ${STAGE2}

buildpkg S2.0017.make 64.make.sh ${STAGE2}
