#!/bin/bash
#################################################################
# 
# Description       : 同步tc 包到管理机
#
#################################################################
DATE=`date +%Y%m%d`
#本地目录
localPath=/opt/t3/branch/test/server/rel/
#远端ip
remoteIp=47.102.119.76
#远端目录
remotePath=/data/package/server
cd ..
echo -e "正在同步...\n"
./rsync_file.sh ${remoteIp} ${localPath} ${remotePath} && echo -e "同步完毕.\n\n"
