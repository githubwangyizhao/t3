%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(pre_build).

%% API
-export([main/1]).
-define(LIB_FILE, "../src/lib/*.erl").
-define(LIB_FILE1, "../src/lib/*/*.erl").
-define(TOOL_FILE, "../src/tool/*.erl").
-define(UTILS_FILE, "../src/utils/*.erl").

main(_) ->
    {_, S, _} = os:timestamp(),
    L1 = filelib:wildcard(?LIB_FILE),
    L2 = filelib:wildcard(?LIB_FILE1),
    L3 = filelib:wildcard(?TOOL_FILE),
    L4 = filelib:wildcard(?UTILS_FILE),
    make:files(L1 ++ L2 ++ L3 ++ L4),
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
