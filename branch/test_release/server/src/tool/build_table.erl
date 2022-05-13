%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            构建CSV数据
%%% @end
%%% Created : 23. 六月 2016 下午 2:32
%%%-------------------------------------------------------------------
-module(build_table).
%% API
-export([start/0, utf8_build/1]).

-define(CSV_CONFIG_FILE, "../config/csv.config").
-define(TABLE_DB_RECORD_FILE, "../include/gen/table_db.hrl").
-define(TABLE_ENUM_FILE, "../include/gen/table_enum.hrl").
-define(LIST_FILED_SUF, "_list").
-define(TUPLE_FILED_SUF, "_tuple").
-define(CLIENT_SYS_ENUM, "../../server_client/client_enum/").      % 客户端枚举目录
%%-define(CLIENT_JSON, "../data/json/").          % 客户端枚举目录
-define(JSON_PATH, util:to_list(env:get(json_dir, "../data/json/"))). % json目录
-define(TYPE_STR, "str").       %% 字段类型: 字符串
-define(TYPE_INT, "int").       %% 字段类型: 整型
-define(TYPE_FLOAT, "float").   %% 字段类型: 浮点型
-define(TYPE_KEY, "key").       %% 字段类型: key
-define(TYPE_IGNORE, "ignore").       %% 忽略
-define(FOREIGN_KEY_COMMON_STR, "_").   % 外键通用字符串
-define(FOREIGN_KEY_JOIN, ".").         % 外键字段分隔符
-define(FOREIGN_KEY_JOIN_2, ".[").      % 外键多字段分隔符
-define(LANGUAGE_JOIN, "&").        % 语言字段分隔符
%% 枚举配置
-record(enum_config, {table_name, pre, id, sign, name, comment, create_type = 0}).
-record(json_config, {table_name, filed_list = []}).
-record(table_config, {table_name, head, type_fields, key_fields, key_field_flag, filed_list, default_value_list, comment_list}).
-record(foreign_key_table, {rowKey, table, foreign_table, foreign_key_list}).

start() ->
    env:init(),
    ets:new(ets_table_config, [set, named_table, public, {keypos, #table_config.table_name}]),
    ets:new(ets_foreign_key_table, [set, named_table, public, {keypos, #foreign_key_table.rowKey}]),
    {_, S, _} = os:timestamp(),
    CsvConfigs = util_file:load_term(?CSV_CONFIG_FILE),
    EnumConfigs = util_list:opt(enum, CsvConfigs),
    ExcludeConfigs = util_list:opt(exclude, CsvConfigs),
    JsonConfigs = util_list:opt(json, CsvConfigs),
    FileList =
        lists:foldl(
            fun(File, Tmp) ->
                case lists:member(util:to_atom(filename:basename(File, ".csv")), ExcludeConfigs) of
                    true ->
                        Tmp;
                    false ->
                        [File | Tmp]
                end

            end,
            [],
            get_all_table_file()
        ),
    io:format("~nStarting decode tables...~n~n"),

    RealEnumConfig = lists:foldl(
        fun(Config, Tmp) ->
            [tran_enum_config(Config) | Tmp]
        end,
        [],
        EnumConfigs
    ),
    RealJsonConfigs = lists:foldl(
        fun(Config, Tmp) ->
            [tran_json_config(Config) | Tmp]
        end,
        [],
        JsonConfigs
    ),
    TableList = build_table_map(FileList, [], "", "", RealEnumConfig, RealJsonConfigs),
    build_code_db:start(TableList),
    do_as(RealEnumConfig),
    logic_code:check_table(),
    case util:is_linux() of
        true ->
            Cmd = "svn ci " ++ ?CLIENT_SYS_ENUM ++ " -m 'auto submit'",
            Result = os:cmd(Cmd),
            if Result =/= "" ->
                io:format("~n~nSVN COMMIT client enum:~ts~n", [Result]);
                true ->
                    noop
            end;
        _ ->
            noop
    end,
    case env:get(is_check_foreign_key, false) of
        true ->
            create_foreign(),
            apply(foreign_key, check_foreign_key, []);
        _ ->
            noop
    end,
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

%% ----------------------------------
%% @doc 	生成表格映射
%% @throws 	none
%% @end
%% ----------------------------------
build_table_map([], TableList, RecordOut, EnumOut, _EnumConfigs, _JsonConfigs) ->
    util_file:save_code(?TABLE_DB_RECORD_FILE, file_head() ++ RecordOut),
    util_file:save_code(?TABLE_ENUM_FILE, file_head() ++ EnumOut),
    TableList;
build_table_map([TableFile | L], TableList, RecordOut, EnumOut, EnumConfigs, JsonConfigs) ->
    {csv, Parser} = csv:binary_reader(TableFile, [{annotation, false}]),

    %% 1.文件头行 %%
    H = get_next_line(Parser),
    Head = io_lib:format("%% ~s\n", [utf8_build(hd(H))]),

    BaseFileName = filename:basename(TableFile, ".csv"),
    TableName = "t_" ++ BaseFileName,
    io:format("Decode table ~s ~s", [TableName, lists:duplicate(max(0, 45 - length(TableName)), ".")]),

    %% 2.字段类型行 %%
    FieldTypeRow = get_next_line(Parser),
    TypeFields = lists:foldl(
        fun(Field, Tmp) ->
            IsStr = string:str(Field, ?TYPE_STR),
            IsInt = string:str(Field, ?TYPE_INT),
            IsFloat = string:str(Field, ?TYPE_FLOAT),
            IsIgnore = string:str(Field, "server_ignore"),
            FieldType =
                if
                    IsIgnore > 0 -> ?TYPE_IGNORE;
                    IsStr > 0 -> ?TYPE_STR;
                    IsInt > 0 -> ?TYPE_INT;
                    IsFloat > 0 -> ?TYPE_FLOAT;
                    true ->
                        io:format("[ERROR]:~p~n", [{unknow_field_type, TableName, Field}]),
                        halt(1)
%%                        exit({unknow_field_type, TableName, Field})
                end,
            [FieldType | Tmp]
        end,
        [],
        lists:reverse(FieldTypeRow)
    ),
    KeyFieldFlag = lists:foldl(
        fun(Field, Tmp) ->
            IsKey = string:str(Field, ?TYPE_KEY),
            IsKey1 =
                if IsKey > 0 -> true;
                    true -> false
                end,
            [IsKey1 | Tmp]
        end,
        [],
        lists:reverse(FieldTypeRow)
    ),

    %% 3.默认值行
    DefaultValueList = get_next_line(Parser),

    %% 4.字段名行
    FieldList_0 = get_next_line(Parser),

    {_, FieldList1} =
        lists:foldl(
            fun(File0Str, {FieldNum1, FieldL1}) ->
                IsForeignKey = string:str(File0Str, "|"),
                File0Lower =
                    if
                        IsForeignKey > 0 ->
                            OldForeignList = util:get_dict(foreign_key, []),
                            {File0Lower1, ForeignKeyStr, IsBoolStr} =
                                case string:tokens(File0Str, "|") of
                                    [File0Lower11, ForeignKeyStr11] ->
                                        {File0Lower11, ForeignKeyStr11, true};
                                    [File0Lower11, ForeignKeyStr11, IsBoolStr11] ->
                                        {File0Lower11, ForeignKeyStr11, IsBoolStr11};
                                    _ ->
                                        io:format("未找到外键内容：~p~n", [File0Str]),
                                        exit({not_find_foreign_key, File0Str})
                                end,
%%                            [File0Lower1 | ForeignKeyStrL] = string:tokens(File0Str, "|"),
%%                            ForeignKeyStr = lists:nth(1, ForeignKeyStrL),
                            [ForeignTable | ForeignKeyL] = string:tokens(ForeignKeyStr, ?FOREIGN_KEY_JOIN),
                            if
                                ForeignKeyL == [] ->
                                    io:format("外键内容格式错误table:~p >> ~p~n", [TableFile, File0Str]);
                                true -> noop
                            end,

%%                            [_ForeignKeyOtherL1 | ForeignKeyOtherL2] = string:tokens(ForeignKeyStr, "["),
                            ForeignKeyOtherIndex = string:str(ForeignKeyStr, ?FOREIGN_KEY_JOIN_2),
                            ForeignField = lists:nth(1, ForeignKeyL),
                            ForeignList =
                                if
                                    ForeignKeyOtherIndex == 0 ->
%%                                    ForeignList = calc_foreign_list(ForeignTable, {File0Lower1, IsBoolStr, ForeignField}, ForeignField, OldForeignList);
                                        calc_foreign_list(ForeignTable, {File0Lower1, IsBoolStr, ForeignField}, ForeignField, OldForeignList);
                                    true ->
                                        ForeignKeyOtherL = util_string:string_to_tuple_term(ForeignField),
                                        lists:foldl(
                                            fun(TempOldForeign, TempOldForeignList) ->
                                                TempOldForeignStr = util:to_list(TempOldForeign),
                                                calc_foreign_list(ForeignTable, {File0Lower1, IsBoolStr, TempOldForeignStr}, TempOldForeignStr, TempOldForeignList)
                                            end, OldForeignList, ForeignKeyOtherL)
                                end,
%%                            ForeignList = util_list:key_insert({ForeignTable, {File0Lower1, IsBoolStr, lists:nth(1, ForeignKeyL)}}, OldForeignList),
%%                            if
%%                                TableName == "mission" ->
%%                                    io:format("ForeignList--：~p~n", [ForeignList]);
%%                                true ->
%%                                    noop
%%                            end,
                            put(foreign_key, ForeignList),
                            util_string:str_to_lower(File0Lower1);
                        true ->
                            util_string:str_to_lower(File0Str)
                    end,
                case is_valid_filed(File0Lower) of
                    true ->
                        noop;
                    false ->
                        case lists:nth(FieldNum1, TypeFields) of
                            ?TYPE_IGNORE -> noop;
                            _ ->
                                io:format("table field error: ~ts.csv ~ts\n", [BaseFileName, File0Lower]),
                                halt(1)
                        end
                end,
                {FieldNum1 + 1, [File0Lower | FieldL1]}
            end, {1, []}, FieldList_0),

    case erase(foreign_key) of
        undefined ->
            noop;
        CalcForeignKeyList ->
            lists:foldl(
                fun({ForeignTableName, ForeignKeyList}, Count) ->
                    ets:insert(ets_foreign_key_table, #foreign_key_table{
                        rowKey = {TableName, ForeignTableName, Count},
                        table = TableName,
                        foreign_table = ForeignTableName,
                        foreign_key_list = ForeignKeyList
                    }),
                    Count + 1
                end, 1, CalcForeignKeyList)
    end,

%%    FieldList = [util_string:str_to_lower(E) || E <- FieldList_0],
    FieldList = lists:reverse(FieldList1),
    {_, TempKeyFields} = lists:foldl(
        fun(Field, {N, Tmp}) ->
            case lists:nth(N, KeyFieldFlag) of
                true ->
                    {N + 1, [Field | Tmp]};
                false ->
                    {N + 1, Tmp}
            end
        end,
        {1, []},
        FieldList
    ),
    KeyFields = lists:reverse(TempKeyFields),

    %% 5.注释
    CommentList_0 = get_next_line(Parser),

    CommentList =
        lists:reverse(
            lists:foldl(
                fun(ThisComment, Tmp) ->
                    [utf8_build(ThisComment) | Tmp]
                end,
                [],
                CommentList_0
            )),

    %% 创建 ets 表
    AtomTableName = util:to_atom(TableName),
    ets:new(AtomTableName, [set, named_table, public, {keypos, 2}]),
    {MatchEnumConfigList, LeftEnumConfigList} =
        lists:foldl(fun(C, {TmpMatchEnumConfigList, TmpLeftEnumConfigList}) ->
            if
                C#enum_config.table_name == AtomTableName ->
                    {[C | TmpMatchEnumConfigList], TmpLeftEnumConfigList};
                true ->
                    {TmpMatchEnumConfigList, [C | TmpLeftEnumConfigList]}
            end end, {[], []}, EnumConfigs),

    {MatchJsonConfigList, LeftJsonConfigList} =
        lists:foldl(fun(C, {TmpMatchJsonConfigList, TmpLeftJsonConfigList}) ->
%%            io:format("~p~n", [{BaseFileName, C#json_config.table_name }]),
            AtomBaseFileName = util:to_atom(BaseFileName),
            if
                C#json_config.table_name == AtomBaseFileName ->

                    {[C | TmpMatchJsonConfigList], TmpLeftJsonConfigList};
                true ->
                    {TmpMatchJsonConfigList, [C | TmpLeftJsonConfigList]}
            end end, {[], []}, JsonConfigs),

    %% 映射到ets表
    insert_to_ets(Parser, AtomTableName, TypeFields, KeyFieldFlag, FieldList, DefaultValueList),

    RealFieldList = lists:reverse(get_real_table_field_list(TypeFields, FieldList)),
    ets:insert(ets_table_config, #table_config{
        table_name = TableName,
        head = Head,
        type_fields = TypeFields,
        key_field_flag = KeyFieldFlag,
        filed_list = RealFieldList,
        default_value_list = DefaultValueList,
        key_fields = KeyFields,
        comment_list = CommentList
    }),
    %% 生成枚举
    NewEnumOut =
        case MatchEnumConfigList of
            [] ->
                EnumOut;
            _ ->
                build_enum(RealFieldList, EnumOut, MatchEnumConfigList)
        end,
    case env:get(is_create_json) of
        true ->
            %% 生成json
            build_json(RealFieldList, MatchJsonConfigList);
        _ ->
            noop
    end,

    csv:kill(Parser),

    {_, _, _, _, TableRecord} =
        lists:foldl(
            fun(Field1, {CountN, N, AfterDes, Max, Tmp}) ->
                Field = get_field_language_str(Field1),
                ConfigDefault = lists:nth(N, DefaultValueList),
                FileType = lists:nth(N, TypeFields),
                %% 获取字段默认值
                Default =
                    case lists:suffix(?LIST_FILED_SUF, Field) of
                        true ->
                            util_string:string_to_list_term(ConfigDefault);
                        false ->
                            case lists:suffix(?TUPLE_FILED_SUF, Field) of
                                true ->
                                    case ConfigDefault of
                                        "" ->
                                            {};
                                        _ ->
                                            util_string:string_to_tuple_term(ConfigDefault)
                                    end;
                                _ ->
                                    case ConfigDefault of
                                        "" ->
                                            case FileType of
                                                ?TYPE_INT -> 0;
                                                _ -> ""
                                            end;
                                        _ ->
                                            case FileType of
                                                ?TYPE_INT -> to_int(ConfigDefault);
                                                ?TYPE_STR -> util:to_list(ConfigDefault);
                                                ?TYPE_IGNORE -> ""
                                            end
                                    end
                            end
                    end,
                if
                    FileType == ?TYPE_IGNORE ->
                        if N == Max ->
                            Comment = "",
                            S = Tmp ++ io_lib:format(
                                " ~s",
                                [AfterDes]
                            ) ++ "}).\n";
                            true ->
                                Comment = AfterDes,
                                S = Tmp
                        end,
                        {CountN, N + 1, Comment, Max, S};
                    CountN == 1 ->
                        if N == Max ->
                            Comment = io_lib:format("~s%% ~s", [lists:duplicate(max(0, 40 - length(lists:flatten(io_lib:format("~s~p", [Field, Default])))), " "), lists:nth(N, CommentList)]),
                            S = Tmp ++ io_lib:format("-record(~s, {\n"
                            "    row_key,\n"
                            "    ~s = ~p~s\n",
                                [TableName, Field, Default, Comment]
                            ) ++ "}).\n";
                            true ->
                                Comment = io_lib:format("~s%% ~s\n", [lists:duplicate(max(0, 39 - length(lists:flatten(io_lib:format("~s~p", [Field, Default])))), " "), lists:nth(N, CommentList)]),
                                S = Tmp ++ io_lib:format("-record(~s, {\n"
                                "    row_key,\n"
                                "    ~s = ~p",
                                    [TableName, Field, Default]
                                )
                        end,
                        {CountN + 1, N + 1, Comment, Max, S};
                    true ->
                        if N == Max ->
                            Comment = io_lib:format("~s%% ~s\n", [lists:duplicate(max(0, 40 - length(lists:flatten(io_lib:format("~s~p", [Field, Default])))), " "), lists:nth(N, CommentList)]),
                            S = Tmp ++ io_lib:format(
                                ",~s    ~s = ~p~s",
                                [AfterDes, Field, Default, Comment]
                            ) ++ "}).\n";
                            true ->
                                Comment = io_lib:format("~s%% ~s\n", [lists:duplicate(max(0, 39 - length(lists:flatten(io_lib:format("~s~p", [Field, Default])))), " "), lists:nth(N, CommentList)]),
                                S = Tmp ++ io_lib:format(
                                    ",~s    ~s = ~p",
                                    [AfterDes, Field, Default]
                                )
                        end,
                        {CountN + 1, N + 1, Comment, Max, S}
                end
            end,
            {1, 1, "\n", length(FieldList), Head},
            FieldList
        ),
    {_, _, TableKeyRecord} =
        lists:foldl(
            fun(Field, {N, Max, Tmp}) ->
                case lists:nth(N, KeyFieldFlag) of
                    true ->
                        if
                            N == 1 ->
                                if N == Max ->
                                    Comment = io_lib:format("~s%% ~s", [lists:duplicate(max(0, 43 - length(lists:flatten(Field))), " "), lists:nth(N, CommentList)]),
                                    S = io_lib:format("-record(key_~s, {\n"
                                    "    ~s\n",
                                        [TableName, Field ++ Comment]
                                    ) ++ "}).\n\n";
                                    true ->
                                        Comment = io_lib:format(",~s%% ~s", [lists:duplicate(max(0, 42 - length(lists:flatten(Field))), " "), lists:nth(N, CommentList)]),
                                        S = io_lib:format("-record(key_~s, {\n"
                                        "    ~s\n",
                                            [TableName, Field ++ Comment]
                                        )
                                end,
                                {N + 1, Max, S};
                            true ->
                                if N == Max ->
                                    Comment = io_lib:format("~s%% ~s", [lists:duplicate(max(0, 43 - length(lists:flatten(Field))), " "), lists:nth(N, CommentList)]),
                                    S = Tmp ++ io_lib:format(
                                        "    ~s\n",
                                        [Field ++ Comment]
                                    ) ++ "}).\n\n";
                                    true ->
                                        Comment = io_lib:format(",~s%% ~s", [lists:duplicate(max(0, 42 - length(lists:flatten(Field))), " "), lists:nth(N, CommentList)]),
                                        S = Tmp ++ io_lib:format(
                                            "    ~s\n",
                                            [Field ++ Comment]
                                        )
                                end,
                                {N + 1, Max, S}
                        end;
                    false ->
                        S =
                            if N == Max ->
                                Tmp ++ "}).\n\n";
                                true ->
                                    Tmp
                            end,
                        {N + 1, Max, S}
                end
            end,
            {1, length(KeyFields), ""},
            KeyFields
        ),
    io:format(" [ok]~n"),
    build_table_map(L, [TableName | TableList], RecordOut ++ TableRecord ++ TableKeyRecord, NewEnumOut, LeftEnumConfigList, LeftJsonConfigList).

%% 获得各国语言字段
get_field_language_str(Field) ->
    Index = string:str(Field, ?LANGUAGE_JOIN),
    if
        Index > 0 ->
            case string:tokens(Field, ?LANGUAGE_JOIN) of
                [LanguageStr, FieldStr] ->
                    io_lib:format("~s__~s", [FieldStr, LanguageStr]);
                _ ->
                    Field
            end;
        true -> Field
    end.

%% 获得真实的字段列表
get_real_table_field_list(TypeFields, FieldList) ->
    get_real_table_field_list(TypeFields, FieldList, []).
get_real_table_field_list([], _FieldList, NewFieldList) ->
    NewFieldList;
get_real_table_field_list(_TypeFields, [], NewFieldList) ->
    NewFieldList;
get_real_table_field_list([TypeField | TypeFields], [Field | FieldList], NewFieldList) ->
    CalcFieldList =
        if
            TypeField == ?TYPE_IGNORE ->
                NewFieldList;
            true ->
                [Field | NewFieldList]
        end,
    get_real_table_field_list(TypeFields, FieldList, CalcFieldList).


get_all_csv_rows(Parser, List) ->
    case csv:next_line(Parser) of
        {row, DataList, _Id} ->
            get_all_csv_rows(Parser, [DataList | List]);
        _ ->
            lists:reverse(List)
    end.

%% 转文本内容
utf8_build(Str) ->
    GbkStr = gbk:decode(Str),
    util_string:to_utf8(GbkStr).


%% ----------------------------------
%% @doc 	插入csv 数据到 ets表
%% @throws 	none
%% @end
%% ----------------------------------
insert_to_ets(Parser, TableName, TypeFields, KeyFields, FieldList, DefaultValueList) ->
    Rows = get_all_csv_rows(Parser, []),
    insert_to_ets_1(Rows, TableName, TypeFields, KeyFields, FieldList, DefaultValueList).

insert_to_ets_1([], _TableName, _TypeFields, _KeyFields, _FieldList, _DefaultValueList) ->
    ok;
insert_to_ets_1([Row | LeftRows], TableName, TypeFields, KeyFields, FieldList, DefaultValueList) ->
    {_, Row_1} = lists:foldl(
        fun(Cell, {N, TmpDataList}) ->
            Type = lists:nth(N, TypeFields),
            Field = lists:nth(N, FieldList),
            Default = lists:nth(N, DefaultValueList),
            case Type of
                ?TYPE_IGNORE ->
%%                    {N + 1, ["" | TmpDataList]};
                    {N + 1, TmpDataList};
                ?TYPE_STR ->
                    Data0 =
                        if Cell == "" ->
                            Default;
                            true ->
                                utf8_build(Cell)
                        end,
                    Data1 =
                        case lists:suffix(?LIST_FILED_SUF, Field) of
                            true ->
                                util_string:string_to_list_term(util_string:replace(util_string:replace(Data0, ")", "]"), "(", "["));
                            false ->
                                case lists:suffix(?TUPLE_FILED_SUF, Field) of
                                    true ->
                                        util_string:string_to_list_term(util_string:replace(util_string:replace(Data0, ")", "]"), "(", "["));
                                    false ->
                                        Data0
                                end
                        end,
                    {N + 1, [Data1 | TmpDataList]};
                ?TYPE_INT ->
                    Data0 =
                        if Cell == "" ->
                            case Default of
                                "" ->
                                    0;
                                Default_ ->
                                    Default_
                            end;
                            true ->
                                Cell
                        end,
                    {N + 1, [to_int(Data0) | TmpDataList]}
            end
        end,
        {1, []},
        Row
    ),
    Rows_2 = lists:reverse(Row_1),
    {_, Keys} = lists:foldl(
        fun(IsKey, {N, TempKeys}) ->
            if IsKey ->
                {N + 1, [lists:nth(N, Rows_2) | TempKeys]};
                true ->
                    {N + 1, TempKeys}
            end
        end,
        {1, []},
        KeyFields
    ),
    RealKeys = list_to_tuple(lists:reverse(Keys)),
%%    if TableName == t_reward ->
%%        io:format("~p~n", [RealKeys]);
%%        true ->
%%            noop
%%    end,
    if TableName == t_skill_assembly ->
        noop;
        true ->
            case ets:lookup(TableName, RealKeys) of
                [] ->
                    noop;
                _ ->
                    exit({key_repeated, TableName, RealKeys})
            end
    end,
    ets:insert(TableName, list_to_tuple([TableName, RealKeys | Rows_2])),

    insert_to_ets_1(LeftRows, TableName, TypeFields, KeyFields, FieldList, DefaultValueList).

get_index(TableName, Filed, FieldList) ->
    case util_list:get_element_index(util:to_list(Filed), FieldList) of
        none ->
            io:format("[ERROR] unknow index:~p~n", [{TableName, util:to_list(Filed)}]),
            halt(1);
        {index, IdIndex_} ->
            IdIndex_ + 2
    end.

%% ----------------------------------
%% @doc 	创建外键文件
%% @throws 	none
%% @end
%% ----------------------------------
%% @doc fun 创建外键文件
create_foreign() ->
    Self = self(),
    spawn(fun() ->
        try handle_create_foreign() of
            ok ->
                Self ! {create_foreign, ok}
        catch
            _ : Error ->
                Self ! {create_foreign, Error}
        end end),
    receive
        {create_foreign, ok} ->
            ok;
        {create_foreign, Error} -> exit(Error)
    end.
handle_create_foreign() ->
    io:format("\n\ncreate foreign:\n"),
    {TableKeyList, TableKeyIsBoolList, ForeignTableFieldList, TableKeySwitchList} =
        lists:foldl(
            fun(#foreign_key_table{table = Table, foreign_table = ForeignTable, foreign_key_list = ForeignKeyList}, {TableKeyL, TableKeyIsBoolL, ForeignTableFieldL, TableKeySwitchL}) ->
                {TableFieldList, TableFieldIsBoolList, ForeignTableKeyList} =
                    lists:foldl(
                        fun({TableField, IsBoolStr, ForeignTableField}, {TableFieldL, TableFieldIsBoolL, ForeignTableKeyL}) ->
%%                        ForeignRecordName = get_record_name(ForeignTable),
%%                        io_lib:format("#~p.~p",[ForeignRecordName,ForeignTableField])
                            case lists:member(TableField, TableFieldL) of
                                true -> {TableFieldL, TableFieldIsBoolL, [ForeignTableField | ForeignTableKeyL]};
                                _ ->
                                    {[TableField | TableFieldL], [{TableField, IsBoolStr} | TableFieldIsBoolL], [ForeignTableField | ForeignTableKeyL]}
                            end
                        end, {[], [], []}, ForeignKeyList),
                {
                    util_list:key_insert({Table, TableFieldList}, TableKeyL),  % get_table_key_list(function) -> [[id, type], [sign]]
                    util_list:key_insert({Table, TableFieldIsBoolList}, TableKeyIsBoolL),   % 判断数据内容的
                    util_list:key_insert({"t_" ++ ForeignTable, ForeignTableKeyList}, ForeignTableFieldL),
                    [[{Table, TableFieldList}, {"t_" ++ ForeignTable, ForeignTableKeyList}] | TableKeySwitchL] % get_table_key({function, [id, type]}) -> {acitivity, {activity_id, activity_type}}.
                }
            end, {[], [], [], []}, ets:tab2list(ets_foreign_key_table)),
    util:output_line_info("calc TableDataList"),
    TableDataList =
        lists:foldl(
            fun({Table, TableFieldList}, L) ->
                #table_config{
                    filed_list = FieldList
                } = get_ets_table_config(Table),
                CalcIndexKeyList =
                    lists:foldl(
                        fun(FieldL, CalcIndexKeyL) ->
                            IndexKeyL =
                                lists:foldl(
                                    fun({Field1, IsBoolStr}, FieldL1) ->
                                        Index = get_index(Table, Field1, FieldList),
                                        BoolFun =
                                            fun(CurrValue) ->
                                                if IsBoolStr == true -> true;
                                                    true ->
                                                        case get_str_operators_and_value(IsBoolStr) of
                                                            {Operators, LimieValue} ->
                                                                fun_contrast_value(CurrValue, Operators, LimieValue);
                                                            _ ->
                                                                io:format("~p:运算符转换错误：~p~n", [?MODULE, {Table, Field1, IsBoolStr}]),
                                                                exit(not_operators_error)
                                                        end
                                                end
                                            end,
                                        [{Index, BoolFun} | FieldL1]
                                    end, [], FieldL),
%%                        IndexKey = lists:reverse(NewIndexL1),
                            [{[Field || {Field, _} <- FieldL], IndexKeyL} | CalcIndexKeyL]
                        end, [], TableFieldList),

                lists:foldl(
                    fun({IndexKeyFieldL, IndexKeyL}, TmpL) ->
                        IndexCount = length(IndexKeyL),
                        lists:foldl(
                            fun(Row, Tmp2) ->
                                {CalcValues, FieldNum} =
                                    lists:foldl(
                                        fun({Index, BoolFun}, {FieldL1, FieldNum1}) ->
                                            Value = erlang:element(Index, Row),
                                            IsBool = BoolFun(Value),
                                            if
                                                IsBool == true ->
                                                    {[Value | FieldL1], FieldNum1 + 1};
                                                true ->
                                                    {FieldL1, FieldNum1}
                                            end
                                        end, {[], 0}, IndexKeyL),
                                if
                                    IndexCount == FieldNum ->
                                        Conditions = {Table, IndexKeyFieldL},
                                        util_list:calc_two_key_list(Conditions, CalcValues, erlang:element(2, Row), Tmp2);
                                    FieldNum == 0 ->
                                        Tmp2;
                                    true ->
                                        io:format("not_key_num:多条件key不能有一项外键值不符合的：~p~n", [{Table, IndexKeyFieldL}]),
                                        exit({not_key_num, IndexCount, FieldNum})
                                end
                            end, TmpL, lists:sort(ets:tab2list(util:to_atom(Table))))
                    end, L, CalcIndexKeyList)

            end, [], TableKeyIsBoolList),
%%    io:format("TableDataList:~p~n", [TableDataList]),
    util:finish_line_info(),
    util:output_line_info("calc ForeignTableDataList"),
    ForeignTableDataList =
        lists:foldl(
            fun({ForeignTable, TableFieldList}, L) ->
                SortTableFieldList = lists:usort(TableFieldList),
                FieldList =
                    case get_ets_table_config_no_exit(ForeignTable) of
                        #table_config{filed_list = FieldList1} ->
                            FieldList1;
                        _ ->
                            ErrorTableList_0 = [TableTuple || [TableTuple, {CheckForeignTable, _}] <- TableKeySwitchList, CheckForeignTable == ForeignTable],
                            io:format("~n[ERROR]notFindForeignTable: ~p~nErrorTableList ~p~n", [ForeignTable, ErrorTableList_0]),
                            halt(1)
                    end,
                CalcTableFieldList =
                    lists:foldl(
                        fun(FieldL, CalcTableFieldL) ->
                            NewIndexL1 =
                                [begin
                                     if
                                         Field1 == ?FOREIGN_KEY_COMMON_STR ->
                                             Field1;
                                         true ->
                                             Index = get_index_no_exit(Field1, FieldList),
                                             if
                                                 Index == 0 ->
                                                     ErrorTableList = [TableTuple || [TableTuple, CheckForeignTuple] <- TableKeySwitchList, CheckForeignTuple == {ForeignTable, FieldL}],
                                                     io:format("~n[ERROR]notFindForeignFieldList:~p~nErrorTableList ~p ~n", [{ForeignTable, FieldL}, ErrorTableList]),
                                                     halt(1);
                                                 true ->
                                                     Index
                                             end
                                     end
                                 end || Field1 <- FieldL],
                            [{FieldL, NewIndexL1} | CalcTableFieldL]
                        end, [], SortTableFieldList),
                lists:foldl(
                    fun(Row, Tmp) ->
                        lists:foldl(
                            fun({FieldL, FieldIndexL}, Tmp2) ->
                                NewFieldL1 =
                                    [begin
                                         if
                                             Index == ?FOREIGN_KEY_COMMON_STR -> Index;
                                             true -> erlang:element(Index, Row)
                                         end
                                     end || Index <- FieldIndexL],
                                Conditions = {ForeignTable, FieldL, NewFieldL1},
                                case get(Conditions) of
                                    undefined ->
                                        put(Conditions, true),
                                        [Conditions | Tmp2];
                                    _ -> Tmp2
                                end
%%                                case lists:member(Conditions, Tmp2) of
%%                                    false -> [Conditions | Tmp2];
%%                                    _ -> Tmp2
%%                                end
                            end, Tmp, CalcTableFieldList)
                    end, L, ets:tab2list(util:to_atom(ForeignTable)))
            end, [], ForeignTableFieldList),
    util:finish_line_info(),
%%    io:format("ForeignTableDataList:~p~n", [ForeignTableDataList]),
%%    io:format("TableKeySwitchList:~p~n", [TableKeySwitchList]),
    build_foreign_key:create_foreign(TableKeyList, lists:sort(TableKeySwitchList), TableDataList, ForeignTableDataList),
    ok.

get_ets_table_config(TableName) ->
    case get_ets_table_config_no_exit(TableName) of
        null -> exit({table_no_exists, TableName});
        Ets -> Ets
    end.

get_ets_table_config_no_exit(TableName) ->
    case ets:lookup(ets_table_config, util:to_list(TableName)) of
        [] ->
            null;
        L ->
            hd(L)
    end.

%% doc fun  比较数据
fun_contrast_value(CurrValue, ContrastOperators, ContrastValue) ->
    CalcContrastValue =
        if is_list(CurrValue) -> ContrastValue;
            is_integer(CurrValue) -> util:to_int(ContrastValue);
            is_tuple(CurrValue) -> util_string:string_to_tuple_term(ContrastValue);
            true ->
                0
        end,
    case ContrastOperators of
        ">=" -> CurrValue >= CalcContrastValue;
        "=<" -> CurrValue =< CalcContrastValue;
        ">" -> CurrValue > CalcContrastValue;
        "<" -> CurrValue < CalcContrastValue;
        "==" -> CurrValue == CalcContrastValue;
        "=/=" -> CurrValue =/= CalcContrastValue
    end.

get_index_no_exit(Filed, FieldList) ->
    case get_element_index(util:to_list(Filed), FieldList) of
        none ->
            0;
        {index, IdIndex_} ->
            IdIndex_ + 2
    end.

get_element_index(Element, L) ->
    get_element_index(Element, L, 0).
get_element_index(_Element, [], _N) ->
    none;
get_element_index(Element, [Element | _L], N) ->
    {index, N + 1};
get_element_index(Element, [_H | L], N) ->
    get_element_index(Element, L, N + 1).


is_valid_filed(V) ->
    case re:run(V, "^[a-z][a-z&A-Z0-9_]*$", [unicode]) of %%字母数字
        nomatch ->
            false;
        _ ->
            true
    end.


%% doc fun  计算外键数据列表
calc_foreign_list(CurrKey, CurrValue, CompareValue, List) ->
    calc_foreign_list(List, CurrKey, CurrValue, CompareValue, 3, []).
calc_foreign_list([], CurrKey, CurrValue, _CompareValue, _CompareIndex, ResultList) ->
    [{CurrKey, [CurrValue]} | ResultList];
calc_foreign_list([{Key, ValueL} | List], CurrKey, CurrValue, CompareValue, CompareIndex, ResultList) ->
    if
        CurrKey == Key ->
            case compare_list_repeat_value(ValueL, CompareValue, CompareIndex) of
                true ->
                    calc_foreign_list(List, CurrKey, CurrValue, CompareValue, CompareIndex, [{Key, ValueL} | ResultList]);
                false ->

                    List ++ [{Key, [CurrValue | ValueL]} | ResultList]
            end;
        true ->
            calc_foreign_list(List, CurrKey, CurrValue, CompareValue, CompareIndex, [{Key, ValueL} | ResultList])
    end.
%% doc fun  比较列表相同值
compare_list_repeat_value([], _CompareValue, _CompareIndex) ->
    false;
compare_list_repeat_value([ValueTuple | ListValueL], CompareValue, CompareIndex) ->
    ValueKey = element(CompareIndex, ValueTuple),
    if
        ValueKey == CompareValue ->
            true;
        true ->
            compare_list_repeat_value(ListValueL, CompareValue, CompareIndex)
    end.

%% ----------------------------------
%% @doc 	生成枚举
%% @throws 	none
%% @end
%% ----------------------------------
build_enum(_FieldList, EnumOut, []) ->
    EnumOut;
build_enum(FieldList, EnumOut, [EnumConfig | L]) ->
    NewEnumOut =
        case EnumConfig of
            null ->
                EnumOut;
            #enum_config{table_name = TableName, pre = Pre, id = Id, sign = Sign, name = Name, comment = Comment, create_type = CreateType} ->
                EnumOut_1 = EnumOut ++ io_lib:format("%% ~s~n", [Comment]),
                GetIndexFun =
                    fun(I) ->
                        case util_list:get_element_index(util:to_list(I), FieldList) of
                            none ->
                                io:format("[ERROR] enum_config_error:~p~n", [{enum_config_error, TableName, util:to_list(I)}]),
                                halt(1);
%%                                exit({enum_config_error, TableName, util:to_list(I)});
                            {index, IdIndex_} ->
                                IdIndex_
                        end
                    end,
                lists:foldl(
                    fun(Rows, TmpEnumOut) ->
                        IdGet = erlang:element(GetIndexFun(Id) + 2, Rows),
                        IdStr = util:to_list(IdGet),
                        SignStr = util:to_list(erlang:element(GetIndexFun(Sign) + 2, Rows)),
                        NameStr = util:to_list(erlang:element(GetIndexFun(Name) + 2, Rows)),
                        EnumOut1 =
                            if
                            %% 忽略 sign 为空的数据
                                SignStr =/= "" andalso (CreateType == 0 orelse CreateType == 1 orelse CreateType == 10 orelse CreateType == 11) ->
                                    StrSign = util_string:str_to_upper(util:to_list(Pre) ++ util:to_list(SignStr)),
                                    Blank = lists:duplicate(max(0, 45 - length(StrSign) - length(IdStr)), " "),
                                    if TableName == t_platform orelse TableName == t_channel ->
                                        Out = io_lib:format("-define(~s, \"~s\").~s%% ~s~n", [StrSign, IdStr, Blank, NameStr]);
                                        true ->
                                            Out = io_lib:format("-define(~s, ~s).~s%% ~s~n", [StrSign, IdStr, Blank, NameStr])
                                    end,
                                    TmpEnumOut ++ Out;
                                true ->
                                    TmpEnumOut
                            end,
                        if
                            CreateType >= 1 andalso SignStr =/= "" ->
                                key_put({TableName, IdGet}, [{Id, IdStr}, {Sign, SignStr}, {Name, NameStr}]);
                            true ->
                                ok
                        end,
                        EnumOut1
                    end,
                    EnumOut_1,
                    lists:sort(ets:tab2list(TableName))
                )

        end,
    build_enum(FieldList, NewEnumOut ++ "\n\n", L).

%% ----------------------------------
%% @doc 	生成json
%% @throws 	none
%% @end
%% ----------------------------------
build_json(_FieldList, []) ->
    ok;
build_json(FieldList, [JsonConfig | L]) ->
    #json_config{
        table_name = TableName,
        filed_list = FiledList
    } = JsonConfig,
    StringTableName = util:to_list(TableName),
    io:format("create json ~s ~s ", [StringTableName, lists:duplicate(max(0, 45 - length(StringTableName)), ".")]),
    JsonFileName = ?JSON_PATH ++ util_string:to_var_name(StringTableName) ++ ".json",
    util_file:ensure_dir(?JSON_PATH),
    IndexList = lists:reverse(lists:foldl(
        fun(Filed, TmpList) ->
            case is_tuple(Filed) of
                true ->
                    {RealFiled, AliasName} = Filed,
                    [{AliasName, get_index(TableName, RealFiled, FieldList)} | TmpList];
                false ->
                    [{Filed, get_index(TableName, Filed, FieldList)} | TmpList]
            end
        end,
        [],
        lists:reverse(FiledList)
    )),
    R = lists:sort(lists:foldl(
        fun(Row, Tmp) ->
            [
                lists:foldl(
                    fun({Filed, Index}, Tmp2) ->
                        Value = erlang:element(Index, Row),
                        if is_list(Value) ->
                            if
                                StringTableName =:= "recharge" ->
                                    Value1 =
                                        case catch util:to_binary(Value) of
                                            {'EXIT', _} ->
                                                A = lists:foldl(fun(Ele, EleTmp) -> [atom_to_list(Ele) | EleTmp] end, [], Value),
                                                util:to_binary(lists:join(",", A));
                                            F -> F
                                        end,
                                    [{Filed, Value1} | Tmp2];
                                true ->
                                    [{Filed, util:to_binary(Value)} | Tmp2]
                            end;
                            true ->
                                [{Filed, Value} | Tmp2]
                        end
                    end,
                    [],
                    IndexList
                ) | Tmp]
        end, [], lists:sort(ets:tab2list(util:to_atom("t_" ++ util:to_list(TableName)))))),
%%    io:format("~n~p~n", [R]),
    util_file:save(JsonFileName, [binary_to_list(jsone:encode(R, [native_utf8, {space, 1}, {indent, 4}]))]),
    io:format(" [ok]~n"),
    build_json(FieldList, L).

file_head() ->
    "%%% Generated automatically, no need to modify.\n".

% 记录客户端枚举
key_put({TableName, Value}, List) ->
    case get(TableName) of
        L when is_list(L) ->
            put(TableName, [Value | L]);
        _ ->
            put(TableName, [Value])
    end,
    [put(util:to_list(TableName) ++ util:to_list(Key) ++ util:to_list(Value), V) || {Key, V} <- List].


% 生成客户端枚举 和json
do_as(EnumConfigs) ->
    io:format("~n Starting do_client_ts~n"),
    do_as_config(EnumConfigs).

do_as_config([]) ->
    ok;
do_as_config([EnumConfig | EnumConfigs]) ->
    case EnumConfig of
        #enum_config{table_name = TableName, pre = _Pre, id = Id, sign = Sign, name = Name, create_type = CreateType} ->
%%        {T, _, Id, Sign, Name, IsShowClient} ->
            StrTableName = util:to_list(TableName),
            Table =
                case string:substr(StrTableName, 1, 2) of
                    "t_" ->
                        util_string:to_var_name(string:substr(StrTableName, 3));
                    _ ->
                        util_string:to_var_name(StrTableName)
                end,
            if
                CreateType == 1 orelse CreateType == 2 orelse CreateType == 11 orelse CreateType == 12 ->
                    io:format("do_ts file ~s ~s ", [StrTableName, lists:duplicate(max(0, 45 - length(StrTableName)), ".")]),
                    FileName = Table ++ "Enum",
                    util_file:ensure_dir(?CLIENT_SYS_ENUM),
                    {ok, File} = file:open(?CLIENT_SYS_ENUM ++ FileName ++ ".ts", [write]),
                    T2 = io_lib:format("class ~s ~n{~n", [FileName]),
                    util_file:write(File, T2),
                    lists:foldl(
                        fun(IdV, _L) ->
                            StrId1 = get(util:to_list(TableName) ++ util:to_list(Id) ++ util:to_list(IdV)),
                            {Type, StrId} =
                                case is_integer(IdV) of
                                    true ->
                                        {"number", to_int(StrId1)};
                                    _ ->
                                        {"string", StrId1}
                                end,
                            StrSign = util_string:str_to_upper(get(util:to_list(TableName) ++ util:to_list(Sign) ++ util:to_list(IdV))),
                            StrDesc = get(util:to_list(TableName) ++ util:to_list(Name) ++ util:to_list(IdV)),
                            StrIdBlank = lists:duplicate(max(0, 30 - length(StrSign)), " "),
                            Out = io_lib:format("     /**~s*/~n     public static ~s:~s ~s= ~p;~n", [StrDesc, StrSign, Type, StrIdBlank, StrId]),
                            util_file:write(File, Out)
                        end, [], lists:sort(get_table_name_list(TableName))),
                    T3 = io_lib:format("~n     public constructor() {} ~n}~n", []),
                    util_file:write(File, T3),
                    file:close(File),
                    io:format("[ok]~n");
                true ->
                    noop
            end;
%%            if
%%                CreateType >= 10 ->
%%                    case util:is_linux() of
%%                        true ->
%%                            JsonFileName = ?CLIENT_JSON ++ Table ++ ".json",
%%                            util_file:ensure_dir(?CLIENT_JSON),
%%                            R = lists:sort(lists:foldl(
%%                                fun(IdV, Tmp) ->
%%                                    StrDesc = get(StrTableName ++ util:to_list(Name) ++ util:to_list(IdV)),
%%%%                            io:format("IdV:~p~n", [IdV]),
%%                                    case is_integer(IdV) of
%%                                        true ->
%%                                            [[{id, IdV}, {name, util:to_binary(StrDesc)}] | Tmp];
%%                                        false ->
%%                                            [[{id, util:to_binary(IdV)}, {name, util:to_binary(StrDesc)}] | Tmp]
%%                                    end
%%                                end, [], get_table_name_list(TableName))),
%%                            util_file:save(JsonFileName, [binary_to_list(jsone:encode(R, [native_utf8, {space, 1}, {indent, 4}]))]);
%%                        _ ->
%%                            noop
%%                    end;
%%                true ->
%%                    noop
%%            end;
        _ ->
            noop
    end,
    do_as_config(EnumConfigs).

get_table_name_list(TableName) ->
    List = get(TableName),
    if
        List == undefined ->
            exit({as_null_table, ?MODULE, TableName});
        true ->
            List
    end.

%% ----------------------------------
%% @doc 	转换enum_config
%% @throws 	none
%% @end
%% ----------------------------------
tran_enum_config({TableName, Pre, Id, Sign, Name, Comment}) ->
    #enum_config{
        table_name = TableName,
        pre = Pre,
        id = Id,
        sign = Sign,
        name = Name,
        comment = util_string:string_to_list(Comment)
    };
tran_enum_config({TableName, Pre, Id, Sign, Name, Comment, CreateType}) ->
    #enum_config{
        table_name = TableName,
        pre = Pre,
        id = Id,
        sign = Sign,
        name = Name,
        comment = util_string:string_to_list(Comment),
        create_type = CreateType
    };
tran_enum_config(Other) ->
%%    exit({enum_config_error, Other}),
    io:format("[ERROR] enum_config_error:~p~n", [Other]),
    halt(1).

tran_json_config({TableName, FiledList}) ->
    #json_config{
        table_name = TableName,
        filed_list = FiledList
    };
tran_json_config(Other) ->
    io:format("[ERROR] json_config_error:~p~n", [Other]),
    halt(1).


%% ----------------------------------
%% @doc 	获取所有csv配表
%% @throws 	none
%% @end
%% ----------------------------------
get_all_table_file() ->
    Dir = env:get(template_dir),
    filelib:wildcard(filename:join(Dir, "*.csv")).

get_next_line(Parser) ->
    {_, Data, _} = csv:next_line(Parser),
    Data.

%% ----------------------------------
%% @doc 	转换成 整形或者浮点型
%% @throws 	none
%% @end
%% ----------------------------------
to_int(Number) when is_float(Number) ->
    Number;
to_int(Number) when is_integer(Number) ->
    Number;
to_int(Number) when is_list(Number) ->
    IsFloat = string:str(Number, ".") > 0,
    if IsFloat ->
        util:to_float(Number);
        true ->
            util:to_int(Number)
    end.

%% doc fun  获得字符串的运行算符和值
get_str_operators_and_value(Str) ->
    OperatorsList = [">=", "=<", ">", "<", "=/=", "=="],
    get_str_operators_and_value(OperatorsList, Str).
get_str_operators_and_value([], Str) ->
    io:format("~p：未找到字符串的运行算符和值:~p", [?MODULE, Str]),
    {};
get_str_operators_and_value([Operators | OperatorsList], Str) ->
    Index = string:str(Str, Operators),
    if
        Index > 0 ->
            case string:tokens(Str, Operators) of
                [Value] ->
                    {Operators, Value};
                R ->
                    io:format("~p：未找到字符串的运行算符和值:~p", [?MODULE, {Str, Operators, R}]),
                    {}
            end;
        true ->
            get_str_operators_and_value(OperatorsList, Str)
    end.
