%%%-------------------------------------------------------------------
%%% @author wangZhuFei
%%% @copyright (C) 2019, GAME BOY
%%% @doc    外键文件
%%% Created : 17. 九月 2019 10:31
%%%-------------------------------------------------------------------
-module(build_foreign_key).
-author("wangZhuFei").

-define(FOREIGN_KEY_FILE, "../src/gen/foreign_key.erl").

%% API
-export([
    create_foreign/4
]).

-include("common.hrl").

%% @doc fun 创建外键文件
create_foreign(TableKeyList, TableKeySwitchList, TableDataList, ForeignTableDataList) ->
    Str = check_str() ++ table_list_str([Table || {Table, _} <- TableKeyList]) ++ table_key_str(TableKeyList) ++ table_switch_str(TableKeySwitchList) ++ table_data_str(TableDataList) ++ foreign_data_str(ForeignTableDataList),
    util_file:save_code(?FOREIGN_KEY_FILE, head_key() ++ Str, true),
    qmake:compilep(?FOREIGN_KEY_FILE, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    ok.

%% @doc fun 头部
head_key() ->
    "-module(foreign_key).\n
-export([check_foreign_key/0]).
-define(FOREIGN_KEY_COMMON_STR, \"_\").\n\n".


check_str() ->
    "check_foreign_key() ->
    util:output_line_info(\"checking foreign_key\"),
    put(check_foreign_key_table, []),
    lists:foreach(
    fun(Table) ->
        check_foreign_key_table(Table)
    end,table_list()),
    case erase(check_foreign_key_table) of
        [] -> noop;
        CheckAllAwardList ->
            io:format(\"~n[ERROR] null_find_foreign_key~n\"),
            lists:foreach(
                fun({TableKey, ForeignKeyValueList}) ->
%%                    io:format(\"notFindTableKey:~p ~n    =>foreign_key_list:~p~n\",[TableKey, Value]),
                    io:format(\"notFindTableKey:~p ~n    =>foreign_key_list:\",[TableKey]),
                      lists:foreach(
                      fun(ForeignKeyValueTuple) ->
                        {ForeignKey, TableKeyValueList} = ForeignKeyValueTuple,
                        if length(TableKeyValueList) > 1 ->
                            io:format(\"{~p,[\",[ForeignKey]),
                            lists:foreach(fun(TableKeyValue)-> io:format(\"~p\",[TableKeyValue]) end,TableKeyValueList),
                            io:format(\"]}~n\");
                        true ->
                          io:format(\"~p~n\",[ForeignKeyValueTuple])
                        end
                      end, ForeignKeyValueList)
                end, lists:sort(CheckAllAwardList)),
            halt(1)
    end,
    util:finish_line_info().
check_foreign_key_table(Table) ->
    lists:foreach(
    fun(TableKey) ->
        case get_table_key({Table, TableKey}) of
             {ForeignTable, ForeignKey} ->
                F = fun(ForeignValueTuple) ->
                    ForeignValueTmp = case ForeignValueTuple of
                         [{ForeignValueTmp1, _}] -> [ForeignValueTmp1];
                         _ ->ForeignValueTuple
                    end,
                    case get_foreign_key({ForeignTable, ForeignKey, ForeignValueTmp}) of
                    true -> true;
                    _ -> exit(null_find)
                    end end,
                 IsCommonStr = lists:member(?FOREIGN_KEY_COMMON_STR, ForeignKey),
                 lists:foreach(
                 fun({ForeignValue, TableRowKeyList}) ->
                    IsHaveForeignKey =
                        if IsCommonStr ->
                            catch check_common_foreign_key(ForeignKey, ForeignValue, IsCommonStr, F);
                            true ->
                                [ForeignValueL|_]=ForeignValue,
                                case erlang:is_list(ForeignValueL) of
                                     true -> catch check_common_foreign_key(ForeignKey, ForeignValue, IsCommonStr, F);
                                     _ -> catch F(ForeignValue)
                                end
                        end,
                    case IsHaveForeignKey == true of
                         true -> noop;
                         _ ->
                         put_foreign_key_table({Table, TableKey}, {{ForeignTable, ForeignKey, ForeignValue}, TableRowKeyList})
%                         io:format(\"~p:null foreign_key:~p,~p~nrowKey:~p~n\",[?MODULE,{Table, TableKey},{ForeignTable, ForeignKey, ForeignValue}, TableRowKeyList]),
%                         exit(null_find_foreign_key)
                    end
                 end, get_table_data_list({Table, TableKey}));
             _ ->
                exit({null,get_table_key,Table, TableKey})
        end
    end, get_table_key_list(Table)).

check_common_foreign_key(ForeignKeyList, ForeignValueList, IsCommonStr, Fun) ->
    handle_common_foreign_key(ForeignKeyList, length(ForeignKeyList),  ForeignValueList, IsCommonStr, Fun).
handle_common_foreign_key(_ForeignKeyList, _ForeignKeyLen, [], _IsCommonStr, Fun) ->
    true;
handle_common_foreign_key(ForeignKeyList, ForeignKeyLen, [ ForeignValue | ForeignValueList] = ForeignList, IsCommonStr, Fun) ->
    case is_list(ForeignValue) of
        true ->
            ForeignValueLen = length(ForeignValue),
            if ForeignKeyLen == ForeignValueLen ->
                    SonValue = hd(ForeignValue),
                    case is_list(SonValue) of
                        true ->
                            SonLen = length(SonValue),
                            if ForeignKeyLen == SonLen ->
                                    handle_common_foreign_key(ForeignKeyList,ForeignKeyLen, ForeignValueList, IsCommonStr, handle_common_foreign_key(ForeignKeyList, ForeignKeyLen, ForeignValue, IsCommonStr, Fun));
                                true ->
                                	Fun(replace_list(ForeignKeyList, ForeignValue, [])),
                                    handle_common_foreign_key(ForeignKeyList,ForeignKeyLen, ForeignValueList, IsCommonStr, Fun)
                            end;
                        _ ->
                            Fun(replace_list(ForeignKeyList, ForeignValue, [])),
                            handle_common_foreign_key(ForeignKeyList,ForeignKeyLen, ForeignValueList, IsCommonStr, Fun)
                    end;
                true -> handle_common_foreign_key(ForeignKeyList, ForeignKeyLen, ForeignValue, IsCommonStr, Fun)
            end;
        _ ->
            ForeignValue1 = if IsCommonStr -> replace_list(ForeignKeyList, ForeignList, []); true -> ForeignList end,
%%            io:format('IsCommonStr:~p ~p~n',[IsCommonStr, ForeignValue1]),
            Fun(ForeignValue1),
            if  ForeignValueList == [] -> true;
                true -> [ForeignValueOther|ForeignValueOtherL] = ForeignValueList,
                case erlang:is_list(ForeignValueOther) of
                true -> handle_common_foreign_key(ForeignKeyList, ForeignKeyLen, ForeignValueList, IsCommonStr, Fun);
                _ -> true
                end
            end
    end.
replace_list([], _, ReplaceList) ->
    lists:reverse(ReplaceList);
replace_list([ForeignKey | ForeignKeyList], [ForeignValue | ForeignValueList], ReplaceList) ->
    NewForeignValue =
        if ForeignKey == ?FOREIGN_KEY_COMMON_STR -> ForeignKey;
            true -> ForeignValue
        end,
    replace_list(ForeignKeyList, ForeignValueList, [NewForeignValue | ReplaceList]).
put_foreign_key_table(Key, Value) ->
    CheckAllAwardL = get(check_foreign_key_table),
    CheckAllAwardList = util_list:key_insert({Key, Value}, CheckAllAwardL),
    put(check_foreign_key_table, CheckAllAwardList).\n\n".

%% @doc fun 表的外键列表
table_list_str([]) -> "table_list() ->[].\n\n";
table_list_str(TableList) -> io_lib:format("table_list() ->~p.\n\n\n", [TableList]).

%% @doc fun 表的外键列表
table_key_str(TableKeyList) ->
    table_key_str(TableKeyList, "").
table_key_str([], Str) -> Str ++ "get_table_key_list(_) ->[].\n\n\n";
table_key_str([{Table, TableFieldList} | TableKeyList], Str) ->
    NewStr = io_lib:format("get_table_key_list(~p) ->~p;\n", [Table, TableFieldList]) ++ Str,
    table_key_str(TableKeyList, NewStr).

%%%% @doc fun 表的外键对应
table_switch_str(TableKeySwitchList) ->
    table_switch_str(TableKeySwitchList, "").
table_switch_str([], Str) -> Str ++ "get_table_key(_) ->null.\n\n\n";
table_switch_str([[{Table, TableFieldList}, {ForeignTable, ForeignTableKeyList}] | TableKeySwitchList], Str) ->
    NewStr = io_lib:format("get_table_key({~p,~p}) ->{~p,~p};\n", [Table, TableFieldList, ForeignTable, ForeignTableKeyList]) ++ Str,
    table_switch_str(TableKeySwitchList, NewStr).

%% @doc fun 表外键数据列表
table_data_str(TableDataList) ->
    table_data_str(TableDataList, "").
table_data_str([], Str) -> Str ++ "get_table_data_list(_) ->[].\n\n\n";
table_data_str([{{Table, FieldL}, FieldList} | TableDataList], Str) ->
    NewStr = io_lib:format("get_table_data_list({~p,~p}) ->~w;\n", [Table, FieldL, FieldList]) ++ Str,
%%    NewStr = io_lib:format("get_table_data_list({~p, ~p}) -> ~w;\n", [Table, FieldL, FieldList]) ++ Str,
    table_data_str(TableDataList, NewStr).

%% @doc fun 外键数据
foreign_data_str(ForeignTableDataList) ->
    foreign_data_str(ForeignTableDataList, "", "").
foreign_data_str([], Str, _TableName) -> Str ++ "get_foreign_key(_) ->false.\n\n";
foreign_data_str([{Table, FieldL, FieldList} | ForeignTableDataList], Str, TableName) ->
    NewStr =
        if
            TableName == Table ->
                io_lib:format("get_foreign_key({~p,~p,~w})->true;", [Table, FieldL, FieldList]);
            true ->
                io_lib:format("\nget_foreign_key({~p,~p,~w})->true;", [Table, FieldL, FieldList])
        end ++ Str,
%%    NewStr = io_lib:format("get_foreign_key({~p,~p,~w}) -> true;\n", [Table, FieldL, FieldList]) ++ Str,
    foreign_data_str(ForeignTableDataList, NewStr, Table).
