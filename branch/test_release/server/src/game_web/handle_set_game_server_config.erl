%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 8月 2021 上午 11:16:51
%%%-------------------------------------------------------------------
-module(handle_set_game_server_config).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Path = cowboy_req:path(Req0),
    Req =
        try handle(Path, Method, HasBody, Req0)
        catch
            _:Reason ->
                ?ERROR("设置帐号类型失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"/set_game_server_config">>, <<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),

    ConfigType = util:to_int(maps:get(<<"config_type">>, JsonBody)),
    ConfigId = util:to_int(maps:get(<<"config_id">>, JsonBody)),
    Value = util:to_int(maps:get(<<"value">>, JsonBody)),
    if
        ConfigType >= 0 andalso ConfigId >= 0 ->
            spawn(fun() -> game_config:set_game_server_config(ConfigType, ConfigId, Value) end);
        true ->
            ?INFO("config_type orelse config_id < 0")
    end,
    ?INFO("修改游戏配置成功:~p", [{mod_server:get_server_id()}]),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}, {error_msg, success}])
    );
handle(<<"/delete_game_server_config">>, <<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),

    ConfigType = util:to_int(maps:get(<<"config_type">>, JsonBody)),
    ConfigId = util:to_int(maps:get(<<"config_id">>, JsonBody)),
    if
        ConfigType >= 0 andalso ConfigId >= 0 ->
            spawn(fun() -> game_config:delete_game_server_config(ConfigType, ConfigId) end);
        true ->
            ?INFO("There is no pay times to set")
    end,
    ?INFO("删除游戏配置成功:~p", [{mod_server:get_server_id()}]),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}, {error_msg, success}])
    );
handle(_,<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, _, Req) ->
    cowboy_req:reply(405, Req).
