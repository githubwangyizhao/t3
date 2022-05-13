@echo off
CHCP  936
title T3 项目工具

::color 0A

if "%1" == "" (
    cls
    goto cho
) else (
    set choice=%1
    goto router
)



% 路由 % 
:cho
echo.
echo ==========================================
echo    1. 生成协议
echo    2. 更新数据库结构
echo    3. 生成数据库映射
echo    4. 生成csv映射
echo    5. 生成地图数据
echo    6. 生成场景数据
echo    7. 编译项目
echo    9. 初始化项目
echo    10.启动服务器
echo    11.清理项目
echo    12.SVN更新
echo    13.生成屏蔽字库
echo ==========================================
:choice
set choice=
set /p choice=          请选择: 
:router
if /i "%choice%"=="1" goto build_proto
if /i "%choice%"=="build_proto" goto build_proto
if /i "%choice%"=="2" goto update_database
if /i "%choice%"=="3" goto build_database
if /i "%choice%"=="4" goto build_table
if /i "%choice%"=="build_table" goto build_table
if /i "%choice%"=="5" goto build_map
if /i "%choice%"=="build_map" goto build_map
if /i "%choice%"=="6" goto build_scene
if /i "%choice%"=="build_scene" goto build_scene
if /i "%choice%"=="7" goto make_all
if /i "%choice%"=="make_all" goto make_all
if /i "%choice%"=="9" goto pre_build
if /i "%choice%"=="10" goto start_server
if /i "%choice%"=="start_server" goto start_server
if /i "%choice%"=="11" goto clean_up
if /i "%choice%"=="12" goto svn_up
if /i "%choice%"=="13" goto build_sensitive_words
echo 输入错误，请重新输入
echo.
goto cho

%生成敏感字%
:build_sensitive_words
echo. 
echo 正在生成敏感字文件...
erl -noshell -pa ../ebin -s string_file start -s init stop
erl +t 9999999 -noshell -pa  -s make files ../src/gen/keycheck_vague -s init stop
erl +t 9999999 -noshell -pa  -s make files ../src/gen/keycheck -s init stop
echo 敏感字成功生成并编译...
goto end

%编译项目%
:make_all 
echo. 
erl +t 9999999 -pa ../ebin  -s qmake all  -noshell -s init stop
goto end



%生成地图%
:build_map
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_map start -s init stop
goto end



%生成场景%
:build_scene
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_scene start -s init stop
goto end

%更新数据库%
:update_database
echo. 
cd ..\database
db_version.exe update localhost
cd ..\script
goto end



%清理项目%
:clean_up
echo. 
echo 正在清理项目...
del /a/f/s/q ..\ebin\*.beam 
del /a/f/s/q ..\src\gen\*.erl
del /a/f/s/q ..\include\gen\*.hrl
goto end

%更新项目%
:svn_up
echo 更新代码
lib\svn\svn up ../
echo 更新配置表
lib\svn\svn up ../../table/csv/
echo 更新地图
lib\svn\svn up ../../resource/assets/scene/map/
echo 更新场景
lib\svn\svn up ../../resource/assets/scene/scenedata/
goto end

%启动服务器%
:start_server
echo. 
::start start.bat
start werl ^
-pa ../ebin ^
+t 99999999 ^
+P 320000 ^
-config ../config/sys_logger.config ^
-env ERL_MAX_ETS_TABLES 200000 ^
-boot start_sasl ^
-hidden ^
-name s89@192.168.31.89 ^
-setcookie game ^
-env_file ../config/game.config ^
-s game start
goto cho



%初始化项目%
:pre_build
echo. 
lib\svn\svn up ../ebin/
escript pre_build.escript
goto end




%生成协议% 
:build_proto
echo. 
gen_proto.exe true
:php build_proto.php true
:erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_proto start -s init stop
echo. 
goto end



%生成数据库映射%
:build_database
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s build_db start -s init stop
goto end



%生成csv%
:build_table
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s build_table start -s init stop
goto end



:end
if "%1" == "" (goto cho) else (goto quit)

:cls_
cls
goto :cho

:quit