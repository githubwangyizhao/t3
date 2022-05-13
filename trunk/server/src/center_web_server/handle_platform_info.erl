%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 10月 2021 上午 11:52:14
%%%-------------------------------------------------------------------
-module(handle_platform_info).
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

%% ----------------------------------
%% @doc 	后台修改platformId与tracker_token的对应关系后，发送到中心服保存至ets
%% @throws 	none
%% @end
%% ----------------------------------
handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
    ?INFO("设置platform的tracker_token:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    PlatformId = util:to_list(maps:get(<<"platform_id">>, JsonBody)),
    Channel = util:to_list(maps:get(<<"channel">>, JsonBody)),
    TrackerToken = util:to_list(maps:get(<<"tracker_token">>, JsonBody)),
    mod_adjust_info:update_tracker_token(PlatformId, TrackerToken, Channel),
    Region = util:to_list(maps:get(<<"region">>, JsonBody)),
    AreaCode = util:to_list(maps:get(<<"area_code">>, JsonBody)),
    Currency = util:to_list(maps:get(<<"currency">>, JsonBody)),
    mod_region_info:update_region(TrackerToken, Region, AreaCode, Currency),
    mod_area_info:update_area_info(Currency, Region, AreaCode),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}])
    );
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
