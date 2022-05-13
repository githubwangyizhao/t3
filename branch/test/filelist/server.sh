#!/bin/sh

DATE=$(date +%x--%X)
currDir=$(pwd)
serverSvn=svn://127.0.0.1/t3/branch/test_release/server
serverDir=$currDir/../server

if [ ! -d "log" ]; then
    echo "创建文件夹log"
    mkdir log
fi

#cd ../
#svn up
#cd $currDir

#./plan.sh && ./server_scene_dir && sh ../../../admin_tool/do-branch-test.sh $serverSvn $serverDir && cd ../server/script/ && chmod 755 *.sh gen_proto* &&  sh do-release.sh
./plan.sh && ./server_scene_dir && sh ../../../admin_tool/do-branch.sh $serverSvn $serverDir && cd ../server/script/ && chmod 755 *.sh gen_proto* &&  sh do-release.sh
DATE1=$(date +%x--%X)
cd $currDir
echo -e "\nserver\t====>>完成总时间范围: "${DATE}"\t=>"${DATE1}"<<====" >> log/logChange.txt

