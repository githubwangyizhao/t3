%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         推广
%%% @end
%%% Created : 25. 十一月 2020 下午 06:08:11
%%%-------------------------------------------------------------------
-module(promote_srv).
-author("Administrator").

-behaviour(gen_server).

-include("promote.hrl").
-include("common.hrl").

%% API
-export([start_link/0]).

-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([
    call/1,
    cast/1,
    rpc_call/2
]).

-export([
    call_do_deal_invite/5,
    cast_do_deal_invite/5
]).

-define(SERVER, ?MODULE).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

call(Request) ->
    gen_server:call({?MODULE, mod_server_config:get_center_node()}, Request).

cast(Request) ->
    gen_server:cast({?MODULE, mod_server_config:get_center_node()}, Request).

rpc_call(Function, Args) ->
    rpc:call(mod_server_config:get_center_node(), promote_srv_mod, Function, Args).

try_get_result(Fun) ->
    try Fun()
    catch
        _:_Reason_ ->
            ?ERROR("错误~p", [{_Reason_, erlang:get_stacktrace()}]),
            %% 用DOWN的话上面的call就不用自己写捕捉错误了
%%            {'DOWN', _Reason_}
            {'EXIT', _Reason_}
    end.
call_do_deal_invite(PlatformId, PlayerId, SharePlayerId, AccId, NickName) ->
    gen_server:call({?MODULE, mod_server_config:get_center_node()}, {?PROMOTE_DO_DEAL_INVITE, PlatformId, PlayerId, SharePlayerId, AccId, NickName}).
cast_do_deal_invite(PlatformId, PlayerId, SharePlayerId, AccId, NickName) ->
    gen_server:cast({?MODULE, mod_server_config:get_center_node()}, {?PROMOTE_DO_DEAL_INVITE, PlatformId, PlayerId, SharePlayerId, AccId, NickName}).

handle_call({?PROMOTE_DO_DEAL_INVITE, PlatformId, PlayerId, SharePlayerId, AccId, NickName}, _From, State) ->
    Result = try_get_result(fun() ->
        promote_srv_mod:handle_do_deal_invite(PlatformId, AccId, PlayerId, SharePlayerId, NickName) end),
    {reply, Result, State};
handle_call({?PROMOTE_GET_AWARD, PlatformId, AccId, PlayerId, ServerId}, _From, State) ->
    Result = try_get_result(fun() ->
        promote_srv_mod:handle_get_award(PlatformId, AccId, PlayerId, ServerId) end),
    {reply, Result, State};
handle_call({?PROMOTE_GET_RECORD_LIST, PlatformId, AccId}, _From, State) ->
    Result = try_get_result(fun() ->
        promote_srv_mod:handle_get_record_list(PlatformId, AccId) end),
    {reply, Result, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({?PROMOTE_DO_DEAL_INVITE, PlatformId, PlayerId, SharePlayerId, AccId, NickName}, State) ->
    try_get_result(fun() ->
        promote_srv_mod:handle_do_deal_invite(PlatformId, AccId, PlayerId, SharePlayerId, NickName) end),
    {noreply, State};
handle_cast({?PROMOTE_CHARGE, PlatformId, PlayerName, AccId, Mana, VipExp}, State) ->
    try_get_result(fun() ->
        promote_srv_mod:handle_charge(PlatformId, PlayerName, AccId, Mana, VipExp) end),
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
