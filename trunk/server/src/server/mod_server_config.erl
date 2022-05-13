%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器配置 模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_config).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("client.hrl").
%% API
-export([
    get_center_node/0,                  %% 获取中心节点

    init_tcp_listen_port/1,             %% 初始化tcp监听端口
    get_tcp_listen_port/0,              %% 获取tcp监听端口
    init_web_tcp_listen_port/1,         %% 初始化web tcp监听端口
    get_web_tcp_listen_port/0,          %% 获取web tcp监听端口
    init_game_web_url/1,                %% 初始化web url
    get_game_web_url/0,                 %% 获取web tcp监听端口


%%    init_db_host/1,                     %% 初始化数据库地址
%%    get_db_host/0,                      %% 获取数据库地址

    init_unique_id_node/1,              %% 初始化唯一id节点
    get_unique_id_node/0,               %% 获取唯一id节点

    init_login_server_node/1,
    get_login_server_node/0,

    init_charge_node/1,
    get_charge_node/0,

    init_war_area_node/1,
    get_war_area_node/0,

    init_platform_id/1,                 %% 初始化平台id
    get_platform_id/0,                  %% 获取平台id
%%    get_real_platform_id/0,

    init_zone_node/1,                   %% 初始化战区节点
    get_zone_node/0,                    %% 获取战区节点

%%    init_world_auction_node/2,          %% 初始世界拍卖行节点和状态
%%    get_world_auction_node/0,           %% 获取世界拍卖行节点和状态

%%    init_world_auction_game_nodes/1,    %% 初始世界拍卖行游戏服列表
%%    get_world_auction_game_nodes/0,     %% 获得拍卖行游戏服列表

    set_server_open_time/1,             %% 设置开服时间
    get_server_open_time/0,             %% 获取开服时间
    get_server_merge_time/0,            %% 获取合服时间
%%    init_db_name/1,                     %% 初始化数据库名字
%%    get_db_name/0,                      %% 获取数据库名字

    init_server_type/1,                 %% 设置服务器类型
    get_server_type/0,                  %% 获取服务器类型

    set_is_create_robot/1,              %% 设置是否启用机器人
    is_create_robot/0,                  %% 是否启用机器人
    is_test_server/0                    %% 是否是测试服
]).

%% ----------------------------------
%% @doc 	获取中心服节点
%% @throws 	none
%% @end
%% ----------------------------------
get_center_node() ->
    env:get(center_node).

%% ----------------------------------
%% @doc 	初始化tcp监听端口
%% @throws 	none
%% @end
%% ----------------------------------
init_tcp_listen_port(Port) ->
    env:set(tcp_listen_port, Port).

%% ----------------------------------
%% @doc 	获取tcp监听端口
%% @throws 	none
%% @end
%% ----------------------------------
get_tcp_listen_port() ->
    env:get(tcp_listen_port).


%% ----------------------------------
%% @doc 	初始化web tcp监听端口
%% @throws 	none
%% @end
%% ----------------------------------
init_web_tcp_listen_port(Port) ->
    env:set(tcp_web_listen_port, Port).

%% ----------------------------------
%% @doc 	获取web tcp监听端口
%% @throws 	none
%% @end
%% ----------------------------------
get_web_tcp_listen_port() ->
    env:get(tcp_web_listen_port).


%% ----------------------------------
%% @doc 	初始化web url
%% @throws 	none
%% @end
%% ----------------------------------
init_game_web_url(Url) ->
    env:set(web_tcp_url, Url).
%% ----------------------------------
%% @doc 	初始化web url
%% @throws 	none
%% @end
%% ----------------------------------
get_game_web_url() ->
    env:get(web_tcp_url, "http://192.168.31.89:6160").

%% ----------------------------------
%% @doc 	初始化数据库地址
%% @throws 	none
%% @end
%% ----------------------------------
%%init_db_host(Host) ->
%%    env:set(mysql_host, util:to_list(Host)).


%% ----------------------------------
%% @doc 	获取数据库地址
%% @throws 	none
%% @end
%%%% ----------------------------------
%%get_db_host() ->
%%    env:get(mysql_host).


%% ----------------------------------
%% @doc 	初始化唯一id节点
%% @throws 	none
%% @end
%% ----------------------------------
init_unique_id_node(Node) ->
    env:set(unique_id_node, util:to_atom(Node)).

%% ----------------------------------
%% @doc 	获取唯一id节点
%% @throws 	none
%% @end
%% ----------------------------------
get_unique_id_node() ->
    env:get(unique_id_node).


%% ----------------------------------
%% @doc 	初始化唯一登录节点
%% @throws 	none
%% @end
%% ----------------------------------
init_login_server_node(Node) ->
    env:set(login_server_node, util:to_atom(Node)).

%% ----------------------------------
%% @doc 	获取唯一登录节点
%% @throws 	none
%% @end
%% ----------------------------------
get_login_server_node() ->
    env:get(login_server_node).


%% ----------------------------------
%% @doc 	初始化平台id
%% @throws 	none
%% @end
%% ----------------------------------
init_platform_id(PlatformId) when is_list(PlatformId) ->
    env:set(platform_id, PlatformId).

%% ----------------------------------
%% @doc 	获取平台id
%% @throws 	none
%% @end
%% ----------------------------------
get_platform_id() ->
    env:get(platform_id).


%%get_real_platform_id() ->
%%    case get_platform_id() of
%%        ?PLATFORM_AWY ->
%%            %% 注， 爱微游比较特殊， 爱微游和疯狂是混服， 入口不同, 区服相同
%%            get(?DICT_PLATFORM_PLATFORM_ID);
%%        PlatformId ->
%%            PlatformId
%%    end.

%% ----------------------------------
%% @doc 	初始化战区节点
%% @throws 	none
%% @end
%% ----------------------------------
init_zone_node(ZoneNode) ->
    env:set(zone_node, util:to_atom(ZoneNode)).

%% ----------------------------------
%% @doc 	获取战区节点
%% @throws 	none
%% @end
%% ----------------------------------
get_zone_node() ->
    env:get(zone_node).


%% ----------------------------------
%% @doc 	初始化充值节点
%% @throws 	none
%% @end
%% ----------------------------------
init_charge_node(ChargeNode) ->
    env:set(charge_node, util:to_atom(ChargeNode)).

%% ----------------------------------
%% @doc 	获取充值节点
%% @throws 	none
%% @end
%% ----------------------------------
get_charge_node() ->
    env:get(charge_node).


%% ----------------------------------
%% @doc 	初始化战区节点
%% @throws 	none
%% @end
%% ----------------------------------
init_war_area_node(WarAreaNode) ->
    env:set(war_area_node, util:to_atom(WarAreaNode)).

%% ----------------------------------
%% @doc 	获取战区服节点
%% @throws 	none
%% @end
%% ----------------------------------
get_war_area_node() ->
    env:get(war_area_node).


%%%% ----------------------------------
%%%% @doc 	初始世界拍卖行节点和状态
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%init_world_auction_node(WorldAuctionNode, State) ->
%%    env:set(world_auction, {WorldAuctionNode, State}).
%%
%%%% ----------------------------------
%%%% @doc 	获取世界拍卖行节点和状态
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_world_auction_node() ->
%%    env:get(world_auction).

%%%% ----------------------------------
%%%% @doc 	初始世界拍卖行游戏服列表
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%init_world_auction_game_nodes(GameNodes) ->
%%    env:set(world_auction_game_nodes, GameNodes).
%%
%%%% ----------------------------------
%%%% @doc 	获得拍卖行游戏服列表
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_world_auction_game_nodes() ->
%%    env:get(world_auction_game_nodes).


%% ----------------------------------
%% @doc 	设置开服时间
%% @throws 	none
%% @end
%% ----------------------------------
set_server_open_time(Time) ->
    env:set(server_open_time, Time).

%% ----------------------------------
%% @doc 	获取开服时间
%% @throws 	none
%% @end
%% ----------------------------------
get_server_open_time() ->
    case mod_server:is_game_server() of
        true ->
            env:get(server_open_time);
        false ->
            1483200000
    end.

%% ----------------------------------
%% @doc 	获取合服时间
%% @throws 	none
%% @end
%% ----------------------------------
get_server_merge_time() ->
    mod_server_data:get_int_data(?SERVER_DATA_SERVER_MERGE_TIME).

%%
%%%% ----------------------------------
%%%% @doc 	初始化数据库名字
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%init_db_name(DbName) ->
%%    env:set(mysql_database, util:to_list(DbName)).

%%
%%%% ----------------------------------
%%%% @doc 	获取数据库名字
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_db_name() ->
%%    env:get(mysql_database).

%% ----------------------------------
%% @doc 	设置服务器类型
%% @throws 	none
%% @end
%% ----------------------------------
init_server_type(ServerType) ->
    env:set(server_type, ServerType).

%% ----------------------------------
%% @doc 	获取服务器类型
%% @throws 	none
%% @end
%% ----------------------------------
get_server_type() ->
    env:get(server_type).

%% ----------------------------------
%% @doc 	设置是否启用机器人
%% @throws 	none
%% @end
%% ----------------------------------
set_is_create_robot(Bool) ->
    env:set(is_create_robot, Bool).

%% ----------------------------------
%% @doc 	是否启用机器人
%% @throws 	none
%% @end
%% ----------------------------------
is_create_robot() ->
    env:get(is_create_robot, false).

%% @doc fun 是否是测试服
is_test_server() ->
    env:get(is_test_server, false).

