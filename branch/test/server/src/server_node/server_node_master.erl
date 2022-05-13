%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器节点master进程
%%% @end
%%% Created : 30. 六月 2016 下午 2:54
%%%-------------------------------------------------------------------
-module(server_node_master).

-behaviour(gen_server).
%% API
-export([
    start_link/0,
    join/1,                      %% 加入中心服
    get_node_run_state/1             %% 获取节点状态
]).

%% CALLBACK
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-include("gen/db.hrl").
-include("system.hrl").
-include("common.hrl").

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ----------------------------------
%% @doc 	加入中心服
%% @throws 	none
%% @end
%% ----------------------------------
join(AtomNode) ->
    ?SERVER ! {join, AtomNode}.

%% ----------------------------------
%% @doc 	获取节点状态
%% @throws 	none
%% @end
%% ----------------------------------
get_node_run_state(AtomNode) ->
    ServerNode = mod_server:get_server_node(AtomNode),
    ServerNode#db_c_server_node.run_state.

init(_) ->
    self() ! async_init,
    {ok, noop}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({join, AtomNode}, State) ->
    ?TRY_CATCH2(handle_join(AtomNode)),
    {noreply, State};
handle_info({nodedown, AtomNode}, State) ->
    ?TRY_CATCH2(handle_node_down(AtomNode)),
    {noreply, State};
handle_info(async_init, State) ->
    handle_async_init(),
    {noreply, State};
handle_info(_Request, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    State.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%===================================================================
%%% Internal functions
%%%===================================================================

%% ----------------------------------
%% @doc 	节点加入
%% @throws 	none
%% @end
%% ----------------------------------
handle_join(AtomNode) ->
    case mod_server:get_server_node(AtomNode) of
        null ->
            ?ERROR("Unknown node join!!! ~p", [AtomNode]);
        ServerNode ->
            if ServerNode#db_c_server_node.run_state == ?NODE_RUN_STATE_RUNNING ->
                ?INFO("Node already join: ~p", [AtomNode]);
                true ->
                    erlang:monitor_node(AtomNode, true),
                    mod_server_mgr:set_node_run_state(AtomNode, ?NODE_RUN_STATE_RUNNING),
                    ?INFO("Node join: ~p", [AtomNode])
            end
    end.

handle_node_down(AtomNode) ->
    ?INFO("Node down: ~p", [AtomNode]),
    case mod_server:get_server_node(AtomNode) of
        null ->
            ?ERROR("Node down !!! Node  no found => ~p", [AtomNode]);
        _ ->
            mod_server_mgr:set_node_run_state(AtomNode, ?NODE_RUN_STATE_DISCONNECT)
    end.

%% ----------------------------------
%% @doc 	异步连接所有节点
%% @throws 	none
%% @end
%% ----------------------------------
handle_async_init() ->
    [
        begin
            if ServerNode#db_c_server_node.run_state =/= ?NODE_RUN_STATE_DISCONNECT ->
                mod_server_mgr:set_node_run_state(ServerNode#db_c_server_node.node, ?NODE_RUN_STATE_DISCONNECT);
                true ->
                    noop
            end
        end
        ||
        ServerNode <- mod_server:get_server_node_list()
    ],
    mod_server_rpc:cast_all_node(server_node_slave, join, []).
