%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人BOSS
%%% @end
%%% Created : 25. 十一月 2020 下午 06:25:56
%%%-------------------------------------------------------------------
-module(many_people_boss_srv_mod).
-author("Administrator").

-include("many_people_boss.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("scene.hrl").

%% API
-export([
    init_many_people_boss_room/0,   %% 初始化机器人房间

    get_room_list/1,                %% rpc:call 获得房间列表

    handle_join_room/6,             %% 加入房间
    handle_create_room/6,           %% 创建房间
    handle_start/1,
    handle_participate_in/3,        %% 房主参与
    handle_kick_out_player/2,       %% 踢出玩家
    handle_set_is_all_ready_start/2,%% 设置是否全部准备自动开始
    handle_ready/3,                 %% 准备
    handle_leave_room/2,            %% 离开房间
    handle_mission_leave/2,         %% 玩家离开副本
    handle_login_game/1,            %% 玩家登录游戏

    handle_mission_balance/5,       %% 副本结算

    get_pos_limit/1
]).

%% ================================================ FUN ================================================

%% @doc 初始化多人boss房间
init_many_people_boss_room() ->
    BossIdList = t_mission_many_people_boss:get_keys(),

    {MaxVipLevel} = lists:last(t_vip_level:get_keys()),
    {MaxLevel} = lists:last(t_role_experience:get_keys()),

    lists:foldl(
        fun({BossId}, RobotPlayerId) ->
            NewRoomId = dict_select(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID) + 1,
            InvitationCode = get_unique_invitation_code(),

            #t_mission_many_people_boss{
                create_condition_list = CreateConditionList
            } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),

            {VipLevel, Level} =
                case CreateConditionList of
                    [vip_level, VipLevel1] ->
                        {util_random:random_number(VipLevel1, MaxVipLevel), util_random:random_number(MaxLevel)};
                    [level, Level1] ->
                        {util_random:random_number(MaxVipLevel), util_random:random_number(Level1, MaxLevel)};
                    _ ->
                        {util_random:random_number(MaxVipLevel), util_random:random_number(MaxLevel)}
                end,

            {Sex, Name} = random_name:get_name(),

            OwnerPosData = #many_people_boss_room_pos_data{
                pos_id = 0,
                is_ready = ?TRUE,
                player_id = RobotPlayerId,
                model_head_figure = api_player:pack_model_head_figure(
                    #modelheadfigure{
                        player_id = RobotPlayerId,
                        sex = Sex,
                        nickname = util:to_binary("s1." ++ Name),
                        head_id = 0,
                        vip_level = VipLevel,
                        level = Level
                    }
                ),
                is_owner = ?TRUE,
                state = 0
            },

            EtsRoomData = #ets_many_people_boss_room_data{
                room_id = NewRoomId,
                boss_id = BossId,
                invitation_code = InvitationCode,
                is_lock = ?FALSE,
                password = "",
                owner_pos_data = OwnerPosData,
                is_participate_in = ?FALSE,
                is_all_ready_auto_start = ?TRUE,
                pos_data_list = [],
                kick_player_list = [],
                state = ?FALSE,
                is_robot_room = true
            },

            UpdateData =
                fun() ->
                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, InvitationCode, NewRoomId),
                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID, NewRoomId),
%%                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, RobotPlayerId, NewRoomId),
                    ets_write(EtsRoomData)
                end,
            UpdateData(),
            RobotPlayerId + 1
        end,
        1, BossIdList
    ).


%% @doc 获得房间列表
get_room_list(BossId) when BossId > 0 ->
    ets:select(
        ?ETS_MANY_PEOPLE_BOSS_ROOM_DATA,
        [{
            #ets_many_people_boss_room_data{
                boss_id = BossId,
                state = '$1',
                _ = '_'
            },
            [{'<', '$1', ?TRUE}], ['$_']}
        ]
    );
get_room_list(_) ->
    ets:select(
        ?ETS_MANY_PEOPLE_BOSS_ROOM_DATA,
        [{
            #ets_many_people_boss_room_data{
                state = '$1',
                _ = '_'
            },
            [{'<', '$1', ?TRUE}], ['$_']}
        ]
    ).

%% @doc 加入房间
handle_join_room(PlayerId, RoomId, Password, _InvitationCode, PlayerConditionMap, PlayerData) when RoomId > 0 ->
    handle_join_room_1(PlayerId, RoomId, Password, true, PlayerConditionMap, PlayerData);
handle_join_room(PlayerId, _RoomId, _Password, InvitationCode, PlayerConditionMap, PlayerData) ->
    RoomId = dict_select(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, InvitationCode),
    handle_join_room_1(PlayerId, RoomId, 0, false, PlayerConditionMap, PlayerData).
handle_join_room_1(PlayerId, RoomId, Password, IsUsePassword, PlayerConditionMap, {PlatformId, ServerId, ModelHeadFigure}) ->
    ?ASSERT(dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) =:= null, ?ERROR_ALREADY_JOIN_ROOM),
    EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
    ?ASSERT(EtsRoomData =/= null, ?ERROR_NONE),
    #ets_many_people_boss_room_data{
        boss_id = BossId,
        pos_data_list = PosDataList,
        is_lock = IsLock,
        password = RoomPassWord,
        state = State,
        is_participate_in = IsParticipateIn,
        owner_pos_data = OwnerPosData,
        kick_player_list = KickPlayerList
    } = EtsRoomData,
    ?ASSERT(State =:= ?FALSE),
    case lists:keytake(PlayerId, 1, KickPlayerList) of
        false ->
            noop;
        {value, {PlayerId, Time}, _L} ->
            Now = util_time:timestamp(),
            if
                Now > Time + 10 ->
                    noop;
                true ->
                    exit(?ERROR_TIME_LIMIT)
            end
    end,
    #t_mission_many_people_boss{
        cost_mana = CostMana,
        mission_id = MissionId,
        participants_limit = PosLimit
    } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
    #t_mission{
        enter_conditions_list = JoinConditionList
    } = mod_mission:get_t_mission(?MISSION_TYPE_MANY_PEOPLE_BOSS, MissionId),
    case JoinConditionList of
        [] ->
            noop;
        [ConditionKey, ConditionValue] ->
            ?ASSERT(maps:get(ConditionKey, PlayerConditionMap) >= ConditionValue, ?ERROR_NO_CONDITION),
            ?ASSERT(maps:get(?MANY_PEOPLE_BOSS_CONDITION_MANA, PlayerConditionMap) >= CostMana, ?ERROR_NOT_ENOUGH_MANA)
    end,
    ?IF(?TRAN_INT_2_BOOL(IsLock) andalso IsUsePassword, ?ASSERT(RoomPassWord =:= Password, ?ERROR_ERROR_PASSWORD), noop),
    PeopleNum = length(PosDataList),
    ?ASSERT(PeopleNum < PosLimit, ?ERROR_NOT_AUTHORITY),

    PosData = #many_people_boss_room_pos_data{
        pos_id = get_null_pos_id(PosDataList, PosLimit),
        is_ready = ?FALSE,
        player_id = PlayerId,
        model_head_figure = ModelHeadFigure,
        is_owner = ?FALSE,
        state = 0
    },

    NewPosDataList = [PosData | PosDataList],

    NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList},

    UpdateData =
        fun() ->
            ets_write(NewEtsRoomData),
            dict_write_data(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId, RoomId),
            PlayerIdList = [ThisPosData#many_people_boss_room_pos_data.player_id || ThisPosData <- PosDataList],
            NewPlayerIdList = ?IF(?TRAN_INT_2_BOOL(IsParticipateIn), PlayerIdList, [OwnerPosData#many_people_boss_room_pos_data.player_id] ++ PlayerIdList),
            notice_fun(NewPlayerIdList, notice_player_join, [PosData])
        end,
    UpdateData(),
    mod_player:update_player_server_data_init(PlayerId, PlatformId, ServerId),
%%    try_start(NewEtsRoomData),
    {ok, NewEtsRoomData}.

%% @doc 创建房间
handle_create_room(PlayerId, BossId, IsLock, Password, PlayerConditionMap, {PlatformId, ServerId, ModelHeadFigure}) ->
    ?ASSERT(dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) =:= null, ?ERROR_ALREADY_JOIN_ROOM),
    #t_mission_many_people_boss{
        create_condition_list = CreateConditionList
    } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),

    case CreateConditionList of
        [] ->
            noop;
        [ConditionKey, ConditionValue] ->
            ?ASSERT(maps:get(ConditionKey, PlayerConditionMap) >= ConditionValue, ?ERROR_NO_CONDITION)
    end,

    ?IF(?TRAN_INT_2_BOOL(IsLock), ?ASSERT(Password =/= 0, ?ERROR_NONE), noop),

    NewRoomId = dict_select(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID) + 1,
    InvitationCode = get_unique_invitation_code(),

    OwnerPosData = #many_people_boss_room_pos_data{
        pos_id = 0,
        is_ready = ?TRUE,
        player_id = PlayerId,
        model_head_figure = ModelHeadFigure,
        is_owner = ?TRUE,
        state = 0
    },

    EtsRoomData = #ets_many_people_boss_room_data{
        room_id = NewRoomId,
        boss_id = BossId,
        invitation_code = InvitationCode,
        is_lock = IsLock,
        password = Password,
        owner_pos_data = OwnerPosData,
        is_participate_in = ?FALSE,
        is_all_ready_auto_start = ?TRUE,
        pos_data_list = [],
        kick_player_list = [],
        state = ?FALSE
    },

    UpdateData =
        fun() ->
            dict_write_data(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, InvitationCode, NewRoomId),
            dict_write_data(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID, NewRoomId),
            dict_write_data(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId, NewRoomId),
            ets_write(EtsRoomData)
        end,
    UpdateData(),
    mod_player:update_player_server_data_init(PlayerId, PlatformId, ServerId),
    {ok, EtsRoomData}.

%% @doc 开始游戏
handle_start(PlayerId) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            exit(?ERROR_FAIL);
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                boss_id = BossId,
                owner_pos_data = OwnerPosData,
                pos_data_list = PosDataList,
                state = State,
                is_participate_in = IsParticipateIn
            } = EtsRoomData,
            ?ASSERT(State =:= ?FALSE, ?ERROR_ALREADY_START),
            OwnerPlayerId = OwnerPosData#many_people_boss_room_pos_data.player_id,
            ?ASSERT(OwnerPlayerId =:= PlayerId, ?ERROR_NOT_AUTHORITY),
            PeopleNum = length(PosDataList),
            PeopleLimit = get_pos_limit(BossId),
            ?ASSERT(PeopleLimit =:= PeopleNum, ?ERROR_NOT_ENOUGH_NUMBER),
            IsAllReady = get_is_all_ready(PeopleLimit, PosDataList),
            ?ASSERT(IsAllReady, ?ERROR_NO_CONDITION),
            PlayerIdList = [PosData#many_people_boss_room_pos_data.player_id || PosData <- PosDataList],
            {ok, MissionWorker} = mod_mission_many_people_boss:create_mission(RoomId, BossId, false, IsParticipateIn, OwnerPlayerId, PlayerIdList),
            NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{
                state = ?TRUE,
                mission_worker = MissionWorker
            },
            ets_write(NewEtsRoomData)
    end,
    ok.

%% @doc 房主参与Boss战斗
handle_participate_in(PlayerId, SetIsParticipateIn, PlayerConditionMap) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            exit(?ERROR_FAIL);
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                boss_id = BossId,
                is_participate_in = IsParticipateIn,
                owner_pos_data = OwnerPosData,
                pos_data_list = PosDataList,
                state = State
            } = EtsRoomData,
            OwnerPlayerId = OwnerPosData#many_people_boss_room_pos_data.player_id,
            ?ASSERT(IsParticipateIn =/= SetIsParticipateIn),
            ?ASSERT(OwnerPlayerId =:= PlayerId),
            ?ASSERT(State =:= ?FALSE),
            #t_mission_many_people_boss{
                cost_mana = CostMana,
                participants_limit = PosLimit
            } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
            case SetIsParticipateIn of
                ?TRUE ->
                    ?ASSERT(maps:get(?MANY_PEOPLE_BOSS_CONDITION_MANA, PlayerConditionMap) >= CostMana, ?ERROR_NOT_ENOUGH_MANA),
                    ?ASSERT(length(PosDataList) < PosLimit),
                    PosData = OwnerPosData#many_people_boss_room_pos_data{
                        pos_id = get_null_pos_id(PosDataList, PosLimit)
                    },
                    NewPosDataList = [PosData | PosDataList],
                    NoticePlayerIdList = [ThisPosData#many_people_boss_room_pos_data.player_id || ThisPosData <- NewPosDataList],
                    NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{is_participate_in = SetIsParticipateIn, pos_data_list = NewPosDataList},
                    ets_write(NewEtsRoomData),
                    notice_fun(NoticePlayerIdList, notice_player_join, [PosData]),
                    try_start(NewEtsRoomData);
                ?FALSE ->
                    {value, PosData, NewPosDataList} = lists:keytake(?TRUE, #many_people_boss_room_pos_data.is_owner, PosDataList),
                    NoticePlayerIdList = [PlayerId] ++ [ThisPosData#many_people_boss_room_pos_data.player_id || ThisPosData <- NewPosDataList],
                    NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{is_participate_in = SetIsParticipateIn, pos_data_list = NewPosDataList},
                    ets_write(NewEtsRoomData),
                    notice_fun(NoticePlayerIdList, notice_player_leave, [PosData#many_people_boss_room_pos_data.pos_id])
            end
    end,
    ok.

%% @doc 踢出玩家
handle_kick_out_player(PlayerId, PosId) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                pos_data_list = PosDataList,
                owner_pos_data = OwnerPosData,
                state = State,
                is_participate_in = IsParticipateIn,
                kick_player_list = KickPlayerList
            } = EtsRoomData,
            OwnerPlayerId = OwnerPosData#many_people_boss_room_pos_data.player_id,
            if
                OwnerPlayerId =:= PlayerId andalso State =:= ?FALSE ->
                    case lists:keytake(PosId, #many_people_boss_room_pos_data.pos_id, PosDataList) of
                        {value, ThisPosData, NewPosList} ->
                            ThisPlayerId = ThisPosData#many_people_boss_room_pos_data.player_id,
                            if
                                ThisPlayerId =/= PlayerId ->
                                    Now = util_time:timestamp(),
                                    KickPlayerList1 = [{KickPlayerId, KickPlayerTime} || {KickPlayerId, KickPlayerTime} <- KickPlayerList, Now > KickPlayerTime + 10],
                                    NewKickPlayerList = [{ThisPlayerId, Now}] ++ KickPlayerList1,
                                    UpdateFun =
                                        fun() ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosList, kick_player_list = NewKickPlayerList}),
                                            notice_fun(ThisPlayerId, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE1]),
                                            dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, ThisPlayerId)
                                        end,
                                    UpdateFun(),
                                    PlayerIdList = [PosData#many_people_boss_room_pos_data.player_id || PosData <- NewPosList],
                                    NewPlayerIdList = ?IF(?TRAN_INT_2_BOOL(IsParticipateIn), PlayerIdList, [OwnerPlayerId] ++ PlayerIdList),
                                    notice_fun(NewPlayerIdList, notice_player_leave, [PosId]);
                                true ->
                                    noop
                            end;
                        false ->
                            noop
                    end;
                true ->
                    noop
            end
    end.

%% @doc 设置全部准备自动开始
handle_set_is_all_ready_start(PlayerId, IsAllReadyStart) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                is_all_ready_auto_start = OldIsAllReadyStart
            } = EtsRoomData,
            if
                OldIsAllReadyStart =/= IsAllReadyStart ->
                    NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{is_all_ready_auto_start = IsAllReadyStart},
                    ets_write(NewEtsRoomData),
                    notice_fun(PlayerId, notice_set_is_all_ready_start, [IsAllReadyStart]),
                    ?IF(IsAllReadyStart =:= ?TRUE, try_start(NewEtsRoomData), noop);
                true ->
                    noop
            end
    end.

%% @doc 准备
handle_ready(PlayerId, IsReady, PlayerConditionMap) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            exit(?ERROR_FAIL);
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                pos_data_list = PosDataList,
                owner_pos_data = OwnerPosData,
                state = State
            } = EtsRoomData,
            case State of
                ?FALSE ->
                    #t_mission_many_people_boss{
                        cost_mana = CostMana
                    } = mod_many_people_boss:get_t_mission_many_people_boss(EtsRoomData#ets_many_people_boss_room_data.boss_id),
                    ?ASSERT(maps:get(?MANY_PEOPLE_BOSS_CONDITION_MANA, PlayerConditionMap) >= CostMana, ?ERROR_NOT_ENOUGH_MANA),
                    {IsUpdate, NewPosDataList, NewPosData} =
                        lists:foldl(
                            fun(PosData, {TmpIsUpdate, TmpPosDataList, TmpChangePosData}) ->
                                #many_people_boss_room_pos_data{
                                    player_id = PosPlayerId,
                                    is_ready = PosIsReady
                                } = PosData,
                                case PlayerId =:= PosPlayerId andalso IsReady =/= PosIsReady of
                                    true ->
                                        ChangePosData1 = PosData#many_people_boss_room_pos_data{is_ready = IsReady},
                                        {true, [ChangePosData1 | TmpPosDataList], ChangePosData1};
                                    false ->
                                        {TmpIsUpdate, [PosData | TmpPosDataList], TmpChangePosData}
                                end
                            end,
                            {false, [], ?UNDEFINED}, PosDataList
                        ),
                    if
                        IsUpdate ->
                            NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList},
                            ets_write(NewEtsRoomData),
                            #many_people_boss_room_pos_data{
                                pos_id = ArgPosId,
                                is_ready = ArgIsReady
                            } = NewPosData,
                            OwnerPlayerId = OwnerPosData#many_people_boss_room_pos_data.player_id,
                            PlayerIdList = [ThisPlayerId || #many_people_boss_room_pos_data{player_id = ThisPlayerId} <- NewPosDataList, ThisPlayerId =/= OwnerPlayerId],
                            notice_fun(
                                [OwnerPlayerId] ++ PlayerIdList,
                                notice_player_ready,
                                [ArgPosId, ArgIsReady]
                            ),
                            ?IF(IsReady =:= ?TRUE, try_start(NewEtsRoomData), noop);
                        true ->
                            exit(?ERROR_FAIL)
                    end;
                _ ->
                    exit(?ERROR_FAIL)
            end
    end,
    ok.

%% @doc 离开房间
handle_leave_room(PlayerId, IsLeaveGame) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                pos_data_list = PosDataList,
                owner_pos_data = OwnerPosData,
                is_participate_in = IsParticipateIn,
                state = State
            } = EtsRoomData,

            IsOwner = ?IF(OwnerPosData =:= ?UNDEFINED, false, OwnerPosData#many_people_boss_room_pos_data.player_id =:= PlayerId),

            case State of
                ?FALSE ->
                    if
                        IsOwner ->
                            close_room(EtsRoomData);
                        true ->
                            case lists:keytake(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList) of
                                false ->
                                    ?ERROR("handle_leave_room——bug~p", [{PlayerId, IsLeaveGame, EtsRoomData}]),
                                    dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId),
                                    noop;
                                {value, PosData, NewPosDataList} ->
                                    PlayerIdList = [NewPosData#many_people_boss_room_pos_data.player_id || NewPosData <- NewPosDataList],
                                    UpdateFun =
                                        fun() ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList}),
                                            ?IF(IsLeaveGame, noop, notice_fun(PlayerId, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE3])),
                                            dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId),
                                            NewPlayerIdList = ?IF(IsParticipateIn =:= ?TRUE, PlayerIdList, [OwnerPosData#many_people_boss_room_pos_data.player_id] ++ PlayerIdList),
                                            notice_fun(NewPlayerIdList, notice_player_leave, [PosData#many_people_boss_room_pos_data.pos_id])
                                        end,
                                    UpdateFun()
                            end
                    end;
                ?TRUE ->
                    case IsLeaveGame of
                        true ->
                            GetNewOwnerPosDataFun =
                                fun() ->
                                    OwnerPosData#many_people_boss_room_pos_data{state = 2}
                                end,
                            GetNewPosDataListFun =
                                fun() ->
                                    {value, PosData, PosDataList1} = lists:keytake(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
                                    [PosData#many_people_boss_room_pos_data{state = 2}] ++ PosDataList1
                                end,
                            case OwnerPosData of
                                ?UNDEFINED ->
                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun()});
                                _ ->
                                    if
                                        IsOwner andalso IsParticipateIn =:= ?TRUE ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun(), owner_pos_data = GetNewOwnerPosDataFun()});
                                        IsOwner ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{owner_pos_data = GetNewOwnerPosDataFun()});
                                        true ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun()})
                                    end
%%                                #many_people_boss_room_pos_data{state = 2} ->
%%                                    noop
                            end;
                        false ->
                            if
                                IsOwner andalso IsParticipateIn =:= ?TRUE ->
                                    NewPosDataList = lists:keydelete(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList, owner_pos_data = ?UNDEFINED});
                                IsOwner ->
                                    exit(?ERROR_FAIL);
                                true ->
                                    NewPosDataList = lists:keydelete(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList})
                            end,
                            dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId)
                    end
            end
    end.

%% @doc 关闭房间
close_room(EtsRoomData) ->
    #ets_many_people_boss_room_data{
        pos_data_list = PosDataList,
        owner_pos_data = OwnerPosData,
        state = RoomState
    } = EtsRoomData,
    if
        RoomState =:= ?TRUE ->
            noop;
        true ->
            #many_people_boss_room_pos_data{
                player_id = OwnerPlayerId
            } = OwnerPosData,
            notice_fun(OwnerPlayerId, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE3]),
            NoticePlayerIdList = [PlayerId || #many_people_boss_room_pos_data{player_id = PlayerId, state = PosState} <- PosDataList, PosState =:= 0, PlayerId =/= OwnerPlayerId],
            notice_fun(NoticePlayerIdList, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE2])
    end,
    ?IF(OwnerPosData =/= ?UNDEFINED, dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, OwnerPosData#many_people_boss_room_pos_data.player_id), noop),
    [dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) || #many_people_boss_room_pos_data{player_id = PlayerId, is_owner = IsOwner} <- PosDataList, IsOwner =:= ?FALSE],
    ets_delete_data(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, EtsRoomData#ets_many_people_boss_room_data.room_id),
    dict_delete(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, EtsRoomData#ets_many_people_boss_room_data.invitation_code).

%% @doc 副本结算
handle_mission_balance(RoomId, PlayerIdList, KillBossPlayerId, RankList, PlayerNameStr) ->
    EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
    #ets_many_people_boss_room_data{
        owner_pos_data = OwnerPosData,
        boss_id = BossId,
        pos_data_list = PosDataList,
        is_robot_room = IsRobotRoom
    } = EtsRoomData,
    Result = is_integer(KillBossPlayerId),
%%    PlayerNameStr =
%%        case Result of
%%            true ->
%%                #obj_scene_actor{
%%                    nickname = WinPlayerName
%%                } = ?GET_OBJ_SCENE_PLAYER(KillBossPlayerId),
%%                WinPlayerName;
%%            false ->
%%                ""
%%        end,
    #t_mission_many_people_boss{
        mission_id = MissionId,
%%        kill_boss_award_list = KillBossAwardList,
        join_reward = JoinReward,
        owner_award_mana = OwnerAwardMana
    } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
    #t_mission{
        award_id = AwardId
    } = mod_mission:get_t_mission(?MISSION_TYPE_MANY_PEOPLE_BOSS, MissionId),
    NewEtsRoomData =
        if
            OwnerPosData =:= ?UNDEFINED ->
                close_room(EtsRoomData),
                ?UNDEFINED;
            true ->
                #many_people_boss_room_pos_data{
                    state = OwnerState
                } = OwnerPosData,
                if
                    OwnerState =:= 2 ->
                        close_room(EtsRoomData),
                        ?UNDEFINED;
                    OwnerState =:= 0 ->
                        NewPosDataList =
                            lists:foldl(
                                fun(PosData, L) ->
                                    #many_people_boss_room_pos_data{
                                        state = ThisState,
                                        is_owner = ThisIsOwner
                                    } = PosData,
                                    if
                                        ThisState =:= 0 ->
                                            if
                                                ThisIsOwner =:= ?FALSE ->
                                                    [PosData#many_people_boss_room_pos_data{is_ready = ?FALSE} | L];
                                                true ->
                                                    [PosData#many_people_boss_room_pos_data{is_ready = ?TRUE} | L]
                                            end;
                                        true ->
                                            L
                                    end
                                end,
                                [], PosDataList
                            ),
                        RoomState = ?FALSE,
                        MissionWorker = ?UNDEFINED,
                        EtsRoomData1 = EtsRoomData#ets_many_people_boss_room_data{
                            pos_data_list = NewPosDataList,
                            state = RoomState,
                            mission_worker = MissionWorker
                        },
                        ets_write(EtsRoomData1),
                        EtsRoomData1
                end
        end,

    lists:foreach(
        fun(PosData) ->
            #many_people_boss_room_pos_data{
                player_id = PlayerId,
                state = PlayerState
            } = PosData,
            IsFirstPrize = (PlayerId =:= KillBossPlayerId),

            IsSendMail = ?IF(PlayerState =:= 2 andalso lists:member(PlayerId, PlayerIdList) =:= false, true, false),
            ?IF(PlayerState =:= 0, noop, dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId)),
            Node = mod_player:get_game_node(PlayerId),

            case lists:keyfind(PlayerId, #hurtranking.player_id, RankList) of
                false ->
                    mod_apply:apply_to_online_player(Node, PlayerId, mod_many_people_boss, mission_balance_give_award, [PlayerId, IsSendMail, IsFirstPrize, [], NewEtsRoomData, 0, Result], game_worker);
                Rank ->
                    #hurtranking{
                        ranking = N
                    } = Rank,
                    AwardList =
                        if
                            IsFirstPrize ->
                                mod_award:decode_award(JoinReward) ++ mod_award:decode_award(AwardId);
%%                                JoinReward ++ KillBossAwardList;
                            true ->
                                mod_award:decode_award(JoinReward)
%%                                get_rank_award_list(N, RankAwardList)
                        end,

                    mod_apply:apply_to_online_player(Node, PlayerId, mod_many_people_boss, mission_balance_give_award, [PlayerId, IsSendMail, IsFirstPrize, AwardList, NewEtsRoomData, N, Result, PlayerNameStr], game_worker)
            end
%%            mod_apply:apply_to_online_player(OwnerNode, PlayerId, mod_many_people_boss, mission_owner_fight_result, [PlayerId, OwnerAwardMana, EtsRoomData1], game_worker))
        end,
        PosDataList
    ),

    if
        not IsRobotRoom andalso OwnerPosData =/= ?UNDEFINED ->
            #many_people_boss_room_pos_data{
                player_id = OwnerPlayerId,
                state = ThisOwnerState
            } = OwnerPosData,
            OwnerNode = mod_player:get_game_node(OwnerPlayerId),
            case ThisOwnerState of
                0 ->
                    if
                        Result ->
                            mod_apply:apply_to_online_player(OwnerNode, OwnerPlayerId, mod_many_people_boss, mission_owner_fight_result, [OwnerPlayerId, OwnerAwardMana, NewEtsRoomData], game_worker);
                        true ->
                            mod_apply:apply_to_online_player(OwnerNode, OwnerPlayerId, mod_many_people_boss, mission_owner_fight_result, [OwnerPlayerId, 0, NewEtsRoomData], game_worker)
                    end;
                2 ->
                    if
                        Result ->
                            rpc:cast(OwnerNode, mod_mail, add_mail_item_list, [OwnerPlayerId, ?MAIL_MANY_PEOPLE_BOSS_MAIL, [{?ITEM_GOLD, OwnerAwardMana}], ?LOG_TYPE_MANY_PEOPLE_BOSS]);
                        true ->
                            noop
                    end
            end;
        true ->
            noop
    end,

    ok.

%% @doc  离开副本
handle_mission_leave(RoomId, PlayerId) ->
    EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
    #ets_many_people_boss_room_data{
        pos_data_list = PosDataList
    } = EtsRoomData,
    case lists:keyfind(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList) of
        false ->
            true;
        PosData ->
            case PosData#many_people_boss_room_pos_data.state of
                2 ->
                    false;
                0 ->
                    dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId),
                    IsOwner = PosData#many_people_boss_room_pos_data.is_owner,
                    NewPosDataList = lists:keydelete(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
                    if
                        IsOwner =:= ?TRUE ->
                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList, owner_pos_data = ?UNDEFINED});
                        true ->
                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList})
                    end
            end
    end.

%% @doc  登录游戏
handle_login_game(PlayerId) ->
    case dict_select(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, RoomId),
            #ets_many_people_boss_room_data{
                boss_id = BossId,
                pos_data_list = PosDataList,
                state = RoomState,
                mission_worker = MissionWorker,
                owner_pos_data = OwnerPosData
            } = EtsRoomData,
            case RoomState of
                ?FALSE ->
                    handle_leave_room(PlayerId, true),
                    noop;
                ?TRUE ->
                    case lists:keytake(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList) of
                        false ->
                            noop;
%%                            handle_leave_room(PlayerId, true);
                        {value, PosData, PosDataList1} ->
                            MissionType = ?MISSION_TYPE_MANY_PEOPLE_BOSS,
                            #t_mission_many_people_boss{
                                mission_id = MissionId
                            } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
                            SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
                            {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
                            Node = mod_player:get_game_node(PlayerId),
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_many_people_boss, player_enter_mission, [PlayerId, -1, false, [MissionWorker, SceneId, X, Y, [], null], MissionId], normal),
                            NewPosDataList = [PosData#many_people_boss_room_pos_data{state = 0}] ++ PosDataList1,
                            case OwnerPosData of
                                ?UNDEFINED ->
                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList});
                                _ ->
                                    if
                                        PlayerId =:= OwnerPosData#many_people_boss_room_pos_data.player_id ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList, owner_pos_data = OwnerPosData#many_people_boss_room_pos_data{state = 0}});
                                        true ->
                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList})
                                    end
                            end,
                            ok
                    end
            end
    end.

%% ================================================ UTIL ================================================

%% @doc 获得排行奖励
%%get_rank_award_list(Rank, []) ->
%%    ?ERROR("奖励未配置~p", [Rank]),
%%    exit(?ERROR_FAIL);
%%get_rank_award_list(Rank, [[StartRank, EndRank, AwardPropList] | RankAwardList]) ->
%%    if
%%        StartRank =< Rank andalso (Rank =< EndRank orelse EndRank =:= 0) ->
%%            AwardPropList;
%%        true ->
%%            get_rank_award_list(Rank, RankAwardList)
%%    end.

%% @doc 通知函数
notice_fun(PlayerId, _F, _A) when is_integer(PlayerId) andalso PlayerId < 10000 ->
    noop;
notice_fun(PlayerId, F, A) when is_integer(PlayerId) ->
    Node = mod_player:get_game_node(PlayerId),
    rpc:cast(Node, api_many_people_boss, F, [PlayerId | A]);
notice_fun(PlayerIdList, F, A) when is_list(PlayerIdList) ->
    lists:foreach(
        fun(PlayerId) ->
            notice_fun(PlayerId, F, A)
        end,
        PlayerIdList
    ).

%% @doc 获得是否全部准备
get_is_all_ready(PosLimit, PosDataList) ->
    List =
%%        case ?IS_DEBUG of
%%            true ->
%%                lists:seq(1, 1);
%%            false ->
    lists:seq(1, PosLimit),
%%        end,
    lists:all(
        fun(PosId) ->
            case lists:keyfind(PosId, #many_people_boss_room_pos_data.pos_id, PosDataList) of
                false ->
                    false;
                PosData ->
                    #many_people_boss_room_pos_data{
                        is_ready = IsReady
                    } = PosData,
                    ?TRAN_INT_2_BOOL(IsReady)
            end
        end,
        List
    ).
%%get_is_all_ready(PosLimit, PosDataList) ->
%%    lists:all(
%%        fun(PosId) ->
%%            case lists:keyfind(PosId, #many_people_boss_room_pos_data.pos_id, PosDataList) of
%%                false ->
%%                    false;
%%                PosData ->
%%                    #many_people_boss_room_pos_data{
%%                        is_ready = IsReady
%%                    } = PosData,
%%                    ?TRAN_INT_2_BOOL(IsReady)
%%            end
%%        end,
%%        lists:seq(1, PosLimit)
%%    ).

%% @doc 获得唯一邀请码
get_unique_invitation_code() ->
    get_unique_invitation_code(10).
get_unique_invitation_code(Times) when Times > 0 ->
    %% 去除 O 0 1 I 等容易混淆的字符
    Str = "abcdefghijklmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789",
    InvitationCodeLength = 6,
    RandomKey = [lists:nth(rand:uniform(length(Str)), Str) || _ <- lists:seq(1, InvitationCodeLength)],
    ?IF(dict_select(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, RandomKey) =:= null, RandomKey, get_unique_invitation_code(Times - 1));
get_unique_invitation_code(_) ->
    ?ERROR("防止bug，无限循环"),
    exit(?ERROR_FAIL).

%% @doc 获得房间人数限制
get_pos_limit(BossId) ->
    #t_mission_many_people_boss{
        participants_limit = PosLimit
    } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
    PosLimit.

%% @doc 获得空的位置id
get_null_pos_id(PosDataList, LimitPosId) ->
    get_null_pos_id(PosDataList, 1, LimitPosId).
get_null_pos_id(PosDataList, CurrPosId, LimitPosId) ->
    case lists:keytake(CurrPosId, #many_people_boss_room_pos_data.pos_id, PosDataList) of
        false ->
            CurrPosId;
        {value, _PosData, NewPosDataList} ->
            if
                CurrPosId < LimitPosId ->
                    get_null_pos_id(NewPosDataList, CurrPosId + 1, LimitPosId);
                true ->
                    ?ERROR("这个错误不对劲！！！应该不可能发生的"),
                    exit(?ERROR_FAIL)
            end
    end.

%% @doc 尝试自动开始
try_start(EtsRoomData) ->
    #ets_many_people_boss_room_data{
        room_id = RoomId,
        boss_id = BossId,
        pos_data_list = PosDataList,
        is_all_ready_auto_start = IsAllReadyAutoStart,
        is_participate_in = IsParticipateIn,
        owner_pos_data = OwnerPosData,
        is_robot_room = IsRobotRoom
    } = EtsRoomData,
    PosLimit = get_pos_limit(BossId),
    IsAllReady = get_is_all_ready(PosLimit, PosDataList),
    IsCanStart = IsAllReady andalso ?TRAN_INT_2_BOOL(IsAllReadyAutoStart),
    OwnerPlayerId = OwnerPosData#many_people_boss_room_pos_data.player_id,
    if
        IsCanStart ->
            PlayerIdList = [PosData#many_people_boss_room_pos_data.player_id || PosData <- PosDataList],
            {ok, MissionWorker} = mod_mission_many_people_boss:create_mission(RoomId, BossId, IsRobotRoom, IsParticipateIn, OwnerPlayerId, PlayerIdList),
            NewEtsRoomData = EtsRoomData#ets_many_people_boss_room_data{
                state = ?TRUE,
                mission_worker = MissionWorker
            },
            ets_write(NewEtsRoomData);
        true ->
            noop
    end.

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
    end.

%% @doc ETS 删除数据
ets_delete_data(EtsName, Key) ->
    ets:delete(EtsName, Key).

%% @doc ETS 写入数据
%% @doc 不写入数据库，只是内存操作，操作的时候尽量放在事务的后面
ets_write(EtsData) when is_record(EtsData, ets_many_people_boss_room_data) ->
%%    ?DEBUG("写入ETS——DATA：~p", [EtsData]),
    ets_write_data(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, EtsData#ets_many_people_boss_room_data.room_id, EtsData).
%%ets_write(EtsData) when is_record(EtsData, ets_many_people_boss_room_pos_data) ->
%%    ets_write_data(?ETS_MANY_PEOPLE_BOSS_ROOM_POS_DATA, EtsData, EtsData#ets_many_people_boss_room_pos_data.pos_id);
%%ets_write(EtsData) when is_record(EtsData, ets_many_people_boss_room_player_data) ->
%%    ets_write_data(?ETS_MANY_PEOPLE_BOSS_PLAYER_DATA, EtsData#ets_many_people_boss_room_player_data.player_id, EtsData).
%% @doc ---------------------- 进程中操作  dict(不写入数据库，只是内存操作，操作的时候尽量放在事务的后面)------------------------

%% @doc DICT 查询数据
dict_select(DictKey, DictKeyValue) ->
    case dict_select({DictKey, DictKeyValue}) of
        ?UNDEFINED ->
            null;
        R ->
            R
    end.
dict_select(Key) ->
    get(Key).

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

%%
%%%% @doc 写入房间数据
%%dict_write(DictData) when is_record(DictData, dict_many_people_boss_room_data) ->
%%    case dict_select({?DICT_MANY_PEOPLE_BOSS_ROOM_DATA, DictData#dict_many_people_boss_room_data.room_id}, DictData) of
%%         null ->
%%             % 如果
%%             dict_write_data(?DICT_MANY_PEOPLE_BOSS_ROOM_NUM, dict_select(?DICT_MANY_PEOPLE_BOSS_ROOM_NUM) + 1);
%%         _ ->
%%             noop
%%    end,
%%    dict_write_data(?DICT_MANY_PEOPLE_BOSS_ROOM_DATA, DictData#dict_many_people_boss_room_data.room_id,DictData);
%%ets_write(EtsData) when is_record(EtsData, ets_many_people_boss_room_pos_data) ->
%%    ets_write_data(?ETS_MANY_PEOPLE_BOSS_ROOM_POS_DATA, EtsData, EtsData#ets_many_people_boss_room_pos_data.pos_id);
%%%% @doc 写入玩家数据
%%dict_write(DictData) when is_record(DictData, dict_many_people_boss_room_player_data) ->
%%    dict_write_data(?DICT_MANY_PEOPLE_BOSS_PLAYER_DATA,DictData#dict_many_people_boss_room_player_data.player_id ,DictData).
%%
