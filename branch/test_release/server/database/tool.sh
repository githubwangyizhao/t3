#!/bin/bash

case `uname -s` in
    Linux)
        DB_VERSION=db_version
        ;;
    Darwin)
        DB_VERSION=db_version.mac
        ;;
esac
router_action(){
	case $1 in
			1|update) 
				./$DB_VERSION update localhost
			;;
			2|drop) 
				./$DB_VERSION drop localhost
			;;
			3|version) 
				./$DB_VERSION version localhost
			;;
			4|update_all)
				./$DB_VERSION update center
                ./$DB_VERSION update charge
                ./$DB_VERSION update unique_id
                ./$DB_VERSION update login_server
                ./$DB_VERSION update war
                ./$DB_VERSION update zone
                ./$DB_VERSION update localhost
                ./$DB_VERSION update test
			;;
			q)  break
			;;
			*) echo "输入错误"
			;;
		esac
}
action(){
	while :
	do
		echo -e "\n=========================================="
		echo -e "   1. 更新数据库结构"
		echo -e "   2. 删除数据库"
		echo -e "   3. 获取数据库版本"
		echo -e "   4. 更新所有数据库结构"
		echo -e "==========================================\n"
		read -p '请选择: ' action
		router_action $action
	done	
}
svn up &&
if [ $# = 1 ];
then
	router_action $1
else
	action
fi  
