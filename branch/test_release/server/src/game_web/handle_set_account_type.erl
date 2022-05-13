%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                设置帐号类型
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_set_account_type).

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
                ?ERROR("设置帐号类型失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
%%    ?DEBUG("设置帐号类型:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    PlayerId = util:to_int(maps:get(<<"playerId">>, JsonBody)),
    Type = util:to_int(maps:get(<<"type">>, JsonBody)),
    PayTimes = util:to_int(maps:get(<<"payTimes">>, JsonBody)),
    if
        PayTimes =/= "undefined" ->
            ?DEBUG("fff"),
            spawn(fun() -> mod_cache:update({player_pay_times, PlayerId}, PayTimes, 8640000000) end);
        true ->
            ?INFO("There is no pay times to set")
    end,
%%    PlatformId = util:to_int(maps:get(<<"platformId">>, JsonBody)),
%%    ServerId = util:to_list(maps:get(<<"serverId">>, JsonBody)),
%%    GameServer = mod_server:get_game_server(PlatformId, ServerId),
%%    Result = mod_player:set_account_type(PlayerId, Type),
    PlatformId = mod_server_config:get_platform_id(),
    Player = mod_player:get_player(PlayerId),
    Result = rpc:call(mod_server_config:get_center_node(),  mod_global_account, set_account_type, [PlatformId, Player#db_player.acc_id, Type], 6000),
    if Result == ok ->
        ?INFO("设置帐号类型成功:~p", [{PlayerId, Type}]),
        web_server_util:output_text(
            Req,
            jsone:encode([{error_code, 0}])
        );
        true ->
            ?ERROR("设置帐号类型失败:~p", [{PlayerId, Type, Result}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 1}])
            )
    end;
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
