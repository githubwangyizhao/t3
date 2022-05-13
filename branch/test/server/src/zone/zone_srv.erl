%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            跨服节点控制服务器
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(zone_srv).

-behaviour(gen_server).
-include("common.hrl").
%% API
-export([
    start_link/0,
    join/1,
    get_join_node_list/0
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

join(AtomNode) ->
    gen_server:call(?SERVER, {join, AtomNode}).


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    self() ! async_init,
    {ok, #state{}}.

handle_call({join, AtomNode}, _From, State) ->
    handle_join(AtomNode, State),
    {reply, ok, State};
handle_call(_Request, _From, State) ->
    ?WARNING("未知消息:~p", [_Request]),
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({nodedown, AtomNode}, State) ->
   handle_node_down(AtomNode, State),
    {noreply, State};
handle_info(async_init, State) ->
    handle_async_init(),
    {noreply, State};
handle_info(_Info, State) ->
    ?WARNING("未知消息:~p", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% ----------------------------------
%% @doc 	获取加入的节点列表
%% @throws 	none
%% @end
%% ----------------------------------
get_join_node_list() ->
    mod_cache:get(?CACHE_JOIN_ZONE_NODE_LIST, []).
%%    case ets:lookup(?ETS_ZONE_CACHE_DATA, 0) of
%%        [] ->
%%            [];
%%        [R] ->
%%            R#ets_zone_cache_data.data
%%    end.

%% ----------------------------------
%% @doc 	更新加入的节点列表
%% @throws 	none
%% @end
%% ----------------------------------
update_join_node_list(List) ->
    mod_cache:update(?CACHE_JOIN_ZONE_NODE_LIST, List).
%%    ets:insert(?ETS_ZONE_CACHE_DATA, #ets_zone_cache_data{
%%        id = 0,
%%        data = List
%%    }).

%% ----------------------------------
%% @doc 	节点加入
%% @throws 	none
%% @end
%% ----------------------------------
handle_join(AtomNode, State = #state{}) ->
    NodeList = get_join_node_list(),
    case lists:member(AtomNode, NodeList) of
        true ->
            ?ERROR("节点已经加入跨服:~p", [AtomNode]),
            State;
        false ->
            ?INFO("节点加入跨服:~p", [AtomNode]),
            erlang:monitor_node(AtomNode, true),
            update_join_node_list([AtomNode | NodeList])
    end.

%% ----------------------------------
%% @doc 	节点down
%% @throws 	none
%% @end
%% ----------------------------------
handle_node_down(AtomNode, #state{}) ->
    ?INFO("节点down:~p", [AtomNode]),
    NodeList = get_join_node_list(),
    update_join_node_list(lists:delete(AtomNode, NodeList)).


%% ----------------------------------
%% @doc 	异步连接所有节点
%% @throws 	none
%% @end
%% ----------------------------------
handle_async_init() ->
%%    mod_server_rpc:gen_server_call_zone(?MODULE, join),
    mod_server_rpc:cast_all_game_server(mod_server, join_zone, []).
