@echo off
CHCP 936
title T3���ݿ�����
cls
::color 0A
:cho

echo.
echo ==========================================
echo    1. �������ݿ�ṹ
echo    2. ɾ�����ݿ�
echo    3. ��ȡ���ݿ�汾
echo    4. ���³�ֵ���ݿ�ṹ
echo    5. ɾ�����ݿ�
echo    6. �������з��������ݽṹ
echo ==========================================
:choice
set resture_file_name=
set choice=
set /p choice=          ��ѡ��: 
if /i "%choice%"=="1" goto update
if /i "%choice%"=="2" goto drop
if /i "%choice%"=="3" goto version
if /i "%choice%"=="4" goto :update_charge
if /i "%choice%"=="5" goto :drop_charge
if /i "%choice%"=="6" goto :update_all

echo �����������������...
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