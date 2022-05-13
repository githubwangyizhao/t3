%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器同步模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_sync).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
%%-include("template_db.hrl").
-record(sync_server_data, {
    server_type,
    value_maps
}).


%% API
-export([
    pull/0,                             %% 下拉数据
    after_add_game_node/0,
    sync_c_game_server_list/0,          %% 同步 c_game_server 到本服
    sync_c_server_node_list/0           %% 同步 c_server_node 到本服
]).


%% 推送到节点
-export([
    push_all_node/0,
    push_all_web_node/0,
    push_all_game_node/0,
    push_all_zone_node/0,
    push_all_charge_node/0,
    push_all_war_node/0,
    push_all_login_server_node/0,
    push_node_list/1
%%    push_node/1
]).

%% 同步充值服
-export([
%%    pull_charge_node/0,
%%    pull_charge_node/1
]).
%% CALLBACK
-export([
    handle_sync/1,
    pack_sync_server_data/1            %% 打包同步数据
]).


%% ----------------------------------
%% @doc 	新增游戏节点后 同步数据到需要同步数据的所有节点
%% @throws 	none
%% @end
%% ----------------------------------
after_add_game_node() ->
    push_all_charge_node(),
    push_all_war_node(),
    push_all_login_server_node(),
    push_all_web_node().

%% ----------------------------------
%% @doc 	同步所有节点
%% @throws 	none
%% @end
%% ----------------------------------
push_all_node() ->
    ServerNodeList = mod_server:get_server_node_list(),
    push_server_node_list(ServerNodeList).

push_all_web_node() ->
    ServerNodeList1 = mod_server:get_server_node_list(?SERVER_TYPE_WEB),
    push_server_node_list(ServerNodeList1).
%%    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_LOGIN_SERVER),
%%    ?TRY_CATCH(push_server_node_list(ServerNodeList)).


push_all_login_server_node() ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_LOGIN_SERVER),
    push_server_node_list(ServerNodeList).
%%    ServerNodeList1 = mod_server:get_server_node_list(?SERVER_TYPE_WEB),
%%    ?TRY_CATCH(push_server_node_list(ServerNodeList1)).

push_all_game_node() ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_GAME),
    push_server_node_list(ServerNodeList).

push_all_zone_node() ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_WAR_ZONE),
    push_server_node_list(ServerNodeList).

push_all_charge_node() ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_CHARGE),
    push_server_node_list(ServerNodeList).

push_all_war_node() ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_WAR_AREA),
    push_server_node_list(ServerNodeList).


push_server_node_list(ServerNodeList) ->
    NodeList = lists:foldl(
        fun(ServerNode, Tmp) ->
            #db_c_server_node{
                node = StrNode,
                type = _Type
            } = ServerNode,
            AtomNode = util:to_atom(StrNode),
            [AtomNode | Tmp]
        end,
        [],
        ServerNodeList
    ),
    push_node_list(NodeList).

%%    ?ASSERT(mod_server:is_center_server() == true),
%%    Ref = erlang:make_ref(),
%%    Self = self(),
%%    WaitNum =
%%        lists:foldl(
%%            fun(ServerNode, TmpNum) ->
%%                #c_server_node{
%%                    node = StrNode,
%%                    type = Type
%%                } = ServerNode,
%%                if
%%                %% 中心服 和  唯一id 服 不推送
%%                    Type == ?SERVER_TYPE_UNIQUE_ID orelse
%%                        Type == ?SERVER_TYPE_CENTER ->
%%                        TmpNum;
%%                    true ->
%%                        AtomNode = util:to_atom(StrNode),
%%                        spawn_link(fun() -> monitor_push_node(Self, AtomNode, Ref) end),
%%                        TmpNum + 1
%%                end
%%            end,
%%            0,
%%            ServerNodeList
%%        ),
%%    wait(WaitNum, WaitNum, Ref).

push_node_list(NodeList) when is_list(NodeList) ->
    ?ASSERT(mod_server:is_center_server() == true),
    ExtraArgFun =
        fun(Node) ->
            {ok, SyncServerData} = mod_server_sync:pack_sync_server_data(Node),
            SyncServerData
        end,
    mod_server_rpc:batch_rpc_node_list(NodeList, mod_server_sync, handle_sync, [], ExtraArgFun),
    ok.

%%wait(WaitNum, WaitNum, Ref) ->
%%    ?INFO("waiting push ~p nodes......~n", [WaitNum]),
%%    wait(WaitNum, WaitNum, 0, 0, Ref).
%%wait(0, TotalNum, SuccessNum, FailNum, _Ref) ->
%%    ?INFO(
%%        "\n Push ~p nodes finish:\n"
%%        "    success:~p\n"
%%        "    fail:~p\n"
%%        , [
%%            TotalNum,
%%            SuccessNum,
%%            FailNum
%%        ]);
%%wait(WaitNum, TotalNum, SuccessNum, FailNum, Ref) ->
%%    receive
%%        {success, Node, Ref} ->
%%            ?INFO("waiting:~p, push success:~p", [WaitNum - 1, Node]),
%%            wait(WaitNum - 1, TotalNum, SuccessNum + 1, FailNum, Ref);
%%        {fail, Node, Reason, Ref} ->
%%            ?ERROR("waiting:~p, push fail:~p, reason:~p", [WaitNum - 1, Node, Reason]),
%%            wait(WaitNum - 1, TotalNum, SuccessNum, FailNum + 1, Ref);
%%        _Other ->
%%            ?ERROR("receive unknown msg:~p~n", [_Other]),
%%            throw(error)
%%    end.
%%
%%monitor_push_node(Parent, Node, Ref) when is_atom(Node) ->
%%    try
%%        {ok, SyncServerData} = mod_server_sync:pack_sync_server_data(Node),
%%        case rpc:call(Node, mod_server_sync, handle_sync, [SyncServerData], 180000) of
%%            ok ->
%%                Parent ! {success, Node, Ref};
%%            Other ->
%%                Parent ! {fail, Node, Other, Ref}
%%        end
%%    catch
%%        _:Reason ->
%%            Parent ! {fail, Node, Reason, Ref}
%%    end.
%%
%%push_node(Node) when is_atom(Node) ->
%%    ?ASSERT(mod_server:is_center_server() == true),
%%    {ok, SyncServerData} = mod_server_sync:pack_sync_server_data(Node),
%%    case rpc:call(Node, mod_server_sync, handle_sync, [SyncServerData], 180000) of
%%        ok ->
%%            ?INFO("Push ~p success!", [Node]);
%%        Other ->
%%            ?ERROR("Push ~p fail:~p", [Node, Other])
%%    end.
%%    rpc:cast(AtomNode, server_node_slave, sync, []).


%% ----------------------------------
%% @doc 	下拉中心服数据
%% @throws 	none
%% @end
%% ----------------------------------
pull() ->
    ?ASSERT(mod_server:is_center_server() =/= true),
    case mod_server_rpc:call_center(?MODULE, pack_sync_server_data, [node()]) of
        {ok, SyncServerData} ->
            ?INFO("Pull server data:~p~n", [SyncServerData]),
            handle_sync(SyncServerData),
            ok;
        Other ->
            ?ERROR("Pull server data(~p) failed:~p", [mod_server_config:get_center_node(), Other]),
            exit(pull_center_data_fail)
    end.

handle_sync(SyncServerData) when is_record(SyncServerData, sync_server_data) ->
    #sync_server_data{
        server_type = ServerType,
        value_maps = ValueMaps
    } = SyncServerData,
    %% 初始化服务器类型
    mod_server_config:init_server_type(ServerType),
    handle_sync(ServerType, ValueMaps),
    ok.

%% 游戏服
handle_sync(?SERVER_TYPE_GAME, ValueMaps) ->
%%    GameServerList = maps:get(copy_game_server_list, ValueMaps),
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),
%%    {WorldAuctionNode, WorldAuctionNodeState} = maps:get(world_action_node_and_state, ValueMaps),
    ZoneNode = maps:get(zone_node, ValueMaps),
    Port = maps:get(port, ValueMaps),
    WebPort = maps:get(web_port, ValueMaps),
    Ip = maps:get(ip, ValueMaps),
%%    DbIp = maps:get(db_ip, ValueMaps),
    PlatformId = maps:get(platform_id, ValueMaps),
%%    DbName = maps:get(db_name, ValueMaps),
    OpenTime = maps:get(open_time, ValueMaps),
%%    IsCreateRobot = maps:get(is_create_robot, ValueMaps),
    UniqueIdNode = maps:get(unique_id_node, ValueMaps),
    LoginServerNode = maps:get(login_server_node, ValueMaps),
    ChargeNode = maps:get(charge_node, ValueMaps),
    WarAreaNode = maps:get(war_area_node, ValueMaps),
    %% 初始世界拍卖行节点和状态
%%    mod_server_config:init_world_auction_node(WorldAuctionNode, WorldAuctionNodeState),
    %% 设置开服时间
    mod_server_config:set_server_open_time(OpenTime),
    %% 初始化平台id
    mod_server_config:init_platform_id(PlatformId),
    %% 同步 c_game_server 到本服
    sync_c_game_server_list(),
    %% 同步 c_server_node 到本服
    sync_c_server_node_list(),
    %% 设置本服战区节点
    mod_server_config:init_zone_node(ZoneNode),
    %% 设置数据库地址
%%    mod_server_config:init_db_host(DbIp),
    %% 设置数据库名字
%%    mod_server_config:init_db_name(DbName),
    %% 设置tcp端口
    mod_server_config:init_tcp_listen_port(Port),

    %% 设置web tcp端口
    mod_server_config:init_web_tcp_listen_port(WebPort),
    %% 设置web url
    mod_server_config:init_game_web_url("http://" ++ util:to_list(Ip) ++ ":" ++ util:to_list(WebPort)),

    %% 初始化唯一id节点
    mod_server_config:init_login_server_node(LoginServerNode),
    mod_server_config:init_unique_id_node(UniqueIdNode),
    mod_server_config:init_charge_node(ChargeNode),
    mod_server_config:init_war_area_node(WarAreaNode);
%% 是否启动机器人
%%    mod_server_config:set_is_create_robot(IsCreateRobot);

%% 跨服服务器
handle_sync(?SERVER_TYPE_WAR_ZONE, ValueMaps) ->
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),

%%    DbIp = maps:get(db_ip, ValueMaps),
%%    DbName = maps:get(db_name, ValueMaps),
%% 同步 c_game_server 到本服
    sync_c_game_server_list(),
%% 同步 c_server_node 到本服
    sync_c_server_node_list();
%% 设置数据库地址
%%    mod_server_config:init_db_host(DbIp),
%% 设置数据库名字
%%    mod_server_config:init_db_name(DbName);

%% 拍卖行
%%handle_sync(?SERVER_TYPE_WORLD_AUCTION, ValueMaps) ->
%%    GameNodes = maps:get(game_nodes, ValueMaps),
%%%%    DbIp = maps:get(db_ip, ValueMaps),
%%%%    DbName = maps:get(db_name, ValueMaps),
%%
%%%% 初始世界拍卖行 游戏服的节点
%%    mod_server_config:init_world_auction_game_nodes(GameNodes);
%% 设置数据库地址
%%    mod_server_config:init_db_host(DbIp),
%% 设置数据库名字
%%    mod_server_config:init_db_name(DbName);

%% login_server 服务器
handle_sync(?SERVER_TYPE_LOGIN_SERVER, ValueMaps) ->
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),
    Port = maps:get(port, ValueMaps),
    WebPort = maps:get(web_port, ValueMaps),
%% 同步 c_game_server 到本服
    sync_c_game_server_list(),
%% 同步 c_server_node 到本服
    sync_c_server_node_list(),
%% 设置tcp端口
    mod_server_config:init_tcp_listen_port(Port),
    mod_server_config:init_web_tcp_listen_port(WebPort);
%% 设置数据库地址
%%    mod_server_config:init_db_host(DbIp),
%% 设置数据库名字
%%    mod_server_config:init_db_name(DbName);

%% WEB服务器
handle_sync(?SERVER_TYPE_WEB, ValueMaps) ->
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),
    Port = maps:get(port, ValueMaps),
    WebPort = maps:get(web_port, ValueMaps),
%% 同步 c_game_server 到本服
    sync_c_game_server_list(),
%% 同步 c_server_node 到本服
    sync_c_server_node_list(),
%% 设置tcp端口
    mod_server_config:init_tcp_listen_port(Port),
    mod_server_config:init_web_tcp_listen_port(WebPort);
%% 充值服务器
handle_sync(?SERVER_TYPE_CHARGE, ValueMaps) ->
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),
    Port = maps:get(port, ValueMaps),
    WebPort = maps:get(web_port, ValueMaps),
%% 同步 c_game_server 到本服
    sync_c_game_server_list(),
%% 同步 c_server_node 到本服
    sync_c_server_node_list(),
%% 设置tcp端口
    mod_server_config:init_tcp_listen_port(Port),
    mod_server_config:init_web_tcp_listen_port(WebPort);

%% 唯一id 服务器
handle_sync(?SERVER_TYPE_UNIQUE_ID, _ValueMaps) ->
    noop;
%%    DbIp = maps:get(db_ip, ValueMaps),
%%    DbName = maps:get(db_name, ValueMaps),
%% 设置数据库地址
%%    mod_server_config:init_db_host(DbIp),
%% 设置数据库名字
%%    mod_server_config:init_db_name(DbName);
%% 战区服
handle_sync(?SERVER_TYPE_WAR_AREA, ValueMaps) ->
    GameServerList = maps:get(c_game_server_list, ValueMaps),
    ServerNodeList = maps:get(c_server_node_list, ValueMaps),
    env:set(c_game_server_list, GameServerList),
    env:set(c_server_node_list, ServerNodeList),
    PlatformId = maps:get(platform_id, ValueMaps),
    Port = maps:get(port, ValueMaps),
%% 同步 c_game_server 到本服
    sync_c_game_server_list(),
%% 同步 c_server_node 到本服
    sync_c_server_node_list(),
    %% 初始化平台id
    mod_server_config:init_platform_id(PlatformId),
%% 设置tcp端口
    mod_server_config:init_tcp_listen_port(Port);
handle_sync(Other, ValueMaps) ->
    ?ERROR("Unknow dump_data:~p", [{node(), Other, ValueMaps}]),
    exit(unknow_dump_data).


pack_sync_server_data(Node) ->
    case mod_server:get_server_node(Node) of
        null ->
            ?ERROR("节点未配置: ~p!!!!", [Node]),
            exit(node_not_find);
        ServerNode ->
            #db_c_server_node{
                port = Port,
%%                db_ip = DbIp,
%%                db_name = DbName,
                web_port = WebPort,
                ip = Ip,
                platform_id = PlatformId,
                type = Type,
                zone_node = ZoneNode
            } = ServerNode,
            case Type of
                %%游戏服
                ?SERVER_TYPE_GAME ->
                    GameServerList = mod_server:get_game_server_list_by_node(Node),
                    UniqueNode = mod_server:get_unique_id_server_node(),
                    ChargeNode = mod_server:get_charge_server_node(),
                    WarAreaNode = mod_server:get_war_area_server_node(PlatformId),
                    if UniqueNode == null ->
                        ?ERROR("唯一id节点未配置"),
                        exit(unique_id_no_config);
                        true ->
                            noop
                    end,
                    LoginServerNode = mod_server:get_login_server_node(),
                    if LoginServerNode == null ->
                        ?ERROR("登录服节点未配置"),
                        exit(login_server_no_config);
                        true ->
                            noop
                    end,
                    if ChargeNode == null ->
                        ?ERROR("充值节点未配置"),
                        exit(charge_node_no_config);
                        true ->
                            noop
                    end,
                    WarAreaNodeAtom =
                        if WarAreaNode == null ->
                            ?ERROR("战区服节点未配置"),
                            #db_c_server_node{};
%%                        exit(war_area_node_no_config);
                            true ->
                                WarAreaNode
                        end,
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => [ServerNode],
                                zone_node => ZoneNode,
                                port => Port,
                                web_port => WebPort,
                                ip => Ip,
%%                                db_ip => DbIp,
%%                                db_name => DbName,
                                platform_id => PlatformId,
                                open_time => ServerNode#db_c_server_node.open_time,
%%                                is_create_robot => true,
                                unique_id_node => util:to_atom(UniqueNode#db_c_server_node.node),
                                login_server_node => util:to_atom(LoginServerNode#db_c_server_node.node),
                                charge_node => util:to_atom(ChargeNode#db_c_server_node.node),
                                war_area_node => util:to_atom(WarAreaNodeAtom#db_c_server_node.node)
                            }
                        }
                    };
                %%跨服
                ?SERVER_TYPE_WAR_ZONE ->
                    GameServerNodeList = mod_server:get_server_node_list_by_zone(Node),
                    GameServerList = lists:foldl(
                        fun(GameServerNode, T) ->
                            mod_server:get_game_server_list_by_node(GameServerNode#db_c_server_node.node) ++ T
                        end,
                        [],
                        GameServerNodeList
                    ),
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => [ServerNode | GameServerNodeList]
%%                                db_ip => DbIp,
%%                                db_name => DbName
                            }
                        }
                    };
                %% web server
                ?SERVER_TYPE_LOGIN_SERVER ->
                    GameServerList = mod_server:get_game_server_list(),
                    ServerNodeList = mod_server:get_server_node_list(),
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => ServerNodeList,
%%                                db_ip => DbIp,
                                port => Port,
                                web_port => WebPort
%%                                db_name => DbName
                            }
                        }
                    };
                ?SERVER_TYPE_WEB ->
                    GameServerList = mod_server:get_game_server_list(),
                    ServerNodeList = mod_server:get_server_node_list(),
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => ServerNodeList,
%%                                db_ip => DbIp,
                                port => Port,
                                web_port => WebPort
%%                                db_name => DbName
                            }
                        }
                    };
                %% 唯一id 服务器
                ?SERVER_TYPE_UNIQUE_ID ->
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
%%                                db_ip => DbIp,
%%                                db_name => DbName
                            }
                        }
                    };
                %% 充值 服务器
                ?SERVER_TYPE_CHARGE ->
                    GameServerList = mod_server:get_game_server_list(),
                    ServerNodeList = mod_server:get_server_node_list(),
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => ServerNodeList,
                                web_port => WebPort,
                                port => Port
                            }
                        }
                    };
                %% 战区服 服务器
                ?SERVER_TYPE_WAR_AREA ->
                    ?ASSERT(PlatformId =/= "", platform_null),
                    GameServerList = mod_server:get_game_server_list(PlatformId),
                    ServerNodeList =
                        lists:foldl(
                            fun(E, Tmp) ->
                                [mod_server:get_server_node(E#db_c_game_server.node) | Tmp]
                            end,
                            [],
                            GameServerList
                        ),
%%                    ServerNodeList = mod_server:get_server_node_list(),
                    {
                        ok,
                        #sync_server_data{
                            server_type = Type,
                            value_maps = #{
                                c_game_server_list => GameServerList,
                                c_server_node_list => ServerNodeList,
                                platform_id => PlatformId,
                                port => Port
                            }
                        }
                    }
            end
    end.

%% ----------------------------------
%% @doc 	中心服 同步 c_game_server 到本服
%% @throws 	none
%% @end
%% ----------------------------------
sync_c_game_server_list() ->
    ?ASSERT(mod_server:is_center_server() =/= true),
    case ets:info(c_game_server) of
        undefined ->
            noop;
        _ ->
            case env:get(c_game_server_list) of
                GameServerList when is_list(GameServerList) ->
%%                    ets:delete_all_objects(c_game_server),
                    OldGameServerList = ets:tab2list(c_game_server),
                    lists:foreach(
                        fun(GameServer) ->
                            case lists:keymember(GameServer#db_c_game_server.row_key, #db_c_game_server.row_key, GameServerList) of
                                true ->
                                    noop;
                                false ->
                                    ?WARNING("删除GameServer:~p", [GameServer]),
                                    ets:delete_object(c_game_server, GameServer)
                            end
                        end,
                        OldGameServerList
                    ),
                    lists:foreach(
                        fun(GameServer) ->
                            ets:insert(c_game_server, GameServer)
                        end,
                        GameServerList
                    );
                _ ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	中心服 同步 c_server_node 到本服
%% @throws 	none
%% @end
%% ----------------------------------
sync_c_server_node_list() ->
    ?ASSERT(mod_server:is_center_server() =/= true),
    case ets:info(c_game_server) of
        undefined ->
            noop;
        _ ->
            case env:get(c_server_node_list) of
                ServerNodeList when is_list(ServerNodeList) ->
%%                    ets:delete_all_objects(c_server_node),
                    OldServerNodeList = ets:tab2list(c_server_node),
                    lists:foreach(
                        fun(ServerNode) ->
                            case lists:keymember(ServerNode#db_c_server_node.row_key, #db_c_server_node.row_key, ServerNodeList) of
                                true ->
                                    noop;
                                false ->
                                    ?WARNING("删除ServerNode:~p", [ServerNode]),
                                    ets:delete_object(c_server_node, ServerNode)
                            end
                        end,
                        OldServerNodeList
                    ),
                    lists:foreach(
                        fun(ServerNode) ->
                            ets:insert(c_server_node, ServerNode)
                        end,
                        ServerNodeList
                    );
                _ ->
                    noop
            end
    end.

%%%% ----------------------------------
%%%% @doc 	同步充值服
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%pull_charge_node() ->
%%    pull_charge_node(?CHARGE_NODE).
%%pull_charge_node(Node) ->
%%    InfoList = mod_server:get_all_game_server_info_list(),
%%    util:rpc_call(Node, mod_charge, init_server_node, [InfoList]).
