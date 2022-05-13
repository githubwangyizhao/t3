%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            环境变量
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(env).
-export([
    init/0,
    reload/0,
    get/1,
    get/2,
    set/2,
    del/1
]).

init() ->
    {ok, [[File]]} = init:get_argument(env_file),
    init(File).
init(EnvFile) ->
    ets:new(env, [set, named_table, public, {keypos, 1}, {read_concurrency, true}]),
    load_env_file(EnvFile).

reload() ->
    {ok, [[EnvFile]]} = init:get_argument(env_file),
    load_env_file(EnvFile).

get(Key) ->
    get(Key, undefined).
get(Key, Default) ->
    case ets:lookup(env, Key) of
        [{_, Val}] ->
            Val;
        [] ->
            Default
    end.

set(Key, Val) ->
    ets:insert(env, {Key, Val}),
    Val.

del(Key) ->
    ets:delete(env, Key),
    ok.

load_env_file(File) ->
    L = load(File),
    [set(K, V) || {K, V} <- L].

load(File) ->
    case file:consult(File) of
        {error, Reason} ->
            io:format("Load env file ~s fail:~p~n", [File, Reason]),
            error({Reason, File});
        {ok, []} -> [];
        {ok, [Term]} -> Term
    end.

