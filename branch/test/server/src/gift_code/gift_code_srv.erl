%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         礼包码进程
%%% @end
%%% Created : 11. 8月 2021 上午 09:56:50
%%%-------------------------------------------------------------------
-module(gift_code_srv).

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
    call/1,
    cast/1
]).

-include("common.hrl").

-record(state, {}).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    {ok, #state{}}.

call(Request) ->
    case gen_server:call({?MODULE, mod_server_config:get_center_node()}, Request) of
        {'EXIT', Reason} ->
            exit(Reason);
        Result ->
            Result
    end.

cast(Request) ->
    gen_server:cast({?MODULE, mod_server_config:get_center_node()}, Request).

handle_call({get_gift_code_info, GiftCode}, _From, State) ->
    {reply, ?CATCH(mod_gift_code:handle_get_gift_code_info(GiftCode)), State};
handle_call({use_gift_code, GiftCode}, _From, State) ->
    {reply, ?CATCH(mod_gift_code:handle_use_gift_code(GiftCode)), State};
handle_call(_Request, _From, State) ->
    ?WARNING("no match call:~p", [_Request]),
    {reply, null, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_, State) ->
    {noreply, State}.

terminate(_, State) ->
    State.
