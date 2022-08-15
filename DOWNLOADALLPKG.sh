#!/bin/sh

# Reject expansion of unset variables.
set -u

# Exit when a command fails.
if [ "${PS1:-}" == "" ]; then set -e; fi


DIR=$(dirname $0)

cd ${DIR}

for i in $(find . -name getsrc.sh)
do
	sh ${i}
done
