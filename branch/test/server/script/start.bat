@echo off
cls

title server
erl ^
-pa ../ebin ^
+P 320000 ^
-env ERL_MAX_ETS_TABLES 200000 ^
-hidden ^
-boot start_sasl ^
-name t3_s160@192.168.31.160 ^
-setcookie game ^
-config ../config/sys_logger.config ^
-env_file ../config/game.config ^
-s game start
pause