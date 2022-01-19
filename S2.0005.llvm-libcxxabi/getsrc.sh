#!/bin/sh

DIR=$(dirname $0)
wget -P ${DIR} --tries=10 -c -i ${DIR}/wget.txt
