%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器更新 模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_update).

-include("common.hrl").
-include("system.hrl").
-include("gen/db.hrl").

%% 中心服调用
-export([
    update_all_web_node/2,
    update_all_game_node/2,
    update_all_zone_node/2,
%%    update_all_world_auction_node/2,
    update_node_list/3
]).

%% 本服调用
-export([
    hot_update/0           %% 热更新
%%    cold_update/1          %% 冷更新
]).

%% 更新类型
-define(UPDATE_TYPE_HOT, hot).  %% 热更新
-define(UPDATE_TYPE_COLD, cold).%% 冷更新


%% ----------------------------------
%% @doc 	更新所有节点
%% @throws 	none
%% @end
%% ----------------------------------
%%update_all_node(Version, UpdateType) ->
%%    ServerNodeList = mod_server:get_server_node_list(),
%%    update_server_node_list(ServerNodeList, Version, UpdateType).

%% ----------------------------------
%% @doc 	更新web节点
%% @throws 	none
%% @end
%% ----------------------------------
update_all_web_node(Version, UpdateType) ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_LOGIN_SERVER),
    update_server_node_list(ServerNodeList, Version, UpdateType).

%% ----------------------------------
%% @doc 	更新游戏服节点
%% @throws 	none
%% @end
%% ----------------------------------
update_all_game_node(Version, UpdateType) ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_GAME),
    update_server_node_list(ServerNodeList, Version, UpdateType).

%% ----------------------------------
%% @doc 	更新跨服节点
%% @throws 	none
%% @end
%% ----------------------------------
update_all_zone_node(Version, UpdateType) ->
    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_WAR_ZONE),
    update_server_node_list(ServerNodeList, Version, UpdateType).

%%%% ----------------------------------
%%%% @doc 	更新世界拍卖行节点
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%update_all_world_auction_node(Version, UpdateType) ->
%%    ServerNodeList = mod_server:get_server_node_list(?SERVER_TYPE_WORLD_AUCTION),
%%    update_server_node_list(ServerNodeList, Version, UpdateType).

check_update_type(UpdateType) ->
    ?ASSERT(UpdateType == ?UPDATE_TYPE_HOT orelse UpdateType == ?UPDATE_TYPE_COLD, update_type_error).

update_server_node_list(ServerNodeList, Version, UpdateType) when is_list(Version) ->
    NodeList = lists:foldl(
        fun(ServerNode, Tmp) ->
            #db_c_server_node{
                node = StrNode,
                type = Type
            } = ServerNode,
            if
            %%  唯一id 服 不更新
                Type == ?SERVER_TYPE_UNIQUE_ID ->
                    ?WARNING("Ingore node:~p", [ServerNode]),
                    Tmp;
                true ->
                    AtomNode = util:to_atom(StrNode),
                    [AtomNode | Tmp]
            end
        end,
        [],
        ServerNodeList
    ),
    update_node_list(NodeList, Version, UpdateType).

%% ----------------------------------
%% @doc 	更新节点
%% @throws 	none
%% @end
%% ----------------------------------
update_node_list(NodeList, Version, UpdateType) when is_list(NodeList)->
    ?ASSERT(mod_server:is_center_server() == true),
    check_update_type(UpdateType),
    {M, F, A} =
        case UpdateType of
            ?UPDATE_TYPE_HOT ->
                {?MODULE, hot_update, [Version]};
            ?UPDATE_TYPE_COLD ->
                {?MODULE, cold_update, [Version]}
        end,
    mod_server_rpc:batch_rpc_node_list(NodeList, M, F, A).

%% ----------------------------------
%% @doc 	热更新
%% @throws 	none
%% @end
%% ----------------------------------
hot_update() ->
    reloader:reload_changes(),
    version:update(),
    ok.


%%%% ----------------------------------
%%%% @doc 	冷更新
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%cold_update(Version) when is_list(Version) ->
%%    game:stop(true),
%%    Cmd = io_lib:format("./do-patch.sh ~s true", [Version]),
%%    CmdOut = os:cmd(Cmd),
%%        catch io:format("cold_update ~p cmd out:~n~ts~n", [node(), CmdOut]),
%%    reloader:reload_changes(),
%%    game:start(),
%%    ok.
