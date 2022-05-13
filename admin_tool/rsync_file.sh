#!/bin/bash

SCRIPT=$0

if [ $# != 3 ] && [ $# != 4 ] 
then
    echo "args error:"
    echo "    e.g. : $SCRIPT 'host src dest' "
    exit 1
fi
DATE=`date +%Y%m%d`
host=$1
src=$2
dest=$3

logDir=log/$DATE

if [ ! -d log ]
then
    mkdir log
fi
if [ ! -d $logDir ]
then
    mkdir $logDir
fi

isDelete=no


if [ $# == 4 ]
then
    if [ yes == $4 ] 
    then
         isDelete=$4
    fi  
fi

echo "isDelete:  "$isDelete

#日志文件
log=$logDir/$host"_"${dest##*/}.log
echo -e "\nstart*************************************************" >> $log
date  >> ${log}
echo -e "host=$host  src=$src dest=$dest" >> $log

ansible-playbook rsync_file.yml  --extra-vars "host=$host  src=$src dest=$dest delete=$isDelete"
#ansible $host -m synchronize -av " -av src=$src dest=$dest delete=no compress=yes recursive=yes checksum=yes rsync_opts=--exclude-from=exclude.txt"

ES=$?
if [ "$ES" -ne 0 ]; then
	exit $ES
fi

date  >> ${log}
echo -e "end*************************************************" >> $log

