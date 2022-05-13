%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器管理 模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_mgr).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").

%% API
-export([
    add_game_server/8,                  %% 添加游戏服
    delete_game_server/2,               %% 删除游戏服
    add_server_node/9,                  %% 添加节点
    delete_server_node/1,               %% 删除节点
    update_node_state/2,                %% 修改游戏节点 状态
    update_all_game_state/1,            %% 修改所有游戏节点 状态
    update_all_game_server_state/2,
    set_node_run_state/2                %% 设置服务器状态
]).

-export([
%%    start_node_list/1,
%%    stop_node_list/1,
%%    kill_node_list/1
]).
-export([
    %% 设置游戏服开服时间
    set_game_server_open_time/3,
    set_game_server_open_time/2
]).

%% ----------------------------------
%% @doc 	停止节点
%% @throws 	none
%% @end
%%%% ----------------------------------
%%stop_node_list(NodeList) when is_list(NodeList) ->
%%    mod_server_rpc:batch_rpc_node_list(NodeList, game, stop, [true]).
%%    ?INFO("停止节点:~p", [Node]),
%%    rpc:cast(util:to_atom(Node), game, stop, [true]).


%% ----------------------------------
%% @doc 	启动节点
%% @throws 	none
%% @end
%% ----------------------------------
%%start_node_list(NodeList) when is_list(NodeList) ->
%%%%    ?INFO("启动节点:~p", [Node]),
%%    mod_server_rpc:batch_rpc_node_list(NodeList, game, start, []).
%%    rpc:cast(util:to_atom(Node), game, start, []).

%% ----------------------------------
%% @doc 	kill节点
%% @throws 	none
%% @end
%% ----------------------------------
%%kill_node_list(NodeList) when is_list(NodeList) ->
%%    mod_server_rpc:batch_rpc_node_list(NodeList, game, shutdown, []).
%%    ?INFO("kill 节点:~p", [NodeList]),
%%    lists:foreach(
%%        fun(Node) ->
%%            rpc:cast(util:to_atom(Node), init, stop, [])
%%        end,
%%        NodeList
%%    ),
%%    [].

%%%% ----------------------------------
%%%% @doc 	设置client版本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%set_client_version(Node, ClientVersion) when is_list(ClientVersion) andalso is_atom(Node) ->
%%    set_client_version(mod_server:get_server_node(Node), ClientVersion);
%%set_client_version(ServerNode, ClientVersion) when is_list(ClientVersion) ->
%%    %% 游戏服节点有效
%%    ?ASSERT(ServerNode#db_c_server_node.type == ?SERVER_TYPE_GAME),
%%    Tran = fun() ->
%%        db:write(ServerNode#db_c_server_node{client_version = ClientVersion})
%%           end,
%%    db:do(Tran).
%%
%%set_server_list_client_version(ClientVersion) ->
%%    set_server_list_client_version(0, ClientVersion).
%%set_server_list_client_version(PlatformId, ClientVersion) ->
%%    ServerNodeList = mod_server:get_server_node_list(PlatformId, ?SERVER_TYPE_GAME),
%%    lists:foreach(
%%        fun(ServerNode) ->
%%            set_client_version(ServerNode, ClientVersion)
%%        end,
%%        ServerNodeList
%%    ).

%%%% ----------------------------------
%%%% @doc     更新节点版本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%update_node_version(Node, ServerVersion) when is_list(ServerVersion) andalso is_atom(Node) ->
%%    update_node_version(mod_server:get_server_node(Node), ServerVersion);
%%update_node_version(ServerNode, ServerVersion) when is_list(ServerVersion) ->
%%    if ServerNode#db_c_server_node.server_version =/= ServerVersion ->
%%        Tran = fun() ->
%%            db:write(ServerNode#db_c_server_node{server_version = ServerVersion})
%%               end,
%%        db:do(Tran);
%%        true ->
%%            noop
%%    end.

%% ----------------------------------
%% @doc 	设置游戏服开服时间
%% @throws 	none
%% @end
%% ----------------------------------
set_game_server_open_time(PlatformId, ServerId, Time) ->
    GameServer = mod_server:get_game_server(PlatformId, ServerId),
    Node = GameServer#db_c_game_server.node,
    set_game_server_open_time(mod_server:get_server_node(Node), Time).
set_game_server_open_time(Node, Time) when is_integer(Time) andalso is_atom(Node) ->
    set_game_server_open_time(mod_server:get_server_node(Node), Time);
set_game_server_open_time(ServerNode, Time) when is_integer(Time) ->
    %% 游戏服节点有效
    ?ASSERT(ServerNode#db_c_server_node.type == ?SERVER_TYPE_GAME),
    Tran = fun() ->
        db:write(ServerNode#db_c_server_node{open_time = Time})
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	设置服务器状态
%% @throws 	none
%% @end
%% ----------------------------------
set_node_run_state(Node, State) when is_integer(State) ->
    ServerNode = mod_server:get_server_node(Node),
    Tran = fun() ->
        db:write(ServerNode#db_c_server_node{run_state = State})
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	添加游戏服
%% @throws 	none
%% @end
%% ----------------------------------
add_game_server(PlatformId, ServerId, Desc, Node, ZoneNode, State, OpenTime, IsShow)
    when is_list(ServerId) andalso is_list(Desc) ->
    ?INFO("添加游戏服:~p", [{PlatformId, ServerId, Desc, Node}]),


    ?ASSERT(string:sub_string(ServerId, 1, 1) == "s", {head_not_s, ServerId}),
    _ = erlang:list_to_integer(string:sub_string(ServerId, 2)),

    StringPlatformId = util:to_list(PlatformId),
    StringNode = util:to_list(Node),
    StringZoneNode = util:to_list(ZoneNode),
    IntState = util:to_int(State),
    IntIsShow = util:to_int(IsShow),
    IntOpenTime = util:to_int(OpenTime),
    StringDesc = util_string:string_to_list(Desc),
    ?ASSERT(IntOpenTime > 0, open_time_zero),
%%    ?INFO("add_game_server:~p~n", [{Desc, unicode:characters_to_list(Desc), unicode:characters_to_list(Desc, unicode), util_string:string_to_list(Desc), util_string:string_to_binary(Desc)}]),
%%    ?ASSERT(mod_server:get_platform_record(StringPlatformId) =/= null, platform_not_find),
%%    ?ASSERT(util_string:is_valid_name(StringDesc), desc_invalid),
    ?ASSERT(StringDesc =/= "", desc_null),
    ?ASSERT(mod_server:get_server_node(StringNode) =/= null, server_node_undefined),
    ?ASSERT(mod_server:get_server_node(StringZoneNode) =/= null, zone_node_undefined),
    %%状态
    ?ASSERT(lists:member(IntState, [?SERVER_STATE_MAINTENANCE, ?SERVER_STATE_ONLINE, ?SERVER_STATE_HOT])),
    ServerNode = mod_server:get_server_node(StringNode),
    case mod_server:get_game_server(StringPlatformId, ServerId) of
        null ->
            R = #db_c_game_server{
                platform_id = StringPlatformId,
                sid = ServerId,
                desc = StringDesc,
                node = StringNode,
                is_show = IntIsShow
            },
            Tran = fun() ->
                db:write(R),
                db:write(ServerNode#db_c_server_node{
                    state = IntState,
                    open_time = IntOpenTime,
                    zone_node = StringZoneNode
                })
                   end,
            db:do(Tran),
            ?INFO("添加游戏服成功:~p", [R]);
        R ->
            NewR = R#db_c_game_server{
                desc = StringDesc,
                node = StringNode,
                is_show = IntIsShow
            },
            Tran = fun() ->
                db:write(NewR),
                db:write(ServerNode#db_c_server_node{
                    state = IntState,
                    open_time = IntOpenTime,
                    zone_node = StringZoneNode
                })
                   end,
            db:do(Tran),
            ?INFO("更新游戏服成功:~p", [{R, NewR}])
    end.

%% ----------------------------------
%% @doc 	删除游戏服
%% @throws 	none
%% @end
%% ----------------------------------
delete_game_server(PlatformId, ServerId) ->
    case mod_server:get_game_server(PlatformId, ServerId) of
        null ->
            exit({game_server_undefined, PlatformId, ServerId});
        R ->
            Tran = fun() ->
                db:delete(R)
                   end,
            db:do(Tran),
            ?INFO("删除游戏服成功:~p", [R])
    end.

%% ----------------------------------
%% @doc 	添加节点
%% @throws 	none
%% @end
%% ----------------------------------
add_server_node(Node, Ip, Port, HttpPort, Type, PlatformId, DbHost, DbPort, DbName) ->
    ?INFO("添加节点:~p~n", [{Node, Ip, Port, HttpPort, Type, PlatformId, DbHost, DbPort, DbName}]),
    StringNode = util:to_list(Node),
    IntPort = util:to_int(Port),
    IntHttpPort = util:to_int(HttpPort),
    IntType = util:to_int(Type),
%%    IntOpenTime = util:to_int(OpenTime),
    StringPlatformId = util:to_list(PlatformId),
%%    IntState = util:to_int(State),
%%    StringZoneNode = util:to_list(ZoneNode),
    [_, _] = string:tokens(StringNode, "@"),

    StringDbHost = util:to_list(DbHost),
    IntDbPort = util:to_int(DbPort),
    StringDbName = util:to_list(DbName),

    ?ASSERT(StringDbHost =/= "", db_host_null),
    ?ASSERT(IntDbPort =/= 0, db_port_zero),
    ?ASSERT(StringDbName =/= "", db_name_null),

    %% 检测节点类型
    ?ASSERT(
        IntType == ?SERVER_TYPE_GAME
            orelse IntType == ?SERVER_TYPE_WAR_ZONE
            orelse IntType == ?SERVER_TYPE_LOGIN_SERVER
            orelse IntType == ?SERVER_TYPE_UNIQUE_ID
            orelse IntType == ?SERVER_TYPE_CHARGE
            orelse IntType == ?SERVER_TYPE_WAR_AREA
            orelse IntType == ?SERVER_TYPE_WEB
            orelse IntType == ?SERVER_TYPE_CENTER,
        server_type_error
    ),

    %%状态
%%    ?ASSERT(lists:member(IntState, [?SERVER_STATE_MAINTENANCE, ?SERVER_STATE_ONLINE, ?SERVER_STATE_OFFLINE, ?SERVER_STATE_HOT])),

    %% 检测平台id
%%    ?ASSERT(IntType =/= ?SERVER_TYPE_GAME orelse mod_server:get_platform_record(StringPlatformId) =/= null, platform_not_find),

    %% 检测游戏节点相关
%%    if IntType == ?SERVER_TYPE_GAME ->
%%        %% 检测跨服节点
%%        ?ASSERT(StringZoneNode == "null" orelse mod_server:get_server_node(StringZoneNode) =/= null, {zone_node_undefined, StringZoneNode});
%%        true ->
%%            noop
%%    end,
    case mod_server:get_server_node(StringNode) of
        null ->
            R = #db_c_server_node{
                node = StringNode,
                ip = Ip,
                port = IntPort,
                web_port = IntHttpPort,
                type = IntType,
%%                open_time = IntOpenTime,
                platform_id = StringPlatformId,
                run_state = ?NODE_RUN_STATE_DISCONNECT,
%%                zone_node = StringZoneNode,
%%                state = IntState,
                db_host = StringDbHost,
                db_name = StringDbName,
                db_port = IntDbPort
            },

            Tran = fun() ->
                db:write(R),
                check_server_node_valid(R)
                   end,
            db:do(Tran),
            ?INFO("添加节点成功~p", [R]);
        R ->
            NewR = R#db_c_server_node{
                ip = Ip,
                port = IntPort,
                web_port = IntHttpPort,
                type = IntType,
%%                open_time = IntOpenTime,
                platform_id = StringPlatformId,
%%                zone_node = StringZoneNode,
%%                state = IntState,
                db_host = StringDbHost,
                db_name = StringDbName,
                db_port = IntDbPort
            },

            Tran = fun() ->
                db:write(NewR),
                check_server_node_valid(NewR)
                   end,
            db:do(Tran),
            ?INFO("更新节点成功:~p", [{R, NewR}])
    end.

check_server_node_valid(ServerNode) ->
    #db_c_server_node{
        type = Type,
        ip = Ip,
        port = Port,
        web_port = HttpPort
    } = ServerNode,
    if Type == ?SERVER_TYPE_GAME ->
        ?ASSERT(Port > 0, zero_port),
        ?ASSERT(HttpPort > 0, zero_http_port),
        ?ASSERT(length(db:select(c_server_node, [{#db_c_server_node{ip = util:to_list(Ip), port = Port, _ = '_'}, [], ['$_']}])) =< 1, port_repeated),
        ?ASSERT(length(db:select(c_server_node, [{#db_c_server_node{ip = util:to_list(Ip), port = HttpPort, _ = '_'}, [], ['$_']}])) =< 1, httpport_repeated);
        true ->
            noop
    end,
    if Type == ?SERVER_TYPE_LOGIN_SERVER ->
        ?ASSERT(HttpPort > 0, zero_http_port),
        ?ASSERT(length(db:select(c_server_node, [{#db_c_server_node{ip = util:to_list(Ip), port = HttpPort, _ = '_'}, [], ['$_']}])) =< 1, httpport_repeated);
        true ->
            noop
    end,
    if Type == ?SERVER_TYPE_UNIQUE_ID orelse Type == ?SERVER_TYPE_CHARGE ->
        ?ASSERT(length(db:select(c_server_node, [{#db_c_server_node{type = Type, _ = '_'}, [], ['$_']}])) =< 1, {type_repeated, Type});
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	删除节点
%% @throws 	none
%% @end
%% ----------------------------------
delete_server_node(Node) ->
    case mod_server:get_server_node(Node) of
        null ->
            exit(server_node_undefined);
        R ->
            Tran = fun() ->
                db:delete(R)
                   end,
            db:do(Tran),
            ?INFO("删除节点成功:~p", [R])
    end.

%% ----------------------------------
%% @doc 	修改游戏节点 状态
%% @throws 	none
%% @end
%% ----------------------------------
update_node_state(Node, State) ->
    IntState = util:to_int(State),
    ServerNode = mod_server:get_server_node(Node),
    ?ASSERT(ServerNode#db_c_server_node.type == ?SERVER_TYPE_GAME, {no_game_node, ServerNode}),
    ?ASSERT(lists:member(IntState, [?SERVER_STATE_MAINTENANCE, ?SERVER_STATE_ONLINE, ?SERVER_STATE_HOT])),
    if ServerNode#db_c_server_node.state == IntState ->
        noop;
        true ->
            Tran = fun() ->
                db:write(ServerNode#db_c_server_node{
                    state = IntState
                })
                   end,
            db:do(Tran)
    end,
    ok.


%% ----------------------------------
%% @doc 	修改所有游戏节点 状态
%% @throws 	none
%% @end
%% ----------------------------------
update_all_game_state(State) ->
    lists:foreach(
        fun(Node) ->
            update_node_state(Node, State)
        end,
        mod_server:get_all_game_node()
    ).

%% ----------------------------------
%% @doc 	修改所有游戏服 状态
%% @throws 	none
%% @end
%% ----------------------------------
update_all_game_server_state(PlatformId, State) ->
    lists:foreach(
        fun(GameServer) ->
            update_node_state(GameServer#db_c_game_server.node, State)
        end,
        mod_server:get_game_server_list(PlatformId)
    ).
