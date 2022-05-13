#!/bin/bash
#################################################################
#
# Description       : 打包
#
#################################################################
cd ..
VERSION=$(basename `pwd`)
## 打包路径：
PACKAGE_PATH=rel

TIME=`date +%Y%m%d%H%M%S`

if [ -d ${PACKAGE_PATH} ]; then
    rm -rf ${PACKAGE_PATH}
fi
mkdir -p ${PACKAGE_PATH}

#config
mkdir -p ${PACKAGE_PATH}/config &&
cp config/sys_logger.config  ${PACKAGE_PATH}/config/  &&

#database
mkdir -p ${PACKAGE_PATH}/database &&
cp -r database/changes ${PACKAGE_PATH}/database &&
cp database/config.ini ${PACKAGE_PATH}/database/config.ini &&
cp database/db_version ${PACKAGE_PATH}/database/db_version &&

#ebin
mkdir -p ${PACKAGE_PATH}/ebin &&
cp -r ebin ${PACKAGE_PATH} &&

#include
mkdir -p ${PACKAGE_PATH}/include/gen &&
cp include/gen/db.hrl ${PACKAGE_PATH}/include/gen/ &&
cp include/gen/table_db.hrl ${PACKAGE_PATH}/include/gen/ &&

#log
mkdir -p ${PACKAGE_PATH}/log/error_logs &&

#priv
mkdir -p ${PACKAGE_PATH}/priv/ &&
cp -r priv/map ${PACKAGE_PATH}/priv/ &&

#script
mkdir -p ${PACKAGE_PATH}/script &&
#cp script/do-install.sh ${PACKAGE_PATH}/script/ &&
cp script/tool.sh ${PACKAGE_PATH}/script/ &&
cp script/nodetool ${PACKAGE_PATH}/script/ &&
#cp script/do-branch.sh ${PACKAGE_PATH}/script/ &&

echo ${TIME} > ${PACKAGE_PATH}/ebin/version &&
echo "version:"${TIME}
echo "打包成功:"${PACKAGE_PATH}

