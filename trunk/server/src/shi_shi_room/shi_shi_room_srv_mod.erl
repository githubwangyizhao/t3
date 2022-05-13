%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人BOSS
%%% @end
%%% Created : 25. 十一月 2020 下午 06:25:56
%%%-------------------------------------------------------------------
-module(shi_shi_room_srv_mod).
-author("Administrator").

-include("shi_shi_room.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("scene.hrl").

%% API
-export([
%%    init_many_people_boss_room/0,   %% 初始化机器人房间

    get_room_list/1,                %% rpc:call 获得房间列表

    handle_get_room_mission_id/2,   %% 获得房间副本id
    handle_create_room/5,           %% 创建房间
    handle_join_room/5,             %% 加入房间
    handle_start/1,
    handle_kick_out_player/2,       %% 踢出玩家
    handle_ready/2,                 %% 准备
    handle_leave_room/2,            %% 离开房间
    handle_mission_leave/2,         %% 玩家离开副本
    handle_login_game/1,            %% 玩家登录游戏

    handle_mission_balance/4,       %% 副本结算

    get_pos_limit/0
]).

-define(SHI_SHI_ROOM_PLAYER_NUM_LIMIT, 6).

%% ================================================ FUN ================================================

%% @doc 获得房间副本id
handle_get_room_mission_id(RoomId, _InvitationCode) when RoomId > 0 ->
    case ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId) of
        null ->
            0;
        EtsRoomData ->
            #ets_shi_shi_room_data{
                mission_id = MissionId
            } = EtsRoomData,
            MissionId
    end;
handle_get_room_mission_id(_RoomId, InvitationCode) ->
    RoomId = dict_select(?DICT_SHI_SHI_ROOM_INVITATION_CODE, InvitationCode),
    ?DEBUG("查询房间id ~p", [{_RoomId, InvitationCode, RoomId}]),
    case ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId) of
        null ->
            0;
        EtsRoomData ->
            #ets_shi_shi_room_data{
                mission_id = MissionId
            } = EtsRoomData,
            MissionId
    end.

%%%% @doc 初始化多人boss房间
%%init_many_people_boss_room() ->
%%    BossIdList = t_mission_many_people_boss:get_keys(),
%%
%%    {MaxVipLevel} = lists:last(t_vip_level:get_keys()),
%%    {MaxLevel} = lists:last(t_role_experience:get_keys()),
%%
%%    lists:foldl(
%%        fun({BossId}, RobotPlayerId) ->
%%            NewRoomId = dict_select(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID) + 1,
%%            InvitationCode = get_unique_invitation_code(),
%%
%%            #t_mission_many_people_boss{
%%                create_condition_list = CreateConditionList
%%            } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
%%
%%            {VipLevel, Level} =
%%                case CreateConditionList of
%%                    [vip_level, VipLevel1] ->
%%                        {util_random:random_number(VipLevel1, MaxVipLevel), util_random:random_number(MaxLevel)};
%%                    [level, Level1] ->
%%                        {util_random:random_number(MaxVipLevel), util_random:random_number(Level1, MaxLevel)};
%%                    _ ->
%%                        {util_random:random_number(MaxVipLevel), util_random:random_number(MaxLevel)}
%%                end,
%%
%%            {Sex, Name} = random_name:get_name(),
%%
%%            OwnerPosData = #many_people_boss_room_pos_data{
%%                pos_id = 0,
%%                is_ready = ?TRUE,
%%                player_id = RobotPlayerId,
%%                model_head_figure = api_player:pack_model_head_figure(
%%                    #modelheadfigure{
%%                        player_id = RobotPlayerId,
%%                        sex = Sex,
%%                        nickname = util:to_binary("s1." ++ Name),
%%                        head_id = 0,
%%                        vip_level = VipLevel,
%%                        level = Level
%%                    }
%%                ),
%%                is_owner = ?TRUE,
%%                state = 0
%%            },
%%
%%            EtsRoomData = #ets_many_people_boss_room_data{
%%                room_id = NewRoomId,
%%                boss_id = BossId,
%%                invitation_code = InvitationCode,
%%                is_lock = ?FALSE,
%%                password = "",
%%                owner_pos_data = OwnerPosData,
%%                is_participate_in = ?FALSE,
%%                is_all_ready_auto_start = ?TRUE,
%%                pos_data_list = [],
%%                kick_player_list = [],
%%                state = ?FALSE,
%%                is_robot_room = true
%%            },
%%
%%            UpdateData =
%%                fun() ->
%%                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, InvitationCode, NewRoomId),
%%                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID, NewRoomId),
%%%%                    dict_write_data(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, RobotPlayerId, NewRoomId),
%%                    ets_write(EtsRoomData)
%%                end,
%%            UpdateData(),
%%            RobotPlayerId + 1
%%        end,
%%        1, BossIdList
%%    ).


%% @doc 获得房间列表
get_room_list(MissionId) when MissionId > 0 ->
    ets:select(
        ?ETS_SHI_SHI_ROOM_DATA,
        [{
            #ets_shi_shi_room_data{
                mission_id = MissionId,
                state = '$1',
                _ = '_'
            },
            [{'<', '$1', ?TRUE}], ['$_']}
        ]
    );
get_room_list(_) ->
    ets:select(
        ?ETS_SHI_SHI_ROOM_DATA,
        [{
            #ets_shi_shi_room_data{
                state = '$1',
                _ = '_'
            },
            [{'<', '$1', ?TRUE}], ['$_']}
        ]
    ).

%% @doc 创建房间
handle_create_room(PlayerId, MissionId, IsLock, Password, {PlatformId, ServerId, ModelHeadFigure}) ->
    ?ASSERT(dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) =:= null, ?ERROR_ALREADY_JOIN_ROOM),

    ?IF(IsLock, ?ASSERT(Password =/= 0, ?ERROR_NONE), noop),

    NewRoomId = dict_select(?DICT_SHI_SHI_ROOM_MAX_ROOM_ID) + 1,
    InvitationCode = get_unique_invitation_code(),

    OwnerPosData = #shi_shi_pos_data{
        pos_id = 1,
        is_ready = true,
        player_id = PlayerId,
        model_head_figure = ModelHeadFigure,
        is_owner = true
    },

    EtsRoomData = #ets_shi_shi_room_data{
        room_id = NewRoomId,
        mission_id = MissionId,
        invitation_code = InvitationCode,
        is_lock = IsLock,
        password = Password,
        owner_player_id = PlayerId,
        pos_data_list = [OwnerPosData],
        kick_player_list = [],
        state = ?FALSE
    },

    dict_write_data(?DICT_SHI_SHI_ROOM_INVITATION_CODE, InvitationCode, NewRoomId),
    dict_write_data(?DICT_SHI_SHI_ROOM_MAX_ROOM_ID, NewRoomId),
    dict_write_data(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId, NewRoomId),
    ets_write(EtsRoomData),

    mod_player:update_player_server_data_init(PlayerId, PlatformId, ServerId),
    {ok, EtsRoomData}.

%% @doc 加入房间
handle_join_room(PlayerId, RoomId, Password, _InvitationCode, PlayerData) when RoomId > 0 ->
    handle_join_room_1(PlayerId, RoomId, Password, true, PlayerData);
handle_join_room(PlayerId, _RoomId, _Password, InvitationCode, PlayerData) ->
    RoomId = dict_select(?DICT_SHI_SHI_ROOM_INVITATION_CODE, InvitationCode),
    handle_join_room_1(PlayerId, RoomId, 0, false, PlayerData).
handle_join_room_1(PlayerId, RoomId, Password, IsUsePassword, {PlatformId, ServerId, ModelHeadFigure}) ->
    ?ASSERT(dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) =:= null, ?ERROR_ALREADY_JOIN_ROOM),
    EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
    ?ASSERT(EtsRoomData =/= null, ?ERROR_NONE),
    #ets_shi_shi_room_data{
        pos_data_list = PosDataList,
        is_lock = IsLock,
        password = RoomPassWord,
        state = State,
%%        owner_pos_data = OwnerPosData,
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
    ?IF(IsLock andalso IsUsePassword, ?ASSERT(RoomPassWord =:= Password, ?ERROR_ERROR_PASSWORD), noop),
    PeopleNum = length(PosDataList),
    ?ASSERT(PeopleNum < ?SHI_SHI_ROOM_PLAYER_NUM_LIMIT, ?ERROR_NOT_AUTHORITY),

    PosData = #shi_shi_pos_data{
        pos_id = get_null_pos_id(PosDataList, ?SHI_SHI_ROOM_PLAYER_NUM_LIMIT),
        is_ready = false,
        player_id = PlayerId,
        model_head_figure = ModelHeadFigure,
        is_owner = false
    },

    NewPosDataList = [PosData | PosDataList],

    NewEtsRoomData = EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosDataList},


    ets_write(NewEtsRoomData),
    dict_write_data(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId, RoomId),
    notice_fun([ThisPosData#shi_shi_pos_data.player_id || ThisPosData <- PosDataList], notice_player_join, [PosData]),

    mod_player:update_player_server_data_init(PlayerId, PlatformId, ServerId),
%%    try_start(NewEtsRoomData),
    {ok, NewEtsRoomData}.

%% @doc 开始游戏
handle_start(PlayerId) ->
    case dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) of
        null ->
            exit(?ERROR_FAIL);
        RoomId ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                mission_id = MissionId,
                owner_player_id = OwnerPlayerId,
                pos_data_list = PosDataList,
                state = State
            } = EtsRoomData,
            ?ASSERT(State =:= ?FALSE, ?ERROR_ALREADY_START),
            ?ASSERT(OwnerPlayerId =:= PlayerId, ?ERROR_NOT_AUTHORITY),
            PeopleNum = length(PosDataList),
            ?ASSERT(PeopleNum > 1, ?ERROR_NOT_ENOUGH_NUMBER),
            IsAllReady = get_is_all_ready(PosDataList),
            ?ASSERT(IsAllReady, ?ERROR_NO_CONDITION),
            PlayerIdList = [PosData#shi_shi_pos_data.player_id || PosData <- PosDataList],
            {ok, MissionWorker} = mod_mission_shi_shi_room:create_mission(RoomId, MissionId, PlayerIdList),
            notice_fun(PlayerIdList, notice_player_fight_start, []),
            NewEtsRoomData = EtsRoomData#ets_shi_shi_room_data{
                state = ?TRUE,
                mission_worker = MissionWorker
            },
            ets_write(NewEtsRoomData)
    end,
    ok.

%% @doc 踢出玩家
handle_kick_out_player(PlayerId, PosId) ->
    case dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                pos_data_list = PosDataList,
                owner_player_id = OwnerPlayerId,
                state = State,
                kick_player_list = KickPlayerList
            } = EtsRoomData,
            if
                OwnerPlayerId =:= PlayerId andalso State =:= ?FALSE ->
                    case lists:keytake(PosId, #shi_shi_pos_data.pos_id, PosDataList) of
                        {value, ThisPosData, NewPosList} ->
                            ThisPlayerId = ThisPosData#shi_shi_pos_data.player_id,
                            if
                                ThisPlayerId =/= PlayerId ->
                                    Now = util_time:timestamp(),
                                    NewKickPlayerList = [{ThisPlayerId, Now}] ++ [{KickPlayerId, KickPlayerTime} || {KickPlayerId, KickPlayerTime} <- KickPlayerList, Now > KickPlayerTime + 10],

                                    ets_write(EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosList, kick_player_list = NewKickPlayerList}),
                                    notice_fun(ThisPlayerId, notice_leave_room, [?SHI_SHI_ROOM_LEAVE_ROOM_TYPE1]),
                                    dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, ThisPlayerId),

                                    notice_fun([PosData#shi_shi_pos_data.player_id || PosData <- NewPosList], notice_player_leave, [PosId]);
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

%% @doc 准备
handle_ready(PlayerId, IsReady) ->
    case dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) of
        null ->
            exit(?ERROR_FAIL);
        RoomId ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                pos_data_list = PosDataList,
                state = State
            } = EtsRoomData,
            case State of
                ?FALSE ->
                    {IsUpdate, NewPosDataList, NewPosData} =
                        lists:foldl(
                            fun(PosData, {TmpIsUpdate, TmpPosDataList, TmpChangePosData}) ->
                                #shi_shi_pos_data{
                                    player_id = PosPlayerId,
                                    is_ready = PosIsReady
                                } = PosData,
                                case PlayerId =:= PosPlayerId andalso IsReady =/= PosIsReady of
                                    true ->
                                        ChangePosData1 = PosData#shi_shi_pos_data{is_ready = IsReady},
                                        {true, [ChangePosData1 | TmpPosDataList], ChangePosData1};
                                    false ->
                                        {TmpIsUpdate, [PosData | TmpPosDataList], TmpChangePosData}
                                end
                            end,
                            {false, [], ?UNDEFINED}, PosDataList
                        ),
                    if
                        IsUpdate ->
                            NewEtsRoomData = EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosDataList},
                            ets_write(NewEtsRoomData),
                            #shi_shi_pos_data{
                                pos_id = ArgPosId,
                                is_ready = ArgIsReady
                            } = NewPosData,
                            notice_fun(
                                [ThisPlayerId || #shi_shi_pos_data{player_id = ThisPlayerId} <- NewPosDataList],
                                notice_player_ready,
                                [ArgPosId, ArgIsReady]
                            );
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
    case dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                room_id = RoomId,
                pos_data_list = PosDataList,
                owner_player_id = OwnerPlayerId,
                state = State
            } = EtsRoomData,

            IsOwner = OwnerPlayerId =:= PlayerId,

            case State of
                ?FALSE ->
                    case lists:keytake(PlayerId, #shi_shi_pos_data.player_id, PosDataList) of
                        false ->
                            ?ERROR("handle_leave_room——bug~p", [{PlayerId, IsLeaveGame, EtsRoomData}]),
                            dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId),
                            noop;
                        {value, PosData, NewPosDataList} ->
                            if
                                NewPosDataList =:= [] ->
                                    ets_delete_data(?ETS_SHI_SHI_ROOM_DATA, RoomId),
                                    dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId),
                                    ?IF(IsLeaveGame, noop, notice_fun(PlayerId, notice_leave_room, [?SHI_SHI_ROOM_LEAVE_ROOM_TYPE3]));
                                true ->
                                    {NewOwnerPlayerId, NewPosDataList2, NewOwnerPosId} =
                                        if
                                            IsOwner ->
                                                [OwnerPosData | NewPosDataList1] = lists:sort(
                                                    fun(A, B) ->
                                                        A#shi_shi_pos_data.pos_id < B#shi_shi_pos_data.pos_id
                                                    end
                                                    , NewPosDataList),
                                                {OwnerPosData#shi_shi_pos_data.player_id, [OwnerPosData#shi_shi_pos_data{is_ready = false, is_owner = true} | NewPosDataList1], OwnerPosData#shi_shi_pos_data.pos_id};
                                            true ->
                                                {OwnerPlayerId, NewPosDataList, PosData#shi_shi_pos_data.pos_id}
                                        end,
                                    PlayerIdList = [NewPosData#shi_shi_pos_data.player_id || NewPosData <- NewPosDataList],

                                    ets_write(EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosDataList2, owner_player_id = NewOwnerPlayerId}),
                                    dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId),
                                    ?IF(IsLeaveGame, noop, notice_fun(PlayerId, notice_leave_room, [?SHI_SHI_ROOM_LEAVE_ROOM_TYPE3])),
                                    notice_fun(PlayerIdList, notice_player_leave, [PosData#shi_shi_pos_data.pos_id]),
                                    ?IF(IsOwner, notice_fun(PlayerIdList, notice_room_owner_change, [NewOwnerPosId]), noop)
                            end
                    end;
                ?TRUE ->
                    case IsLeaveGame of
                        true ->
                            put(shi_shi_leave_room, [PlayerId | util:get_dict(shi_shi_leave_room, [])]);
%%                            GetNewOwnerPosDataFun =
%%                                fun() ->
%%                                    OwnerPosData#many_people_boss_room_pos_data{state = 2}
%%                                end,
%%                            GetNewPosDataListFun =
%%                                fun() ->
%%                                    {value, PosData, PosDataList1} = lists:keytake(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
%%                                    [PosData#many_people_boss_room_pos_data{state = 2}] ++ PosDataList1
%%                                end,
%%                            case OwnerPosData of
%%                                ?UNDEFINED ->
%%                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun()});
%%                                _ ->
%%                                    if
%%                                        IsOwner andalso IsParticipateIn =:= ?TRUE ->
%%                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun(), owner_pos_data = GetNewOwnerPosDataFun()});
%%                                        IsOwner ->
%%                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{owner_pos_data = GetNewOwnerPosDataFun()});
%%                                        true ->
%%                                            ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = GetNewPosDataListFun()})
%%                                    end
%%%%                                #many_people_boss_room_pos_data{state = 2} ->
%%%%                                    noop
%%                            end;
                        false ->
                            noop
%%                            if
%%                                IsOwner andalso IsParticipateIn =:= ?TRUE ->
%%                                    NewPosDataList = lists:keydelete(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
%%                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList, owner_pos_data = ?UNDEFINED});
%%                                IsOwner ->
%%                                    exit(?ERROR_FAIL);
%%                                true ->
%%                                    NewPosDataList = lists:keydelete(PlayerId, #many_people_boss_room_pos_data.player_id, PosDataList),
%%                                    ets_write(EtsRoomData#ets_many_people_boss_room_data{pos_data_list = NewPosDataList})
%%                            end,
%%                            dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId)
                    end
            end
    end.

%%%% @doc 关闭房间
%%close_room(EtsRoomData) ->
%%    #ets_many_people_boss_room_data{
%%        pos_data_list = PosDataList,
%%        owner_pos_data = OwnerPosData,
%%        state = RoomState
%%    } = EtsRoomData,
%%    if
%%        RoomState =:= ?TRUE ->
%%            noop;
%%        true ->
%%            #many_people_boss_room_pos_data{
%%                player_id = OwnerPlayerId
%%            } = OwnerPosData,
%%            notice_fun(OwnerPlayerId, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE3]),
%%            NoticePlayerIdList = [PlayerId || #many_people_boss_room_pos_data{player_id = PlayerId, state = PosState} <- PosDataList, PosState =:= 0, PlayerId =/= OwnerPlayerId],
%%            notice_fun(NoticePlayerIdList, notice_leave_room, [?MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE2])
%%    end,
%%    ?IF(OwnerPosData =/= ?UNDEFINED, dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, OwnerPosData#many_people_boss_room_pos_data.player_id), noop),
%%    [dict_delete(?DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, PlayerId) || #many_people_boss_room_pos_data{player_id = PlayerId, is_owner = IsOwner} <- PosDataList, IsOwner =:= ?FALSE],
%%    ets_delete_data(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, EtsRoomData#ets_many_people_boss_room_data.room_id),
%%    dict_delete(?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, EtsRoomData#ets_many_people_boss_room_data.invitation_code).

%% @doc 副本结算
handle_mission_balance(RoomId, PlayerIdList, RankList, AwardValue) ->
    EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
    #ets_shi_shi_room_data{
        room_id = RoomId,
        owner_player_id = OwnerPlayerId,
        pos_data_list = PosDataList
    } = EtsRoomData,

    SortPosDataList0 = lists:sort(PosDataList),
    SortPosDataList = [SortPosData#shi_shi_pos_data{is_ready = false} || SortPosData = #shi_shi_pos_data{player_id = PosPlayerId} <- SortPosDataList0, lists:member(PosPlayerId, PlayerIdList)],

    HurtList = [{{PlayerId, Name}, Hurt} || #hurtranking{player_id = PlayerId, player_name = Name, hurt = Hurt} <- RankList],
    {WinPlayerId, WinPlayerName} =
        if
            RankList =:= [] ->
                {?UNDEFINED, ?UNDEFINED};
            true ->
                util_random:get_probability_item(HurtList)
        end,

    NewEtsRoomData =
        if
            SortPosDataList =:= [] ->
                ets_delete_data(?ETS_SHI_SHI_ROOM_DATA, RoomId),
                ?UNDEFINED;
            true ->
                case lists:keyfind(OwnerPlayerId, #shi_shi_pos_data.player_id, SortPosDataList) of
                    false ->
                        [NewOwnerPosData | NewSortPosDataList] = SortPosDataList,
                        NewOwnerPlayerId = NewOwnerPosData#shi_shi_pos_data.player_id,
                        NewOwnerPosData1 = NewOwnerPosData#shi_shi_pos_data{is_owner = true},
                        ets_write(EtsRoomData#ets_shi_shi_room_data{owner_player_id = NewOwnerPlayerId, pos_data_list = [NewOwnerPosData1 | NewSortPosDataList], state = 0, mission_worker = ?UNDEFINED});
                    _ ->
                        ets_write(EtsRoomData#ets_shi_shi_room_data{pos_data_list = SortPosDataList, state = 0, mission_worker = ?UNDEFINED})
                end
        end,

    lists:foreach(
        fun(PosData) ->
            #shi_shi_pos_data{
                player_id = PlayerId
            } = PosData,
            IsWinPlayer = (PlayerId =:= WinPlayerId),
            IsInRoom = lists:member(PlayerId, PlayerIdList),
            ?IF(IsInRoom, noop, dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId)),
            Node = mod_player:get_game_node(PlayerId),
            AwardList =
                if
                    IsWinPlayer ->
                        [{?ITEM_GOLD, AwardValue}];
                    true ->
                        []
                end,

            TotalCostValue =
                case lists:keyfind(PlayerId, #hurtranking.player_id, RankList) of
                    false ->
                        0;
                    HurtRanking ->
                        HurtRanking#hurtranking.hurt
                end,

            catch mod_apply:apply_to_online_player(Node, PlayerId, mod_shi_shi_room, mission_balance_give_award, [PlayerId, AwardList, IsInRoom, NewEtsRoomData, WinPlayerName, TotalCostValue, WinPlayerId], game_worker)
%%            mod_apply:apply_to_online_player(OwnerNode, PlayerId, mod_many_people_boss, mission_owner_fight_result, [PlayerId, OwnerAwardMana, EtsRoomData1], game_worker))
        end,
        PosDataList
    ),

    {ok, WinPlayerId}.

%% @doc  离开副本
handle_mission_leave(RoomId, PlayerId) ->
    List = util:get_dict(shi_shi_leave_room, []),
    case lists:member(PlayerId, List) of
        true ->
            put(shi_shi_leave_room, lists:delete(PlayerId, List)),
            false;
        false ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                owner_player_id = OwnerPlayerId,
                pos_data_list = PosDataList
            } = EtsRoomData,
            case lists:keytake(PlayerId, #shi_shi_pos_data.player_id, PosDataList) of
                false ->
                    true;
                {value, _PosData, NewPosDataList} ->
                    dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId),
                    if
                        OwnerPlayerId =:= PlayerId ->
                            ets_write(EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosDataList, owner_player_id = 0});
                        true ->
                            ets_write(EtsRoomData#ets_shi_shi_room_data{pos_data_list = NewPosDataList})
                    end,
                    true
            end
    end.

%% @doc  登录游戏
handle_login_game(PlayerId) ->
    case dict_select(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId) of
        null ->
            noop;
        RoomId ->
            EtsRoomData = ets_select(?ETS_SHI_SHI_ROOM_DATA, RoomId),
            #ets_shi_shi_room_data{
                mission_id = MissionId,
                pos_data_list = PosDataList,
                state = RoomState,
                mission_worker = MissionWorker
            } = EtsRoomData,
            case RoomState of
                ?FALSE ->
                    handle_leave_room(PlayerId, true),
                    noop;
                ?TRUE ->
                    case lists:keytake(PlayerId, #shi_shi_pos_data.player_id, PosDataList) of
                        false ->
                            dict_delete(?DICT_SHI_SHI_ROOM_PLAYER_ROOM, PlayerId),
                            ?ERROR("数据有问题~p", [{PlayerId, EtsRoomData}]);
%%                            handle_leave_room(PlayerId, true);
                        {value, _PosData, _PosDataList1} ->
                            MissionType = ?MISSION_TYPE_MANY_PEOPLE_SHISHI,
                            SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
                            {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
                            Node = mod_player:get_game_node(PlayerId),
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_shi_shi_room, player_enter_mission, [PlayerId, [MissionWorker, SceneId, X, Y, [], null], MissionId], normal),
                            shi_shi_room
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
    rpc:cast(Node, api_shi_shi_room, F, [PlayerId | A]);
notice_fun(PlayerIdList, F, A) when is_list(PlayerIdList) ->
    lists:foreach(
        fun(PlayerId) ->
            notice_fun(PlayerId, F, A)
        end,
        PlayerIdList
    ).

%% @doc 获得是否全部准备
get_is_all_ready(PosDataList) ->
    lists:all(
        fun(PosData) ->
            #shi_shi_pos_data{
                is_ready = IsReady,
                is_owner = IsOwner
            } = PosData,
            IsReady orelse IsOwner
        end,
        PosDataList
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
    ?IF(dict_select(?DICT_SHI_SHI_ROOM_INVITATION_CODE, RandomKey) =:= null, RandomKey, get_unique_invitation_code(Times - 1));
get_unique_invitation_code(_) ->
    ?ERROR("防止bug，无限循环"),
    exit(?ERROR_FAIL).

%% @doc 获得房间人数限制
get_pos_limit() ->
    ?SHI_SHI_ROOM_PLAYER_NUM_LIMIT.

%% @doc 获得空的位置id
get_null_pos_id(PosDataList, LimitPosId) ->
    get_null_pos_id(PosDataList, 1, LimitPosId).
get_null_pos_id(PosDataList, CurrPosId, LimitPosId) ->
    case lists:keytake(CurrPosId, #shi_shi_pos_data.pos_id, PosDataList) of
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
ets_write(EtsData) when is_record(EtsData, ets_shi_shi_room_data) ->
%%    ?DEBUG("写入ETS——DATA：~p", [EtsData]),
    ets_write_data(?ETS_SHI_SHI_ROOM_DATA, EtsData#ets_shi_shi_room_data.room_id, EtsData).
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
