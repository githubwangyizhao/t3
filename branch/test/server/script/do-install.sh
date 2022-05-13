#!/bin/bash
#################################################################
#
# Description       : 部署项目
#
#################################################################
if [ $# != 6 ]
then
    echo "args error:"
    echo "    e.g. : do-install.sh node app db_name db_host db_port db_user"
    echo "           do-install.sh s1@127.0.0.1 game db_game_s1 127.0.0.1 3306 root"
    exit 1
fi

##          入口参数(请勿修改)    ##
#节点
NODE=$1
#应用
APP=$2
# 数据库名
MYSQL_DATABASE=$3
## 数据库地址
MYSQL_HOST=$4
## 数据库端口
MYSQL_PORT=$5
## 数据库用户
MYSQL_USER=$6
#是否强制覆盖
IS_FORCE=false
#节点名
NODE_NAME=`echo ${NODE} | cut -d \@ -f 1`


##           外部配置               ##

## 中心服节点 ##
CENTER_NODE=center@127.0.0.1
## 源目录 ##
SRC_PATH=../
#cookie
COOKIE=game
## 节点路径 ##
NODE_PATH=/data/node
## 数据库密码
MYSQL_PASSWORD=game1234
## 日志路径 ##
LOG_DIR=/data/log/${APP}/${NODE_NAME}/
## tcp 模块 ##
TCP_MODE=ssl ## ssl | gen_tcp


if [ ${APP} != game ] && [ ${APP} != center ]  && [ ${APP} != zone ] && [ ${APP} != charge ] && [ ${APP} != login_server ] && [ ${APP} != unique_id ] && [ ${APP} != war ];then
   echo "Unknow app:"${APP}
   exit 1
fi


##       内部变量(请勿修改)         ##

## 日志名 ##
LOG_NAME=${APP}.log
## 目标目录 ##
TARGET_PATH=${NODE_PATH}/${NODE_NAME}
## 节点配置文件
CONFIG_FILE=${TARGET_PATH}/config/${APP}.config
## 启动脚本
START_FILE=${TARGET_PATH}/script/start.sh
## 启动参数
VMARGS_FILE=${TARGET_PATH}/script/vm.args
## 数据库配置文件
DATABASE_CONFIG_FILE=${TARGET_PATH}/database/config.ini
## 应用模块 ##
APP_MODE=game

ensure_dir(){
    if [ ! -d $1 ]
    then
        mkdir $1
    fi
}


################ 生成路径 ####################

ensure_dir ${NODE_PATH}

if [ ! -d ${SRC_PATH} ]
then
    echo "Src no exists: $SRC_PATH"
    exit 1
fi


if [ -d ${TARGET_PATH} ]
then
    if [[ ${IS_FORCE} = "true" ]]
    then
        echo "[WARNING]: Remove $TARGET_PATH"
        rm -rf ${TARGET_PATH}
    else
        echo "[ERROR]: Target exists $TARGET_PATH"
        exit 1
    fi
fi
echo "1:拷贝目录:"
echo "Move $SRC_PATH  to $TARGET_PATH"
cp -r ${SRC_PATH} ${TARGET_PATH}


################ 生成配置文件 ####################
## 启动参数 ##
create_vm_args_file(){
    echo "-name $NODE"                                                 >  ${VMARGS_FILE}
    echo "-setcookie $COOKIE"                                          >> ${VMARGS_FILE}
    echo "-config ../config/sys_logger.config"                         >> ${VMARGS_FILE}
    echo "+P 32000 "                                                   >> ${VMARGS_FILE}
    echo "+K true"                                                    >> ${VMARGS_FILE}
    echo "-pa ../ebin"                                                >> ${VMARGS_FILE}
    echo "-boot start_sasl"                                           >> ${VMARGS_FILE}
    echo "-env ERL_MAX_ETS_TABLES 60000"                              >> ${VMARGS_FILE}
    echo "-hidden"                                                    >> ${VMARGS_FILE}
    echo "-config ../config/sys_logger.config"                        >> ${VMARGS_FILE}
    echo "-env_file ../config/${APP}.config"                          >> ${VMARGS_FILE}
    echo "-kernel inet_dist_listen_min 21000 inet_dist_listen_max 22000">> ${VMARGS_FILE}
    echo "-s $APP_MODE start"                                         >> ${VMARGS_FILE}
}


##  数据库配置文件 ##
create_database_config(){
    echo "sql_dir = \"./changes\""                 >  ${DATABASE_CONFIG_FILE}
    echo "[$NODE_NAME]"                            >> ${DATABASE_CONFIG_FILE}
    echo "db_user = \"root\""                      >> ${DATABASE_CONFIG_FILE}
    echo "db_passwd = \"$MYSQL_PASSWORD\""         >> ${DATABASE_CONFIG_FILE}
    echo "db_name = \"$MYSQL_DATABASE\""           >> ${DATABASE_CONFIG_FILE}
    echo "db_host = \"$MYSQL_HOST\""               >> ${DATABASE_CONFIG_FILE}
    echo "db_port = $MYSQL_PORT"                   >> ${DATABASE_CONFIG_FILE}
}



## 中心服配置文件 ##
create_center_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {mysql_host, \"$MYSQL_HOST\"}, %%数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, $MYSQL_PORT}, %% 数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"$MYSQL_USER\"},%%数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"$MYSQL_DATABASE\"},%%数据库名称"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"$MYSQL_PASSWORD\"},%%数据库密码"          >> ${CONFIG_FILE}
    echo "    {log_dir, \"$LOG_DIR\"},%%日志目录"                          >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%%日志文件名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 1},%%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error">> ${CONFIG_FILE}
    echo "    {is_center, true} %% 是否是中心节点"                                  >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}

## 游戏服配置文件 ##
create_game_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {max_client_count, 3000},%%最大可连接socket数量"   >> ${CONFIG_FILE}
    echo "    {tcp_accept_count, 80},%%socket监听数量"                           >> ${CONFIG_FILE}
    echo "    {mysql_host, \"$MYSQL_HOST\"},%%数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, $MYSQL_PORT},%%数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"$MYSQL_USER\"},%%数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"$MYSQL_DATABASE\"},%%数据库名"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"$MYSQL_PASSWORD\"},%%数据库密码"          >> ${CONFIG_FILE}
    echo "    {log_dir, \"$LOG_DIR\"},%%日志目录"                          >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%%日志名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 1},%%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error"                                   >> ${CONFIG_FILE}
    echo "    {certfile,\"/data/key/cert.pem\"},%%"                           >> ${CONFIG_FILE}
    echo "    {keyfile, \"/data/key/key.pem\"},%%"                           >> ${CONFIG_FILE}
    echo "    {cacertfile, \"/data/key/cacert.pem\"},%%"                      >> ${CONFIG_FILE}
    echo "    {center_node, '$CENTER_NODE'},%%中心节点"           >> ${CONFIG_FILE}
    echo "    {tcp_mode, '$TCP_MODE'},%%tcp 模块"                 >> ${CONFIG_FILE}
    echo "    {is_create_robot, true},%%是否创建机器人"                 >> ${CONFIG_FILE}
    echo "    {is_trace_proto, false}%%是否启动协议日志"         >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}


## login_server 配置文件 ##
create_login_server_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {log_dir, \"$LOG_DIR\"},%%日志目录"                          >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%%日志文件名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 0},%%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error"                                   >> ${CONFIG_FILE}
    echo "    {certfile,\"/data/key/cert.pem\"},%%"                           >> ${CONFIG_FILE}
    echo "    {keyfile, \"/data/key/key.pem\"},%%"                           >> ${CONFIG_FILE}
    echo "    {cacertfile, \"/data/key/cacert.pem\"},%%"                      >> ${CONFIG_FILE}
    echo "    {mysql_host, \"${MYSQL_HOST}\"},%% 数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, ${MYSQL_PORT}},%% 数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"${MYSQL_USER}\"},%% 数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"${MYSQL_DATABASE}\"},%% 数据库名"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"${MYSQL_PASSWORD}\"},%% 数据库密码"          >> ${CONFIG_FILE}
    echo "    {center_node, '${CENTER_NODE}'} %% 中心服"                  >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}


## 跨服节点  配置文件 ##
create_zone_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {log_dir, \"/data/log/zone/$NODE_NAME/\"}, %% 日志目录"      >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%% 日志文件名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 1}, %%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error"                                   >> ${CONFIG_FILE}
    echo "    {mysql_host, \"$MYSQL_HOST\"}, %%数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, $MYSQL_PORT}, %%数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"$MYSQL_USER\"}, %%数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"$MYSQL_DATABASE\"},%%数据库名"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"$MYSQL_PASSWORD\"},%%数据库密码"          >> ${CONFIG_FILE}
    echo "    {center_node, '$CENTER_NODE'} %%中心节点"           >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}

## 充值节点  配置文件 ##
create_charge_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {log_dir, \"/data/log/charge/$NODE_NAME/\"},%%日志目录"      >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%%日志名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 1},%%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error"                                   >> ${CONFIG_FILE}
    echo "    {mysql_host, \"$MYSQL_HOST\"},%%数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, $MYSQL_PORT},%%数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"$MYSQL_USER\"},%%数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"$MYSQL_DATABASE\"},%%数据库名"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"$MYSQL_PASSWORD\"},%%数据库密码"          >> ${CONFIG_FILE}
    echo "  {center_node, '${CENTER_NODE}'} %% 中心服"                  >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}

## 唯一id节点  配置文件 ##
create_unique_id_config(){
    echo "["                                                     >  ${CONFIG_FILE}
    echo "    {log_dir, \"$LOG_DIR\"},%%日志目录"                          >> ${CONFIG_FILE}
    echo "    {log_name, \"$LOG_NAME\"},%%日志名"                        >> ${CONFIG_FILE}
    echo "    {log_level, 1},%%日志输出级别 0:debug 1:info 2:warning 3:error 4:fetal_error"                                   >> ${CONFIG_FILE}
    echo "    {mysql_host, \"$MYSQL_HOST\"},%%数据库地址"                  >> ${CONFIG_FILE}
    echo "    {mysql_port, $MYSQL_PORT},%%数据库端口"                      >> ${CONFIG_FILE}
    echo "    {mysql_user, \"$MYSQL_USER\"},%%数据库用户名"                  >> ${CONFIG_FILE}
    echo "    {mysql_database, \"$MYSQL_DATABASE\"},%%数据库名"          >> ${CONFIG_FILE}
    echo "    {mysql_password, \"$MYSQL_PASSWORD\"},%%数据库密码"          >> ${CONFIG_FILE}
    echo "    {center_node, '$CENTER_NODE'} %%中心节点"          >> ${CONFIG_FILE}
    echo "]."                                                    >> ${CONFIG_FILE}
}

echo "2:生成启动参数文件:script/vm.args"
## 生成启动参数文件
create_vm_args_file

echo "3:生成节点配置文件:config/${APP}.config"
## 生成节点配置文件
case ${APP} in
    center)
        create_center_config
    ;;
    game)
        create_game_config
    ;;
    login_server)
        create_login_server_config
    ;;
    zone)
        create_zone_config
    ;;
    unique_id)
        create_unique_id_config
    ;;
    charge)
        create_charge_config
    ;;
    war)
        create_zone_config
    ;;
    *)
        echo "Unknow app:"${APP}
        exit 1
esac

echo "4:生成数据库配置文件:database/config.ini"
## 生成数据库配置文件
create_database_config


echo "5:初始化数据库:$MYSQL_DATABASE"
cd ${TARGET_PATH}/database
./db_version update ${NODE_NAME}

echo "部署完毕."
