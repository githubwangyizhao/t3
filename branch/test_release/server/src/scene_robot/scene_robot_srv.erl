%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 一月 2021 下午 05:59:24
%%%-------------------------------------------------------------------
-module(scene_robot_srv).
-author("Administrator").

-behaviour(gen_server).

%% API
-export([start_link/0]).

-include("common.hrl").

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-export([
    call/1,
    cast/1
]).

-define(SERVER, ?MODULE).

-record(state, {}).


start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

call(Request) ->
    case gen_server:call(?MODULE, Request) of
        {'EXIT', _Reason_} ->
            exit(_Reason_);
        Result ->
            Result
    end.

cast(Request) ->
    gen_server:cast(?MODULE, Request).

try_get_result(Fun) ->
    try Fun()
    catch
        _:_Reason_ ->
            ?DEBUG("错误~p", [{_Reason_, erlang:get_stacktrace()}]),
            %% 用DOWN的话上面的call就不用自己写捕捉错误了
%%            {'DOWN', _Reason_}
            {'EXIT', _Reason_}
    end.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({update, ObjActor}, State) ->
    try_get_result(fun() -> mod_robot_player_scene_cache:handle_update(ObjActor) end),
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.