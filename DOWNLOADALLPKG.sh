#!/bin/sh
DIR=$(dirname $0)

cd ${DIR}

for i in $(find . -name getsrc.sh)
do
	sh ${i}
done
