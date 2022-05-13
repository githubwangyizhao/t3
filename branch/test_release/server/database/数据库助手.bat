@echo off
CHCP 936
title T3数据库助手
cls
::color 0A
:cho

echo.
echo ==========================================
echo    1. 更新数据库结构
echo    2. 删除数据库
echo    3. 获取数据库版本
echo    4. 更新充值数据库结构
echo    5. 删除数据库
echo    6. 更新所有服务器数据结构
echo ==========================================
:choice
set resture_file_name=
set choice=
set /p choice=          请选择: 
if /i "%choice%"=="1" goto update
if /i "%choice%"=="2" goto drop
if /i "%choice%"=="3" goto version
if /i "%choice%"=="4" goto :update_charge
if /i "%choice%"=="5" goto :drop_charge
if /i "%choice%"=="6" goto :update_all

echo 输入错误，请重新输入...
echo.
goto cho

:update
echo.
db_version.exe update localhost
goto end

:update_charge
echo.
db_version.exe update charge
goto end

:update_all
echo.
db_version.exe update center
db_version.exe update login_server
db_version.exe update unique_id
db_version.exe update charge
db_version.exe update war
db_version.exe update zone
db_version.exe update localhost
goto end

:drop
echo.
db_version.exe drop localhost
goto end

:drop_charge
echo.
db_version.exe drop charge
goto end

:version
echo.
db_version.exe version localhost
goto end

:end
goto :cho

:cls_
cls
goto :cho

:quit