%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            唯一id服务器
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(unique_id_srv).

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    get_unique_id/1
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).
-include("common.hrl").
-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_unique_id(UniqueIdType) ->
    gen_server:call(?SERVER, {get_unique_id, UniqueIdType}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    {ok, #state{}}.

handle_call({get_unique_id, UniqueIdType}, _From, State) ->
    try unique_id:get_next_unique_id(UniqueIdType) of
        UniqueId ->
            {reply, {ok, UniqueId}, State}
    catch
        _:Reason ->
            ?ERROR("get_unique_id error:~p ~n", [{UniqueIdType, Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%handle_get_unique_player_id() ->
%%    UniqueId =
%%        case mod_server_data:get_server_data(?SERVER_DATA_UNIQUE_PLAYER_ID) of
%%            null ->
%%                mod_server_data:set_server_data(?SERVER_DATA_UNIQUE_PLAYER_ID, 1),
%%                1;
%%            ServerData ->
%%                #server_data{data = Data} = ServerData,
%%                Tran = fun() ->
%%                    game_db:write(ServerData#server_data{data = Data + 1})
%%                       end,
%%                game_db:do(Tran),
%%                Data + 1
%%        end,
%%    UniqueId.
