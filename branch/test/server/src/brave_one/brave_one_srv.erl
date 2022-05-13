%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% @end
%%% Created : 10. 3月 2021 下午 11:07:58
%%%-------------------------------------------------------------------
-module(brave_one_srv).
-author("Administrator").

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
    call/1      % 同步消息
]).

-include("common.hrl").
-include("brave_one.hrl").

-define(SERVER, ?MODULE).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    {ok, noop}.

%% 同步消息
call(CallTuple) ->
    mod_server_rpc:gen_server_call_war(?SERVER, CallTuple).
%%    gen_server:call()

handle_call({?BRAVE_ONE_INFO_LIST, Tuple}, _From, State) ->
    Result = ?TRY_CATCH2(brave_one_srv_mod:get_info_list_srv(Tuple)),
    {reply, Result, State};
handle_call({?BRAVE_ONE_CREATE, Tuple}, _From, State) ->
    Result = ?TRY_CATCH2(brave_one_srv_mod:create_srv(Tuple)),
    {reply, Result, State};
handle_call({?BRAVE_ONE_ENTER, Tuple}, _From, State) ->
    Result = ?TRY_CATCH2(brave_one_srv_mod:enter_srv(Tuple)),
    {reply, Result, State};
handle_call({?BRAVE_ONE_CLEAN, Tuple}, _From, State) ->
    Result = ?TRY_CATCH2(brave_one_srv_mod:clean_srv(Tuple)),
    {reply, Result, State};
handle_call({?BRAVE_ONE_GET_WORKER, Tuple}, _From, State) ->
    Result = ?TRY_CATCH2(brave_one_srv_mod:get_mission_worker(Tuple)),
    {reply, Result, State};
handle_call(_, _From, State) ->
    {reply, State, State}.

handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({'DOWN', MonitorRef, process, _SceneWorker, _Reason}, State) ->
    case get({?BRAVE_ONE_MISSION_MONITOR_REF, MonitorRef}) of
        #dict_brave_one{main_player_id = MainPlayerId, fight_player_id = FightPlayerId} ->
            ?TRY_CATCH(brave_one_srv_mod:clean_brave_one_data(MainPlayerId, FightPlayerId)),
            erase({?BRAVE_ONE_MISSION_MONITOR_REF, MonitorRef});
        _ ->
            noop
    end,
    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

terminate(_, State) ->
    State.