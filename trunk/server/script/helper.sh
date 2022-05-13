#!/bin/bash
#################################################################
#                                                               #
#                            项目工具                           #
#                                                               #
#################################################################

case `uname -s` in
    Linux)
        GEN_PROTO=gen_proto
        DB_VERSION=db_version
        ;;
    Darwin)
        GEN_PROTO=gen_proto.mac
        DB_VERSION=db_version.mac
        ;;
esac
router_action(){
    case $1 in
        1|build_proto) 
            ./$GEN_PROTO false;
        ;;
        2|update_database)
            pwd_=`pwd`
            cd ../database &&
            ./$DB_VERSION update localhost &&
            cd $pwd_
        ;;
        3|build_database) 
            erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_db start -s init stop
        ;;
        4|build_table) 
            erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_table start -s init stop
        ;;
        5|build_map) 
            erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_map start -s init stop
        ;;
        6|build_scene) 
            erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_scene start -s init stop
        ;;
        7|make_all)
            erl  -pa ../ebin  -s qmake all  -noshell -s init stop
        ;;
        8|compile_file)     
            echo -n "源文件路径: "
            read filename
            erl -noshell -pa  -s make files ../src/$filename -s init stop
        ;;
        9|pre_build)
            escript pre_build.escript
        ;;
        10|update)
            svn up ../
            svn up ../../plan/配置表/
            svn up ../../resource/assets/scene/map/
            svn up ../../resource/assets/scene/scenedata/
            #pwd_=`pwd`
            #cd .. &&
            #svn up &&
            #cd $pwd_
        ;;
        11|clean)
            rm -vf ../ebin/*.beam &&
            rm -vf ../src/gen/*.erl &&
            rm -vf ../include/gen/*.hrl
        ;;
        12|auto)
            router_action clean &&
            router_action update &&
            router_action pre_build &&
            router_action build_proto &&
            router_action build_database &&
            router_action build_table &&
            router_action build_map &&
            router_action build_scene &&
            router_action make_all 
        ;;
        q)  break
        ;;
        *)  echo "输入错误"
        ;;
    esac
}
action(){
    while :
    do
        echo -e "\n=========================================="
        echo -e " 1. 生成协议"
        echo -e " 2. 更新数据库结构"
        echo -e " 3. 生成数据库映射"
        echo -e " 4. 生成csv映射"
        echo -e " 5. 生成地图数据"
        echo -e " 6. 生成场景数据"
        echo -e " 7. 编译项目"
        echo -e " 8. 编译文件"
        echo -e " 9. 初始化项目"
        echo -e " 10. SVN 更新"
        echo -e " 11. 清理项目"
        echo -e " 12. 自动构建"
        echo -e "=========================================="
        read -p '请选择: ' action
        router_action $action
    done    
}

if [ $# = 1 ];
then
    router_action $1
else
    action
fi  
