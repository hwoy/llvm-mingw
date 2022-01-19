#!/bin/sh

i=1
count=$#
if [ $count -eq $i ]
then
	for i in $(ls -tr -w 0 $1/*.7z)
	do
		7z x ${i} -y -o$1
	done
exit 0
fi

j=2
if [ $count -eq $j ]
then
	for i in $(ls -tr -w 0 $1/*.7z)
	do
		7z x ${i} -y -o$2
	done
exit 0
fi
