%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 10月 2021 下午 12:30:06
%%%-------------------------------------------------------------------
-module(handle_app_notice).
-author("Administrator").

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    HasBody = cowboy_req:has_body(Req0),
    Method = cowboy_req:method(Req0),
%%    {IP, _} = cowboy_req:peer(Req0),
%%    ?INFO("IP: ~p", [IP]),
%%    _Ip = inet_parse:ntoa(IP),
    ?DEBUG("Method: ~p", [Method]),
    Req =
        try handle(Method, HasBody, Req0)
        catch
            _:Reason ->
                ?ERROR("app公告失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, false, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    ?INFO("获取app登录公告:~p~n", [{cowboy_req:peer(Req), Body}]),
    Params = cowboy_req:parse_qs(Req),
    ?INFO("params: ~p", [Params]),
    Version = util:to_list(proplists:get_value(<<"version">>, Params)),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    Type = util:to_list(proplists:get_value(<<"type">>, Params)),
    Resp = mod_app_notice:get_app_notice(AppId, Type, Version),
    web_server_util:output_text_utf8(
        Req,
        lib_json:encode(Resp)
    );
handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
    ?INFO("设置app登录公告:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    AppId = util:to_list(maps:get(<<"app_id">>, JsonBody)),
    Version = util:to_list(maps:get(<<"version">>, JsonBody)),
    Type = util:to_list(maps:get(<<"type">>, JsonBody)),
    Notice = util:to_list(maps:get(<<"notice">>, JsonBody)),
    Stats = util:to_int(maps:get(<<"stats">>, JsonBody)),
    Repeated = util:to_int(maps:get(<<"repeated">>, JsonBody)),
    if
        Stats =:= 1 ->
            mod_app_notice:update_app_notice(AppId, Version, Type, Notice, Repeated);
        true ->
            mod_app_notice:delete_app_notice(AppId, Type, Version)
    end,
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}])
    );
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
