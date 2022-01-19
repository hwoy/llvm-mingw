#!/bin/sh


DIR=$(dirname $0)

FILE=${DIR}/../PKGLIST.md
rm -rf ${FILE}

for i in $(find ${DIR}/../ -name wget.txt)
do
	cat ${i} >> ${FILE}
	echo "" >> ${FILE}
done

for i in $(cat ${FILE})
do
	echo $(basename ${i}) >> ${FILE}.1
done

source ../0_common_head.sh

echo "\`\`\`" > ${FILE}
echo "Distro name: ${PROJ}" >> ${FILE}
echo "Created by: ${AUTHOR}" >> ${FILE}
echo "Reversion: ${REV}" >> ${FILE}
echo "Compilers: ${_languages}" >> ${FILE}
echo "Thread: ${X_THREAD}" >> ${FILE}
echo "Exception: SEH for 64 and Dwarf-2 for 32" >> ${FILE}
echo "Libc: ${_default_msvcrt}" >> ${FILE}
echo "\`\`\`" >> ${FILE}
echo "" >> ${FILE}
echo "" >> ${FILE}
echo "**====================== Packages ======================**" >> ${FILE}
echo "\`\`\`" >> ${FILE}
awk '!seen[$0]++' ${FILE}.1 >> ${FILE}
echo "\`\`\`" >> ${FILE}
echo "**====================== Packages ======================**" >> ${FILE}
rm -f ${FILE}.1