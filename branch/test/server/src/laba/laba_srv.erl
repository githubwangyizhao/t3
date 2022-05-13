%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		拉霸服务进程
%%% @end
%%% Created : 11. 11月 2021 10:30
%%%-------------------------------------------------------------------
-module(laba_srv).
-author("yizhao.wang").

-behaviour(gen_server).
-include("common.hrl").
-include("laba.hrl").

%% API
-export([start_link/0]).

-export([cast/1, call/1]).

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
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

cast(Msg) ->
	gen_server:cast(?SERVER, Msg).

call(Msg) ->
	gen_server:call(?SERVER, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_LABA_PLAYER_DATA, ?ETS_INIT_ARGS(#ets_laba_player_data.player_id)),
	ets:new(?ETS_LABA_DATA, ?ETS_INIT_ARGS(#ets_laba_data.key)),
	clock_clear_timeout_player(),
	{ok, #state{}}.

handle_call({join, PlayerId, ClientWorker, LaBaId, CostRate}, _From, State) ->
	?TRY_CATCH(laba_handle:handle_player_join(PlayerId, ClientWorker, LaBaId, CostRate)),
	{reply, ok, State};
handle_call(_Request, _From, State) ->
	?ERROR("unkown call request ~p", [_Request]),
	{reply, ok, State}.

handle_cast({leave, PlayerId}, State) ->
	?TRY_CATCH(laba_handle:handle_player_leave(PlayerId)),
	{noreply, State};
handle_cast({update_pool, LaBaId, CostRate, PoolChangeVal}, State) ->
	?TRY_CATCH(laba_handle:handle_update_laba_data(LaBaId, CostRate, PoolChangeVal)),
	{noreply, State};
handle_cast(_Request, State) ->
	?ERROR("unkown cast request ~p", [_Request]),
	{noreply, State}.

handle_info({'DOWN', _Ref, process, ClientWorker, _Reason}, State) ->
	PlayerId = get(ClientWorker),
	?TRY_CATCH(laba_handle:handle_player_leave(PlayerId)),
	{noreply, State};
handle_info(clear_timeout_player, State) ->
	clock_clear_timeout_player(),
	?TRY_CATCH(laba_handle:clear_timeout_player()),
	{noreply, State};
handle_info(_Info, State) ->
	?ERROR("unkown info ~p", [_Info]),
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
clock_clear_timeout_player() ->
	erlang:send_after(5*1000, self(), clear_timeout_player).
