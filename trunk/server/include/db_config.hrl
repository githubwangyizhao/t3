%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             数据库配置
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------
%%%%%%%%%%%%%%%%  MYSQL CONFIG %%%%%%%%%%%%%%%%%%
-define(MYSQL_HOST,     util:to_list(env:get(mysql_host, "localhost"))).
-define(MYSQL_PORT,     util:to_int(env:get(mysql_port,  3306))).
-define(MYSQL_USERNAME, util:to_list(env:get(mysql_user, "root"))).
-define(MYSQL_PASSWORD, util:to_list(env:get(mysql_password, "gamehome1234"))).
-define(MYSQL_DATABASE, util:to_list(env:get(mysql_database, "game"))).
-define(MYSQL_POOL_SIZE,util:to_int(env:get(mysql_poolsize, 1))).
-define(BACKUP_DIR,     env:get(mysql_backup_dir, "../data/mysql_backup/")).

-ifdef(debug).
-define(DB_ERROR(Format, Args), db_log_srv:write_log("[ERROR] " ++ Format, Args), io:format("[ERROR] " ++ Format, Args)).
-define(DB_LOG(Format, Args), db_log_srv:write_log("[LOG] " ++ Format, Args), io:format("[LOG] " ++ Format, Args)).
-else.
-define(DB_ERROR(Format, Args), db_log_srv:write_log("[ERROR] " ++ Format, Args)).
-define(DB_LOG(Format, Args), db_log_srv:write_log("[LOG] " ++ Format, Args)).
-endif.

%% db 回写间隔
-define(DB_BIN_LOG_SYNC_TIME, util:to_int(env:get(db_sync_time_ms, 1 * 60 * 1000))).       %% 每10秒 同步到数据库

%%-ifdef(debug).
%%-define(DB_BIN_LOG_SYNC_TIME, util:to_int(env:get(mysql_poolsize, 1)))).       %% 每10秒 同步到数据库
%%-else.
%%-define(DB_BIN_LOG_SYNC_TIME, 3 * 60 * 1000).   %% 每3分钟 同步到数据库
%%-endif.

-define(DB_WORKER_NUM, 10).

-define(POWER_LOAD_TABLES, power_load_tables).
-define(COMPRESS_TABLES, compress_tables).
-define(INDEX, index).
-define(INIT_TABLES, init_tables).
-define(DETS_TABLES, dets_tables).
-define(HOT_LOAD_TABLES, hot_load_tables).
-define(DIRTY_TABLES, dirty_tables).
-define(INCREMENT_SYNC_TABLES, increment_sync_tables).
-define(SLICE_COLUMN_LIST, slice_column_list).
-define(DETS_DATA_DIR, "../data/dets/").
-define(DB_CONFIG_FILE, "../config/db.config").
-define(DB_RECORD_FILE, "../include/gen/db.hrl").
-define(DB_FILE, "../src/gen/db.erl").
-define(DB_INIT_FILE, "../src/gen/db_init.erl").
-define(DB_INDEX_FILE, "../src/gen/db_index.erl").
-define(DB_LOAD_FILE, "../src/gen/db_load.erl").
-define(AUTO_INCREMENT, "auto_increment").
-define(PRI, "PRI").


-define(DB_LOG_SRV, db_log_srv).
-define(GAME_DB_SYNC, db_sync).
-define(GAME_DB_LOAD_PROXY, db_load_proxy).
-define(GAME_DB, game_db).
-define(LOG_DATA_TABLE_SUF, "_log").
-define(SQL_PAGE_NUM, 50000).
-define(INDEX_KEY_PRE, "IndexKey").
-define(SLICE_NUM, 100).
-define(INDEX_PRE, "idx_").
-define(DB_RECORD_PRE, "db_").

-record(table_info, {
    table_name,
    'Field',
    'Type',
    'Collation',
    'Null',
    'Key',
    'Default',
    'Extra',
    'Privileges',
    'Comment'
}).
-record(ets_table_fields, {
    table_name,
    keys,
    fields
}).

-record(ets_table_info, {
    table_name,
    rows
}).
