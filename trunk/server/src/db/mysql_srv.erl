%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 2:43
%%%-------------------------------------------------------------------
-module(mysql_srv).

%% API
-export([start_link/0,get_db_configs/0]).
-include("db_config.hrl").
start_link() ->
    PoolSize = erlang:system_info(schedulers),
    io:format(
        "~n~nStarting connect Mysql~n"
        "       Host    : ~p~n"
        "       User    : ~p~n"
        "       Database: ~p~n"
        "       PoolSize: ~p~n",
        [?MYSQL_HOST, ?MYSQL_USERNAME, ?MYSQL_DATABASE, PoolSize]
    ),
    {ok, Pid} = mysql:start_link(
        ?GAME_DB,
        ?MYSQL_HOST,
        ?MYSQL_PORT,
        ?MYSQL_USERNAME,
        ?MYSQL_PASSWORD,
        ?MYSQL_DATABASE,
        fun log/4,
        utf8,
        PoolSize
    ),
    io:format("~nMysql 连接成功!~n"),
    {ok, Pid}.

get_db_configs() ->
    {?MYSQL_HOST, ?MYSQL_PORT, ?MYSQL_DATABASE}.

log(Module, Line, error, FormatFun) ->
    {Format, Arguments} = FormatFun(),
    logger:error("DB_ERROR!!!!!! ~w:~b: " ++ Format ++ "~n", [Module, Line] ++ Arguments);
log(_Module, _Line, _Level, _FormatFun) -> noop.
