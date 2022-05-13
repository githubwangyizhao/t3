@echo off
CHCP  936
title T3 ��Ŀ����

::color 0A

if "%1" == "" (
    cls
    goto cho
) else (
    set choice=%1
    goto router
)



% ·�� % 
:cho
echo.
echo ==========================================
echo    1. ����Э��
echo    2. �������ݿ�ṹ
echo    3. �������ݿ�ӳ��
echo    4. ����csvӳ��
echo    5. ���ɵ�ͼ����
echo    6. ���ɳ�������
echo    7. ������Ŀ
echo    9. ��ʼ����Ŀ
echo    10.����������
echo    11.������Ŀ
echo    12.SVN����
echo    13.���������ֿ�
echo ==========================================
:choice
set choice=
set /p choice=          ��ѡ��: 
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
echo �����������������
echo.
goto cho

%����������%
:build_sensitive_words
echo. 
echo ���������������ļ�...
erl -noshell -pa ../ebin -s string_file start -s init stop
erl +t 9999999 -noshell -pa  -s make files ../src/gen/keycheck_vague -s init stop
erl +t 9999999 -noshell -pa  -s make files ../src/gen/keycheck -s init stop
echo �����ֳɹ����ɲ�����...
goto end

%������Ŀ%
:make_all 
echo. 
erl +t 9999999 -pa ../ebin  -s qmake all  -noshell -s init stop
goto end



%���ɵ�ͼ%
:build_map
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_map start -s init stop
goto end



%���ɳ���%
:build_scene
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_scene start -s init stop
goto end

%�������ݿ�%
:update_database
echo. 
cd ..\database
db_version.exe update localhost
cd ..\script
goto end



%������Ŀ%
:clean_up
echo. 
echo ����������Ŀ...
::del /a/f/s/q ..\ebin\*.beam
::del /a/f/s/q ..\src\gen\*.erl
::del /a/f/s/q ..\include\gen\*.hrl
goto end

%������Ŀ%
:svn_up
echo ���´���
lib\svn\svn up ../
echo �������ñ�
lib\svn\svn up ../../table/csv/
echo ���µ�ͼ
lib\svn\svn up ../../resource/assets/scene/map/
echo ���³���
lib\svn\svn up ../../resource/assets/scene/scenedata/
goto end

%����������%
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



%��ʼ����Ŀ%
:pre_build
echo. 
lib\svn\svn up ../ebin/
escript pre_build.escript
goto end




%����Э��% 
:build_proto
echo. 
gen_proto.exe true
:php build_proto.php true
:erl -noshell -pa ../ebin -env_file ../config/game.config -s  build_proto start -s init stop
echo. 
goto end



%�������ݿ�ӳ��%
:build_database
echo. 
erl -noshell -pa ../ebin -env_file ../config/game.config -s build_db start -s init stop
goto end



%����csv%
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