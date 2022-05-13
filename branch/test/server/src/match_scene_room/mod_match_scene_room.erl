%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 10月 2021 下午 03:01:33
%%%-------------------------------------------------------------------
-module(mod_match_scene_room).
-author("Administrator").

-include("common.hrl").
-include("match_scene.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("gen/db.hrl").

%% API
-export([
    get_unread_room_num/1,
    handle_get_unread_room_num/1,

    get_player_room_list/1,
    handle_get_player_room_list/1,

    exit_room_list/1,
    handle_exit_room_list/1,

    offline/1,

    create_room/3,
    handle_create_room/4,

    world_recruit/1,
    handle_world_recruit/1,

    recruit/2,
    handle_recruit/3,

    join_room/3,
    handle_join_room/4,

    leave_room/1,
    handle_leave_room/1
]).

-export([
    get_server_type/0
]).

-export([
    game_server_notice_add_room/2,

    game_server_notice_update_room/3,

    game_server_notice_delete_room/5,

    add_room_num/1,

    delete_room_num/2
]).

-define(WORLD_RECRUIT, 0).
-define(PLAYER_RECRUIT, 1).

-define(UNREAD_MATCH_ROOM_NUM, unread_match_room_num).

get_unread_room_num(PlayerId) ->
    UnreadRoomNum = match_scene_room_srv:call({get_unread_room_num, PlayerId}),
    put(?UNREAD_MATCH_ROOM_NUM, UnreadRoomNum),
    api_match_scene_room:notice_unread_num(PlayerId, UnreadRoomNum).
handle_get_unread_room_num(PlayerId) ->
    Fun =
        fun(List, Type) ->
            lists:foldl(
                fun({RoomId, _RecruitTime}, TmpNum) ->
                    EtsRoomData = ets_select(?ETS_ROOM_DATA, RoomId),
                    #ets_room_data{
                        world_observer_id_list = ObserverPlayerIdList,
                        player_observer_id_list = PlayerObserverPlayerIdList
                    } = EtsRoomData,
                    ObserverList =
                        case Type of
                            ?WORLD_RECRUIT ->
                                ObserverPlayerIdList;
                            ?PLAYER_RECRUIT ->
                                PlayerObserverPlayerIdList
                        end,
                    case lists:member(PlayerId, ObserverList) of
                        true ->
                            TmpNum;
                        false ->
                            TmpNum + 1
                    end
                end,
                0, List
            )
        end,
    WorldRecruitList = get(?DICT_WORLD_RECRUIT_LIST),
    WorldRecruitNum = Fun(WorldRecruitList, ?WORLD_RECRUIT),
    PlayerRecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, PlayerId}, []),
    PlayerRecruitNum = Fun(PlayerRecruitList, ?PLAYER_RECRUIT),
    WorldRecruitNum + PlayerRecruitNum.

%% @doc 获得玩家房间列表
get_player_room_list(PlayerId) ->
    match_scene_room_srv:call({get_player_room_list, PlayerId}).
handle_get_player_room_list(PlayerId) ->
    ObServerList = get(?DICT_OBSERVER_LIST),
    ?DEBUG("查看 ObServerList ： ~p", [ObServerList]),
    case lists:member(PlayerId, ObServerList) of
        true ->
            noop;
        false ->
            put(?DICT_OBSERVER_LIST, [PlayerId | ObServerList])
    end,
    WorldRecruitList = get(?DICT_WORLD_RECRUIT_LIST),
    Fun =
        fun(List, Type) ->
            lists:map(
                fun({RoomId, RecruitTime}) ->
                    EtsRoomData = ets_select(?ETS_ROOM_DATA, RoomId),
                    #ets_room_data{
                        model_head_figure = ModelHeadFigure,
                        cost_num = Cost,
                        password = Password,
                        player_list = PlayerList,
                        world_observer_id_list = ObserverPlayerIdList,
                        player_observer_id_list = PlayerObserverIdList
                    } = EtsRoomData,
                    case Type of
                        ?WORLD_RECRUIT ->
                            NewObserverPlayerIdList =
                                case lists:member(PlayerId, ObserverPlayerIdList) of
                                    true ->
                                        ObserverPlayerIdList;
                                    false ->
                                        [PlayerId | ObserverPlayerIdList]
                                end,
                            ets_write(EtsRoomData#ets_room_data{world_observer_id_list = NewObserverPlayerIdList});
                        ?PLAYER_RECRUIT ->
                            NewPlayerObserverIdList =
                                case lists:member(PlayerId, PlayerObserverIdList) of
                                    true ->
                                        PlayerObserverIdList;
                                    false ->
                                        [PlayerId | PlayerObserverIdList]
                                end,
                            ets_write(EtsRoomData#ets_room_data{player_observer_id_list = NewPlayerObserverIdList})
                    end,

                    IsLock = ?TRAN_BOOL_2_INT(Password =/= ""),
                    PlayerNum = length(PlayerList),
                    api_match_scene_room:pack_pb_match_scene_room_data(Type, RoomId, ModelHeadFigure, Cost, IsLock, RecruitTime, PlayerNum)
                end,
                List
            )
        end,
    PbWorldRecruitList = Fun(WorldRecruitList, ?WORLD_RECRUIT),
    PlayerRecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, PlayerId}, []),
    PbPlayerRecruitList = Fun(PlayerRecruitList, ?PLAYER_RECRUIT),
    PbWorldRecruitList ++ PbPlayerRecruitList.

%% @doc 退出房间列表
exit_room_list(PlayerId) ->
    put(?UNREAD_MATCH_ROOM_NUM, 0),
%%    ?DEBUG("exit_room_list : ~p", [PlayerId]),
    match_scene_room_srv:cast({exit_room_list, PlayerId}).
handle_exit_room_list(PlayerId) ->
    ObServerList = get(?DICT_OBSERVER_LIST),
    NewObserverList = lists:delete(PlayerId, ObServerList),
%%    ?DEBUG("NewObserverList : ~p", [NewObserverList]),
    put(?DICT_OBSERVER_LIST, NewObserverList).

offline(PlayerId) ->
    catch exit_room_list(PlayerId),
    catch leave_room(PlayerId).

%% @doc 创建房间
create_room(PlayerId, Password, CostNum) ->
    ?ASSERT(CostNum >= ?SD_CUSTONMIZE_MIN_COST andalso CostNum =< ?SD_CUSTONMIZE_MOST, ?ERROR_FAIL),
    ?ASSERT(length(Password) == 4 orelse length(Password) == 0, ?ERROR_FAIL),
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    match_scene_room_srv:call({create_room, PlayerId, Password, CostNum, ModelHeadFigure}).
handle_create_room(PlayerId, Password, CostNum, ModelHeadFigure) ->
    ?ASSERT(get({?DICT_PLAYER_ROOM, PlayerId}) =:= ?UNDEFINED, ?ERROR_ALREADY_JOIN_ROOM),

    NewRoomId = get(?DICT_ROOM_ID) + 1,

    EtsRoomData = #ets_room_data{
        room_id = NewRoomId,
        password = Password,
        owner_player_id = PlayerId,
        cost_num = CostNum,
        player_list = [PlayerId],
        model_head_figure = ModelHeadFigure
    },

    put({?DICT_PLAYER_ROOM, PlayerId}, NewRoomId),
    put(?DICT_ROOM_ID, NewRoomId),
    ets_write(EtsRoomData),
    ok.

%% @doc 世界招募
world_recruit(PlayerId) ->
    match_scene_room_srv:call({world_recruit, PlayerId}).
handle_world_recruit(PlayerId) ->
    RoomId = get({?DICT_PLAYER_ROOM, PlayerId}),
    ?ASSERT(RoomId =/= ?UNDEFINED, ?ERROR_FAIL),
    RoomData = ets_select(?ETS_ROOM_DATA, RoomId),
    ?ASSERT(RoomData =/= null),
    Time = util_time:timestamp(),

    ObServerList = get(?DICT_OBSERVER_LIST),

    #ets_room_data{
        model_head_figure = ModelHeadFigure,
        cost_num = Cost,
        password = Password,
        player_list = PlayerList,
        world_recruit_time_limit = WorldRecruitTimeLimit,
        world_observer_id_list = WorldObserverIdList
    } = RoomData,
    ?ASSERT(Time >= WorldRecruitTimeLimit),

    NewWorldRecruitTimeLimit = Time + 5,

    ets_write(RoomData#ets_room_data{world_observer_id_list = ObServerList, world_recruit_time_limit = NewWorldRecruitTimeLimit}),

    IsLock = ?TRAN_BOOL_2_INT(Password =/= ""),
    PlayerNum = length(PlayerList),

    WorldRecruitList = get(?DICT_WORLD_RECRUIT_LIST),
    NewWorldRecruitList =
        case lists:keytake(RoomId, 1, WorldRecruitList) of
            false ->
                mod_server_rpc:cast_all_game_server(?MODULE, game_server_notice_add_room, [ObServerList, {?WORLD_RECRUIT, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum}]),
                [{RoomId, Time} | WorldRecruitList];
            {value, {RoomId, _OldTime}, WorldRecruitList1} ->
                mod_server_rpc:cast_all_game_server(?MODULE, game_server_notice_update_room, [ObServerList, WorldObserverIdList, {?WORLD_RECRUIT, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum}]),
                [{RoomId, Time} | WorldRecruitList1]
        end,
    put(?DICT_WORLD_RECRUIT_LIST, NewWorldRecruitList),

    {ok, NewWorldRecruitTimeLimit}.

%% @doc 指定招募
recruit(PlayerId, RecruitPlayerName) ->
    {ServerId1, Name1} =
        case string:tokens(RecruitPlayerName, ".") of
            [ServerId, Name] ->
                {ServerId, Name};
            List when is_list(List) ->
                [ServerId | NewList] = List,
                Name = lists:append(NewList),
                {ServerId, Name};
            _ ->
                exit(?ERROR_NONE)
        end,
    match_scene_room_srv:call({recruit, PlayerId, ServerId1, Name1}).
handle_recruit(PlayerId, ServerId, RecruitPlayerName) ->
    PlatformId = mod_server_config:get_platform_id(),
    case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_player, get_player_by_sid_and_nickname, [ServerId, RecruitPlayerName]) of
        null ->
            {ok, 0};
        DbPlayer ->
            ?ASSERT(erlang:is_record(DbPlayer, db_player), ?ERROR_NO_CONDITION),
            #db_player{
                id = RecruitPlayerId,
                is_online = IsOnline
            } = DbPlayer,
            ?ASSERT(IsOnline == ?TRUE, ?ERROR_NO_CONDITION),
            ?ASSERT(PlayerId =/= RecruitPlayerId),
            RoomId = get({?DICT_PLAYER_ROOM, PlayerId}),
            ?ASSERT(RoomId =/= ?UNDEFINED, ?ERROR_FAIL),
            RoomData = ets_select(?ETS_ROOM_DATA, RoomId),
            ?ASSERT(RoomData =/= null),
            Time = util_time:timestamp(),
            #ets_room_data{
                model_head_figure = ModelHeadFigure,
                cost_num = Cost,
                password = Password,
                player_list = PlayerList,
                recruit_player_list = RecruitPlayerList,
                player_observer_id_list = PlayerObserverIdList
            } = RoomData,
            ObserverList = get(?DICT_OBSERVER_LIST),

            IsLock = ?TRAN_BOOL_2_INT(Password =/= ""),
            PlayerNum = length(PlayerList),

            case lists:member(RecruitPlayerId, RecruitPlayerList) of
                true ->
                    PlayerRecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, []),
                    NewPlayerRecruitList =
                        case lists:keytake(RoomId, 1, PlayerRecruitList) of
                            false ->
                                [{RoomId, Time} | PlayerRecruitList];
                            {value, {RoomId, _OldTime}, PlayerRecruitList1} ->
                                [{RoomId, Time} | PlayerRecruitList1]
                        end,
                    put({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, NewPlayerRecruitList),

                    NewPlayerObserverIdList =
                        case lists:member(RecruitPlayerId, ObserverList) of
                            true ->
                                case lists:member(RecruitPlayerId, PlayerObserverIdList) of
                                    false ->
                                        [RecruitPlayerId | PlayerObserverIdList];
                                    true ->
                                        PlayerObserverIdList
                                end;
                            false ->
                                case lists:member(RecruitPlayerId, PlayerObserverIdList) of
                                    false ->
                                        PlayerObserverIdList;
                                    true ->
                                        lists:delete(RecruitPlayerId, PlayerObserverIdList)
                                end
                        end,
                    ets_write(RoomData#ets_room_data{
                        player_observer_id_list = NewPlayerObserverIdList
                    }),
                    Node = mod_player:get_game_node(RecruitPlayerId),
                    case lists:member(RecruitPlayerId, ObserverList) of
                        true ->
                            noop;
                        false ->
                            case lists:member(RecruitPlayerId, PlayerObserverIdList) of
                                true ->
                                    mod_apply:apply_to_online_player(Node, RecruitPlayerId, ?MODULE, add_room_num, [RecruitPlayerId], normal);
                                false ->
                                    noop
                            end
                    end;
                false ->
                    PlayerRecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, []),
                    put({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, [{RoomId, Time} | PlayerRecruitList]),
                    ets_write(RoomData#ets_room_data{
                        recruit_player_list = [RecruitPlayerId | RecruitPlayerList]
                    }),
                    Node = mod_player:get_game_node(RecruitPlayerId),
                    case lists:member(RecruitPlayerId, ObserverList) of
                        true ->
                            rpc:cast(Node, api_match_scene_room, notice_add_room, [RecruitPlayerId, {?PLAYER_RECRUIT, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum}]);
                        false ->
                            mod_apply:apply_to_online_player(Node, RecruitPlayerId, ?MODULE, add_room_num, [RecruitPlayerId], normal)
                    end
            end,
            {ok, 0}
    end.

%% @doc 加入房间
join_room(PlayerId, RoomId, Password) ->
    ?ASSERT(length(Password) == 4 orelse length(Password) == 0, ?ERROR_FAIL),
    PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_RUCHANGJUAN),
    match_scene_room_srv:call({join_room, PlayerId, RoomId, Password, PlayerPropNum}).
handle_join_room(PlayerId, RoomId, Password, PlayerPropNum) ->
    ?ASSERT(get({?DICT_PLAYER_ROOM, PlayerId}) =:= ?UNDEFINED, ?ERROR_ALREADY_JOIN_ROOM),
    RoomData = ets_select(?ETS_ROOM_DATA, RoomId),
    ?ASSERT(RoomData =/= null, ?ERROR_NONE),
    #ets_room_data{
        password = RoomPassword,
        cost_num = CostNum,
        player_list = PlayerList,
        recruit_player_list = RecruitPlayerList
    } = RoomData,
    ?ASSERT(lists:member(PlayerId, PlayerList) == false, ?ERROR_ALREADY_JOIN_ROOM),
    ?ASSERT(RoomPassword == Password, ?ERROR_ERROR_PASSWORD),
    ?ASSERT(PlayerPropNum >= CostNum, ?ERROR_NOT_ENOUGH_MANA),
    NewPlayerList = [PlayerId | PlayerList],
    NewPlayerNum = length(NewPlayerList),
    IsRecruit = lists:member(PlayerId, RecruitPlayerList),
    NewRecruitPlayerList = lists:delete(PlayerId, RecruitPlayerList),
    NewRoomData = RoomData#ets_room_data{
        player_list = NewPlayerList,
        recruit_player_list = NewRecruitPlayerList
    },
    put(?DICT_OBSERVER_LIST, lists:delete(PlayerId, get(?DICT_OBSERVER_LIST))),
    IsStart = try_start(NewRoomData),
    if
        IsStart ->
            close_room(NewRoomData, true);
        true ->
            ets_write(NewRoomData),
            put({?DICT_PLAYER_ROOM, PlayerId}, RoomId),
            ObserverList = get(?DICT_OBSERVER_LIST),
            lists:foreach(
                fun(ObserverPlayerId) ->
                    Node = mod_player:get_game_node(ObserverPlayerId),
                    rpc:cast(Node, api_match_scene_room, notice_room_people_num_change, [ObserverPlayerId, RoomId, NewPlayerNum])
                end,
                ObserverList
            ),
            lists:foreach(
                fun(ThisPlayerId) ->
                    Node = mod_player:get_game_node(ThisPlayerId),
                    rpc:cast(Node, api_match_scene_room, notice_people_num_change, [ThisPlayerId, NewPlayerNum])
                end,
                NewPlayerList
            ),
            case IsRecruit of
                true ->
                    Node = mod_player:get_game_node(PlayerId),
                    rpc:cast(Node, api_match_scene_room, notice_delete_room, [PlayerId, RoomId, ?PLAYER_RECRUIT]),
%%                    api_match_scene_room:notice_delete_room(PlayerId, RoomId),
                    RecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, PlayerId}, []),
                    NewRecruitList = lists:keydelete(RoomId, 1, RecruitList),
                    case NewRecruitList of
                        [] ->
                            erase({?DICT_PLAYER_RECRUIT, PlayerId});
                        _ ->
                            put({?DICT_PLAYER_RECRUIT, PlayerId}, NewRecruitList)
                    end;
                false ->
                    noop
            end
    end,
    {ok, NewPlayerNum}.
try_start(RoomData) ->
    #ets_room_data{
        player_list = PlayerList,
        cost_num = Cost
    } = RoomData,
    NewPlayerNum = length(PlayerList),
    [_, _, _, _, _, SceneId] = ?SD_CUSTONMIZE_PARAMETER,
    #t_scene{
        max_player = MaxPlayerNum
    } = mod_scene:get_t_scene(SceneId),
    if
        NewPlayerNum == MaxPlayerNum ->
            start(Cost, PlayerList),
            true;
        true ->
            false
    end.
start(Cost, PlayerList) ->
    [_, _, _, StartNum, _, SceneId] = ?SD_CUSTONMIZE_PARAMETER,
    #t_scene{
        mana_attack_list = [ScenePropId, _]
    } = mod_scene:get_t_scene(SceneId),
    %% 启动场景进程
    {ok, SceneWorker} = scene_worker:start(SceneId, self(), [{match_scene_type, match_scene_room}, {player_id_list, PlayerList}, {cost, Cost}]),
    lists:foreach(
        fun(PlayerId) ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, match_scene, enter_scene, [PlayerId, SceneWorker, SceneId, [{ScenePropId, StartNum}], [{?ITEM_RUCHANGJUAN, Cost}]], normal)
        end,
        PlayerList
    ).

leave_room(PlayerId) ->
    match_scene_room_srv:call({leave_room, PlayerId}).
handle_leave_room(PlayerId) ->
    case get({?DICT_PLAYER_ROOM, PlayerId}) of
        ?UNDEFINED ->
            ok;
        RoomId ->
            RoomData = ets_select(?ETS_ROOM_DATA, RoomId),
            if
                RoomData == null ->
                    ?ERROR("玩家不在房间 ： ~p", [{PlayerId, RoomId, RoomData}]),
                    erase({?DICT_PLAYER_ROOM, PlayerId}),
                    exit(?ERROR_FAIL);
                true ->
                    #ets_room_data{
                        owner_player_id = OwnerPlayerId,
                        player_list = PlayerList
                    } = RoomData,
                    if
                        PlayerId == OwnerPlayerId ->
                            close_room(RoomData, false);
                        true ->
                            erase({?DICT_PLAYER_ROOM, PlayerId}),
                            NewPlayerList = lists:delete(PlayerId, PlayerList),
                            NewPlayerNum = length(NewPlayerList),
                            ObserverList = get(?DICT_OBSERVER_LIST),
                            lists:foreach(
                                fun(ThisPlayerId) ->
                                    Node = mod_player:get_game_node(ThisPlayerId),
                                    rpc:cast(Node, api_match_scene_room, notice_room_people_num_change, [ThisPlayerId, RoomId, NewPlayerNum])
                                end,
                                ObserverList
                            ),
                            lists:foreach(
                                fun(ThisPlayerId) ->
                                    Node = mod_player:get_game_node(ThisPlayerId),
                                    rpc:cast(Node, api_match_scene_room, notice_people_num_change, [ThisPlayerId, NewPlayerNum])
                                end,
                                NewPlayerList
                            ),
                            ets_write(RoomData#ets_room_data{player_list = NewPlayerList})
                    end
            end,
            ok
    end.
close_room(RoomData, IsStart) ->
    #ets_room_data{
        room_id = RoomId,
        owner_player_id = OwnerPlayerId,
        player_list = PlayerList,
        recruit_player_list = RecruitPlayerList,
        world_observer_id_list = WorldObserverIdList,
        player_observer_id_list = PlayerObserverIdList
    } = RoomData,
    lists:foreach(
        fun(PlayerId) ->
            if
                OwnerPlayerId == PlayerId ->
                    noop;
                IsStart == false ->
                    Node = mod_player:get_game_node(PlayerId),
                    rpc:cast(Node, api_match_scene_room, notice_leave_room, [PlayerId]);
                true ->
                    noop
            end,
            erase({?DICT_PLAYER_ROOM, PlayerId})
        end,
        PlayerList
    ),
    lists:foreach(
        fun(RecruitPlayerId) ->
            RecruitList = util:get_dict({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, []),
            NewRecruitList = lists:keydelete(RoomId, 1, RecruitList),
            case NewRecruitList of
                [] ->
                    erase({?DICT_PLAYER_RECRUIT, RecruitPlayerId});
                _ ->
                    put({?DICT_PLAYER_RECRUIT, RecruitPlayerId}, NewRecruitList)
            end
        end,
        RecruitPlayerList
    ),
    WorldRecruitList = get(?DICT_WORLD_RECRUIT_LIST),
    NewWorldRecruitList = lists:keydelete(RoomId, 1, WorldRecruitList),
    put(?DICT_WORLD_RECRUIT_LIST, NewWorldRecruitList),
    ets_delete_data(?ETS_ROOM_DATA, RoomId),
    ObserverList = get(?DICT_OBSERVER_LIST),
    mod_server_rpc:cast_all_game_server(?MODULE, game_server_notice_delete_room, [ObserverList, WorldObserverIdList, PlayerObserverIdList, RecruitPlayerList, RoomId]),
    ok.

get_server_type() ->
    [_, _, _, _, _, SceneId] = ?SD_CUSTONMIZE_PARAMETER,
    #t_scene{
        server_type = ServerType
    } = mod_scene:get_t_scene(SceneId),
    ServerType.

game_server_notice_add_room(ObserverList, {Type, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum}) ->
    PlayerIdList = mod_online:get_all_online_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            case lists:member(PlayerId, ObserverList) of
                true ->
                    api_match_scene_room:notice_add_room(PlayerId, {Type, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum});
                false ->
                    mod_apply:apply_to_online_player(PlayerId, ?MODULE, add_room_num, [PlayerId])
            end
        end,
        PlayerIdList
    ).
game_server_notice_update_room(ObserverList, List, {Type, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum}) ->
    PlayerIdList = mod_online:get_all_online_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            case lists:member(PlayerId, ObserverList) of
                true ->
                    api_match_scene_room:notice_delete_room(PlayerId, RoomId, Type),
                    api_match_scene_room:notice_add_room(PlayerId, {Type, RoomId, ModelHeadFigure, Cost, IsLock, Time, PlayerNum});
                false ->
                    case lists:member(PlayerId, List) of
                        true ->
                            mod_apply:apply_to_online_player(PlayerId, ?MODULE, add_room_num, [PlayerId]);
                        false ->
                            noop
                    end
            end
        end,
        PlayerIdList
    ).
game_server_notice_delete_room(ObserverList, WorldObserverIdList, PlayerObserverIdList, RecruitPlayerList, RoomId) ->
    PlayerIdList = mod_online:get_all_online_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            case lists:member(PlayerId, ObserverList) of
                true ->
                    api_match_scene_room:notice_delete_room(PlayerId, RoomId, 0);
                false ->
                    Num =
                        case lists:member(PlayerId, WorldObserverIdList) of
                            true ->
                                0;
                            false ->
                                1
                        end +
                            case lists:member(PlayerId, PlayerObserverIdList) of
                                true ->
                                    0;
                                false ->
                                    case lists:member(PlayerId, RecruitPlayerList) of
                                        true ->
                                            1;
                                        false ->
                                            0
                                    end
                            end,
                    if
                        Num > 0 ->
                            mod_apply:apply_to_online_player(PlayerId, ?MODULE, delete_room_num, [PlayerId, Num]);
                        true ->
                            noop
                    end
            end
        end,
        PlayerIdList
    ).
add_room_num(PlayerId) ->
    UnreadNum = get(?UNREAD_MATCH_ROOM_NUM),
    NewUnreadNum = UnreadNum + 1,
    put(?UNREAD_MATCH_ROOM_NUM, NewUnreadNum),
    api_match_scene_room:notice_unread_num(PlayerId, NewUnreadNum).
delete_room_num(PlayerId, Num) ->
    UnreadNum = get(?UNREAD_MATCH_ROOM_NUM),
    NewUnreadNum = max(0, UnreadNum - Num),
    put(?UNREAD_MATCH_ROOM_NUM, NewUnreadNum),
    api_match_scene_room:notice_unread_num(PlayerId, NewUnreadNum).

%% ================================================ 进程中操作  ets ================================================
%% @doc ETS 查询数据
ets_select(EtsTable, Key) ->
    case ets:lookup(EtsTable, Key) of
        [R] ->
            R;
        _ ->
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
ets_delete_data(EtsName, Key) ->
    ets:delete(EtsName, Key).

%% @doc ETS 写入数据
%% @doc 不写入数据库，只是内存操作，操作的时候尽量放在事务的后面
ets_write(EtsData) when is_record(EtsData, ets_room_data) ->
    ets_write_data(?ETS_ROOM_DATA, EtsData#ets_room_data.room_id, EtsData).