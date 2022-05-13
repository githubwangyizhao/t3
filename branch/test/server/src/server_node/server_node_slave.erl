%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器节点 slave进程
%%% @end
%%% Created : 30. 六月 2016 下午 2:54
%%%-------------------------------------------------------------------
-module(server_node_slave).

-behaviour(gen_server).
%% API
-export([
    start_link/0,
    join/0,
    sync/0        %% 下拉数据
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
%% @doc     下拉数据
%% @throws 	none
%% @end
%% ----------------------------------
sync() ->
    ?SERVER ! sync.

%% ----------------------------------
%% @doc     加入集群
%% @throws 	none
%% @end
%% ----------------------------------
join() ->
    ?SERVER ! join.

init(_) ->
    {ok, null}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.
handle_info(sync, State) ->
    ?TRY_CATCH(mod_server_sync:pull()),
    {noreply, State};
handle_info(join, State) ->
    ?TRY_CATCH(mod_server:join_center()),
    {noreply, State};
handle_info(_Request, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    State.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

