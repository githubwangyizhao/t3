#!/bin/bash
#################################################################
# 
# Description       : 同步后台到管理机
#
#################################################################
DATE=`date +%Y%m%d`
#本地目录
localPath=/opt/admin/t1/admin
#远端ip
remoteIp=47.101.164.86
#远端目录
remotePath=/data/admin/admin

cd ..
echo -e "正在同步...\n"

chmod 755 ${localPath} &&
./rsync_file.sh ${remoteIp} ${localPath} ${remotePath} yes
echo -e "同步完毕.\n\n"
