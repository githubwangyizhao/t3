#!/bin/sh

DATE=$(date +%x--%X)

currDir=$(pwd)

if [ ! -d "log" ]; then
    echo "创建文件夹log"
    mkdir log
fi

cd ../
svn up
cd $currDir
./filebranch

cd ../release/

svn st | awk '{if ($1 == "?"||$1 == "A") {print $2} }' | xargs -r svn add
svn st | awk '{if ($1 == "!") {print $2} }' | xargs -r svn del

svn  ci -m 'res 差量版本更新' *

DATE1=$(date +%x--%X)

cd $currDir
echo -e "\nres\t====>>完成总时间范围: "${DATE}"\t=>"${DATE1}"<<====" >> log/logChange.txt
cat version.txt >> log/logChange.txt
svn st | awk '{if ($1 == "?"||$1 == "A") {print $2} }' | xargs -r svn add
svn ci -m 'filelist' * --force-log
