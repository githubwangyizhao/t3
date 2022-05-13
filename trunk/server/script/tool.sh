#!/bin/bash
## 版本 2018081601
VMARGS_PATH="vm.args"
SCRIPT=`basename $0`
# Extract the target node name from node.args
NAME_ARG=`egrep '^-s?name' ${VMARGS_PATH}`
if [ -z "$NAME_ARG" ]; then
    echo "vm.args needs to have either -name or -sname parameter."
    exit 1
fi

# Extract the target cookie
COOKIE_ARG=`grep '^-setcookie' ${VMARGS_PATH}`
if [ -z "$COOKIE_ARG" ]; then
    echo "vm.args needs to have a -setcookie parameter."
    exit 1
fi

#COOKIE=`echo ${COOKIE_ARG} | awk '{print $2}'`

NODE=`echo ${NAME_ARG} | awk '{print $2}'`
#GM_NODE="gm_${REMOTE_NODE}"
echo "NODE:"${NODE}
NODETOOL="escript nodetool $NAME_ARG $COOKIE_ARG"
PIDFILE="node.pid"

router_action(){
    case $1 in
            start)# 启动节点(后台运行)
                RES=`$NODETOOL ping`
                if [ "$RES" = "pong" ]; then
                    echo "Node is already running!"
                    exit 0
                fi
                erl ulimit -n 320000 -args_file ${VMARGS_PATH} -detached
                i=1
                while [ ! -n "$pid" ];
                do
                    echo "Waiting ${i}s ......"
                    if [ $i -ge 6  ]; then
                        echo "Start node($NODE) failed!!!!!!"
                        exit 1
                    fi
                    ((i++))
                    sleep 1
                    pid=`ps ax -o pid= -o command= | grep " $NODE " | grep -v grep |awk '{print $1}'`
                done
                echo $pid > $PIDFILE;
                echo "Start node($NODE) success, pid:$pid."
            ;;
            stop)# 停止节点(关闭进程)
                #pid=`ps ax -o pid= -o command= | grep " $NODE " | grep -v grep |awk '{print $1}'`
                RES=`$NODETOOL ping`
                if [ "$RES" != "pong" ]; then
                    echo "Node is not running!"
                    exit 0
                fi
                pid=`cat $PIDFILE`
                $NODETOOL stop
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
#                echo "Waiting process($pid) close..."
#                while `kill -0 $pid 2>/dev/null`;
#                do
#                    sleep 1
#                done
                rm -f $PIDFILE
                echo "Process($pid) closed."
            ;;
            restart)# 重启节点(进程未关闭)
                $NODETOOL restart
                 ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            reboot)
                $NODETOOL reboot
                 ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            console)# 启动节点(控制台)
                RES=`$NODETOOL ping`
                if [ "$RES" = "pong" ]; then
                    echo "Node is already running!"
                    exit 1
                fi
                erl ulimit -n 320000 -args_file ${VMARGS_PATH}
            ;;
            ping)
                $NODETOOL ping
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            reload)# 热更新
                $NODETOOL rpcterms mod_server_update hot_update ""
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            reload_env) #重载配置
                $NODETOOL rpcterms env reload ""
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            pull) #下拉配置数据
                $NODETOOL rpcterms mod_server_sync pull ""
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            version) # 获取节点当前版本
                $NODETOOL rpcterms version get_server_version ""
                ES=$?
                if [ "$ES" -ne 0 ]; then
                    exit $ES
                fi
            ;;
            help) # 帮助
                echo "USAGE: $SCRIPT OPTION"
                echo "OPTIONS:"
                echo "    start       启动节点(守护进程)."
                echo "    stop        停止节点."
                echo "    restart     重启节点."
                echo "    console     启动节点(控制台)."
                echo "    connect     连接节点."
                echo "    ping        查看节点存活."
                echo "    reload      热更新."
                echo "    reload_env  重载配置."
                echo "    pull        下拉配置数据."
                echo "    version     查看节点当前版本."
            ;;
            *)
                router_action help
                #echo "Usage: $SCRIPT [start|stop|restart|console|ping|reload|reload_env|version|help|pull]"
                exit 1
            ;;
    esac
}

if [ $# != 1 ]
then
    router_action args_error
fi

router_action $1
