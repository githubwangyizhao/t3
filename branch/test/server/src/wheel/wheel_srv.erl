%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(wheel_srv).

-behaviour(gen_server).

-include("system.hrl").
-include("wheel.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
    code_change/3]).

-export([
    call/1,
    cast/1
]).

-define(SERVER, ?MODULE).

-record(wheel_srv_state, {}).

call(Request) ->
    CallNode =
        case mod_server_config:get_server_type() of
            ?SERVER_TYPE_WAR_AREA ->
                ?MODULE;
            ?SERVER_TYPE_GAME ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode}
        end,
    case catch gen_server:call(CallNode, Request) of
        {'EXIT', Reason} ->
            exit(Reason);
        Result ->
            Result
    end.

cast(Request) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_WAR_AREA ->
            gen_server:cast(?MODULE, Request);
        ?SERVER_TYPE_GAME ->
            WarNode = mod_server_config:get_war_area_node(),
            gen_server:cast({?MODULE, WarNode}, Request)
    end.

%%call(Request) ->
%%    gen_server:call(?MODULE, Request).
%%
%%cast(Request) ->
%%    gen_server:cast(?MODULE, Request).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    wheel_srv_mod:init(),
    {ok, #wheel_srv_state{}}.

handle_call({?WHEEL_MSG_JOIN_WHEEL, PlayerId, Type, PlatformId, ServerId, ModelHeadFigure}, _From, State = #wheel_srv_state{}) ->
    Result = ?CATCH(wheel_srv_mod:handle_join_wheel(PlayerId, Type, PlatformId, ServerId, ModelHeadFigure)),
    {reply, Result, State};
handle_call({?WHEEL_MSG_BET, PlayerId, BetId, Num}, _From, State = #wheel_srv_state{}) ->
    Result = ?CATCH(wheel_srv_mod:handle_bet(PlayerId, BetId, Num)),
    {reply, Result, State};
handle_call({?WHEEL_MSG_GET_PLAYER_LIST, WheelType}, _From, State = #wheel_srv_state{}) ->
    Result = ?CATCH(wheel_srv_mod:handle_get_player_list(WheelType)),
    {reply, Result, State};
handle_call({?WHEEL_MSG_GET_LAST_BET_LIST, PlayerId}, _From, State = #wheel_srv_state{}) ->
    Result = ?CATCH(wheel_srv_mod:get_last_bet_list(PlayerId)),
    {reply, Result, State};
handle_call({?WHEEL_MSG_USE_LAST_BET_LIST, PlayerId, LastBetList}, _From, State = #wheel_srv_state{}) ->
    Result = ?CATCH(wheel_srv_mod:use_last_bet_list(PlayerId, LastBetList)),
    {reply, Result, State};
handle_call(_Request, _From, State = #wheel_srv_state{}) ->
    {reply, ok, State}.

handle_cast({?WHEEL_MSG_EXIT_WHEEL, PlayerId}, State = #wheel_srv_state{}) ->
    ?CATCH(wheel_srv_mod:handle_exit_wheel(PlayerId)),
    {noreply, State};
handle_cast(clear_record, State = #wheel_srv_state{}) ->
    ?CATCH(wheel_srv_mod:handle_clear_record()),
    {noreply, State};
handle_cast(_Request, State = #wheel_srv_state{}) ->
    {noreply, State}.

handle_info({?WHEEL_MSG_BALANCE, WheelType}, State = #wheel_srv_state{}) ->
    ?CATCH(wheel_srv_mod:handle_balance(WheelType)),
    {noreply, State};
handle_info(_Info, State = #wheel_srv_state{}) ->
    {noreply, State}.

terminate(_Reason, _State = #wheel_srv_state{}) ->
    ok.

code_change(_OldVsn, State = #wheel_srv_state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
