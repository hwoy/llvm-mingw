#!/bin/sh

i=1
count=$#
PWD=$(pwd)
if [ $count -eq $i ]
then
	if [ -d $1 ] ; then
		cd $1 && \
		7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on ../$1.7z * && \
		echo "packed $1 success"
		exit 0
	fi
fi

j=2

if [ $count -eq $j ]
then
	if [ -d $1 ] ; then
		cd $1 && \
		7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on $2.7z * && \
		echo "packed $1 success"
		exit 0
	fi
fi
echo "Errror"
exit  1
