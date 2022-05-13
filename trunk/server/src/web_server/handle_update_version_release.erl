%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                刷新区服入口
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_update_version_release).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),

    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("设置客户端版本失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, Req) ->
    QS = cowboy_req:qs(Req),
    Data = web_server_util:get_data_and_check_sign(QS),
    Params = cow_qs:parse_qs(Data),
    ?INFO("设置客户端版本:~p~n", [{cowboy_req:peer(Req), Params}]),
    Version = util:to_list(proplists:get_value(<<"version">>, Params)),
    IsRelease = util:to_list(proplists:get_value(<<"is_release">>, Params)),
    mod_client_version:update_client_version(util:to_list(Version), util:to_int(IsRelease)),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}])
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
