%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            RPC 模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_rpc).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
%%-include("template_db.hrl").

%% API
-export([

    batch_rpc_node_list/4,              %% 批量rpc call
    batch_rpc_node_list/5,
    batch_rpc_node_list/6,


    call_all_game_server/3,             %% rpc call 所有游戏服
    call_all_game_server/4,
    call_all_game_server_by_platform/4,
    call_all_game_server_by_platform/5,


    call_game_server/5,                 %% rpc call 游戏服
    call_game_server/6,

    cast_all_node/3,

    cast_all_game_server/3,             %% rpc call所有游戏服
    cast_all_game_server_by_platform/4,

    cast_game_server/5,                 %% rpc cast游戏服

    call_center/3,                      %% rpc call中心服
    call_center/4,
    cast_center/3,                      %% rpc cast中心服

    call_zone/3,                        %% rpc call跨服
    call_zone/4,
    cast_zone/3,                        %% rpc cast跨服
    call_all_zone/3,
    call_all_zone/4,

    call_war/3,                         %% rpc call 战区
    call_war/4,
    cast_war/3,                         %% rpc cast 战区

    remote_call/1,                      %% 远程call
    remote_cast/1,                      %% 远程cast

    send_zone/2,                        %% 发消息到跨服服务器进程
    gen_server_cast_zone/2,             %% gen_server cast 跨服服务器进程
    gen_server_call_zone/2,             %% gen_server call 跨服服务器进程
    gen_server_call_zone/3,

    send_war/2,
    gen_server_cast_war/2,              %% gen_server cast战区服务器
    gen_server_call_war/2,              %% gen_server call战区服务器
    gen_server_call_war/3,

    send_all_game_node/2,               %% 发消息到所有游戏服务器进程
    gen_server_cast_all_game_node/2,    %% gen_server cast 所有游戏服务器进程
    gen_server_call_all_game_node/2     %% gen_server call 所有游戏服务器进程

]).


%% ----------------------------------
%% @doc 	call 所有游戏服
%% @throws 	none
%% @end
%% ----------------------------------
-spec call_all_game_server(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].

call_all_game_server(M, F, A) ->
    call_all_game_server(M, F, A, infinity).
call_all_game_server(M, F, A, TimeOut) ->
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = Node
            } = ServerNode,
            util:rpc_call(util:to_atom(Node), M, F, A, TimeOut)
        end,
        mod_server:get_server_node_list(?SERVER_TYPE_GAME)
    ).

call_all_game_server_by_platform(PlatformId, M, F, A) ->
    call_all_game_server_by_platform(PlatformId, M, F, A, infinity).
call_all_game_server_by_platform(PlatformId, M, F, A, TimeOut) ->
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = Node
            } = ServerNode,
            util:rpc_call(util:to_atom(Node), M, F, A, TimeOut)
        end,
        mod_server:get_server_node_list(PlatformId, ?SERVER_TYPE_GAME)
    ).

-spec call_game_server(PlatformId, ServerId, M, F, A) -> term() when
    PlatformId :: string(),
    ServerId :: string(),
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec call_game_server(PlatformId, ServerId, M, F, A, TimeOut) -> term() when
    PlatformId :: string(),
    ServerId :: string(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    TimeOut :: integer().

call_game_server(PlatformId, ServerId, M, F, A) ->
    call_game_server(PlatformId, ServerId, M, F, A, infinity).

call_game_server(PlatformId, ServerId, M, F, A, TimeOut) ->
    Node = mod_server:get_game_node(PlatformId, ServerId),
    util:rpc_call(Node, M, F, A, TimeOut).


%% ----------------------------------
%% @doc 	cast 所有游戏服
%% @throws 	none
%% @end
%% ----------------------------------
-spec cast_all_game_server(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
cast_all_game_server(M, F, A) ->
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = Node
            } = ServerNode,
            rpc:cast(util:to_atom(Node), M, F, A)
        end,
        mod_server:get_server_node_list(?SERVER_TYPE_GAME)
    ).


cast_all_game_server_by_platform(PlatformId, M, F, A) ->
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = Node
            } = ServerNode,
            rpc:cast(util:to_atom(Node), M, F, A)
        end,
        mod_server:get_server_node_list(PlatformId, ?SERVER_TYPE_GAME)
    ).

-spec cast_game_server(PlatformId, ServerId, M, F, A) -> term() when
    PlatformId :: string(),
    ServerId :: string(),
    M :: module(),
    F :: atom(),
    A :: [term()].
cast_game_server(PlatformId, ServerId, M, F, A) ->
    Node = mod_server:get_game_node(PlatformId, ServerId),
    rpc:cast(Node, M, F, A).

%% ----------------------------------
%% @doc 	call 中心服
%% @throws 	none
%% @end
%% ----------------------------------
-spec call_center(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
-spec call_center(M, F, A, Timeout) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    Timeout :: integer().
call_center(M, F, A) ->
    call_center(M, F, A, infinity).
call_center(M, F, A, TimeOut) ->
    CenterNode = mod_server_config:get_center_node(),
    util:rpc_call(CenterNode, M, F, A, TimeOut).

%% ----------------------------------
%% @doc 	cast 中心服
%% @throws 	none
%% @end
%% ----------------------------------
-spec cast_center(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
cast_center(M, F, A) ->
    CenterNode = mod_server_config:get_center_node(),
    rpc:cast(CenterNode, M, F, A).

%% ----------------------------------
%% @doc 	call 跨服服务器
%% @throws 	none
%% @end
%% ----------------------------------
-spec call_zone(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
-spec call_zone(M, F, A, TimeOut) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    TimeOut :: integer().
call_zone(M, F, A) ->
    call_zone(M, F, A, 6000).
call_zone(M, F, A, TimeOut) ->
    ZoneNode = mod_server_config:get_zone_node(),
    util:rpc_call(ZoneNode, M, F, A, TimeOut).

%% ----------------------------------
%% @doc 	call 所有游戏服
%% @throws 	none
%% @end
%% ----------------------------------
call_all_zone(M, F, A) ->
    call_all_zone(M, F, A, infinity).
call_all_zone(M, F, A, TimeOut) ->
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = Node
            } = ServerNode,
            util:rpc_call(util:to_atom(Node), M, F, A, TimeOut)
        end,
        mod_server:get_server_node_list(?SERVER_TYPE_WAR_ZONE)
    ).

%% ----------------------------------
%% @doc 	cast 跨服服务器
%% @throws 	none
%% @end
%% ----------------------------------
cast_zone(M, F, A) ->
    ZoneNode = mod_server_config:get_zone_node(),
    rpc:cast(ZoneNode, M, F, A).



cast_all_node(M, F, A) ->
    ServerNodeList = mod_server:get_server_node_list(),
    lists:foreach(
        fun(ServerNode) ->
            #db_c_server_node{
                node = StrNode
            } = ServerNode,
            Node = util:to_atom(StrNode),
            if Node == node() ->
                noop;
                true ->
                    rpc:cast(Node, M, F, A)
            end
        end,
        ServerNodeList
    ).


%% ----------------------------------
%% @doc 	rpc call 战区服务器
%% @throws 	none
%% @end
%% ----------------------------------
-spec call_war(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
-spec call_war(M, F, A, TimeOut) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    TimeOut :: integer().
call_war(M, F, A) ->
    call_war(M, F, A, 6000).
call_war(M, F, A, TimeOut) ->
    WarNode = mod_server_config:get_war_area_node(),
    util:rpc_call(WarNode, M, F, A, TimeOut).


%% ----------------------------------
%% @doc 	rpc cast 跨服服务器
%% @throws 	none
%% @end
%% ----------------------------------
-spec cast_war(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].
cast_war(M, F, A) ->
    WarNode = mod_server_config:get_war_area_node(),
    rpc:cast(WarNode, M, F, A).

%% ----------------------------------
%% @doc 	gen_server 跨服服务器
%% @throws 	none
%% @end
%% ----------------------------------
send_zone(RegName, Msg) when is_atom(RegName) ->
    erlang:send({RegName, mod_server_config:get_zone_node()}, Msg).

gen_server_cast_zone(RegName, Msg) when is_atom(RegName) ->
    gen_server:cast({RegName, mod_server_config:get_zone_node()}, Msg).

gen_server_call_zone(RegName, Msg) when is_atom(RegName) ->
    gen_server_call_zone(RegName, Msg, 6000).
gen_server_call_zone(RegName, Msg, Timeout) when is_atom(RegName) ->
    gen_server:call({RegName, mod_server_config:get_zone_node()}, Msg, Timeout).


%% @fun 战区服务器

send_war(RegName, Msg) when is_atom(RegName) ->
    erlang:send({RegName, mod_server_config:get_war_area_node()}, Msg).

gen_server_cast_war(RegName, Msg) when is_atom(RegName) ->
    gen_server:cast({RegName, mod_server_config:get_war_area_node()}, Msg).

gen_server_call_war(RegName, Msg) when is_atom(RegName) ->
    gen_server_call_war(RegName, Msg, 6000).
gen_server_call_war(RegName, Msg, Timeout) when is_atom(RegName) ->
    gen_server:call({RegName, mod_server_config:get_war_area_node()}, Msg, Timeout).


%% ----------------------------------
%% @doc 	gen_server 所有游戏服务器
%% @throws 	none
%% @end
%% ----------------------------------
send_all_game_node(RegName, Msg) when is_atom(RegName) ->
    GameNodeList = mod_server:get_all_game_node(),
    lists:foreach(
        fun(Node) ->
            erlang:send({RegName, Node}, Msg)
        end,
        GameNodeList
    ),
    GameNodeList.

gen_server_cast_all_game_node(RegName, Msg) when is_atom(RegName) ->
    GameNodeList = mod_server:get_all_game_node(),
    lists:foreach(
        fun(Node) ->
            gen_server:cast({RegName, Node}, Msg)
        end,
        GameNodeList
    ),
    GameNodeList.

gen_server_call_all_game_node(RegName, Msg) when is_atom(RegName) ->
    GameNodeList = mod_server:get_all_game_node(),
    lists:foldl(
        fun(Node, Tmp) ->
            case catch gen_server:call({RegName, Node}, Msg) of
                {'EXIT', _Reason} ->
                    Tmp;
                _ ->
                    [Node | Tmp]
            end
        end,
        [],
        GameNodeList
    ).


%% ----------------------------------
%% @doc 	批量rpc 节点 (阻塞, 多进程异步), 返回失败的节点列表
%% @throws 	none
%% @end
%% ----------------------------------
batch_rpc_node_list(NodeList, M, F, A) ->
    batch_rpc_node_list(NodeList, M, F, A, null).

batch_rpc_node_list(NodeList, M, F, A, ExtraArgFun) ->
    batch_rpc_node_list(NodeList, M, F, A, ExtraArgFun, ?MINUTE_MS * 15).

batch_rpc_node_list(NodeList, M, F, A, ExtraArgFun, TimeOut) when is_list(NodeList) ->
    Ref = erlang:make_ref(),
    ?INFO(
        "\n\nBatch_rpc_node_list:\n"
        "    node_list:~p\n"
        "    node_num:~p\n"
        "    {m,f,a}:~p\n"
        "    time_out:~p\n"
        "    ref:~p\n"
        , [
            NodeList,
            length(NodeList),
            {M, F, A},
            TimeOut,
            Ref
        ]),

    Self = self(),
    WaitNum =
        lists:foldl(
            fun(Node, TmpNum) ->
                AtomNode = util:to_atom(Node),
                RealArg = case is_function(ExtraArgFun) of
                              true ->
                                  [ExtraArgFun(AtomNode) | A];
                              false ->
                                  A
                          end,
                spawn_link(fun() -> do_monitor_rpc(Self, AtomNode, M, F, RealArg, TimeOut, Ref) end),
                TmpNum + 1
            end,
            0,
            NodeList
        ),
    waiting(WaitNum, WaitNum, Ref).

waiting(WaitNum, WaitNum, Ref) ->
    ?INFO("waiting ~p batch rpc nodes......~n", [WaitNum]),
    waiting(WaitNum, WaitNum, 0, [], Ref).

waiting(0, _TotalNum, SuccessNum, FailNodeList, Ref) ->
    ?INFO(
        "\nBatch_rpc_node_list result:\n"
        "    success_num:~p\n"
        "    fail_num:~p\n"
        "    fail_node_list:~p\n"
        "    ref:~p\n"
        , [
%%            TotalNum,
            SuccessNum,
            length(FailNodeList),
            FailNodeList,
            Ref
        ]),
    FailNodeList;
waiting(WaitNum, TotalNum, SuccessNum, FailNodeList, Ref) ->
    receive
        {success, Node, Ref} ->
            ?INFO("Rpc ~p:success, waiting:~p", [Node, WaitNum - 1]),
            waiting(WaitNum - 1, TotalNum, SuccessNum + 1, FailNodeList, Ref);
        {fail, Node, Reason, Ref} ->
            ?INFO("Rpc ~p:fail, reason:~p, waiting:~p", [Node, Reason, WaitNum - 1]),
            waiting(WaitNum - 1, TotalNum, SuccessNum, [Node | FailNodeList], Ref)
%%        _Other ->
%%            ?ERROR("Batch_rpc_node_list receive unknown msg:~p~n", [_Other]),
%%            waiting(WaitNum, TotalNum, SuccessNum, FailNum, Ref)
    end.

do_monitor_rpc(Parent, Node, M, F, A, TimeOut, Ref) ->
    try rpc:call(Node, M, F, A, TimeOut) of
        ok ->
            Parent ! {success, Node, Ref};
        Other ->
            Parent ! {fail, Node, Other, Ref}
    catch
        _:Reason ->
            Parent ! {fail, Node, Reason, Ref}
    end.


%% ----------------------------------
%% @doc 	远程call
%% @throws 	none
%% @end
%% ----------------------------------
remote_call(Params) ->
    io:format("Remote_call params:~p~n", [Params]),
    [Node, M, F | Args] = Params,
    AtomNode = util:to_atom(Node),
    io:format("rpc:call(~p, ~p, ~p, ~p)......~n~n", [AtomNode, M, F, Args]),
    Result = rpc:call(AtomNode, M, F, Args),
    case Result of
        {badrpc, Reason} ->
            io:format(
                "Remote call fail !!!!!!!!!!!!~n"
                "Reason:~p~n~n",
                [Reason]
            );
        _ ->
            io:format(
                "~n~n"
                "***********************************************~n~n"
                "      Remote call success.~n"
                "      Result:~p~n~n"
                "***********************************************~n~n",
                [Result]
            )
    end.

%% ----------------------------------
%% @doc 	远程cast
%% @throws 	none
%% @end
%% ----------------------------------
remote_cast(Params) ->
    io:format("Remote_cast params:~p~n", [Params]),
    [Node, M, F | Args] = Params,
    AtomNode = util:to_atom(Node),
    io:format("rpc:cast(~p, ~p, ~p, ~p)......~n~n", [AtomNode, M, F, Args]),
    true = rpc:cast(AtomNode, M, F, Args).
