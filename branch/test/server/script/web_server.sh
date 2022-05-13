#!/bin/bash

ulimit -n 320000 &&
erl \
+P 320000 \
+K true \
-pa ../ebin \
-boot start_sasl \
-name 'web_server@192.168.31.100' \
-env ERL_MAX_ETS_TABLES 30000 \
-setcookie game \
-hidden \
-config ../config/sys_logger.config \
-env_file ../config/web_server.config \
-s web_server start
