%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 11月 2021 上午 11:43:47
%%%-------------------------------------------------------------------
-module(handle_filter).
-author("Administrator").

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    HasBody = cowboy_req:has_body(Req0),
    Method = cowboy_req:method(Req0),
    ?DEBUG("Method: ~p", [Method]),
    Req =
        try handle(Method, HasBody, Req0)
        catch
            _:Reason ->
                ?ERROR("获取中心服域名:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, false, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    ?INFO("获取中心服域名:~p~n", [{cowboy_req:peer(Req), Body}]),
    Params = cowboy_req:parse_qs(Req),
    ?INFO("params: ~p", [Params]),
    VersionInQuery = util:to_list(proplists:get_value(<<"version">>, Params)),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    [Version, _] = string:tokens(VersionInQuery, "."),
    Domain = mod_domain_filter:get_domain(AppId, Version),
    web_server_util:output_text_utf8(
        Req,
        lib_json:encode([{domain, Domain}])
    );
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
