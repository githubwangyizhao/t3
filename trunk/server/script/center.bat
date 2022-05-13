@echo off
cls

title server
erl ^
-pa ../ebin ^
+P 200000 ^
-boot start_sasl ^
-name t3_center@192.168.31.160 ^
-setcookie game ^
-hidden ^
-config ../config/sys_logger.config ^
-env_file ../config/center.config ^
-s game start 
pause