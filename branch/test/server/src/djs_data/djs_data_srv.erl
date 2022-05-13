%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 26. 九月 2018 14:32
%%%-------------------------------------------------------------------
-module(djs_data_srv).
-author("home").

%% API
-export([
    start_link/0,
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2
]).

-export([
    cast/1,             %% 异步请求
    call/1,             %% 同步请求
    call_sell/1         %% 同步兑换
]).

-include("common.hrl").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%    proc_lib:start_link(?MODULE, init, []).

init(_) ->
    {ok, null}.

call(Request) ->
    gen_server:call(?MODULE, Request).

cast(Request) ->
    gen_server:cast(?MODULE, Request).

%% @fun 同步兑换
call_sell(Param) ->
    gen_server:call(?MODULE, {djs_sell, Param}).


handle_call({djs_sell, Param}, _From, State) ->
    Result = ?TRY_CATCH(mod_djs_data:srv_djs_sell(Param)),
    {reply, Result, State};
handle_call({insert_access_token, Param}, _From, State) ->
    Result = ?TRY_CATCH(access_token_handler:insert_access_token(Param)),
    {reply, Result, State};
handle_call(_, _From, State) ->
    {reply, State, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.

terminate(_, State) ->
    State.
