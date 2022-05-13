@echo off
cls

title server
werl ^
-pa ../ebin ^
+P 200000 ^
-boot start_sasl ^
-name t3_zone@192.168.31.160 ^
-setcookie game^
-hidden ^
-config ../config/sys_logger.config ^
-env_file ../config/zone.config ^
-s game start 
pause