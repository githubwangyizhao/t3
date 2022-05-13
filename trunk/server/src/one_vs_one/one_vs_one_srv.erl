%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(one_vs_one_srv).

-behaviour(gen_server).

-include("system.hrl").
-include("one_vs_one.hrl").
-include("common.hrl").

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
    code_change/3]).

-export([
    call/1,
    cast/1
]).

-define(SERVER, ?MODULE).

-record(one_vs_one_srv_state, {}).

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
run(Result) ->
    lists:foreach(
        fun({Type}) ->
            UpdateRoomDataList = util:get_dict({update_room_data_list, Type}, []),
            if
                UpdateRoomDataList =/= [] ->
                    ThisPlayerList = util:get_dict({player_list, Type}, []),
                    lists:foreach(
                        fun({{PlatformId, ServerId}, PlayerIdList}) ->
                            if
                                PlayerIdList =/= [] ->
                                    NoticeRoomDataList =
                                        lists:map(
                                            fun(RoomData) ->
                                                #ets_one_vs_one_room_data{
                                                    room_id = RoomId,
                                                    player_list = PlayerList
                                                } = RoomData,
                                                ModelHeadFigureList = [ModelHeadFigure || {_, ModelHeadFigure} <- PlayerList],
%%                                                ?DEBUG("Data : ~p",[{RoomId, ModelHeadFigureList}]),
                                                api_one_vs_one:pack_pb_one_vs_one_room_data(RoomId, ModelHeadFigureList)
                                            end,
                                            UpdateRoomDataList
                                        ),
%%                                    ?DEBUG("Data : ~p",[NoticeRoomDataList]),
                                    mod_server_rpc:cast_game_server(PlatformId, ServerId, api_one_vs_one, notice_update_room_list, [PlayerIdList, Type, NoticeRoomDataList]);
                                true ->
                                    noop
                            end
                        end,
                        ThisPlayerList
                    ),
                    put({update_room_data_list, Type}, []);
                true ->
                    noop
            end
        end,
        t_bettle:get_keys()
    ),
    Result.

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    ets:new(ets_one_vs_one_room_data, ?ETS_INIT_ARGS(#ets_one_vs_one_room_data.row_key)),
    one_vs_one_srv_mod:try_everyday_balance(),
    {ok, #one_vs_one_srv_state{}}.

handle_call({get_room_list, PlayerId, PlatformId, ServerId, Type}, _From, State = #one_vs_one_srv_state{}) ->
    Result = ?CATCH(run(one_vs_one_srv_mod:handle_get_room_list(PlayerId, PlatformId, ServerId, Type))),
    {reply, Result, State};
handle_call({exit_room_list, PlayerId}, _From, State = #one_vs_one_srv_state{}) ->
    Result = ?CATCH(run(one_vs_one_srv_mod:handle_exit_room_list(PlayerId))),
    {reply, Result, State};
handle_call({join_room, PlayerId, ModelHeadFigure, Type, RoomId}, _From, State = #one_vs_one_srv_state{}) ->
    Result = ?CATCH(run(one_vs_one_srv_mod:handle_join_room(PlayerId, ModelHeadFigure, Type, RoomId))),
    {reply, Result, State};
handle_call(_Request, _From, State = #one_vs_one_srv_state{}) ->
    ?DEBUG("unread msg : ~p", [_Request]),
    {reply, ok, State}.

handle_cast({balance, Type, RoomId, RankList}, State = #one_vs_one_srv_state{}) ->
    ?CATCH(run(one_vs_one_srv_mod:handle_balance(Type, RoomId, RankList))),
    {noreply, State};
handle_cast({exit_room_list, PlayerId}, State = #one_vs_one_srv_state{}) ->
    ?CATCH(run(one_vs_one_srv_mod:handle_exit_room_list(PlayerId))),
    {noreply, State};
handle_cast(_Request, State = #one_vs_one_srv_state{}) ->
    {noreply, State}.

handle_info({everyday_balance, BalanceConfigTime}, State) ->
    Now = util_time:timestamp(),
    erlang:send_after((BalanceConfigTime - Now) * ?SECOND_MS, self(), {everyday_balance, BalanceConfigTime + ?DAY_S}),
    one_vs_one_srv_mod:everyday_balance(BalanceConfigTime),
    {noreply, State};
handle_info(_Info, State = #one_vs_one_srv_state{}) ->
    {noreply, State}.

terminate(_Reason, _State = #one_vs_one_srv_state{}) ->
    ok.

code_change(_OldVsn, State = #one_vs_one_srv_state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================