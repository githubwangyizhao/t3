#!/bin/sh

DATE=$(date +%x--%X)
currDir=$(pwd)

if [ ! -d "log" ]; then
    echo "创建文件夹log"
    mkdir log
fi

./res.sh && ./server.sh

DATE1=$(date +%x--%X)

cd $currDir
echo -e "\n====>>完成总时间范围: "${DATE}"\t=>"${DATE1}"<<====" >> logChange.txt
cat version.txt >> log/logChange.txt
svn st | awk '{if ($1 == "?"||$1 == "A") {print $2} }' | xargs -r svn add
svn ci -m 'filelist' * --force-log
cat version.txt 
