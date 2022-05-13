%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            构建数据表映射
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(build_db).

%% API
-export([start/0]).

-include("common.hrl").
-include("db_config.hrl").

start() ->
    {_, S, _} = os:timestamp(),
    put(start_second, S),
    env:init(),
    %************** 1.读取db配置 **************%
    DbConfigs = util_file:load_term(?DB_CONFIG_FILE),

    process_flag(trap_exit, true),
    crypto:start(),

    %************** 2.连接数据库 **************%
    mysql:start_link(?GAME_DB, ?MYSQL_HOST, ?MYSQL_PORT, ?MYSQL_USERNAME, ?MYSQL_PASSWORD, ?MYSQL_DATABASE, fun log/4, utf8),
    Sql = io_lib:format(
        " SELECT `table_name` FROM information_schema.tables WHERE table_schema='~s' and table_type='base table';",
        [?MYSQL_DATABASE]
    ),
    {data, Res} = mysql:fetch(?GAME_DB, erlang:list_to_binary(Sql)),
    Rows = lib_mysql:get_rows(Res),

    %************** 3.获取所有数据库表 **************%
    DbTableList = [try_binary_to_list(hd(Row)) || Row <- Rows, Row =/= [<<"db_version">>]],


    %************** 4.初始化配置 **************%
    ets:new(ets_table_fields, [set, named_table, public, {keypos, #ets_table_fields.table_name}]),
    ets:new(ets_table_info, [set, named_table, public, {keypos, #ets_table_info.table_name}]),

    init_all_ets_table_info(DbTableList),
    init_all_ets_table_fields(DbTableList),

    % 脏表
    DirtyTableList = [util:to_list(E) || E <- util_list:opt(dirty_tables, DbConfigs)],

    % 内存表
    MemGameDbTableList = DbTableList -- DirtyTableList,
    % 冷表
    PowerLoadGameDbTableList = lists:usort(
        get_real_power_tables(MemGameDbTableList) ++
        [util:to_list(E) || E <- util_list:opt(power_load_tables, DbConfigs)]
    ),
%%    PowerLoadGameDbTableList = MemGameDbTableList,
    % 热表
%%    HotLoadGameDbTableList = [],
%%    % 热表
    HotLoadGameDbTableList = MemGameDbTableList -- PowerLoadGameDbTableList,
    % 增量表
    IncrementSyncTables = [util:to_list(E) || E <- util_list:opt(increment_sync_tables, DbConfigs)],


    % 冷表
    env:set(?POWER_LOAD_TABLES, PowerLoadGameDbTableList),
    % 压缩表
    env:set(?COMPRESS_TABLES, util_list:opt(compress, DbConfigs)),
    % 索引配置
    env:set(?INDEX, util_list:opt(?INDEX, DbConfigs)),
    % 内存表
    env:set(?INIT_TABLES, MemGameDbTableList),
    % dets表
    env:set(?DETS_TABLES,[util:to_list(E) || E <-  util_list:opt(dets, DbConfigs)]),
    % 热表
    env:set(?HOT_LOAD_TABLES, HotLoadGameDbTableList),
    % 脏表
    env:set(?DIRTY_TABLES, DirtyTableList),
    % 增量表
    env:set(?INCREMENT_SYNC_TABLES, IncrementSyncTables),
    % 分表配置
    env:set(?SLICE_COLUMN_LIST, util_list:opt(slice_column, DbConfigs)),

    lists:foreach(
        fun(T) ->
            ?ASSERT(is_power_table(util:to_list(T)), {dets_table_must_power_load_table, T})
        end,
        util_list:opt(dets, DbConfigs)
    ),
    %************** 5.生成映射 **************%
    Ref = make_ref(),
    Self = self(),
    io:format("~nStarting build db mapping...~n~n"),

    % db.hrl
    create_db_hrl(DbTableList),

    % game_db.erl
    spawn_link(fun() -> create_db_erl(DbTableList, Self, Ref) end),

    % game_db_init.erl
    spawn_link(fun() -> create_db_init_erl(MemGameDbTableList, Self, Ref) end),

    % game_db_load.erl
    spawn_link(fun() -> create_db_load_erl(MemGameDbTableList, Self, Ref) end),

%%    % game_db_dump.erl
%%    spawn_link(fun() -> create_db_dump_erl(MemGameDbTableList, Self, Ref) end),

    % game_db_index.erl
    spawn_link(fun() -> create_db_index_erl(MemGameDbTableList, Self, Ref) end),

    % 等待进程结束
    do_wait_worker(4, Ref),
    {_, S1, _} = os:timestamp(),
    S2 = S1 - S,
    io:format(
        "~n~n"
        "*************************************************************~n~n"
        "                       All finished                          ~n"
        "                  Used ~p minute, ~p second         ~n~n"
        "*************************************************************~n~n",
        [S2 div 60, S2 rem 60]
    ).

try_binary_to_list(A) when is_binary(A) ->
    binary_to_list(A);
try_binary_to_list(A) ->
    A.


log(Module, Line, error, FormatFun) ->
    {Format, Arguments} = FormatFun(),
    logger:error("DB_ERROR!!!!!! ~w:~b: " ++ Format ++ "~n", [Module, Line] ++ Arguments);
log(_Module, _Line, _Level, _FormatFun) -> noop.


do_wait_worker(0, _Ref) ->
    ok;
do_wait_worker(N, Ref) ->
    receive
        {ack, Ref} ->
            do_wait_worker(N - 1, Ref);
        {error, Ref} ->
            erlang:halt(1);
        {'EXIT', _P, _Reason} ->
            do_wait_worker(N, Ref);
        _Other ->
            io:format("receive unknown msg:~p~n", [_Other]),
            do_wait_worker(N, Ref)
    end.

create_db_erl(TableNameList, Parent, Ref) ->
    io:format("Create file ~s~n", [?DB_FILE]),
%%    DbPool = ?GAME_DB,
    {
        ReadCode,
        WriteCode,
        TranSqlCode,
        ValidToSqlCode,
        TranUpdateCode,
        SaveBinLogCode,
        DirtyWriteCode,

        DeleteCode,
        DeleteAllCode
    } =
        lists:foldl(
            fun(TableName, {T0, T1, T2, T3, T4, T5, T6, T7, T8}) when is_list(TableName) ->
                Rows = get_table_info_rows(TableName),
                case lists:member(util:to_list(TableName), env:get(?DIRTY_TABLES)) of
                    true ->
                        {
                            T0,
                            T1,
                            [build_tran_to_sql_code1(Rows) | T2],
                            T3,
                            T4,
                            T5,
                            [build_dirty_write_code(TableName) | T6],

                            T7,
                            T8
                        };
                    false ->
                        {
                            [build_read_code(Rows) | T0],
                            [build_write_code(Rows) | T1],
                            [build_tran_to_sql_code(Rows) | T2],
                            [build_valid_to_sql(Rows) | T3],
                            [build_generate_update_sql_code(Rows) | T4],
                            [build_save_bin_log_code(Rows) | T5],
                            T6,

                            [build_delete_code(Rows) | T7],
                            [build_delete_all_code(Rows) | T8]
                        }
                end
            end,
            {[], [], [], [], [], [], [], [], []},
            TableNameList
        ),

    LogTableList = lists:foldl(
        fun(TableName, Tmp) ->
            case is_log_data_table(TableName) of
                true ->
                    [TableName | Tmp];
                false ->
                    Tmp
            end
        end,
        [],
        TableNameList
    ),
%%    io:format("~n~nNotLogTableList:~p~n~n~n", [NotLogTableList]),
    {SliceSelectCode, NoSliceSelectCode, SliceDeleteSelectCode, NoSliceDeleteSelectCode, SliceTableListCode, SliceTableCode} = lists:foldl(
        fun(TableName, {SL, NSL, SDL, NSDL, TmpSliceTableListCode, TmpSliceTableCode}) ->

            Rows = get_table_info_rows(TableName),

            TableName = (hd(Rows))#table_info.table_name,
            case lists:member(util:to_list(TableName), env:get(?DIRTY_TABLES)) of
                true ->
                    {SL, NSL, SDL, NSDL, TmpSliceTableListCode, TmpSliceTableCode};
                false ->
                    case is_slice_table(TableName) of
                        true ->
                            {
                                [build_slice_select_code(Rows) | SL],
                                NSL,
                                [build_slice_delete_select_code(Rows) | SDL],
                                NSDL,
                                [build_slice_table_list_code(TableName) | TmpSliceTableListCode],
                                [build_slice_table_code(TableName) | TmpSliceTableCode]

                            };

                        false ->
                            {
                                SL,
                                [build_no_slice_select_code(Rows) | NSL],
                                SDL,
                                [build_no_slice_delete_select_code(Rows) | NSDL],
                                TmpSliceTableListCode,
                                TmpSliceTableCode
                            }

                    end
            end

        end,
        {[], [], [], [], [], []},
        TableNameList
    ),


    Content =
        file_head() ++
        game_db_file_head() ++
        game_db_file_fix_context() ++
        ?IF(ReadCode =/= "", lists:concat([string:join(ReadCode, ";\n"), ".\n\n"]), "read(_)->\n    null.\n") ++
        ?IF(WriteCode =/= "", lists:concat([string:join(WriteCode, ";\n"), ".\n\n"]), "write(_)->\n    null.\n") ++
        ?IF(DirtyWriteCode =/= "", lists:concat([string:join(DirtyWriteCode, ";\n"), ".\n\n"]), "dirty_write(_)->\n    null.\n") ++

        ?IF(DeleteCode =/= "", lists:concat([string:join(DeleteCode, ";\n\n"), ".\n\n"]), "delete(_)->\n    null.\n") ++
        ?IF(DeleteAllCode =/= "", lists:concat([string:join(DeleteAllCode, ";\n\n"), ".\n\n"]), "delete_all(_)->\n    null.\n") ++

        ?IF(SliceSelectCode =/= "", lists:concat([string:join(SliceSelectCode, ";\n\n"), ".\n\n"]), "select(_, _, _)->\n    null.\n") ++
        ?IF(NoSliceSelectCode =/= "", lists:concat([string:join(NoSliceSelectCode, ";\n\n"), ".\n\n"]), "select(_, _)->\n    null.\n") ++

        ?IF(SliceDeleteSelectCode =/= "", lists:concat([string:join(SliceDeleteSelectCode, ";\n\n"), ".\n\n"]), "select_delete(_, _, _)->\n    null.\n") ++
        ?IF(NoSliceDeleteSelectCode =/= "", lists:concat([string:join(NoSliceDeleteSelectCode, ";\n\n"), ".\n\n"]), "select_delete(_, _)->\n    null.\n") ++
        ?IF(SliceTableListCode =/= "", lists:concat([string:join(SliceTableListCode, ";\n\n"), ".\n\n"]), "get_slice_table_list(_)->\n    null.\n") ++
        ?IF(SliceTableCode =/= "", lists:concat([string:join(SliceTableCode, ";\n\n"), ".\n\n"]), "get_slice_table(_, _)->\n    null.\n") ++

        save_bin_log_code_head() ++
        ?IF(SaveBinLogCode =/= "", lists:concat([string:join(SaveBinLogCode, ";\n"), ".\n\n"]), "save_bin_log(_)->\n    null.\n") ++
        ?IF(TranSqlCode =/= "", lists:concat([string:join(TranSqlCode, ";\n"), ".\n\n"]), "tran_to_sql(_)->\n    null.\n") ++
        ?IF(ValidToSqlCode =/= "", lists:concat([string:join(ValidToSqlCode, ";\n"), ".\n\n"]), "ensure_to_sql(_)->\n    null.\n") ++
        ?IF(TranUpdateCode =/= "", lists:concat([string:join(TranUpdateCode, ";\n"), ".\n\n"]), "generate_update_sql(_,_,_,_)->\n    null.\n") ++

        game_db_incremental_sync_context() ++
        game_db_get_incremental_tables_context() ++
        game_db_bin_log_table_context() ++
    game_db_is_dets_table_context() ++
        game_db_get_log_table_list(LogTableList) ++
        game_db_file_fix_context1(),
    util_file:save_code(?DB_FILE, Content, true),
    Parent ! {ack, Ref}.

create_db_init_erl(TableNameList, Parent, Ref) ->
    io:format("Create file ~s~n", [?DB_INIT_FILE]),
    Content = lists:foldl(
        fun(TableName, T) ->
            Rows = get_table_info_rows(TableName),
            [build_db_init_code(Rows) | T]
        end,
        [],
        TableNameList
    ),
    Content1 =
        file_head() ++
        game_db_init_file_head() ++
        game_db_init_file_init_code() ++
        ?IF(Content =/= "", lists:concat([string:join(Content, ";\n"), ".\n\n"]), ""),
    util_file:save_code(?DB_INIT_FILE, Content1, true),
    Parent ! {ack, Ref}.

create_db_index_erl(TableNameList, Parent, Ref) ->
    io:format("Create file ~s~n", [?DB_INDEX_FILE]),
    {
        InsertIndexCode,
        UpdateIndexCode,
        EraseIndexCode,
        EraseAllIndexCode,
        GetKeyCode
    } =
        lists:foldl(
            fun(TableName, {T, T1, T2, T3, T4}) ->
                Rows = get_table_info_rows(TableName),
                case is_index_table(TableName) of
                    true ->
                        {
                            [build_insert_index_code(Rows) | T],
                            [build_update_index_code(Rows) | T1],
                            [build_erase_index_code(Rows) | T2],
                            [build_erase_all_index_code(Rows) | T3],
                            [build_get_keys_code(Rows) | T4]
                        };
                    false ->
                        {T, T1, T2, T3, T4}
                end
            end,
            {[], [], [], [], []},
            TableNameList
        ),
    Content1 =
        file_head() ++
        game_db_index_file_head() ++
        game_db_index_fix_content_2() ++
        ?IF(GetKeyCode =/= "", lists:concat([string:join(GetKeyCode, ";\n"), ".\n\n"]), "get_keys(_)-> undefined.\n\n") ++
        game_db_index_fix_content_1() ++
        InsertIndexCode ++ "insert_index(_)->noop.\n\n" ++
        UpdateIndexCode ++ "update_index(_, _)->noop.\n\n" ++
        EraseIndexCode ++ "erase_index(_)->noop.\n\n" ++
        EraseAllIndexCode ++ "erase_all_index(_)->noop.\n\n",
    util_file:save_code(?DB_INDEX_FILE, Content1, true),
    Parent ! {ack, Ref}.

create_db_load_erl(TableNameList, Parent, Ref) ->
    io:format("Create file ~s~n", [?DB_LOAD_FILE]),
    DbPool = ?GAME_DB,
    Content = lists:foldl(
        fun(TableName, T) ->
            Rows = get_table_info_rows(TableName),
            [build_db_load_code(Rows, DbPool) | T]
        end,
        [],
        env:get(?HOT_LOAD_TABLES)
    ),
    Content1 = lists:foldl(
        fun(TableName, T) ->
            Rows = get_table_info_rows(TableName),
            [build_db_load_code1(Rows, DbPool) | T]
        end,
        [],
        TableNameList
    ),
    Content2 = lists:foldl(
        fun(TableName, T) ->
            Rows = get_table_info_rows(TableName),
            [build_db_load_code2(Rows) | T]
        end,
        [],
        env:get(?HOT_LOAD_TABLES)
    ),
    Out =
        file_head() ++
        game_db_load_file_head() ++
        game_db_load_file_init_code() ++
        ?IF(Content1 =/= "", lists:concat([string:join(Content1, ";\n"), ".\n\n"]), "load(_) -> noop.\n\n") ++
        ?IF(Content =/= "", lists:concat([string:join(Content, ";\n"), ".\n\n"]), "load(_, _) -> noop.\n\n") ++
        ?IF(Content2 =/= "", lists:concat([string:join(Content2, ";\n"), ".\n\n"]), "unload(_, _) -> noop.\n\n"),
    util_file:save_code(?DB_LOAD_FILE, Out, true),
    Parent ! {ack, Ref}.


init_all_ets_table_fields(TableList) ->
    lists:foreach(
        fun(TableName) ->
            Rows = get_table_info_rows(TableName),
            Keys = [
                TableInfo#table_info.'Field'
                || TableInfo <- Rows, TableInfo#table_info.'Key' =:= ?PRI
            ],
            Fields = [
                TableInfo#table_info.'Field'
                || TableInfo <- Rows
            ],
            ets:insert(ets_table_fields,
                #ets_table_fields{
                    table_name = TableName,
                    keys = Keys,
                    fields = Fields
                })
        end,
        TableList
    ).

get_ets_table_fields(TableName) ->
    [R] = ets:lookup(ets_table_fields, TableName),
    R.

%% 开机加载表
get_real_power_tables(TableNameList) ->
    lists:foldl(
        fun(TableName, T) ->
            R = get_ets_table_fields(TableName),
            %% player_ 开头， 并且 key  里面有Player_id 的表 不会开机加载
            case is_player_table(TableName) andalso lists:member("player_id", R#ets_table_fields.keys) of
                true ->
                    T;
                false ->
                    [TableName | T]
            end
        end,
        [],
        TableNameList
    ).

is_power_table(TableName) ->
    R = get_ets_table_fields(TableName),
    case lists:member(TableName, env:get(?POWER_LOAD_TABLES)) of
        true ->
            true;
        false ->
            not (is_player_table(TableName) andalso lists:member("player_id", R#ets_table_fields.keys))
    end.


init_all_ets_table_info(TableList) ->
    lists:foreach(
        fun(TableName) ->
            SqlBin = list_to_binary(io_lib:format("SHOW FULL FIELDS FROM `~s`", [TableName])),
            {data, Res} = mysql:fetch(?GAME_DB, SqlBin),
            Fun = fun(R) ->
                R#table_info{
                    table_name = TableName
                }
                  end,
            Rows = lib_mysql:as_record(Res, table_info, record_info(fields, table_info), Fun),
            ets:insert(ets_table_info,
                #ets_table_info{
                    table_name = TableName,
                    rows = Rows
                })
        end,
        TableList
    ).

get_table_info_rows(TableName) ->
    [R] = ets:lookup(ets_table_info, TableName),
    R#ets_table_info.rows.

create_db_hrl(TableNameList) ->
    io:format("Create file ~s~n", [?DB_RECORD_FILE]),
    Content = lists:foldl(
        fun(TableName, T) ->
            Rows = get_table_info_rows(TableName),
            T ++ get_db_record_file_content(Rows)
        end,
        [],
        TableNameList
    ),
    util_file:save_code(?DB_RECORD_FILE, file_head() ++ Content).

file_head() ->
    "%%% Generated automatically, no need to modify.\n".
%%    io_lib:format(
%%        "%%% Generated automatically, no need to modify.\n"
%%        "%%% Created : ~s\n\n",
%%        [util:format_datetime()]).

is_index_table(TableName) ->
    case lists:keyfind(util:to_atom(TableName), 2, env:get(?INDEX)) of
        false ->
            false;
        _ ->
            true
    end.

get_index_list_by_table_name(TableName) ->
    AtomTableName = util:to_atom(TableName),
    lists:reverse(lists:filter(
        fun({_, Name, _}) ->
            if Name == AtomTableName ->
                true;
                true ->
                    false
            end
        end,
        env:get(?INDEX)
    )).

get_db_record_file_content(TableInfoList) ->
    Keys = [
        TableInfo#table_info.'Field'
        || TableInfo <- TableInfoList, TableInfo#table_info.'Key' =:= ?PRI
    ],
    TableName = (hd(TableInfoList))#table_info.table_name,
%%    DbRecordName = get_db_record_name(TableName),
    DbRecordDefine =
        io_lib:format(
            "\n-define(~s, ~s).\n",
            [string:to_upper(TableName), TableName]
        ),
    KeyRecord =
        io_lib:format(
            "-record(~s, {\n"
            "    ~s"
            "\n}).\n",
            [get_db_key_record_name(TableName), string:join(Keys, ",\n    ")]
        ),
    IndexRecords =
        lists:foldl(
            fun({IndexName, _, IndexFiledList}, Tmp) ->
                io_lib:format(
                    "-record(~s, {\n"
                    "    ~s"
                    "\n}).\n",
                    [get_db_index_record_name(util:to_list(IndexName)), string:join([util:to_list(IndexFiled) || IndexFiled <- IndexFiledList], ",\n    ")]
                ) ++ Tmp
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    DbRecordDefine ++ KeyRecord ++ IndexRecords ++ get_db_record_file_content1(TableInfoList, []).

get_db_record_name(TableName) ->
    ?DB_RECORD_PRE ++ TableName.

get_db_key_record_name(TableName) ->
    "key_" ++ TableName.

get_db_index_record_name(IndexName) ->
    ?INDEX_PRE ++ IndexName.

get_db_bin_log_table_name(TableName) ->
    TableName ++ "_bin_log".

%%get_db_bin_log_macro(TableName) ->
%%    io_lib:format("~s_BIN_LOG", [string:to_upper(util:to_list(TableName))]).

get_db_record_file_content1([], R) ->
    R;
get_db_record_file_content1(InfoList, R) ->
    [H | T] = InfoList,
    {Type, _} = get_type_info(H#table_info.'Type'),
    Default =
        if H#table_info.'Default' =:= undefined ->
            [];
            true ->
                case Type of
                    int ->
                        io_lib:format(" = ~s", [H#table_info.'Default']);
                    float ->
                        Index = string:str(H#table_info.'Default', "."),
                        if Index > 0 ->
                            io_lib:format(" = ~p", [util:to_float(H#table_info.'Default')]);
                            true ->
                                io_lib:format(" = ~p", [util:to_float(util:to_int(H#table_info.'Default'))])
                        end;
                    string ->
                        io_lib:format(" = \"~s\"", [H#table_info.'Default'])
                end
        end,
    Comment =
        if H#table_info.'Comment' =:= undefined orelse H#table_info.'Comment' =:= [] ->
            io_lib:format("~s%% ~p", [lists:duplicate(max(0, 30 - length(lists:flatten(H#table_info.'Field' ++ Default))), " "), Type]);
            true ->
                io_lib:format("~s%% ~p ~s", [lists:duplicate(max(0, 30 - length(lists:flatten(H#table_info.'Field' ++ Default))), " "), Type, H#table_info.'Comment'])
        end,
    DbRecordName = get_db_record_name(H#table_info.table_name),

    if R == [] andalso T =/= [] ->
        Result = io_lib:format(
            "-record(~s, {\n"
            "    row_key, \n"
            "    ~s~s, ~s\n",
            [DbRecordName, H#table_info.'Field', Default, Comment]
        );
        R == [] andalso T == [] ->
            Result = io_lib:format(
                "-record( ~s, {\n"
                "    row_key, \n"
                "    ~s~s  ~s\n"
                "}).\n",
                [DbRecordName, H#table_info.'Field', Default, Comment]
            );
        T == [] ->
            Result = io_lib:format(
                "~s"
                "    ~s~s  ~s\n"
                "}).\n",
                [R, H#table_info.'Field', Default, Comment]
            );
        true ->
            Result = io_lib:format(
                "~s"
                "    ~s~s, ~s\n",
                [R, H#table_info.'Field', Default, Comment]
            )
    end,
    get_db_record_file_content1(T, Result).


game_db_file_head() ->
    "-module(db).\n"
    "-include(\"gen/db.hrl\").\n"
    "-include(\"prof.hrl\").\n"
    "%% API\n"
    "-export([\n"
    "    select_all/2,\n"
    "    select/2,\n"
    "    select/3,\n"
    "    read/1,\n"
    "    delete/1,\n"
    "    select_delete/2,\n"
    "    select_delete/3,\n"
    "    write/1,\n"
    "    dirty_write/1,\n"
    "    delete_all/1,\n"
    "    tran_apply/1,\n"
    "    tran_merge_apply/2,\n"
    "    tran_merge_apply/3,\n"
    "    tran_merge_apply_2/2,\n"
    "    do/1\n"
    "]).\n"
    "-export([\n"
    "    tran_to_sql/1,\n"
    "    tran_bin_log/2,\n"
    "    save_bin_log/1,\n"
    "    get_changes/3,\n"
    "    is_incremental_sync/1,\n"
    "    get_incremental_tables/0,\n"
    "    get_slice_table/2,\n"
    "    get_slice_table_list/1,\n"
    "    get_bin_log_table/1,\n"
    "    get_log_table_list/0\n"
    "]).\n\n".


game_db_incremental_sync_context() ->
    Head =
        "is_incremental_sync(Table) ->\n"
        "    case Table of\n",
    lists:foldl(
        fun(Table, Tmp) ->
            io_lib:format(
                "~s"
                "        ~p ->\n"
                "            true;\n",
                [Tmp, Table]
            )
        end,
        Head,
        [util:to_atom(E) || E <- env:get(?INCREMENT_SYNC_TABLES)]
    ) ++
    "        _ ->\n"
    "            false\n"
    "    end.\n\n".

game_db_get_incremental_tables_context() ->
    TableStringList = ["        " ++ util:to_list(Table) || Table <- env:get(?INCREMENT_SYNC_TABLES)],
    "get_incremental_tables() ->\n"
    "    [\n" ++
        string:join(TableStringList, ",\n") ++
        "\n    ].\n\n".

game_db_get_log_table_list(NotLogTableList) ->
    "get_log_table_list() ->\n"
    "    [\"" ++ string:join(NotLogTableList, "\", \"") ++ "\"].\n\n".

game_db_bin_log_table_context() ->
    Code = lists:foldl(
        fun(Table, Tmp) ->
            [io_lib:format(
                "get_bin_log_table(~s) ->\n"
                "   ~s_bin_log",
                [util:to_list(Table), util:to_list(Table)]
            ) | Tmp]
        end,
        ["\nget_bin_log_table(Other) ->exit({none_bin_log_table, Other})"],
        env:get(?INCREMENT_SYNC_TABLES)
    ),
    lists:concat([string:join(Code, ";\n"), ".\n\n"]).

game_db_file_fix_context1() ->
    "tran_bin_log (_Table, {_, _Current, _Current}) ->\n"
    "    noop;\n"
    "tran_bin_log (Table, {_, null, Last}) ->\n"
    "    tran_to_sql({Table, Table, insert, Last});\n"
    "tran_bin_log (Table, {_, Current, null}) ->\n"
    "    tran_to_sql({Table, Table, delete, Current});\n"
    "tran_bin_log (Table, {_, Current, Last}) ->\n"
    "    Size = tuple_size(Last),\n"
    "    tran_to_sql({Table, Table, update, Last, Current, get_changes(Size, Last, Current)}).\n\n"
    "get_changes (N, NewRecord, OldRecord) ->\n"
    "    get_changes(N, NewRecord, OldRecord, []).\n"
    "get_changes (2, _, _, Changes) ->\n"
    "    Changes;\n"
    "get_changes (N, NewRecord, OldRecord, Changes) ->\n"
    "    case erlang:element(N, NewRecord) =:= erlang:element(N, OldRecord) of\n"
    "        true -> get_changes(N - 1, NewRecord, OldRecord, Changes);\n"
    "        false -> get_changes(N - 1, NewRecord, OldRecord, [N | Changes])\n"
    "    end.\n\n"
    "add_tran_action (Action) ->\n"
    "    case get(tran_actions) of\n"
    "        [] ->\n"
    "            put(tran_actions, [Action]);\n"
    "        ActionList ->\n"
    "            put(tran_actions, [Action | ActionList])\n"
    "    end.\n\n"
    "add_dirty_action(Action) ->\n"
    "    case get(dirty_actions) of\n"
    "        undefined ->\n"
    "            put(dirty_actions, [Action]);\n"
    "        [] ->\n"
    "            put(dirty_actions, [Action]);\n"
    "        ActionList ->\n"
    "            put(dirty_actions, [Action | ActionList])\n"
    "    end.\n\n"
    "tran_apply(F) when is_function(F) ->\n"
    "    ensure_tran(),\n"
    "    case get(tran_apply_actions) of\n"
    "        undefined ->\n"
    "            put(tran_apply_actions, [F]);\n"
    "        [] ->\n"
    "            put(tran_apply_actions, [F]);\n"
    "        ActionList ->\n"
    "            put(tran_apply_actions, [F | ActionList])\n"
    "    end,\n"
    "    ok.\n\n"
    "do_tran_apply_action(TranApplyActions) ->\n"
    "    case TranApplyActions of\n"
    "        undefined ->\n"
    "            noop;\n"
    "        [] ->\n"
    "            noop;\n"
    "        ActionList ->\n"
    "            case catch [F() || F <- lists:reverse(ActionList)] of\n"
    "                 {'EXIT', Reason} ->\n"
    "                     logger:error(\"tran_apply:~p~n\", [Reason]);\n"
    "                 _ ->\n"
    "                     noop\n"
    "            end,\n"
    "            ok\n"
    "    end.\n\n"
    "tran_merge_apply({M, F, A}, E) ->\n"
    "    tran_merge_apply({M, F, A}, E, true).\n"
    "tran_merge_apply({M, F, A}, E, IsState) ->\n"
    "    ensure_tran(),\n"
    "    case get(tran_merge_apply_actions) of\n"
    "        undefined ->\n"
    "            put(tran_merge_apply_actions, [{{M, F, A}, [E]}]);\n"
    "        [] ->\n"
    "            put(tran_merge_apply_actions, [{{M, F, A}, [E]}]);\n"
    "        ActionList ->\n"
    "            case lists:keytake({M, F, A}, 1, ActionList) of\n"
    "           {value, {{M, F, A}, L}, L1} ->\n"
    "               NewList =\n"
    "                   if\n"
    "                       IsState ->\n"
    "                           [{{M, F, A}, [E | L]} | L1];\n"
    "                       true ->\n"
    "                           {Key, _Value} = E,\n"
    "                           NewL2 = lists:keydelete(Key, 1, L),\n"
    "                           [{{M, F, A}, [E | NewL2]} | L1]\n"
    "                   end,\n"
    "               put(tran_merge_apply_actions, NewList);\n"
    "           _ ->\n"
    "               put(tran_merge_apply_actions, ActionList ++ [{{M, F, A}, [E]}])\n"
    "       end\n"
    "    end,\n"
    "    ok.\n\n"
    "do_tran_merge_apply_action(TranMergeApplyActions) ->\n"
    "    case TranMergeApplyActions of\n"
    "        undefined ->\n"
    "            noop;\n"
    "        [] ->\n"
    "            noop;\n"
    "        ActionList ->\n"
    "            case catch [erlang:apply(M, F, [A, L]) || {{M, F, A}, L} <- lists:reverse(ActionList)] of\n"
    "                 {'EXIT', Reason} ->\n"
    "                     logger:error(\"tran_merge_apply:~p~n\", [Reason]);\n"
    "                 _ ->\n"
    "                     noop\n"
    "            end,\n"
    "            ok\n"
    "    end.\n\n"


    "tran_merge_apply_2({M, F, A}, MergeFun) ->\n"
    "    ensure_tran(),\n"
    "    case get(tran_merge_apply_2_actions) of\n"
    "        undefined ->  put(tran_merge_apply_2_actions, [{{M, F}, MergeFun(A, undefined)}]);\n"
    "        ActionList ->\n"
    "            case lists:keytake({M, F}, 1, ActionList) of\n"
    "                {value, {{M, F}, ThisA}, LeftActionList} ->\n"
    "                put(tran_merge_apply_2_actions, [{{M, F}, MergeFun(A, ThisA)} | LeftActionList]);\n"
    "            _ ->\n"
    "                put(tran_merge_apply_2_actions, [{{M, F}, MergeFun(A, undefined)} | ActionList])\n"
    "            end\n"
    "    end,\n"
    "    ok.\n"

    "do_tran_merge_apply_2_action(TranMergeApply2Actions) ->\n"
    "    case TranMergeApply2Actions of\n"
    "        undefined ->  noop;\n"
    "        [] ->  noop;\n"
    "        ActionList ->\n"
    "            case catch [erlang:apply(M, F, A) || {{M, F}, A} <- lists:reverse(ActionList)] of\n"
    "       {'EXIT', Reason} ->\n"
    "           logger:error(\"tran_merge_apply_2:~p~n\", [Reason]);\n"
    "                _ ->\n"
    "                    noop\n"
    "            end,\n"
    "            ok\n"
    "    end.\n"


    "do(Tran) when is_function(Tran) ->\n"
    "    case get(tran_actions) of\n"
    "        undefined ->\n"
    "            put(tran_actions, []),\n"
    "            put(dirty_actions, []),\n"
    "            put(tran_apply_actions, []),\n"
    "            try Tran() of\n"
    "                Return ->\n"
    "                    TranActions = lists:reverse(get(tran_actions)),\n"
    "                    DirtyActions = lists:reverse(get(dirty_actions)),\n"
    "                    TranApplyActions = get(tran_apply_actions),\n"
    "                    TranMergeApplyActions = get(tran_merge_apply_actions),\n"
    "                    TranMergeApply2Actions = get(tran_merge_apply_2_actions),\n"
    "                    erase(tran_actions),\n"
    "                    erase(dirty_actions),\n"
    "                    erase(tran_apply_actions),\n"
    "                    erase(tran_merge_apply_actions),\n"
    "                    erase(tran_merge_apply_2_actions),\n"
    "                    db_proxy:submit(TranActions),\n"
    "                    db_proxy:submit(DirtyActions),\n"
    "                    do_tran_merge_apply_action(TranMergeApplyActions),\n"
    "                    do_tran_merge_apply_2_action(TranMergeApply2Actions),\n"
    "                    do_tran_apply_action(TranApplyActions),\n"
    "                    Return\n"
    "            catch\n"
    "                _:Reason ->\n"
    "                    TranActions = get(tran_actions),\n"
%%    "                    DirtyActions = get(dirty_actions),\n"
    "                    erase(tran_actions),\n"
    "                    erase(dirty_actions),\n"
    "                    erase(tran_apply_actions),\n"
    "                    erase(tran_merge_apply_actions),\n"
    "                    erase(tran_merge_apply_2_actions),\n"
    "                    rollback(TranActions),\n"
    "                    if\n"
    "                        Reason == {error, not_action_time} ->\n"
    "                            noop;\n"
    "                        Reason == not_action_time ->\n"
    "                            noop;\n"
    "                        true ->\n"
    "                            logger:error(\"Rollback =>~n\"\n"
    "                                \"    reason: ~p~n\"\n"
%%    "                              \"    tran_actions: ~p~n\"\n"
%%    "                              \"    dirty_actions: ~p~n\"\n"
    "                          \"    stacktrace: ~p~n\",\n"
    "                           [Reason, erlang:get_stacktrace()]\n"
    "                           )\n"
    "                    end,\n"
    "                    exit(Reason)\n"
    "                end;\n"
    "        _ ->\n"
    "            Tran()\n"
    "    end.\n"
    "rollback([]) ->\n"
    "    ok;\n"
    "rollback([{EtsTable, _Table, delete, Record} | T]) ->\n"
    "    case is_dets_table(_Table) of true -> dets:insert(EtsTable, Record); false -> ets:insert(EtsTable, Record) end,\n"
    "    db_index:insert_index(Record),\n"
    "    rollback(T);\n"
    "rollback([{EtsTable, _Table, delete_all, RecordList} | T]) ->\n"
    "    case is_dets_table(_Table) of true -> dets:insert(EtsTable, RecordList); false -> ets:insert(EtsTable, RecordList) end,\n"
    "    db_index:insert_indexs(RecordList),\n"
    "    rollback(T);\n"
    "rollback([{EtsTable, _Table, insert, Record} | T]) ->\n"
    "    case is_dets_table(_Table) of true -> dets:delete_object(EtsTable, Record); false -> ets:delete_object(EtsTable, Record) end,\n"
    "    db_index:erase_index(Record),\n"
    "    rollback(T);\n"
    "rollback([{EtsTable, _Table, update, NewRecord, OldRecord} | T]) ->\n"
    "    case is_dets_table(_Table) of true -> dets:insert(EtsTable, OldRecord); false -> ets:insert(EtsTable, OldRecord) end,\n"
    "    db_index:update_index(NewRecord, OldRecord),\n"
    "    rollback(T).\n\n"

    "ensure_tran() ->\n"
    "    case get(tran_actions) of\n"
    "        undefined ->\n"
    "        exit(no_transaction);\n"
    "    _ ->\n"
    "        ok\n"
    "    end.\n"
    "is_tran() ->\n"
    "    case get(tran_actions) of\n"
    "        undefined ->\n"
    "        false;\n"
    "    _ ->\n"
    "        true\n"
    "    end.\n"
    "int_to_bin(undefined) ->\n"
    "    <<\"NULL\">>;\n"
    "int_to_bin(Value) ->\n"
    "    list_to_binary(integer_to_list(Value)).\n"
    "float_to_bin(undefined) ->\n"
    "    <<\"NULL\">>;\n"
    "float_to_bin(Value) ->\n"
    "    list_to_binary(float_to_list(Value)).\n"
    "list_to_bin(undefined) ->\n"
    "    <<\"NULL\">>;\n"
    "list_to_bin(List) ->\n"
    "    List2 = escape_str(List, []),\n"
    "    Bin = list_to_binary(List2),\n"
    "    <<\"'\", Bin/binary, \"'\">>.\n"
    "escape_str([], Result) ->\n"
    "    lists:reverse(Result);\n"
    "escape_str([$' | String], Result) ->\n"
    "    escape_str(String, [$' | [$\\" "\\ | Result]]);\n"
    "escape_str([$\" | String], Result) ->\n"
    "    escape_str(String, [$\" | [$\\" "\\ | Result]]);\n"
    "escape_str([$\\" "\\ | String], Result) ->\n"
    "    escape_str(String, [$\\" "\\ | [$\\" "\\ | Result]]);\n"
    "escape_str([Char | String], Result) ->\n"
    "    escape_str(String, [Char | Result]).\n".
game_db_file_fix_context() ->
    "\n"
    "select_all(Table, MatchSpec) ->\n" %Table atom
    "    ?START_PROF,\n"
    "    Result =\n"
    "        lists:foldl(\n"
    "            fun(TableId, Tmp) ->\n"
    "                case ets:select(TableId, MatchSpec) of\n"
    "                    [] ->\n"
    "                        Tmp;\n"
    "                    R ->\n"
    "                        [R | Tmp]\n"
    "                end\n"
    "            end,\n"
    "            [],\n"
    "            get_slice_table_list(Table)\n"
    "        ),\n"
    "    ?STOP_PROF(?MODULE, select_all, Table),\n"
    "    lists:concat(Result).\n"
    "      \n"
    "fetch_lookup(TablePrefix, Key) ->\n"
    "    fetch_lookup(TablePrefix, Key, 0).\n"
    "\n"
    "fetch_lookup(_, _, " ++ integer_to_list(?SLICE_NUM) ++ ") ->\n"
    "    [];\n"
    "\n"
    "fetch_lookup(TablePrefix, Key, N) ->\n"
    "    case ets:lookup(get_slice_table(TablePrefix, N), Key) of\n"
    "        [] -> fetch_lookup(TablePrefix, Key, N + 1);\n"
    "        R  -> R\n"
    "    end.\n"

    "\n"
    "\n"
    "\n".


build_slice_delete_select_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,

    io_lib:format(
        "select_delete(~s, SliceId, MatchSpec) ->\n"
        "    ?START_PROF,\n"
        "    ensure_tran(),\n"
        "    RecordList = select(~s, SliceId, MatchSpec),\n"
        "    [delete(Record) || Record <- RecordList],\n"
        "    ?STOP_PROF(?MODULE, select_delete, ~s),\n"
        "    RecordList",
        [TableName, TableName, TableName]
    ).

build_no_slice_delete_select_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,

    io_lib:format(
        "select_delete(~s, MatchSpec) ->\n"
        "    ?START_PROF,\n"
        "    ensure_tran(),\n"
        "    RecordList = select(~s, MatchSpec),\n"
        %%"    server_state_srv:update_table_count({~s, select_delete_all}),\n"
        "    [delete(Record) || Record <- RecordList],\n"
        "    ?STOP_PROF(?MODULE, select_delete, ~s),\n"
        "    RecordList",
        [TableName, TableName, TableName]
    ).




build_slice_select_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,

    io_lib:format(
        "select(~s, SliceId, MatchSpec) ->\n"
%%        "    case SliceId of\n"
%%        "       slow ->\n"
%%        "           server_state_srv:update_table_count({~s, select_slow}),\n"
%%        "           fetch_select(\"~s\", MatchSpec);\n"
%%        "       SliceId ->\n"
        "    ?START_PROF,\n"
        %% "    server_state_srv:update_table_count({~s, select}),\n"
        "    R = ets:select(get_slice_table(~s, SliceId rem " ++ integer_to_list(?SLICE_NUM) ++ "), MatchSpec),\n"
        "    ?STOP_PROF(?MODULE, select, ~s),\n"
        "    R",
%%        "    end",
        [TableName, TableName, TableName]
    ).

build_no_slice_select_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,

    io_lib:format(
        "select(~s, MatchSpec) ->\n"
%%        "    server_state_srv:update_table_count({~s, select_all}),\n"
        "    ?START_PROF,\n"
        "    R = " ++ get_cache_mod(TableName) ++ ":select(~s, MatchSpec),\n"
        "    ?STOP_PROF(?MODULE, select, ~s),\n"
        "    R",
        [TableName, TableName, TableName]
    ).
game_db_is_dets_table_context() ->
    Code = lists:foldl(
        fun(Table, Tmp) ->
            [io_lib:format(
                "is_dets_table(~s) ->\n"
                "   true",
                [util:to_list(Table)]
            ) | Tmp]
        end,
        ["\is_dets_table(_) ->false"],
        env:get(?DETS_TABLES)
    ),
    lists:concat([string:join(Code, ";\n"), ".\n\n"]).

%%-------------------------------
%% @doc     创建game_db:delete
%% @throws  none
%% @end
%%-------------------------------
build_delete_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    IndexCode = case is_index_table(TableName) of
                    true ->
                        "    db_index:erase_index(Record),\n";
                    false ->
                        ""
                end,
    case is_slice_table(TableName) of
        true ->
            io_lib:format(
                "delete(#~s{}=Record) ->\n"
                "    ?START_PROF,\n"
                "    ensure_tran(),\n"
                "    EtsTable = get_slice_table(~s, Record#~s.~s rem " ++ integer_to_list(?SLICE_NUM) ++ "),\n"
                "    add_tran_action({EtsTable, ~s,delete, Record}),\n"
%%                "    server_state_srv:update_table_count({~s, del}),\n"
                "    ets:delete_object(EtsTable, Record),\n"
                    ++ IndexCode ++
                    "    ?STOP_PROF(?MODULE, delete, ~s)",
                [DbRecordName, TableName, DbRecordName, atom_to_list(get_slice_column(TableName)), TableName, TableName]
            );

        false ->
            io_lib:format(
                "delete(#~s{}=Record) ->\n"
                "    ?START_PROF,\n"
                "    ensure_tran(),\n"
                "    EtsTable = ~s,\n"
                "    add_tran_action({EtsTable, ~s, delete, Record}),\n"
%%                "    server_state_srv:update_table_count({~s, del}),\n"
                "    " ++ get_cache_mod(TableName) ++ ":delete_object(~s, Record),\n"
                ++ IndexCode ++
                    "    ?STOP_PROF(?MODULE, delete, ~s)",
                [DbRecordName, TableName, TableName, TableName, TableName])
    end.

build_delete_all_code(TableColList) ->
    %?DEBUG("[~p]~p TableColList=~p~n", [?MODULE, ?LINE, TableColList]),
    TableName = (hd(TableColList))#table_info.table_name,
%%    DbRecordName = get_db_record_name(TableName),
    IndexCode = case is_index_table(TableName) of
                    true ->
                        "    db_index:erase_all_index(" ++ TableName ++ "),\n";
                    false ->
                        ""
                end,
    case is_slice_table(TableName) of
        true ->

            io_lib:format(
                "delete_all(~s) ->\n"
                "    ?START_PROF,\n"
                "    ensure_tran(),\n"
                "    lists:foreach(\n"
                "       fun(Seq) ->\n"
                "           add_tran_action({get_slice_table(~s, Seq), ~s, delete_all, ets:tab2list(get_slice_table(~s, Seq))}),\n"
                "           ets:delete_all_objects(get_slice_table(~s, Seq))\n"
                "       end,\n"
                "       lists:seq(0, " ++ integer_to_list(?SLICE_NUM - 1) ++ ")\n"
                "    ),\n"
                    ++ IndexCode ++
                    "    ?STOP_PROF(?MODULE, delete_all, ~s)",
                [TableName, TableName, TableName, TableName, TableName, TableName]);

        false ->
            case is_dets_table(TableName) of
                true ->
                    io_lib:format(
                        "delete_all(~s) ->\n"
                        "    ?START_PROF,\n"
                        "    ensure_tran(),\n"
                        "    DeleteRows = case dets:select(~s, [{#db_~s{ _ ='_'}, [], ['$_']}]) of {error, Reason} -> exit({delete_all_select_error, ~s, Reason}); DeleteRows0 -> DeleteRows0 end,\n"
                        "    add_tran_action({~s, ~s, delete_all, DeleteRows}),\n"
                        "    DeleteResult = dets:delete_all_objects(~s),\n"
                        "    case DeleteResult of {error, ErrorReason} -> exit({delete_all_error, " ++ TableName ++ ", ErrorReason}); _ -> noop end,\n"
                        ++ IndexCode ++
                            "    ?STOP_PROF(?MODULE, delete_all, ~s)",
                        [TableName, TableName, TableName, TableName, TableName, TableName, TableName, TableName]);
                false ->
                    io_lib:format(
                        "delete_all(~s) ->\n"
                        "    ?START_PROF,\n"
                        "    ensure_tran(),\n"
                        "    add_tran_action({~s, ~s, delete_all, ets:tab2list(~s)}),\n"
                        "    ets:delete_all_objects(~s),\n"
                        ++ IndexCode ++
                            "    ?STOP_PROF(?MODULE, delete_all, ~s)",
                        [TableName, TableName, TableName, TableName, TableName, TableName])
            end

    end.




build_read_code(TableInfoList) ->
    %io:format("[~p]~p TableInfoList=~p~n", [?MODULE, ?LINE, TableInfoList]),
    TableName = (hd(TableInfoList))#table_info.table_name,
    KeyTableName = get_db_key_record_name(TableName),
%%    DbRecordName = get_db_record_name(TableName),
    Keys = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList, TableInfo#table_info.'Key' =:= ?PRI],
    {L1, L2} = lists:foldl(
        fun(KEY, {Temp1, Temp2}) ->
            {
                [
                    io_lib:format(
                        "    ~s = Record#~s.~s",
                        [
                            util_string:to_var_name(KEY),
                            KeyTableName,
                            KEY
                        ]
                    ) | Temp1
                ],
                [util_string:to_var_name(KEY) | Temp2]
            }
        end,
        {[], []},
        Keys
    ),
    case is_slice_table(TableName) of
        false ->
            io_lib:format(
                "read(Record) when is_record(Record, ~s) ->\n"
                "~s,\n"
                "    ?START_PROF,\n"
                "    R1 =\n"
                "    case " ++ get_cache_mod(TableName) ++ ":lookup(~s, {~s}) of\n"
                "        [] ->\n"
                "            null;\n"
                "        [R] ->\n"
                "            R\n"
                "    end,\n"
                "    ?STOP_PROF(?MODULE, lookup, ~s),\n"
                "    R1",
                [KeyTableName, string:join(lists:reverse(L1), ",\n"), TableName, string:join(lists:reverse(L2), ", "), TableName]);
        true ->
            SliceCol = get_slice_column(TableName), %atom

            %?DEBUG("[~p]~p ~p, ~p, ~p ~p~n", [?MODULE, ?LINE, TableName, SliceCol, Keys, util_string:to_var_name(SliceCol)]),

            case lists:member(atom_to_list(SliceCol), Keys) of
                true ->
                    EtsTable = "get_slice_table(" ++ TableName ++ ", " ++ util_string:to_var_name(SliceCol) ++ " rem " ++ integer_to_list(?SLICE_NUM) ++ ")",

                    %?DEBUG("[~p]~p ~p~n", [?MODULE, ?LINE, EtsTable]),

                    io_lib:format(
                        "read(Record) when is_record(Record, ~s) ->\n"
                        "~s,\n"
                        "    ?START_PROF,\n"
                        "    R1 = \n"
                        "    case ets:lookup(~s, {~s}) of\n"
                        %"     case ets:lookup(list_to_atom(\"~s_\" ++ integer_to_list(SliceColumn rem 100)), {~s}) of\n"
                        "        [] ->\n"
                        "           null;\n"
                        "        [R] ->\n"
                        "           R\n"
                        "    end,\n"
                        "    ?STOP_PROF(?MODULE, lookup, ~s),\n"
                        "    R1",
                        [KeyTableName, string:join(lists:reverse(L1), ",\n"), EtsTable, string:join(lists:reverse(L2), ", "), TableName]);

                false ->
                    io_lib:format(
                        "read(Record) when is_record(Record, ~s) ->\n"
                        "~s,\n"
                        "    ?START_PROF,\n"
                        "    R1 = \n"
                        "    case fetch_lookup(~s, {~s}) of\n"
                        %"     case ets:lookup(list_to_atom(\"~s_\" ++ integer_to_list(SliceColumn rem 100)), {~s}) of\n"
                        "        [] ->\n"
                        "           null;\n"
                        "        [R] ->\n"
                        "           R\n"
                        "    end,\n"
                        "    ?STOP_PROF(?MODULE, lookup, ~s),\n"
                        "    R1",
                        [KeyTableName, string:join(lists:reverse(L1), ",\n"), TableName, string:join(lists:reverse(L2), ", "), TableName])

            end

    end.

save_bin_log_code_head() ->
    "save_bin_log({_EtsTable,Table, delete_all, RecordList})->\n"
    "    [save_bin_log({_EtsTable,Table, delete, Record}) || Record <- RecordList],\n"
    "    ok;\n".

build_save_bin_log_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    BinLogTableName = get_db_bin_log_table_name(TableName),
    DbRecordName = get_db_record_name(TableName),
    io_lib:format(
        "save_bin_log({_EtsTable,~s, delete, Record})->\n"
        "    case ets:lookup(~s, Record#~s.row_key) of\n"
        "	    []->\n"
        "		    ets:insert(~s, {Record#~s.row_key, Record, null});\n"
        "	    [{_, Current, _Last}] ->\n"
        "		    ets:insert(~s, {Record#~s.row_key, Current, null})\n"
        "    end;\n"
        "save_bin_log({_EtsTable,~s, insert, NewRecord})->\n"
        "    case ets:lookup(~s, NewRecord#~s.row_key) of\n"
        "        []->\n"
        "            ets:insert(~s, {NewRecord#~s.row_key, null, NewRecord});\n"
        "        [{_, Current, null}] ->\n"
        "            ets:insert(~s, {NewRecord#~s.row_key, Current, NewRecord})\n"
        "    end;\n"
        "save_bin_log({_EtsTable,~s, update, NewRecord, OldRecord})->\n"
        "    case ets:lookup(~s, NewRecord#~s.row_key) of\n"
        "	    []->\n"
        "		     ets:insert(~s, {NewRecord#~s.row_key, OldRecord, NewRecord});\n"
        "	    [{_, Current, _Last}] ->\n"
        "		    ets:insert(~s, {NewRecord#~s.row_key, Current, NewRecord})\n"
        "    end",
        [
            TableName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName,
            TableName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName,
            TableName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName, BinLogTableName, DbRecordName
        ]
    ).


build_write_code(TableColList) ->
    TableName = (hd(TableColList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    {IsAutoIncrement, TempKeys} = lists:foldl(
        fun(TableInfo, {TempIsAutoIncrement, TempKeys}) ->
            if TableInfo#table_info.'Key' =:= ?PRI andalso TempIsAutoIncrement == false ->
                if TableInfo#table_info.'Extra' == ?AUTO_INCREMENT ->
                    {true, [TableInfo#table_info.'Field' | TempKeys]};
                    true ->
                        {TempIsAutoIncrement, [TableInfo#table_info.'Field' | TempKeys]}
                end;
                true ->
                    {TempIsAutoIncrement, TempKeys}
            end
        end,
        {false, []},
        TableColList
    ),
    Keys = lists:reverse(TempKeys),
    L = if IsAutoIncrement == true ->
        [KEY] = Keys,
        VarKey = util_string:to_var_name(KEY),
        io_lib:format(
            "            case Record#~s.~s of\n"
            "                undefined ->\n"
            "                    ~s = ets:update_counter(auto_increment, ~s, 1),\n"
            "                    RealRecord = Record#~s{row_key ={~s}, ~s = ~s};\n"
            "                ~s->\n"
            "                    RealRecord = Record#~s{row_key ={~s}}\n"
            "            end,\n",
            [DbRecordName, KEY, VarKey, TableName, DbRecordName, VarKey, KEY, VarKey, VarKey, DbRecordName, VarKey]
        );
            true ->
                L1 = lists:foldl(
                    fun(KEY, Temp) ->
                        VarKey = util_string:to_var_name(KEY),
                        io_lib:format(
                            "~s"
                            "            ~s = Record#~s.~s,\n",
                            [Temp, VarKey, DbRecordName, KEY])
                    end,
                    [],
                    Keys
                ),
                L2 = lists:foldl(
                    fun(KEY, Temp) ->
                        VarKey = util_string:to_var_name(KEY),
                        Temp ++ [VarKey]
                    end,
                    [],
                    Keys
                ),
                io_lib:format(
                    "~s"
                    "            RealRecord = Record#~s{row_key ={~s}},\n",
                    [L1, DbRecordName, string:join(L2, ", ")]
                )
        end,

    IndexCode = case is_index_table(TableName) of
                    true ->
                        "            db_index:insert_index(RealRecord),\n";
                    false ->
                        ""
                end,

    IndexCode1 = case is_index_table(TableName) of
                     true ->
                         "                    db_index:update_index(OldRecord, Record),\n";
                     false ->
                         ""
                 end,

    case is_slice_table(TableName) of
        false ->
            io_lib:format(
                "write(Record) when is_record(Record, ~s) ->\n"
                "    ?START_PROF,\n"
                "    ensure_tran(),\n"
                "    EtsTable = ~s,\n"
                "    case Record#~s.row_key of \n"
                "        undefined -> \n" ++ L ++
                    "            ensure_to_sql(RealRecord),\n"
                    "            true = " ++ get_cache_mod(TableName) ++ ":insert_new(EtsTable, [RealRecord]),\n"
                    ++ IndexCode ++
                    "            add_tran_action({EtsTable, ~s, insert, RealRecord}),\n"
%%                    "            server_state_srv:update_table_count({~s, insert}),\n"
                    "            ?STOP_PROF(?MODULE, insert, ~s),\n"
                    "            RealRecord;\n"
                    "        _ ->\n"
                    "            [OldRecord] = " ++ get_cache_mod(TableName) ++ ":lookup(~s, Record#~s.row_key),\n"
                    "            if OldRecord == Record -> Record;\n"
                    "                true ->\n"
                    "                    ensure_to_sql(Record),\n"
                    "                    " ++ get_cache_mod(TableName) ++ ":insert(EtsTable, [Record]),\n"
                    ++ IndexCode1 ++
                    "                    add_tran_action({EtsTable, ~s, update, Record, OldRecord}),\n"
                    "                    ?STOP_PROF(?MODULE, update, ~s),\n"
%%                    "            server_state_srv:update_table_count({~s, update}),\n"
                    "                    Record\n"
                    "            end\n"
                    "    end",
                [DbRecordName, TableName, DbRecordName, TableName, TableName, TableName, DbRecordName, TableName, TableName]);

        true ->
            %?DEBUG("[~p]~p ~p, ~p~n", [?MODULE, ?LINE, TableName, atom_to_list(get_slice_column(TableName))]),
            io_lib:format(
                "write(Record) when is_record(Record, ~s) ->\n"
                "    ?START_PROF,\n"
                "    ensure_tran(),\n"
                "\n"
                "    EtsTable = get_slice_table(~s, Record#~s.~s rem " ++ integer_to_list(?SLICE_NUM) ++ "),\n"

                "    case Record#~s.row_key of \n"
                "        undefined -> \n" ++ L ++
                    "            ensure_to_sql(RealRecord),\n"
                    "            true = ets:insert_new(EtsTable, [RealRecord]),\n"
                    ++ IndexCode ++
                    "            add_tran_action({EtsTable, ~s, insert, RealRecord}),\n"
                    "            ?STOP_PROF(?MODULE, insert, ~s),\n"
%%                    "            server_state_srv:update_table_count({~s, insert}),\n"
                    "            RealRecord;\n"
                    "        _ ->\n"
                    "            [OldRecord] = ets:lookup(EtsTable, Record#~s.row_key),\n"
                    "            if OldRecord == Record -> Record;\n"
                    "                true ->\n"
                    "                    ensure_to_sql(Record),\n"
                    "                    ets:insert(EtsTable, [Record]),\n"
                    ++ IndexCode1 ++
                    "                    add_tran_action({EtsTable, ~s, update, Record, OldRecord}),\n"
                    "                    ?STOP_PROF(?MODULE, update, ~s),\n"
%%                    "            server_state_srv:update_table_count({~s, update}),\n"
                    "                    Record\n"
                    "            end\n"
                    "    end",
                [DbRecordName, TableName, DbRecordName, atom_to_list(get_slice_column(TableName)), DbRecordName, TableName, TableName, TableName, TableName, TableName])
    end.

game_db_index_file_head() ->
    "-module(db_index).\n"
    "-include(\"gen/db.hrl\").\n"
    "-compile({no_auto_import,[get_keys/1]}).\n\n"
    "%% API\n"
    "-export([\n"
    "    get_keys/1, \n"
    "    get_rows/1\n"
    "]).\n\n"
    "%%Internal functions\n"
    "-export([\n"
    "    insert_indexs/1, \n"
    "    insert_index/1, \n"
    "    update_index/2,\n"
    "    erase_index/1, \n"
    "    erase_indexs/1, \n"
    "    erase_all_index/1\n"
    "]).\n\n".

game_db_index_fix_content_1() ->
    "\ninsert_indexs(Rows) ->\n"
    "    lists:foreach(\n"
    "        fun(Row) ->\n"
    "            insert_index(Row)\n"
    "        end,\n"
    "        Rows\n"
    "    ).\n\n"
    "\nerase_indexs(Rows) ->\n"
    "    lists:foreach(\n"
    "        fun(Row) ->\n"
    "            erase_index(Row)\n"
    "        end,\n"
    "        Rows\n"
    "    ).\n\n".

game_db_index_fix_content_2() ->
    "get_rows(Index) ->\n"
    "    [\n"
    "        begin\n"
    "          R = db:read(Key),\n"
    "          if R =/= null -> noop; true -> exit({get_rows_null, Index, Key}) end,\n"
    "          R\n"
    "        end\n"
    "        || Key <- get_keys(Index)\n"
    "    ].\n\n".


game_db_init_file_head() ->
    "-module(db_init).\n"
    "-include(\"gen/db.hrl\").\n"
%%    "-include(\"db.hrl\").\n"
    "%% API\n"
    "-export([init/0, init/1]).\n\n".

game_db_load_file_head() ->
    "-module(db_load).\n"
%%    "-include(\"db.hrl\").\n"
    "-include(\"gen/db.hrl\").\n\n"
%%    "-include(\"db_config.hrl\").\n"
    "-ifdef(debug).\n"
    "-define(IS_DEBUG, true).\n"
    "-else.\n"
    "-define(IS_DEBUG, false).\n"
    "-endif.\n\n"
    "%% API\n"
    "-export([\n"
    "    load_power_data/0,\n"
    "    load_hot_data/1,\n"
    "    unload_hot_data/1,\n"
    "    safe_load_hot_data/1,\n"
    "    safe_unload_hot_data/1,\n"
    "    load/1,\n"
    "    load/2,\n"
    "    unload/2\n"
    "]).\n\n".

game_db_load_file_init_code() ->
    "load_power_data() ->\n"
    "    {_, S, _} = os:timestamp(),\n"
%%    "    LoadTables = env:get(?POWER_LOAD_TABLES),\n"
    ++ io_lib:format("    LoadTables = ~p,\n", [[util:to_atom(E) || E <- env:get(?POWER_LOAD_TABLES)]]) ++
        "    lists:foreach(\n"
        "        fun(Table) ->\n"
        "            load(Table)\n"
        "        end,\n"
        "        LoadTables\n"
        "    ),\n"
        "    {_, S1, _} = os:timestamp(),\n"
        "    S2 = S1 - S,\n"
        "    io:format(\"~nAll table load success, used ~p minute, ~p second!~n~n\", [S2 div 60, S2 rem 60]),\n"
        "    ok.\n\n"
        "safe_load_hot_data(PlayerId) ->\n"
        "    case get(is_load_hot_data) of\n"
        "        true ->\n"
        "            already_load;\n"
        "        _ ->\n"
        "            db_load_proxy:load(PlayerId),\n"
        "            put(is_load_hot_data, true),\n"
        "            ok\n"
        "    end.\n\n"
        "load_hot_data(PlayerId) ->\n"
        "    lists:foreach(\n"
        "        fun(Table) ->\n"
        "            load(Table, PlayerId)\n"
        "        end,\n"
        ++ io_lib:format("        ~p\n", [[util:to_atom(E) || E <- env:get(?HOT_LOAD_TABLES)]]) ++
        "    ),\n"
        "    ok.\n\n"
        "safe_unload_hot_data(PlayerId) ->\n"
        "    db_load_proxy:unload(PlayerId).\n\n"
        "unload_hot_data(PlayerId) ->\n"
        "    lists:foreach(\n"
        "        fun(Table) ->\n"
        "            unload(Table, PlayerId)\n"
        "        end,\n"
        ++ io_lib:format("        ~p\n", [[util:to_atom(E) || E <- env:get(?HOT_LOAD_TABLES)]]) ++
        "    ),\n"
        "    ok.\n\n".

game_db_init_file_init_code() ->
    "init() ->\n"
    "    ets:new(auto_increment,[set, named_table, public]),\n"
    ++ io_lib:format("    util_file:ensure_dir(~p),\n", [?DETS_DATA_DIR])
    ++ io_lib:format("    InitTables = ~p,\n",
        [[util:to_atom(E) || E <- env:get(?INIT_TABLES)]]) ++
        "    lists:foreach(\n"
        "        fun(Table) ->\n"
        "            init(Table)\n"
        "        end,\n"
        "        InitTables\n"
        "    ),\n"
        "    io:format(\"~nAll table init success!~n~n\"),\n"
        "    ok.\n\n".

get_all_index_field_list(TableName) ->
    L1 = lists:foldl(
        fun({_IndexName, _, IndexFiledList}, Tmp) ->
            [IndexFiledList | Tmp]
        end,
        [],
        get_index_list_by_table_name(TableName)
    ),
    L2 = lists:flatten(L1),
    lists:reverse(lists:usort(L2)).

build_insert_index_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    IndexFieldCode =
        lists:foldl(
            fun(Field, Tmp) ->
                [
                    io_lib:format(
                        "    ~s = Row#~s.~s,\n",
                        [util_string:to_var_name(Field), DbRecordName, Field]
                    ) | Tmp]
            end,
            "",
            get_all_index_field_list(TableName)
        ),
    InsertCode =
        lists:foldl(
            fun({IndexName, _, IndexFiledList}, Tmp) ->
                DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
                [
                    io_lib:format(
                        "    ets:insert(~s, {{~s}, RowKey})",
                        [DbIndexRecordName, string:join([util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", ")]
                    ) | Tmp]
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    io_lib:format(
        "insert_index(Row) when is_record(Row, ~s) ->\n"
        "    RowKey = Row#~s.row_key,\n" ++
            IndexFieldCode ++
            string:join(InsertCode, ",\n") ++ ";\n",
        [
            DbRecordName,
            DbRecordName
        ]
    ).


build_update_index_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    IndexFieldCode =
        lists:foldl(
            fun(Field, Tmp) ->
                [
                    io_lib:format(
                        "    ~s = NewRow#~s.~s,\n",
                        ["New" ++ util_string:to_var_name(Field), DbRecordName, Field]
                    ) | Tmp]
            end,
            "",
            get_all_index_field_list(TableName)
        ),
    OldIndexFieldCode =
        lists:foldl(
            fun(Field, Tmp) ->
                [
                    io_lib:format(
                        "    ~s = OldRow#~s.~s,\n",
                        ["Old" ++ util_string:to_var_name(Field), DbRecordName, Field]
                    ) | Tmp]
            end,
            "",
            get_all_index_field_list(TableName)
        ),
    InsertCode =
        lists:foldl(
            fun({IndexName, _, IndexFiledList}, Tmp) ->
                DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
                [
                    io_lib:format(
                        "    if ({~s} =/= {~s}) -> ets:delete_object(~s, {{~s}, RowKey}), ets:insert(~s, {{~s}, RowKey}); true -> noop end",
                        [
                            string:join(["Old" ++ util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", "),
                            string:join(["New" ++ util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", "),
                            DbIndexRecordName,
                            string:join(["Old" ++ util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", "),
                            DbIndexRecordName,
                            string:join(["New" ++ util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", ")
                        ]
                    ) | Tmp]
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    io_lib:format(
        "update_index(OldRow, NewRow) when is_record(NewRow, ~s) ->\n"
        "    RowKey = NewRow#~s.row_key,\n" ++
            OldIndexFieldCode ++
            IndexFieldCode ++
            string:join(InsertCode, ",\n") ++ ";\n",
        [
            DbRecordName,
            DbRecordName
        ]
    ).

build_erase_index_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    IndexFieldCode =
        lists:foldl(
            fun(Field, Tmp) ->
                [
                    io_lib:format(
                        "    ~s = Row#~s.~s,\n",
                        [util_string:to_var_name(Field), DbRecordName, Field]
                    ) | Tmp]
            end,
            "",
            get_all_index_field_list(TableName)
        ),
    InsertCode =
        lists:foldl(
            fun({IndexName, _, IndexFiledList}, Tmp) ->
                DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
                [
                    io_lib:format(
                        "    ets:delete_object(~s, {{~s}, RowKey})",
                        [DbIndexRecordName, string:join([util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", ")]
                    ) | Tmp]
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    io_lib:format(
        "erase_index(Row) when is_record(Row, ~s) ->\n"
        "    RowKey = Row#~s.row_key,\n" ++
            IndexFieldCode ++
            string:join(InsertCode, ",\n") ++ ";\n",
        [
            DbRecordName,
            DbRecordName
        ]
    ).

build_erase_all_index_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
%%    DbRecordName = get_db_record_name(TableName),
    InsertCode =
        lists:foldl(
            fun({IndexName, _, _IndexFiledList}, Tmp) ->
                DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
                [
                    io_lib:format(
                        "    ets:delete_all_objects(~s)",
                        [DbIndexRecordName]
                    ) | Tmp]
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    io_lib:format(
        "erase_all_index(~s) ->\n" ++
            string:join(InsertCode, ",\n") ++ ";\n",
        [
            TableName
        ]
    ).


build_get_keys_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
%%    DbRecordName = get_db_record_name(TableName),
    L = lists:foldl(
        fun({IndexName, _, IndexFiledList}, Tmp) ->
            IndexFieldCode =
                lists:foldl(
                    fun(Field, Tmp1) ->
                        [
                            io_lib:format(
                                "~s = ~s",
                                [Field, util_string:to_var_name(Field)]
                            ) | Tmp1]
                    end,
                    "",
                    lists:reverse(IndexFiledList)
                ),
            R = get_ets_table_fields(TableName),
            Keys = R#ets_table_fields.keys,
            KeysCode =
                lists:foldl(
                    fun(Key, Tmp1) ->
                        [
                            io_lib:format(
                                "~s = ~s",
                                [Key, ?INDEX_KEY_PRE ++ util_string:to_var_name(Key)]
                            ) | Tmp1]
                    end,
                    "",
                    lists:reverse(Keys)
                ),
            DbKeyRecordName = get_db_key_record_name(TableName),
            DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
%%            Context =
%%                io_lib:format(
%%                    "    lists:foldl(\n"
%%                    "        fun({_, {~s}}, Tmp) ->\n"
%%                    "            [#~s{" ++ string:join(KeysCode, ",") ++ "} | Tmp]\n"
%%                    "        end,\n"
%%                    "        [],\n"
%%                    "        ets:lookup(~s, {~s})\n"
%%                    "    )",
%%                    [
%%                        string:join([?INDEX_KEY_PRE ++ util_string:to_var_name(Key) || Key <- Keys], ", "),
%%                        DbKeyRecordName,
%%                        DbIndexRecordName,
%%                        string:join([util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", ")
%%                    ]
%%                ),
            Context =
                io_lib:format(
                    "    [\n"
                    "       #~s{" ++ string:join(KeysCode, ",") ++ "}\n"
                    "       || {_, {~s}}  <- ets:lookup(~s, {~s})\n"
                    "    ]",
                    [
                        DbKeyRecordName,
                        string:join([?INDEX_KEY_PRE ++ util_string:to_var_name(Key) || Key <- Keys], ", "),
                        DbIndexRecordName,
                        string:join([util_string:to_var_name(IndexFiled) || IndexFiled <- IndexFiledList], ", ")
                    ]
                ),
            [
                io_lib:format(
                    "get_keys(#~s{~s})->\n" ++
                    Context,
                    [DbIndexRecordName, string:join(IndexFieldCode, ", ")]
                ) | Tmp]
        end,
        "",
        get_index_list_by_table_name(TableName)
    ),
    string:join(L, ";\n").

build_db_init_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
%%    DbRecordName = get_db_record_name(TableName),
    AutoKey = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList, TableInfo#table_info.'Extra' =:= ?AUTO_INCREMENT],
%%    IsHotLoadTable = lists:member(util:to_list(TableName), env:get(?HOT_LOAD_TABLES)),

    %ets:new(?OFFLINE_CHAT_RECORD_BIN_LOG, [set, named_table, public, {keypos, 1}]),

    CompressTables = env:get(?COMPRESS_TABLES),
    IsCompressTable = lists:member(util:to_atom(TableName), CompressTables),

    CreateTableCode =
    case is_dets_table(TableName) of
        true ->
            io_lib:format(
                "    File = filename:join([~p, util:get_node_shot_name() ++ \"_\" ++ ~p  ++ \".dat\"]),\n"
                "    file:delete(File),\n"
                "    {ok, _} = dets:open_file(~s, [{type, set}, {keypos, 2}, {file, File}]),\n",
                [?DETS_DATA_DIR, TableName, TableName]
            );
        false ->
            if IsCompressTable ->
                io_lib:format("    ets:new(~s, [set, named_table, public, {keypos, 2}, compressed]),\n", [TableName]);
                true ->
                    io_lib:format("    ets:new(~s, [set, named_table, public, {keypos, 2}]),\n", [TableName])
            end
    end,


    AutoincrementCode = case AutoKey of
                            [] -> "";
                            _ ->
                                io_lib:format(
                                    "    {data, Res2} = mysql:fetch(game_db, <<\"SELECT max(~s) FROM `~s` \">>, infinity),\n"
                                    "    [[MaxId]] = lib_mysql:get_rows(Res2),\n"
                                    "    case is_integer(MaxId) of\n"
                                    "        true ->\n"
                                    "            ets:insert(auto_increment,[{~s, MaxId}]);\n"
                                    "        false ->\n"
                                    "            ets:insert(auto_increment,[{~s, 0}])\n"
                                    "    end,\n",
                                    [AutoKey, TableName, TableName, TableName]
                                )
                        end,
    InitLogBin =
        io_lib:format(
            "    ets:new(~s, [set, named_table, public, {keypos, 1}]),\n",
            [get_db_bin_log_table_name(TableName)]
        ),
    InitIndexCode =
        lists:foldl(
            fun({IndexName, _, _}, Tmp) ->
                DbIndexRecordName = get_db_index_record_name(util:to_list(IndexName)),
                io_lib:format(
                    "    ets:new(~s, [bag, named_table, public, {keypos, 1}]),\n",
                    [DbIndexRecordName]
                ) ++ Tmp
            end,
            "",
            get_index_list_by_table_name(TableName)
        ),
    PrepareCode = "", %% 去除prepare
%%        if IsHotLoadTable ->
%%            io_lib:format(
%%                "    mysql:prepare(~s_stmt, <<\"SELECT * from ~s WHERE player_id = ? \">>),\n",
%%                [TableName, TableName]);
%%            true ->
%%                ""
%%        end,
    io_lib:format(
        "\ninit(~s) ->\n"
        "    io:format(\"Init table : ~s~s\"),\n"
        ++
            CreateTableCode
            ++
            "~s"
            ++ PrepareCode ++ AutoincrementCode ++ InitIndexCode
            ++
            "    io:format(\" [ok] \\n\")",
        [
            TableName,
            TableName,
            lists:duplicate(max(0, 45 - length(TableName)), "."),
            InitLogBin
        ]
    ).
%%    end.



build_db_load_code(TableInfoList, DbPool) ->
    TableName = (hd(TableInfoList))#table_info.table_name,%"auto_increment"
    KEYS = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList, TableInfo#table_info.'Key' =:= ?PRI],
%%    Fields = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList],
    DbRecordName = get_db_record_name(TableName),
    L = lists:foldl(
        fun(KEY, Temp) ->
            if Temp =:= [] ->
                io_lib:format("R#~s.~s", [DbRecordName, KEY]);
                true ->
                    io_lib:format("~s, R#~s.~s", [Temp, DbRecordName, KEY])
            end
        end,
        [],
        KEYS
    ),
    IndexCode =
        case is_index_table(TableName) of
            true ->
                "    db_index:insert_indexs(Rows)";
            false ->
                ""
        end,
    FiledTran = "",
    case is_slice_table(TableName) of
        true ->
            io_lib:format(
                "load(~s, PlayerId) when is_integer(PlayerId) -> \n"
                "    Sql = io_lib:format(\"SELECT * from `~s` WHERE player_id = ~~p; \", [PlayerId]),\n"
                "    {data, Res} = mysql:fetch(~p, list_to_binary(Sql), 30000),\n"
%%                "    {data, Res} = mysql:execute(~s, ~s_stmt, [PlayerId]),\n"
                "    Fun = fun(R) ->\n"
                "        R#~s{\n"
                "            row_key = {~s}"
                "~s\n"
                "        }\n"
                "    end,\n"
                "    Rows = lib_mysql:as_record(Res, ~s, record_info(fields, ~s), Fun),\n"
                "    TableId  = PlayerId rem " ++ integer_to_list(?SLICE_NUM) ++ ",\n"
                "    EtsTable = db:get_slice_table(~s, TableId),\n"
                % "    io:format(\"Rows:~~p~~n\",[Rows]),\n"
                "~s",

                [
                    TableName,
                    TableName,
                    DbPool,
                    DbRecordName,
                    L,
                    FiledTran,
                    DbRecordName,
                    DbRecordName,
                    TableName,
                    if
                        IndexCode == "" ->
                            "    ets:insert(EtsTable, Rows)";
                        true ->
                            "    ets:insert_new(EtsTable, Rows),\n" ++ IndexCode
                    end
                ]
            );
        false ->
            io_lib:format(
                "load(~s, PlayerId) when is_integer(PlayerId) -> \n"
                "    Sql = io_lib:format(\"SELECT * from `~s` WHERE player_id = ~~p; \", [PlayerId]),\n"
                "    {data, Res} = mysql:fetch(~p, list_to_binary(Sql), 30000),\n"
%%                "    {data, Res} = mysql:execute(~s, ~s_stmt, [PlayerId]),\n"
                "    Fun = fun(R) ->\n"
                "        R#~s{\n"
                "            row_key = {~s}"
                "~s\n"
                "        }\n"
                "    end,\n"
                "    Rows = lib_mysql:as_record(Res, ~s, record_info(fields, ~s), Fun),\n"
%%                "    TableId  = integer_to_list(PlayerId rem 100),\n"
%%                "    EtsTable = list_to_atom(\"~s_\" ++  TableId), \n"
                % "    io:format(\"Rows:~~p~~n\",[Rows]),\n"
                "    EtsTable = ~s,\n"
                "~s",

                [
                    TableName,
                    TableName,
                    DbPool,
                    DbRecordName,
                    L,
                    FiledTran,
                    DbRecordName,
                    DbRecordName,
                    TableName,
                    if
                        IndexCode == "" ->
                            "    " ++ get_cache_mod(TableName) ++ ":insert(EtsTable, Rows)";
                        true ->
                            "    " ++ get_cache_mod(TableName)++ ":insert_new(EtsTable, Rows),\n" ++ IndexCode
                    end
                ]
            )
    end.
get_cache_mod(TableName) when is_list(TableName) ->
    case is_dets_table(TableName) of
        true ->
            "dets";
        false ->
            "ets"
    end.
build_db_load_code2(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    IndexCode = case is_index_table(TableName) of
                    true ->
                        "    db_index:erase_indexs(RecordList)";
                    false ->
                        ""
                end,
    case is_slice_table(TableName) of
        true ->
            if
                IndexCode == "" ->
                    io_lib:format(
                        "unload(~s, PlayerId) when is_integer(PlayerId) ->\n"
                        "    TableId  = PlayerId rem " ++ integer_to_list(?SLICE_NUM) ++ ",\n"
                        "    EtsTable = db:get_slice_table(~s,TableId), \n"
                        "    ets:select_delete(EtsTable, [{#~s{player_id = PlayerId, _ = '_'}, [], [true]}])"
                        "~s",
                        [
                            TableName,
                            TableName,
                            DbRecordName
                        ]
                    );
                true ->
                    io_lib:format(
                        "unload(~s, PlayerId) when is_integer(PlayerId) ->\n"
                        "    TableId  = PlayerId rem " ++ integer_to_list(?SLICE_NUM) ++ ",\n"
                        "    EtsTable = db:get_slice_table(~s,TableId), \n"
                        "    RecordList = ets:select(EtsTable, [{#~s{player_id = PlayerId, _ = '_'}, [], ['$_']}]),\n"
                        "~s",
                        [
                            TableName,
                            TableName,
                            DbRecordName,
                                "    [ets:delete_object(EtsTable, Record) || Record <- RecordList],\n" ++ IndexCode
                        ]
                    )
            end;
        false ->
            if
                IndexCode == "" ->
                    io_lib:format(
                        "unload(~s, PlayerId) when is_integer(PlayerId) ->\n"
                        "    ets:select_delete(~s, [{#~s{player_id = PlayerId, _ = '_'}, [], [true]}])",
                        [
                            TableName,
                            TableName,
                            DbRecordName
                        ]
                    );
                true ->
                    io_lib:format(
                        "unload(~s, PlayerId) when is_integer(PlayerId) ->\n"
                        "    RecordList = ets:select(~s, [{#~s{player_id = PlayerId, _ = '_'}, [], ['$_']}]),\n"
                        "~s",
                        [
                            TableName,
                            TableName,
                            DbRecordName,
                                "    [ets:delete_object(" ++ TableName ++ ", Record) || Record <- RecordList],\n" ++ IndexCode
                        ]
                    )
            end
    end.

build_db_load_code1(TableInfoList, DbPool) ->
    TableName = (hd(TableInfoList))#table_info.table_name,%"auto_increment"
    KEYS = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList, TableInfo#table_info.'Key' =:= ?PRI],
    DbRecordName = get_db_record_name(TableName),
%%    Fields = [TableInfo#table_info.'Field' || TableInfo <- TableInfoList],
    RowKey = lists:foldl(
        fun(KEY, Temp) ->
            if Temp =:= [] ->
                io_lib:format("R#~s.~s", [DbRecordName, KEY]);
                true ->
                    io_lib:format("~s, R#~s.~s", [Temp, DbRecordName, KEY])
            end
        end,
        [],
        KEYS
    ),
    FiledTran = "",

    ConstructTableName = case is_slice_table(TableName) of
                             true ->
                                 IndexCode =
                                     case is_index_table(TableName) of
                                         true ->
                                             "                   db_index:update_index(Row)\n";
                                         false ->
                                             ""
                                     end,
                                 io_lib:format(
                                     "           lists:foreach(\n"
                                     "                fun(Row) ->\n"
                                     "                   TableId  = Row#~s.~s rem " ++ integer_to_list(?SLICE_NUM) ++ ",\n"
                                     "                   EtsTable = db:get_slice_table(~s, TableId), \n"
                                     "~s"
                                     "                end,\n"
                                     "                Rows\n"
                                     "            )\n",
                                     [
                                         DbRecordName, get_slice_column(TableName), TableName,
                                         if
                                             IndexCode == "" ->
                                                 "                   ets:insert(EtsTable, Row)\n";
                                             true ->
                                                 "                   ets:insert(EtsTable, Row),\n" ++ IndexCode
                                         end
                                     ]
                                 );

                             false ->
                                 IndexCode =
                                     case is_index_table(TableName) of
                                         true ->
                                             "            db_index:insert_indexs(Rows)\n";
                                         false ->
                                             ""
                                     end,
                                 if
                                     IndexCode == "" ->
                                         io_lib:format(
                                             "            " ++ get_cache_mod(TableName) ++ ":insert(~s, Rows)\n",
                                             [TableName]
                                         );
                                     true ->
                                         io_lib:format(
                                             "            " ++ get_cache_mod(TableName) ++ ":insert(~s, Rows),\n"
                                             "~s",
                                             [TableName, IndexCode]
                                         )
                                 end
                         end,


    io_lib:format(
%        "\n\n" ++
%        ConstructTableName
%        ++
        "load(~s) ->\n"
        "    io:format(\"Load table : ~s~s\"),\n"
        "    {data, Res} = mysql:fetch(~s, <<\"SELECT count(1) FROM `~s`\">>, infinity),\n"
        "    [[RowNum]] = lib_mysql:get_rows(Res),\n"
        "    lists:foreach(\n"
        "        fun(Page) ->\n"
        "            Sql = \"SELECT * FROM `~s` LIMIT \" ++ integer_to_list(Page * ~p) ++ \", ~p;\",\n"
        "            {data, Res1} = mysql:fetch(~p, list_to_binary(Sql), infinity),\n"
        "            Fun = fun(R) ->\n"
        "                R#~s{\n"
        "                    row_key = {~s}"
        "~s\n"
        "                }\n"
        "            end,\n"
        "            Rows = lib_mysql:as_record(Res1, ~s, record_info(fields, ~s), Fun),\n"
        ++
            ConstructTableName
            ++
            %"            ets:insert(EtsTable, Rows)\n"
            "        end,\n"
            "        lists:seq(0, erlang:ceil(RowNum / ~p) - 1)\n"
            "    )"
            ",\n"
            "    io:format(\" [ok] \\n\")",
        [
            TableName,
            TableName,
            lists:duplicate(max(0, 45 - length(TableName)), "."),
            DbPool,
            TableName,
            TableName,
            ?SQL_PAGE_NUM,
            ?SQL_PAGE_NUM,
            DbPool,
            DbRecordName,
            RowKey,
            FiledTran,
            DbRecordName,
            DbRecordName,
            ?SQL_PAGE_NUM
        ]
    ).

build_valid_to_sql(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,

    L = [
        begin
            {
                TableInfo#table_info.'Field',
                TableInfo#table_info.'Null',
                get_type_info(TableInfo#table_info.'Type')
            }
        end
        || TableInfo <- TableInfoList
    ],
    get_valid_code(L, TableName).

get_valid_code(L, TableName) ->
    DbRecordName = get_db_record_name(TableName),
    Head = io_lib:format("ensure_to_sql(Record) when is_record(Record, ~s) ->\n", [DbRecordName]),
    get_valid_to_sql_code(L, TableName, Head).
get_valid_to_sql_code([{Field, "NO", {Type, _}}], TableName, R) ->
    DbRecordName = get_db_record_name(TableName),
    io_lib:format(
        "~s    if ~s(Record#~s.~s) -> noop ;true -> exit({vaild_for_sql,~s,~s, Record#~s.~s}) end",
        [R, get_handle_function(Type), DbRecordName, Field, TableName, Field, DbRecordName, Field]
    );
get_valid_to_sql_code([{Field, _, {Type, _}}], TableName, R) ->
    DbRecordName = get_db_record_name(TableName),
    io_lib:format(
        "~s    if ~s(Record#~s.~s) orelse Record#~s.~s =:= undefined-> noop ;true -> exit({vaild_for_sql,~s,~s, Record#~s.~s}) end",
        [R, get_handle_function(Type), DbRecordName, Field, DbRecordName, Field, TableName, Field, DbRecordName, Field]
    );
get_valid_to_sql_code([{Field, "NO", {Type, _}} | T], TableName, R) ->
    DbRecordName = get_db_record_name(TableName),
    NR = io_lib:format(
        "~s    if ~s(Record#~s.~s) -> noop ;true -> exit({vaild_for_sql,~s,~s, Record#~s.~s}) end,\n",
        [R, get_handle_function(Type), DbRecordName, Field, TableName, Field, DbRecordName, Field]
    ),
    get_valid_to_sql_code(T, TableName, NR);
get_valid_to_sql_code([{Field, _, {Type, _}} | T], TableName, R) ->
    DbRecordName = get_db_record_name(TableName),
    NR = io_lib:format(
        "~s    if ~s(Record#~s.~s) orelse Record#~s.~s =:= undefined-> noop ;true -> exit({vaild_for_sql,~s,~s, Record#~s.~s}) end,\n",
        [R, get_handle_function(Type), DbRecordName, Field, DbRecordName, Field, TableName, Field, DbRecordName, Field]
    ),
    get_valid_to_sql_code(T, TableName, NR).
get_handle_function(A) ->
    if
        A =:= int -> "is_integer";
        A =:= string -> "is_list";
        A =:= float -> "is_float"
    end.

build_generate_update_sql_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    L = [
        begin
            {
                TableInfo#table_info.'Field',
                TableInfo#table_info.'Key',
                get_type_info(TableInfo#table_info.'Type')
            }
        end
        || TableInfo <- TableInfoList
    ],
    L2 =
        lists:foldl(
            fun({Field, KeyFlag, {_Type, _Function}}, R) ->
                if KeyFlag =:= ?PRI ->
                    if R =:= "" ->
                        "\" WHERE `" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,";
                        true ->
                            R ++ "        \" AND `" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,"
                    end;
                    true ->
                        R
                end
            end,
            "",
            lists:reverse(L)
        ) ++ " \";\\n\"",
    L7 = [
            "    " ++ util_string:to_var_name(Field) ++ " = " ++ Function ++ "(Record#" ++ DbRecordName ++ "." ++ Field ++ "),\n"
        ||
        {Field, KeyFlag, {_Type, Function}} <- L, KeyFlag =:= ?PRI
    ],
    Start = 1,
    End = length(TableInfoList),
    R2 = io_lib:format(
        "generate_update_sql (~s, Record, [], Out) ->\n"
        " ~s"
        "    [<<~s>> | Out]",
        [TableName, L7, L2]
    ),
    Res = [R2 | lists:foldl(
        fun(N, Temp) ->
            {Field, _KeyFlag, {_Type, Function}} = lists:nth(N, L),
            VarKey = util_string:to_var_name(Field),
            [
                io_lib:format(
                    "generate_update_sql(~s, Record, [~p|Changes], Out)->\n"
                    "    ~s = ~s(Record#~s.~s ),\n"
                    "    Out1 = case length(Out) of 1 -> [<<\"`~s` = \", ~s/binary>> | Out]; _ -> [<<\",`~s` = \", ~s/binary>> | Out] end,\n"
                    "    generate_update_sql (~s, Record, Changes, Out1)",
                    [
                        TableName, N + 2, VarKey, Function, DbRecordName, Field,
                        Field, VarKey, Field, VarKey, TableName
                    ])
                | Temp
            ]

        end,
        [],
        lists:seq(Start, End)
    )],
    string:join(Res, ";\n").

build_tran_to_sql_code(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    L = [
        begin
            {
                TableInfo#table_info.'Field',
                TableInfo#table_info.'Key',
                get_type_info(TableInfo#table_info.'Type')
            }
        end
        || TableInfo <- TableInfoList
    ],
    L1 = "tran_to_sql ({_EtsTable," ++ TableName ++ ", insert, Record}) ->\n",
    L2 = [
            "    " ++ util_string:to_var_name(Field) ++ " = " ++ Function ++ "(Record#" ++ DbRecordName ++ "." ++ Field ++ "),\n"
        ||
        {Field, _KeyFlag, {_Type, Function}} <- L
    ],
    L3 = "    <<\n        \"INSERT INTO `" ++ TableName ++ "` SET \"\n",
    L4 =
        lists:foldl(
            fun({Field, _KeyFlag, {_Type, _Function}}, R) ->
                if R =:= [] ->
                    "        \" `" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,\n";
                    true ->
                        R ++ "        \" ,`" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,\n"
                end
            end,
            [],
            L
        ),
    L5 = "        \";\\n\"\n    >>;\n",
    L6 = io_lib:format(
        "tran_to_sql ({_EtsTable, ~s, update, NewRecord, OldRecord}) ->\n"
        "    tran_to_sql({_EtsTable, ~s , update, NewRecord, OldRecord, get_changes(~p, NewRecord, OldRecord)});\n"
        "tran_to_sql ({_EtsTable, ~s, update, _NewRecord, _OldRecord, []}) ->\n"
        "    ignore;\n"
        "tran_to_sql ({_EtsTable, ~s, update, NewRecord, _OldRecord, Changes}) ->\n"
        "    list_to_binary(lists:reverse(generate_update_sql(~s, NewRecord, Changes, [<< \"UPDATE `~s` SET \">>])));\n",
        [TableName, TableName, length(TableInfoList) + 2, TableName, TableName, TableName, TableName]
    ),
    L11 = "        \";\\n\"\n    >>;\n",
    L12 = "tran_to_sql ({_EtsTable, " ++ TableName ++ ", delete, Record}) ->\n",
    L13 = [
            "    " ++ util_string:to_var_name(Field) ++ " = " ++ Function ++ "(Record#" ++ DbRecordName ++ "." ++ Field ++ "),\n"
        ||
        {Field, ?PRI, {_Type, Function}} <- L
    ],
    L14 = "    <<\n        \"DELETE FROM `" ++ TableName ++ "` WHERE \"\n",
    L15 = lists:reverse(lists:foldl(
        fun({KeyField, KeyFlag, {_Type, _Function}}, Temp) ->
            if KeyFlag =/= ?PRI ->
                Temp;
                Temp == [] ->
                    ["        \"`" ++ KeyField ++ "` = \", " ++ util_string:to_var_name(KeyField) ++ "/binary,\n" | Temp];
                true ->
                    ["        \" and `" ++ KeyField ++ "` = \", " ++ util_string:to_var_name(KeyField) ++ "/binary,\n" | Temp]
            end
        end,
        [],
        L
    )),
    L16 = "tran_to_sql ({_EtsTable, " ++ TableName ++ ", delete_all, _Record}) ->\n",
    L17 = "    <<\n        \"DELETE FROM `" ++ TableName ++ "`;\\n\"\n    >>",
    Insert = L1 ++ L2 ++ L3 ++ L4 ++ L5,
    Update = L6,
    Delete = L12 ++ L13 ++ L14 ++ L15 ++ L11,
    DeleteAll = L16 ++ L17,
    Insert ++ Update ++ Delete ++ DeleteAll.

build_tran_to_sql_code1(TableInfoList) ->
    TableName = (hd(TableInfoList))#table_info.table_name,
    DbRecordName = get_db_record_name(TableName),
    L = [
        begin
            {
                TableInfo#table_info.'Field',
                TableInfo#table_info.'Key',
                get_type_info(TableInfo#table_info.'Type')
            }
        end
        || TableInfo <- TableInfoList, TableInfo#table_info.'Extra' =/= ?AUTO_INCREMENT
    ],
    L1 = "tran_to_sql({" ++ TableName ++ " , insert, Record}) ->\n",
    L2 = [
            "    " ++ util_string:to_var_name(Field) ++ " = " ++ Function ++ "(Record#" ++ DbRecordName ++ "." ++ Field ++ "),\n"
        ||
        {Field, _KeyFlag, {_Type, Function}} <- L
    ],
    L3 = "    <<\n        \"INSERT INTO `" ++ TableName ++ "` SET \"\n",
    L4 =
        lists:foldl(
            fun({Field, _KeyFlag, {_Type, _Function}}, R) ->
                if R =:= [] ->
                    "        \" `" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,\n";
                    true ->
                        R ++ "        \" ,`" ++ Field ++ "` = \", " ++ util_string:to_var_name(Field) ++ "/binary,\n"
                end
            end,
            [],
            L
        ),
    L5 = "        \";\\n\"\n    >>",
    Insert = L1 ++ L2 ++ L3 ++ L4 ++ L5,
    Insert.

build_dirty_write_code(TableName) ->
    DbRecordName = get_db_record_name(TableName),
    io_lib:format(
        "dirty_write(Record) when is_record(Record, ~s) ->\n"
        "    ?START_PROF,\n"
%%        "    server_state_srv:update_table_count({~s, insert}),\n"
        "    case is_tran() of\n"
        "       false ->\n"
        "           db_proxy:fetch(tran_to_sql({~s, insert, Record})), Record;\n"
        "       true ->\n"
        "           add_dirty_action({~s, insert, Record}), Record\n"
        "    end,\n"
        "    ?STOP_PROF(?MODULE, insert, ~s)",
        [DbRecordName, TableName, TableName, TableName]
    ).

build_slice_table_list_code(TableName) ->
    io_lib:format(
        "get_slice_table_list(~s)->\n"
        "    ~w",
        [
            TableName,
            lists:foldl(
                fun(Id, Tmp) ->
                    [list_to_atom(TableName ++ "_" ++ integer_to_list(Id)) | Tmp]
                end,
                [],
                lists:seq(0, ?SLICE_NUM - 1)
            )
        ]
    ).

build_slice_table_code(TableName) ->
    build_slice_table_code(TableName, ?SLICE_NUM - 1, []).
build_slice_table_code(TableName, Id, L) ->
    E = io_lib:format(
        "get_slice_table(~s, ~s)->\n"
        "    ~w",
        [
            TableName,
            integer_to_list(Id),
            list_to_atom(TableName ++ "_" ++ integer_to_list(Id))
        ]
    ),
    if
        Id == 0 ->
            string:join([E | L], ";\n");
        true ->
            build_slice_table_code(TableName, Id - 1, [E | L])
    end.

get_type_info(T) when is_list(T) ->
    Type = string:to_lower(T),
    IsInt = is_type_int(Type),
    IsFloat = is_type_float(Type),
    IsString = is_type_string(Type),
    if IsInt =:= true ->
        {int, "int_to_bin"};
        IsString =:= true ->
            {string, "list_to_bin"};
        IsFloat =:= true ->
            {float, "float_to_bin"};
        true ->
            io:format("Dosen`t support mysql type:~p~n", [Type]),
            halt(1)
    end.
is_type_int(Type) ->
    lists:prefix("tinyint", Type) orelse lists:prefix("int", Type)
        orelse lists:prefix("bigint", Type) orelse lists:prefix("smallint", Type)
        orelse lists:prefix("mediumint", Type).
is_type_float(Type) ->
    lists:prefix("float", Type) orelse lists:prefix("double", Type) orelse lists:prefix("decimal", Type).
is_type_string(Type) ->
    lists:prefix("varchar", Type) orelse string:equal("text", Type) orelse lists:prefix("char", Type)
        orelse string:equal("tinytext", Type) orelse string:equal("mediumtext", Type) orelse string:equal("longtext", Type) orelse string:equal("datetime", Type).


is_log_data_table(TableName) ->
    lists:suffix(?LOG_DATA_TABLE_SUF, TableName).

%%-------------------------------
%% @doc     是否需要分表（新增分表 ）
%% @throws
%% @end
%%-------------------------------
is_slice_table(TableName) when is_list(TableName) ->
%%    case lists:member(list_to_atom(TableName), env:get(?NO_SLICE_TABLE_LIST)) of
%%        true ->
%%            false;
%%        false ->
    case lists:keyfind(list_to_atom(TableName), 1, env:get(?SLICE_COLUMN_LIST)) of
        {_, _SliceColumn} ->
            true;
        _ ->
            false
%%                    is_player_table(TableName)
%%                    TableInfo = get_ets_table_fields(TableName),
%%                    lists:member("player_id", TableInfo#ets_table_fields.keys)
%%                        andalso is_player_table(TableName)
%%                        andalso length(TableInfo#ets_table_fields.keys) > 1
    end.

%%    end.
is_dets_table(TableName) when is_list(TableName) ->
%%    io:format("~p~n", [{TableName, env:get(?DETS_TABLES)}]),
    lists:member(TableName, env:get(?DETS_TABLES)).
is_player_table(TableName) ->
    lists:prefix("player_", TableName).

get_slice_column(TableName) when is_list(TableName) ->
    case lists:keyfind(list_to_atom(TableName), 1, env:get(?SLICE_COLUMN_LIST)) of
        {_, SliceColumn} ->
            SliceColumn;
        _ ->
            player_id
    end.

