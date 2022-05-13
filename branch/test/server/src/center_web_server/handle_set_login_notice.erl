%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                设置登录公告
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_set_login_notice).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Req =
        try handle(Method, HasBody, Req0)
        catch
            _:Reason ->
                ?ERROR("设置登录公告失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
    ?INFO("设置登录公告:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    PlatformId = util:to_list(maps:get(<<"platformId">>, JsonBody)),
    ChannelId = util:to_list(maps:get(<<"channelId">>, JsonBody, "")),
    Content = util:to_list(maps:get(<<"notice">>, JsonBody)),
    mod_login_notice:update_login_notice(PlatformId, ChannelId, Content),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}])
    );
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
