%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动进程
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_srv).

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    cast/1,
    cast/2,
    call/1,
    call/2,
    send/1,
    send/2
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
-include("common.hrl").
-include("activity.hrl").
%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

call(Msg) ->
    gen_server:call(?ACTIVITY_SRV, Msg).

call(Node, Msg) ->
    gen_server:call({?ACTIVITY_SRV, Node}, Msg).

cast(Msg) ->
    gen_server:cast(?ACTIVITY_SRV, Msg).

cast(Node, Msg) ->
    gen_server:cast({?ACTIVITY_SRV, Node}, Msg).

send(Msg) ->
    erlang:send(?ACTIVITY_SRV, Msg).

send(Node, Msg) ->
    erlang:send({?ACTIVITY_SRV, Node}, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    activity_handle:init(),
    {ok, #state{}}.

handle_call(?ACTIVITY_MSG_PULL_ACTIVITY, _From, State) ->
    {reply, ?CATCH(activity_sync:get_war_activity_list()), State};
handle_call(_Request, _From, State) ->
    ?WARNING("unexpect call:~p", [_Request]),
    {reply, ok, State}.

handle_cast({?ACTIVITY_MSG_DEBUG_OPEN, ActivityId, OpenTime, CloseTime}, State) ->
    ?CATCH(activity_handle:handle_debug_open(ActivityId, OpenTime, CloseTime)),
    {noreply, State};
handle_cast({?ACTIVITY_MSG_CLEAN_DEBUG, ActivityId}, State) ->
    ?CATCH(activity_handle:handle_clean_debug(ActivityId)),
    {noreply, State};
handle_cast({?ACTIVITY_MSG_CLOSE_ACTIVITY, ActivityId}, State) ->
    ?CATCH(activity_handle:handle_close_activity(ActivityId, util_time:timestamp())),
    {noreply, State};
handle_cast(_Request, State) ->
    ?WARNING("unexpect cast:~p", [_Request]),
    {noreply, State}.

handle_info(?ACTIVITY_MSG_CLOCK, State) ->
    ?CATCH(activity_handle:handle_clock()),
    {noreply, State};
handle_info({?ACTIVITY_MSG_PUSH_ACTIVITY, ActivityInfoList, IsReset}, State) ->
    ?CATCH(activity_sync:handle_receive_war_push(ActivityInfoList, IsReset)),
    {noreply, State};
handle_info(?ACTIVITY_MSG_CLOCK_PUSH, State) ->
    ?CATCH(activity_sync:handle_clock_push()),
    {noreply, State};
handle_info(_Info, State) ->
    ?WARNING("unexpect info:~p", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
