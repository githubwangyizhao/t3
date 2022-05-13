#!/bin/bash
#################################################################
#
# Description       : 打补丁
#
#################################################################
if [ $# != 2 ]
then
    echo "args error:"
    echo "    e.g. : do-patch.sh version is_update_database"
    exit 1
fi
VERSION=$1
IS_UPDATE_DATABASE=$2
SRC=/data/package/${VERSION}

echo "开始更新:${VERSION}"
echo "源:${SRC}"
cp  ${SRC}/ebin/* ../ebin &&
cp  ${SRC}/database/changes/* ../database/changes &&
cp  ${SRC}/priv/map/* ../priv/map &&
if [[ ${IS_UPDATE_DATABASE} = "true" ]]
then
    echo "更新数据库..." &&
    cd ../database &&
    ./db_version update localhost
fi
echo "更新完成"
cd ../script



