%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2021 下午 05:02:13
%%%-------------------------------------------------------------------
-module(one_vs_one_srv_mod).
-author("Administrator").

-include("common.hrl").
-include("one_vs_one.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("p_message.hrl").

%% API
-export([
    handle_get_room_list/4,
    handle_exit_room_list/1,
    handle_join_room/4,
    handle_balance/3,
    try_everyday_balance/0,
    everyday_balance/1
]).

-export([
    get_t_bettle/1
]).

-export([dict_select/2]).

handle_get_room_list(PlayerId, PlatformId, ServerId, Type) ->
    NewPlayerData =
        #one_vs_one_player_data{
            player_id = PlayerId,
            type = Type,
            room_id = 0,
            platform_id = PlatformId,
            server_id = ServerId
        },
    IsStart =
        case dict_select(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId) of
            null ->
                false;
            PlayerData ->
                #one_vs_one_player_data{
                    type = PlayerType,
                    room_id = PlayerRoomId
                } = PlayerData,
                case ets_select(ets_one_vs_one_room_data, {PlayerType, PlayerRoomId}) of
                    null ->
                        false;
                    PlayerRoomData ->
                        #ets_one_vs_one_room_data{
                            scene_worker = SceneWorker
                        } = PlayerRoomData,
                        if
                            SceneWorker == ?UNDEFINED ->
                                handle_exit_room_list(PlayerData),
                                false;
                            true ->
                                Node = mod_player:get_game_node(PlayerId),
                                #t_bettle{
                                    scene = SceneId
                                } = get_t_bettle(PlayerType),
                                {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
                                mod_apply:apply_to_online_player(Node, PlayerId, mod_scene, player_prepare_enter_scene, [PlayerId, SceneWorker, SceneId, X, Y, [], null], normal),
                                true
                        end
                end
        end,
    if
        IsStart ->
            {[], [], 0};
        true ->
            dict_write_data(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId, NewPlayerData),
            add_player(Type, PlatformId, ServerId, PlayerId),

            RoomDataList = ets:select(ets_one_vs_one_room_data, [{#ets_one_vs_one_room_data{type = Type, _ = '_'}, [], ['$_']}]),

            RankList =
                case get({one_vs_one_rank_list, Type}) of
                    ?UNDEFINED ->
                        RankList1 = get_rank_list(Type),
                        put({one_vs_one_rank_list, Type}, RankList1),
                        RankList1;
                    RankList2 ->
                        RankList2
                end,

            DbOneVsOneRankData = get_db_one_vs_one_rank_data_init(Type, PlayerId),
            MyWinValue = DbOneVsOneRankData#db_one_vs_one_rank_data.score,

            {lists:map(
                fun(RoomData) ->
                    #ets_one_vs_one_room_data{
                        room_id = RoomId,
                        player_list = PlayerList
                    } = RoomData,
                    ModelHeadFigureList = [ModelHeadFigure || {_PlayerId, ModelHeadFigure} <- PlayerList],
                    {RoomId, ModelHeadFigureList}
                end,
                RoomDataList
            ), RankList, MyWinValue}
    end.
get_rank_list(Type) ->
    #t_bettle{
        restrict = Restrict
    } = get_t_bettle(Type),
    DbOneVsOneRankDataList = get_db_one_vs_one_rank_data_list(Type),
    NewDbOneVsOneRankDataList = [DbOneVsOneRankData || DbOneVsOneRankData = #db_one_vs_one_rank_data{score = Score} <- DbOneVsOneRankDataList, Score >= Restrict],
    List = [pack_rank_list(Data) || Data <- NewDbOneVsOneRankDataList],
    RankList = lists:sort(
        fun(A, B) ->
            {_, AScore, ATime} = A,
            {_, BScore, BTime} = B,
            if
                AScore < BScore ->
                    false;
                AScore == BScore ->
                    if
                        ATime < BTime ->
                            true;
                        true ->
                            false
                    end;
                AScore > BScore ->
                    true
            end
        end,
        List
    ),
    {_, L} =
        lists:foldl(
            fun({ModelHeadFigure, Score, _Time}, {TmpRank, TmpL}) ->
                {TmpRank + 1, [{TmpRank, ModelHeadFigure#modelheadfigure.player_id, ModelHeadFigure, Score} | TmpL]}
            end,
            {1, []}, RankList
        ),
    lists:reverse(L).
pack_rank_list(DbOneVsOneRankDataList) ->
    #db_one_vs_one_rank_data{
        player_id = PlayerId,
        score = Score,
        time = Time
    } = DbOneVsOneRankDataList,
    Node = mod_player:get_game_node(PlayerId),

    ModelHeadFigure =
        case catch util:rpc_call(Node, api_player, pack_model_head_figure, [PlayerId], infinity) of
            {'EXIT', _Error} ->
                api_player:pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0);
            {badrpc, _Reason} ->
                api_player:pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0);
            Data ->
                Data
        end,

    {ModelHeadFigure, Score, Time}.

add_player(Type, PlatformId, ServerId, PlayerId) ->
    OldPlayerList = util:get_dict({player_list, Type}, []),
    NewPlayerList =
        case lists:keytake({PlatformId, ServerId}, 1, OldPlayerList) of
            false ->
                [{{PlatformId, ServerId}, [PlayerId]} | OldPlayerList];
            {value, {{PlatformId, ServerId}, OldPlayerIdList}, OldPlayerList1} ->
                [{
                    {PlatformId, ServerId},
                    case lists:member(PlayerId, OldPlayerIdList) of
                        true ->
                            OldPlayerIdList;
                        false ->
                            [PlayerId | OldPlayerIdList]
                    end
                } | OldPlayerList1]
        end,
    put({player_list, Type}, NewPlayerList).
delete_player(Type, PlatformId, ServerId, PlayerId) ->
    OldPlayerList = util:get_dict({player_list, Type}, []),
    NewPlayerList =
        case lists:keytake({PlatformId, ServerId}, 1, OldPlayerList) of
            false ->
%%                ?ERROR("没有玩家数据 ：~p", [{PlatformId, ServerId, PlayerId, OldPlayerList}]),
                OldPlayerList;
            {value, {{PlatformId, ServerId}, OldPlayerIdList}, OldPlayerList1} ->
                [{{PlatformId, ServerId}, lists:delete(PlayerId, OldPlayerIdList)} | OldPlayerList1]
        end,
    put({player_list, Type}, NewPlayerList).

handle_exit_room_list(null) ->
    noop;
handle_exit_room_list(PlayerId) when is_integer(PlayerId) ->
    handle_exit_room_list(dict_select(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId));
handle_exit_room_list(PlayerData) when is_record(PlayerData, one_vs_one_player_data) ->
    #one_vs_one_player_data{
        player_id = PlayerId,
        type = Type,
        room_id = RoomId,
        platform_id = PlatformId,
        server_id = ServerId
    } = PlayerData,
    delete_player(Type, PlatformId, ServerId, PlayerId),
    case ets_select(ets_one_vs_one_room_data, {Type, RoomId}) of
        null ->
            dict_delete(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId);
        RoomData ->
            #ets_one_vs_one_room_data{
                player_list = OldPlayerList,
                scene_worker = SceneWorker
            } = RoomData,
            case SceneWorker of
                ?UNDEFINED ->
                    dict_delete(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId),
                    NewPlayerList = lists:keydelete(PlayerId, 1, OldPlayerList),
                    NewRoomData = RoomData#ets_one_vs_one_room_data{player_list = NewPlayerList},
                    if
                        NewPlayerList == [] ->
                            ets_delete_data(RoomData);
                        true ->
                            ets_write(NewRoomData)
                    end,
                    put({update_room_data_list, Type}, [NewRoomData | util:get_dict({update_room_data_list, Type}, [])]);
                _ ->
                    noop
            end
    end,
    ok.

handle_join_room(PlayerId, ModelHeadFigure, Type, RoomId) ->
    case dict_select(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId) of
        null ->
            exit(fail);
        PlayerData ->
            NewPlayerData =
                PlayerData#one_vs_one_player_data{
                    player_id = PlayerId,
                    type = Type,
                    room_id = RoomId
                },
            handle_exit_room_list(PlayerData),
            add_player(Type, PlayerData#one_vs_one_player_data.platform_id, PlayerData#one_vs_one_player_data.server_id, PlayerId),
            dict_write_data(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId, NewPlayerData)
    end,
    RoomData =
        case ets_select(ets_one_vs_one_room_data, {Type, RoomId}) of
            null ->
                #ets_one_vs_one_room_data{
                    row_key = {Type, RoomId},
                    type = Type,
                    room_id = RoomId,
                    player_list = []
                };
            Db ->
                Db
        end,
    #ets_one_vs_one_room_data{
        player_list = OldPlayerList,
        scene_worker = SceneWorker
    } = RoomData,
    ?ASSERT(SceneWorker == ?UNDEFINED),
    NewPlayerList = [{PlayerId, ModelHeadFigure} | OldPlayerList],
    NewRoomData1 =
        RoomData#ets_one_vs_one_room_data{
            player_list = NewPlayerList
        },
    case length(NewPlayerList) of
        2 ->
            {ok, NewSceneWorker} = start(NewRoomData1),
            NewRoomData = NewRoomData1#ets_one_vs_one_room_data{scene_worker = NewSceneWorker},
            ets_write(NewRoomData),
%%            dict_delete(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId),
%%            delete_player(Type, PlatformId, ServerId, PlayerId),
            put({update_room_data_list, Type}, [NewRoomData | util:get_dict({update_room_data_list, Type}, [])]);
        _ ->
            ets_write(NewRoomData1),
            put({update_room_data_list, Type}, [NewRoomData1 | util:get_dict({update_room_data_list, Type}, [])])
    end,
    ok.
start(RoomData) ->
    #ets_one_vs_one_room_data{
        room_id = RoomId,
        type = Type,
        player_list = PlayerList
    } = RoomData,
    PlayerIdList = [PlayerId || {PlayerId, _} <- PlayerList],
    #t_bettle{
        start = StartNum,
        scene = SceneId,
        cost_list = [CostItemId, CostNum]
    } = get_t_bettle(Type),
    #t_scene{
        mana_attack_list = [ScenePropId, _]
    } = mod_scene:get_t_scene(SceneId),
    %% 启动场景进程
    {ok, SceneWorker} = scene_worker:start(SceneId, self(), [{id, Type}, {player_id_list, PlayerIdList}, {match_scene_type, one_vs_one}, {room_id, RoomId}]),
    lists:foreach(
        fun(PlayerId) ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, match_scene, enter_scene, [PlayerId, SceneWorker, SceneId, [{ScenePropId, StartNum}], [{CostItemId, CostNum}]], normal)
        end,
        PlayerIdList
    ),
    {ok, SceneWorker}.

handle_balance(Type, RoomId, RankList) ->
    case ets_select(ets_one_vs_one_room_data, {Type, RoomId}) of
        null ->
            ?ERROR("结算找不到房间 ： ~p", [{Type, RoomId}]);
        RoomData ->
            [{_ARank, _APlayerId, AScore}, {_BRank, _BPlayerId, BScore}] = RankList,
            if
                AScore == BScore ->
                    noop;
                true ->
                    {1, FirstPlayerId, _Score} = lists:keyfind(1, 1, RankList),
                    DbOneVsOneRankData = get_db_one_vs_one_rank_data_init(Type, FirstPlayerId),
                    #db_one_vs_one_rank_data{
                        score = Score
                    } = DbOneVsOneRankData,
                    Tran =
                        fun() ->
                            db:write(DbOneVsOneRankData#db_one_vs_one_rank_data{score = Score + 1, time = util_time:timestamp()})
                        end,
                    db:do(Tran),
                    ok
            end,
            ets_delete_data(RoomData),
            #ets_one_vs_one_room_data{
                player_list = PlayerList
            } = RoomData,
            lists:foreach(
                fun({PlayerId, _}) ->
                    dict_delete(?DICT_ONE_VS_ONE_PLAYER_DATA, PlayerId)
%%                    {PlatformId, ServerId} = mod_player:get_platform_id_and_server_id(PlayerId),
%%                    delete_player(Type, PlatformId, ServerId, PlayerId)
%%                    delete_player(Type, PlatformId, ServerId, PlayerId),
                end,
                PlayerList
            ),
            update_rank_list(Type),
            put({update_room_data_list, Type}, [RoomData#ets_one_vs_one_room_data{player_list = []} | util:get_dict({update_room_data_list, Type}, [])])
    end.
update_rank_list(Type) ->
    put({one_vs_one_rank_list, Type}, get_rank_list(Type)).


%% ----------------------------------
%% @doc 	尝试每日结算
%% @throws 	none
%% @end
%% ----------------------------------
try_everyday_balance() ->
    LastBalanceTime = mod_server_data:get_int_data(?SERVER_DATA_ONE_VS_ONE_LAST_BALANCE_TIME),
    Now = util_time:timestamp(),
    Time = list_to_tuple(?SD_RANK_MAIL_TIME),
    TodayBalanceConfigTime = util_time:get_today_timestamp(Time),
    LastBalanceConfigTime =
        if
            Now >= TodayBalanceConfigTime ->
                TodayBalanceConfigTime;
            true ->
                TodayBalanceConfigTime - ?DAY_S
        end,
    if
        LastBalanceTime < LastBalanceConfigTime ->
            everyday_balance(LastBalanceTime);
        true ->
            noop
    end,
    NextBalanceConfigTime = LastBalanceConfigTime + ?DAY_S,
    erlang:send_after((NextBalanceConfigTime - Now) * ?SECOND_MS, self(), {everyday_balance, NextBalanceConfigTime}).

%% ----------------------------------
%% @doc 	每日结算
%% @throws 	none
%% @end
%% ----------------------------------
everyday_balance(BalanceTime) ->
    Tran =
        fun() ->
            mod_server_data:set_int_data(?SERVER_DATA_ONE_VS_ONE_LAST_BALANCE_TIME, BalanceTime),
            lists:foreach(
                fun({Type}) ->
                    erase({one_vs_one_rank_list, Type}),
                    RankList = get_rank_list(Type),
                    case RankList of
                        [] ->
                            noop;
                        _ ->
                            #t_bettle{
                                award_list = EveryRankAwardList,
                                rank_mail_id = RankMailId
                            } = get_t_bettle(Type),
                            lists:foreach(
                                fun({Rank, PlayerId, _ModelHeadFigureList, _Score}) ->
                                    case util_list:get_value_from_range_list(Rank, EveryRankAwardList) of
                                        ?UNDEFINED ->
                                            noop;
                                        AwardId ->
%%                                            #modelheadfigure{player_id = PlayerId} = ModelHeadFigureList,
                                            Node = mod_player:get_game_node(PlayerId),
                                            ItemList = mod_award:decode_award(AwardId),
                                            PropNum = case lists:keyfind(?ITEM_RUCHANGJUAN, 1, ItemList) of
                                                          false ->
                                                              0;
                                                          {?ITEM_RUCHANGJUAN, PropNum1} ->
                                                              PropNum1;
                                                          _ ->
                                                              0
                                                      end,
                                            mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, RankMailId, ItemList, [Rank, PropNum], ?LOG_TYPE_ONE_VS_ONE_EVERY_RANK_AWARD], game_worker)
                                    end
                                end,
                                RankList
                            )
                    end
                end, t_bettle:get_keys()
            ),
            db:delete_all(one_vs_one_rank_data)
        end,
    db:do(Tran).

%% ================================================ 进程中操作  ets ================================================
%% @doc ETS 查询数据
ets_select(EtsTable, Key) ->
    case ets:lookup(EtsTable, Key) of
        [R] ->
            R;
        [] ->
            null
    end.

%% @doc ETS 写入数据
ets_write_data(EtsName, Key, EtsData) ->
    case ets_select(EtsName, Key) of
        null ->
            ets:insert_new(EtsName, EtsData);
        OldData ->
            if
                OldData =:= EtsData ->
                    noop;
                true ->
                    ets:insert(EtsName, EtsData)
            end
    end,
    EtsData.

%% @doc ETS 删除数据
ets_delete_data(EtsData) when is_record(EtsData, ets_one_vs_one_room_data) ->
    ets_delete_data(ets_one_vs_one_room_data, EtsData#ets_one_vs_one_room_data.row_key).
ets_delete_data(EtsName, Key) ->
    ets:delete(EtsName, Key).

%% @doc ETS 写入数据
%% @doc 不写入数据库，只是内存操作，操作的时候尽量放在事务的后面
ets_write(EtsData) when is_record(EtsData, ets_one_vs_one_room_data) ->
    #ets_one_vs_one_room_data{
        player_list = PlayerList,
        scene_worker = SceneWorker
    } = EtsData,
    if
        PlayerList == [] andalso SceneWorker == ?UNDEFINED ->
            ets_delete_data(EtsData);
        true ->
            ets_write_data(ets_one_vs_one_room_data, EtsData#ets_one_vs_one_room_data.row_key, EtsData)
    end.

%% @doc ---------------------- 进程中操作  dict(不写入数据库，只是内存操作，操作的时候尽量放在事务的后面)------------------------

%% @doc DICT 查询数据
dict_select(DictKey, DictKeyValue) ->
    dict_select_default(DictKey, DictKeyValue, null).
dict_select(Key) ->
    get(Key).
dict_select_default(DictKey, Default) ->
    case dict_select(DictKey) of
        ?UNDEFINED ->
            Default;
        R ->
            R
    end.
dict_select_default(DictKey, DictKeyValue, Default) ->
    dict_select_default({DictKey, DictKeyValue}, Default).

%% @doc DICT 写入数据
dict_write_data(DictKey, DictKeyValue, DictData) ->
    dict_write_data({DictKey, DictKeyValue}, DictData).
dict_write_data(Key, Value) ->
    put(Key, Value).

%% @doc DICT 删除数据
dict_delete(DictKey, DictKeyValue) ->
    dict_delete({DictKey, DictKeyValue}).
dict_delete(Key) ->
    erase(Key).

%% ================================================ 模板操作 ================================================
%% @doc 匹配场数据
get_t_bettle(Type) ->
    t_bettle:assert_get({Type}).

%% @doc DB 获得1v1排行数据
get_db_one_vs_one_rank_data(Type, PlayerId) ->
    db:read(#key_one_vs_one_rank_data{type = Type, player_id = PlayerId}).
get_db_one_vs_one_rank_data_init(Type, PlayerId) ->
    case get_db_one_vs_one_rank_data(Type, PlayerId) of
        null ->
            #db_one_vs_one_rank_data{
                type = Type,
                player_id = PlayerId,
                score = 0,
                time = 0
            };
        Db ->
            Db
    end.

%% @doc DB 获得1v1排行数据列表
get_db_one_vs_one_rank_data_list(Type) ->
    db_index:get_rows(#idx_one_vs_one_rank_data_by_type{type = Type}).