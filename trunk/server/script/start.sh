#!/bin/bash

ulimit -n 10240 &&
erl \
+P 320000 \
+K true \
-pa ../ebin \
-boot start_sasl \
-name 't3_s1@192.168.31.100' \
-env ERL_MAX_ETS_TABLES 30000 \
-setcookie game \
-hidden \
-config ../config/sys_logger.config \
-env_file ../config/game.config \
-s game start
