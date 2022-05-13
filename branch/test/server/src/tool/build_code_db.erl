%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            构建table映射
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(build_code_db).

-export([start/1, create_scene_logic_code/0]).
-include("common.hrl").
-define(LOGIC_CODE_MOD, logic_code).
-define(LOGIC_CODE_MOD_PATH, "../src/logic_code.erl").
-define(ROBOT_DATA_MOD_PATH, "../src/robot_data.erl").
-define(LOGIC_CODE2_MOD_PATH, "../src/logic_code2.erl").
-define(LOGIC_CODE_PRE, "logic_").
-define(CODE_PRE, "").

start(TableList) ->
    io:format("~nStarting build code db mapping...~n~n"),
    qmake:compilep(?LOGIC_CODE_MOD_PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    do_create_code(TableList),
    io:format("~nStarting build logic code ...~n~n"),
    create_logic_code(),
    qmake:compilep(?ROBOT_DATA_MOD_PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
%%    robot_data:create_robot_data_file(),
    build_random_name:start(),
    qmake:compilep(?LOGIC_CODE2_MOD_PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    logic_code2:start(),
    ok.

%% 生成场景逻辑数据
create_scene_logic_code() ->
    io:format("Starting build scene logic code ...~n~n"),
    qmake:compilep(?LOGIC_CODE_MOD_PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    do_create_logic_code(?LOGIC_CODE_MOD:scene_logic()).

%% 生成逻辑数据
create_logic_code() ->
    do_create_logic_code(?LOGIC_CODE_MOD:logic()).

do_create_logic_code([]) ->
    ok;
do_create_logic_code([H | T]) ->
    Mod = ?LOGIC_CODE_PRE ++ atom_to_list(H),
    FileName = filename:join([?CODE_PATH, Mod ++ ".erl"]),
    io:format("Create file ~s ~s", [Mod ++ ".erl", lists:duplicate(max(0, 45 - length(Mod ++ ".erl")), ".")]),
    Data = apply(?LOGIC_CODE_MOD, H, []),
    Out = do_create_file(Mod, [], Data),
    io:format(" [ok]~n"),
    util_file:save_code(FileName, Out, true),
    do_create_logic_code(T).

do_create_code([]) ->
    ok;
do_create_code([H | T]) ->
    Mod = ?CODE_PRE ++ H,
    FileName = filename:join([?CODE_PATH, Mod ++ ".erl"]),
    io:format("Create file ~s ~s", [Mod ++ ".erl", lists:duplicate(max(0, 45 - length(Mod ++ ".erl")), ".")]),
    List = lists:sort(ets:tab2list(util:to_atom(H))),
    Data = [{erlang:element(2, R), R} || R <- List],
    KeyDataList = [Key || {Key, _Value} <- Data],
    Out = do_create_file(Mod, KeyDataList, lists:reverse(Data)),
    io:format(" [ok]~n"),
    util_file:save_code(FileName, Out, true),
    do_create_code(T).

do_create_file(Mod, KeyDataList, Data) ->
    create_file_head(Mod) ++ create_file_body_key_list(KeyDataList) ++ create_file_body(Data, create_file_tail()).

create_file_body_key_list(KeyDataList) ->
    io_lib:format(
        "get_keys() ->~n"
        "     ~w.~n\n\n"
        , [KeyDataList]
    ).

create_file_head(Mod) ->
    io_lib:format(
        "%%% Generated automatically, no need to modify.\n"
        "-module(~s).~n"
        "-export([get/1, get/2, assert_get/1, get_keys/0]).~n~n"
        "get(Key, Default) ->~n"
        "    case ?MODULE:get(Key) of\n"
        "        null -> Default;\n"
        "        Result -> Result\n"
        "    end.\n\n"
        "assert_get(Key) ->~n"
        "    case ?MODULE:get(Key) of\n"
        "        null -> exit({got_null, ?MODULE, Key});\n"
        "        Result -> Result\n"
        "    end.\n\n"
        , [Mod]
    ).

create_file_tail() ->
    "get(_Id) ->\n"
    "    null.\n".

create_file_body([], Out) ->
    Out;
create_file_body([{Key, Value} | T], Out) ->
    create_file_body(T, io_lib:format(
        "get(~p) ->~n"
        "     ~w;~n"
        , [Key, Value]
    ) ++ Out).

