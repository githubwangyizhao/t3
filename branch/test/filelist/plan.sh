#!/bin/sh

currDir=$(pwd)
DATE=$(date +%x--%X)
svnPath="svn://127.0.0.1/t3/branch/test_release"

if [ ! -d "log" ]; then
    echo "创建文件夹log"
    mkdir log
fi

cd ../
svn up
rm -rf table/*
svn --force export $svnPath/table table
cd table

svn st | awk '{if ($1 == "?"||$1 == "A") {print $2} }' | xargs -r svn add
svn st | awk '{if ($1 == "!") {print $2} }' | xargs -r svn del

svn  ci -m '配置表' * --force-log

DATE1=$(date +%x--%X)
cd $currDir
echo -e "\n配置表\t====>>完成总时间范围: "${DATE}"\t=>"${DATE1}"<<====" >> log/logChange.txt

