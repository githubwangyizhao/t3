#!/bin/bash

#################################################################
#
# Description       : 导出分支
#
#################################################################

SRC_PATH=svn://127.0.0.1/h5/branch/weixin_publish/server
#VERSION=$1
TARGET_PATH=/opt/branch/wx/server
#TARGET_PATH=/opt/h5/branch/server/weixin
#TARGET_PATH=${BRANCH_PATH}/${VERSION}

#if [ $# != 1 ]
#then
#    echo "args error:"
#    echo "    e.g. : do-branch.sh version"
#    exit 1
#fi

if [ -d ${TARGET_PATH} ]; then
    svn up ${TARGET_PATH}
    rm -rf ${TARGET_PATH}
fi
echo "清理目标目录成功:$TARGET_PATH"
# mkdir $TARGET_PATH

echo "正常导出版本库:$SRC_PATH"
svn export  ${SRC_PATH} ${TARGET_PATH}
echo "导出版本库成功:$SRC_PATH"

DB_NAME=release
TOOL_CONFIG=${TARGET_PATH}/config/game.config
sed -i "s#.*mysql_database.*#    {mysql_database, \"$DB_NAME\"},#g" ${TOOL_CONFIG}
sed -i 's#.*map_data_dir.*#    {map_data_dir, "../../resource/assets/scene/map"},#g' ${TOOL_CONFIG}
sed -i 's#.*scene_data_dir.*#    {scene_data_dir, "../../resource/assets/scene/scenedata"},#g' ${TOOL_CONFIG}
sed -i 's#.*template_dir.*#    {template_dir, "../../plan/配置表"},#g' ${TOOL_CONFIG}

START_SH=${TARGET_PATH}/script/start.sh
sed -i 's#.*-name.*#-name 'release@192.168.31.100' \\#g' ${START_SH}
#create_tool_config
#sed -i "7s/.*$/    \{map_data_dir, \"\/opt\/branches\/s0\/res\/data\/image\/maps\/\"\},/" $TOOL_CONFIG
#sed -i "8s/.*$/    \{scene_data_dir, \"\/opt\/branches\/s0\/res\/data\/image\/scenes\/\"\},/" $TOOL_CONFIG
#sed -i "9s/.*$/    \{template_dir, \"\/opt\/branches\/s0\/res\/data\/json\/csv\/\"\}/" $TOOL_CONFIG

## 数据库配置文件 ##
create_database_config(){
    DATABASE_CONFIG_FILE=${TARGET_PATH}/database/config.ini
    echo "生成 ${DATABASE_CONFIG_FILE}"

    echo "sql_dir = \"./changes\""                 >  ${DATABASE_CONFIG_FILE}
    echo '[release]'                               >> ${DATABASE_CONFIG_FILE}
    echo "db_user = \"root\""                      >> ${DATABASE_CONFIG_FILE}
    echo "db_passwd = \"game1234\""                >> ${DATABASE_CONFIG_FILE}
    echo "db_name = \"$DB_NAME\""                  >> ${DATABASE_CONFIG_FILE}
    echo "db_host = \"127.0.0.1\""                 >> ${DATABASE_CONFIG_FILE}
    echo "db_port = 3306"                          >> ${DATABASE_CONFIG_FILE}
}


create_database_config

## Emakefile ##
create_emakefile(){
    EMAKEFILE=${TARGET_PATH}/script/Emakefile
    echo "生成 ${EMAKEFILE}"

    echo "{"                                             >  ${EMAKEFILE}
    echo '    ['                                         >> ${EMAKEFILE}
    echo '        "../src/*/*/*",'                       >> ${EMAKEFILE}
    echo '        "../src/*/*",'                         >> ${EMAKEFILE}
    echo '        "../src/*"'                            >> ${EMAKEFILE}
    echo '    ],'                                        >> ${EMAKEFILE}
    echo '    ['                                         >> ${EMAKEFILE}
   # echo '        debug_info,'                           >> $EMAKEFILE
    echo '        {i, "../include"},'                    >> ${EMAKEFILE}
    echo '        {outdir, "../ebin"}'                   >> ${EMAKEFILE}
    echo '    ]'                                         >> ${EMAKEFILE}
    echo '}.'                                            >> ${EMAKEFILE}
}

create_emakefile


cd ${TARGET_PATH}
#cd ../
echo "开始提交svn..."
svn st | awk '{if ($1 == "?") {print $2} }' | xargs -r svn add
svn st | awk '{if ($1 == "!") {print $2}}' | xargs -r svn rm
svn ci -m "提交分支"
echo "提交svn成功"

echo "生成分支成功:"${TARGET_PATH}



