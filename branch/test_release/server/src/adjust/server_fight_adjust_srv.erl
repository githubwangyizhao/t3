%%%%%-------------------------------------------------------------------
%%%%% @author Administrator
%%%%% @copyright (C) 2021, <COMPANY>
%%%%% @doc
%%%%%
%%%%% @end
%%%%% Created : 17. 7月 2021 下午 04:03:13
%%%%%-------------------------------------------------------------------
-module(server_fight_adjust_srv).
%%-author("Administrator").
%%
%%-behaviour(gen_server).
%%
%%-include("common.hrl").
%%-include("system.hrl").
%%
%%%% API
%%-export([start_link/0]).
%%
%%%% gen_server callbacks
%%-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
%%    code_change/3]).
%%
%%-export([
%%    call/1,
%%    cast/1,
%%    rpc_call/2
%%]).
%%
%%-define(SERVER, ?MODULE).
%%
%%-record(server_fight_adjust_srv_state, {}).
%%
%%start_link() ->
%%    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
%%
%%call(Request) ->
%%    gen_server:call(?MODULE, Request).
%%
%%cast(Request) ->
%%    gen_server:cast(?MODULE, Request).
%%
%%rpc_call(Function, Args) ->
%%    rpc:call(node(), server_fight_adjust, Function, Args).
%%
%%try_get_result(Fun) ->
%%    try Fun()
%%    catch
%%        _:_Reason_ ->
%%            ?DEBUG("错误~p", [{_Reason_, erlang:get_stacktrace()}]),
%%            {'EXIT', _Reason_}
%%    end.
%%
%%init([]) ->
%%    {ok, #server_fight_adjust_srv_state{}}.
%%
%%handle_call(_Request, _From, State = #server_fight_adjust_srv_state{}) ->
%%    {reply, ok, State}.
%%
%%handle_cast({add_award, PropId, Num}, State) ->
%%    try_get_result(fun() ->
%%        server_fight_adjust:handle_add_award(PropId, Num) end),
%%    {noreply, State};
%%handle_cast({add_cost, PropId, Num}, State) ->
%%    try_get_result(fun() ->
%%        server_fight_adjust:handle_add_cost(PropId, Num) end),
%%    {noreply, State};
%%handle_cast(_Request, State = #server_fight_adjust_srv_state{}) ->
%%    {noreply, State}.
%%
%%handle_info(_Info, State = #server_fight_adjust_srv_state{}) ->
%%    {noreply, State}.
%%
%%terminate(_Reason, _State = #server_fight_adjust_srv_state{}) ->
%%    ok.
%%
%%code_change(_OldVsn, State = #server_fight_adjust_srv_state{}, _Extra) ->
%%    {ok, State}.
