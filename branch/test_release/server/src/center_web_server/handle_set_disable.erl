%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                封禁
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_set_disable).

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
                ?ERROR("封禁失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.
handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("请求封禁:~p", [Params]),
    PlatformId = util:to_list(proplists:get_value(<<"platformId">>, Params)),
    AccId = util:to_list(proplists:get_value(<<"accId">>, Params)),
    ServerId = util:to_list(proplists:get_value(<<"serverId">>, Params)),
    Type = util:to_int(proplists:get_value(<<"type">>, Params)),
    PlayerId = util:to_int(proplists:get_value(<<"playerId">>, Params)),
    Sec = util:to_int(proplists:get_value(<<"sec">>, Params)),
    Range = util:to_int(proplists:get_value(<<"range">>, Params)),
%%    Result = mod_global_account:set_forbid(PlatformId, AccId, Type, Sec),
%%    Result = rpc:call(Node, mod_player, set_forbid, [PlayerId, Type, Sec], 6000),

    Result =
        case Range of
            0 ->
                %% 封角色
                mod_server_rpc:call_game_server(PlatformId, ServerId, mod_player, set_forbid, [PlayerId, Type, Sec], 6000);
            1 ->
                %% 封帐号
                Now = util_time:timestamp(),
                R = mod_global_account:set_forbid(PlatformId, AccId, Type, Now + Sec),
                if R == ok ->
                    if Type == ?FORBID_TYPE_DISABLE_LOGIN ->
                        %% 角色下线
                        mod_server_rpc:call_game_server(PlatformId, ServerId, mod_online, kill_online_player, [PlayerId]);
                        true ->
                            noop
                    end;
                    true ->
                        noop
                end,
                R
        end,
    if
        Result == ok ->
            ?INFO("封禁成功:~p", [{PlatformId, AccId}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 0}])
            );
        true ->
            ?ERROR("封禁失败:~p~n", [{PlatformId, AccId, Result}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 1}, {error_msg, util:to_binary(Result)}])
            )
    end;
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
