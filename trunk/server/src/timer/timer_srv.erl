%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            通用定时器
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(timer_srv).

-behaviour(gen_server).
-include("timer.hrl").
%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {ref, status}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?TIME_SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    Ref = mod_timer:init(),
    {ok, #state{ref = Ref, status = true}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({apply, Timer, ClockTimestamp, Ref}, State = #state{ref = ThisRef, status = Status}) ->
    if Status == true andalso ThisRef == Ref ->
        case catch mod_timer:handle_apply_timer(Timer, ClockTimestamp, Ref) of
            {'EXIT', Reason} ->
                logger:error("apply timer error: ~p, ~p", [Timer, Reason]);
            _ ->
                ok
        end;
        true ->
            noop
    end,
    {noreply, State};
handle_info(reload, State) ->
    NewRef = mod_timer:init(),
    {noreply, State#state{ref = NewRef}};
handle_info(start, State) ->
    {noreply, State#state{status = true}};
handle_info(stop, State) ->
    {noreply, State#state{status = false}};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
