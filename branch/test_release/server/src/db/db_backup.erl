%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc         数据库备份
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_backup).
-include("logger.hrl").
-include("db_config.hrl").

-export([
    backup/0,
    backup/1
]).

backup() ->
    {{YY, MM, DD}, {H, M, S}} = util_time:local_datetime(),
    Name = lists:concat(["udpate_", YY, "_", MM, "_", DD, "_", H, "_", M, "_", S, ".sql"]),
    backup(Name).
backup(Name) ->
    MysqlDatabase = ?MYSQL_DATABASE,
    NodeName = mod_server:get_node_name(),
%%    FileName = lists:concat([MysqlDatabase, ".sql"]),
    FileName = filename:join([?BACKUP_DIR, NodeName, Name]),
    util_file:ensure_dir(FileName),
%%    LogTableList = db:get_log_table_list(),
%%    IgnoreList = string:join(["--ignore-table=" ++ MysqlDatabase ++ "." ++ LogTable || LogTable <- LogTableList], " "),
    IgnoreList = "",
    Cmd =
        io_lib:format("mysqldump -h ~s -u ~s -p~s --single-transaction --force -q ~s ~s > ~s", [
            ?MYSQL_HOST,
            ?MYSQL_USERNAME,
            ?MYSQL_PASSWORD,
            MysqlDatabase,
            IgnoreList,
            FileName
        ]),
%%    ?INFO("CMD:~s~n", [Cmd]),
    ?INFO("Start backup database:~p~n", [{MysqlDatabase, FileName}]),
    {Time1, _} = statistics(wall_clock),
    Result = os:cmd(Cmd),
    {Time2, _} = statistics(wall_clock),
    Sec = (Time2 - Time1) / 1000.0,
    ?INFO(
        "Backup finish->\n"
        "  database:~p~n"
        "      file:~p~n"
        "      time:~p~n"
        "    result:~s~n",
        [
            MysqlDatabase,
            FileName,
            Sec,
            Result
        ]
    ).

