@echo off
cls

title server
erl ^
-pa ../ebin ^
+P 320000 ^
-env ERL_MAX_ETS_TABLES 200000 ^
-hidden ^
-boot start_sasl ^
-name t3_unique_id@127.0.0.1 ^
-setcookie game ^
-config ../config/sys_logger.config ^
-env_file ../config/unique_id.config ^
-s game start
pause