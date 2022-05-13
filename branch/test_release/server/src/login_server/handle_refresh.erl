%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                刷新区服入口
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_refresh).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),

    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("刷新区服入口失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

%%f() ->
%%    Tran =fun() ->
%%        L = ets:tab2list(db_global_account),
%%        lists:foreach(
%%            fun() ->
%%
%%        )
%%          end,
%%    db:do(Tran).
handle(<<"GET">>, Req) ->
    QS = cowboy_req:qs(Req),
    Data = web_server_util:get_data_and_check_sign(QS),
    Params = cow_qs:parse_qs(Data),
    ?INFO("刷新区服入口:~p~n", [{cowboy_req:peer(Req), Params}]),
    server_node_slave:sync(),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}])
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).


%%init(Req0, Opts) ->
%%    Method = cowboy_req:method(Req0),
%%    HasBody = cowboy_req:has_body(Req0),
%%    ?DEBUG("请求封禁:~p", [{cowboy_req:peer(Req0), cowboy_req:parse_qs(Req0)}]),
%%    Req =
%%        try handle(Method, HasBody, Req0)
%%        catch
%%            _:Reason ->
%%                ?ERROR("封禁失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
%%        end,
%%    {ok, Req, Opts}.
%%
%%handle(<<"POST">>, true, Req0) ->
%%    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
%%%%    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
%%    Params = cow_qs:parse_qs(Body),
%%%%    ?DEBUG("read_urlencoded_body:~p~n", [{cowboy_req:read_urlencoded_body(Req0)}]),
%%%%    ?DEBUG("parse_qs:~p~n", [{cowboy_req:parse_qs(Req0)}]),
%%    ?INFO("请求封禁:~p~n", [{Body, Params}]),
%%%%    ?DEBUG("jsone:~p~n", [{jsone:decode(PostVals)}]),
%%
%%    PlatformId = util:to_int(proplists:get_value(<<"platform_id">>, Params)),
%%    ServerId = util:to_list(proplists:get_value(<<"server_id">>, Params)),
%%    PlayerId = util:to_int(proplists:get_value(<<"player_id">>, Params)),
%%    Type = util:to_int(proplists:get_value(<<"type">>, Params)),
%%    Sec = util:to_int(proplists:get_value(<<"sec">>, Params)),
%%%%    ?DEBUG("POST:~p~n", [{PlatformId, ServerId, PlayerId, Type, Sec}]),
%%    GameServer = mod_server:get_game_server(PlatformId, ServerId),
%%    Node = util:to_atom(GameServer#db_c_game_server.node),
%%    Result = rpc:call(Node, mod_player, set_forbid, [PlayerId, Type, Sec], 6000),
%%    if Result == ok ->
%%        ?DEBUG("封禁成功"),
%%        web_server_util:output_text(
%%            Req,
%%            jsone:encode([{error_code, 0}])
%%        );
%%        true ->
%%            ?INFO("封禁失败:~p~n", [Result]),
%%            web_server_util:output_text(
%%                Req,
%%                jsone:encode([{error_code, 1}])
%%            )
%%    end;
%%handle(<<"POST">>, false, Req) ->
%%    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
%%handle(_, _, Req) ->
%%    %% Method not allowed.
%%    cowboy_req:reply(405, Req).


%%init(Req0, Opts) ->
%%    Method = cowboy_req:method(Req0),
%%    HasBody = cowboy_req:has_body(Req0),
%%%%    ?DEBUG("请求封禁:~p", [{cowboy_req:peer(Req0), cowboy_req:parse_qs(Req0)}]),
%%    Req =
%%        try handle(Method, HasBody, Req0)
%%        catch
%%            _:Reason ->
%%                ?ERROR("封禁失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
%%        end,
%%    {ok, Req, Opts}.
%%
%%handle(<<"POST">>, true, Req0) ->
%%    cowboy_req:read_body(),
%%    {ok, PostVals, Req} = cowboy_req:read_urlencoded_body(Req0),
%%%%    ?DEBUG("read_urlencoded_body:~p~n", [{cowboy_req:read_urlencoded_body(Req0)}]),
%%%%    ?DEBUG("parse_qs:~p~n", [{cowboy_req:parse_qs(Req0)}]),
%%    ?INFO("请求封禁:~p~n", [{PostVals}]),
%%%%    ?DEBUG("jsone:~p~n", [{jsone:decode(PostVals)}]),
%%
%%    PlatformId = util:to_int(proplists:get_value(<<"platform_id">>, PostVals)),
%%    ServerId = util:to_list(proplists:get_value(<<"server_id">>, PostVals)),
%%    PlayerId = util:to_int(proplists:get_value(<<"player_id">>, PostVals)),
%%    Type = util:to_int(proplists:get_value(<<"type">>, PostVals)),
%%    Sec = util:to_int(proplists:get_value(<<"sec">>, PostVals)),
%%%%    ?DEBUG("POST:~p~n", [{PlatformId, ServerId, PlayerId, Type, Sec}]),
%%    GameServer = mod_server:get_game_server(PlatformId, ServerId),
%%    Node = util:to_atom(GameServer#db_c_game_server.node),
%%    Result = rpc:call(Node, mod_player, set_forbid, [PlayerId, Type, Sec], 6000),
%%    if Result == ok ->
%%        ?DEBUG("封禁成功"),
%%        web_server_util:output_text(
%%            Req,
%%            jsone:encode([{error_code, 0}])
%%        );
%%        true ->
%%            ?INFO("封禁失败:~p~n", [Result]),
%%            web_server_util:output_text(
%%                Req,
%%                jsone:encode([{error_code, 1}])
%%            )
%%    end;
%%handle(<<"POST">>, false, Req) ->
%%    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
%%handle(_, _, Req) ->
%%    %% Method not allowed.
%%    cowboy_req:reply(405, Req).
