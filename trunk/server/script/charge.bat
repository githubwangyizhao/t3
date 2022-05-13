@echo off
cls

title server
werl ^
-pa ../ebin ^
+P 320000 ^
-env ERL_MAX_ETS_TABLES 30000 ^
-hidden ^
-boot start_sasl ^
-name t3_charge@192.168.31.160 ^
-setcookie game ^
-config ../config/sys_logger.config ^
-env_file ../config/charge.config ^
-s game start

