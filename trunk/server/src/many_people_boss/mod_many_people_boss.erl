%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人boss
%%% @end
%%% Created : 25. 十一月 2020 下午 05:39:59
%%%-------------------------------------------------------------------
-module(mod_many_people_boss).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("many_people_boss.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("error.hrl").

%% API
-export([
    get_room_list/2,
    join_room/4,
    create_room/4,
    start/1,
    participate_in/2,
    kick_out_player/2,
    set_is_all_ready_start_tos/2,
    ready/2,
    leave_room/1,
    leave_room/2,

    mission_balance_give_award/8,
    player_enter_mission/5,
    player_enter_game/1,
    mission_owner_fight_result/3,

    get_t_mission_many_people_boss/1
]).

%% @doc 获得房间列表
get_room_list(PlayerId, BossId) ->
    case mod_function:is_open(PlayerId, ?FUNCTION_MISSION_MANY_PEOPLE_BOSS) of
        true ->
            List = many_people_boss_srv:rpc_call(get_room_list, [BossId]),
            get_list(List);
        false ->
            []
    end.

get_list(List) ->
    get_list(List, [], 100).
get_list([], NewList, _Limit) ->
    NewList;
get_list(_List, NewList, 0) ->
    NewList;
get_list([EtsData | List], NewList, Limit) ->
    #ets_many_people_boss_room_data{
        boss_id = BossId,
        pos_data_list = PosDatalist
    } = EtsData,
    case length(PosDatalist) < many_people_boss_srv_mod:get_pos_limit(BossId) of
        true ->
            get_list(List, [EtsData | NewList], Limit - 1);
        false ->
            get_list(List, NewList, Limit)
    end.

%% @doc 加入房间
join_room(PlayerId, RoomId, Password, InvitationCode) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_MISSION_MANY_PEOPLE_BOSS),
    many_people_boss_srv:call({?MANY_PEOPLE_BOSS_JOIN_ROOM, PlayerId, RoomId, util:to_list(Password), util:to_list(InvitationCode), get_player_condition_map(PlayerId), get_player_data(PlayerId)}).

%% @doc 创建房间
create_room(PlayerId, BossId, IsLock, Password) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_MISSION_MANY_PEOPLE_BOSS_ROOM),
    ?IF(IsLock =:= ?TRUE, ?ASSERT(length(Password) =< 20, ?ERROR_FAIL), noop),
    many_people_boss_srv:call({?MANY_PEOPLE_BOSS_CREATE_ROOM, PlayerId, BossId, IsLock, Password, get_player_condition_map(PlayerId), get_player_data(PlayerId)}).

%% @doc 开始游戏
start(PlayerId) ->
    many_people_boss_srv:call({?MANY_PEOPLE_BOSS_START, PlayerId}).

%% @doc 房主参与游戏
participate_in(PlayerId, IsParticipateIn) ->
    many_people_boss_srv:call({?MANY_PEOPLE_BOSS_PARTICIPATE_IN, PlayerId, IsParticipateIn, get_player_condition_map(PlayerId)}).

%% @doc 踢出玩家
kick_out_player(PlayerId, PosId) ->
    many_people_boss_srv:cast({?MANY_PEOPLE_BOSS_KICK_OUT_PLAYER, PlayerId, PosId}).

%% @doc 设置全部准备自动开始
set_is_all_ready_start_tos(PlayerId, IsAllReadyStart) ->
    many_people_boss_srv:cast({?MANY_PEOPLE_BOSS_SET_ALL_READY_START, PlayerId, IsAllReadyStart}).

%% @doc 准备
ready(PlayerId, IsReady) ->
    many_people_boss_srv:call({?MANY_PEOPLE_BOSS_READY, PlayerId, IsReady, get_player_condition_map(PlayerId)}),
    ok.

%% @doc 离开房间
leave_room(PlayerId) ->
    leave_room(PlayerId, false).
leave_room(PlayerId, IsLeaveGame) ->
    many_people_boss_srv:cast({?MANY_PEOPLE_BOSS_LEAVE_ROOM, PlayerId, IsLeaveGame}).

%% @doc 副本房主战斗结算
mission_owner_fight_result(PlayerId, 0, EtsRoomData) ->
    api_many_people_boss:notice_owner_fight_result(PlayerId, 0, EtsRoomData);
mission_owner_fight_result(PlayerId, Mana, EtsRoomData) ->
    Tran =
        fun() ->
            mod_award:give(PlayerId, [[?ITEM_GOLD, Mana]], ?LOG_TYPE_MANY_PEOPLE_BOSS)
        end,
    db:do(Tran),
    api_many_people_boss:notice_owner_fight_result(PlayerId, Mana, EtsRoomData).

%% @doc 副本结算给奖励
mission_balance_give_award(PlayerId, IsSendMail, IsFirstPrize, PropList, EtsRoomData, R, Result, PlayerNameStr) ->
    if
        IsSendMail ->
            if
                PropList =/= [] ->
                    mod_mail:add_mail_item_list(PlayerId, ?MAIL_MANY_PEOPLE_BOSS_MISSION_MAIL, PropList, ?LOG_TYPE_MANY_PEOPLE_BOSS);
                true ->
                    mod_mail:add_mail_id(PlayerId, ?MAIL_MANY_PEOPLE_BOSS_MISSION_FAIL_MAIL, ?LOG_TYPE_MANY_PEOPLE_BOSS)
            end;
        true ->
            if
                PropList =/= [] ->
                    Tran =
                        fun() ->
                            mod_award:give(PlayerId, PropList, ?LOG_TYPE_MANY_PEOPLE_BOSS)
                        end,
                    db:do(Tran);
                true ->
                    noop
            end,
            api_many_people_boss:notice_player_fight_result(PlayerId, IsFirstPrize, PropList, EtsRoomData, R, Result, PlayerNameStr)
    end.

%% @doc 玩家进入副本
player_enter_mission(PlayerId, CostMana, IsCostMana, [MissionSceneWorker, SceneId, X, Y, [], null], MissionId) ->
    if
        IsCostMana ->
            if
                CostMana > 0 ->
                    CostItemList = [[?ITEM_GOLD, CostMana]],
                    case mod_prop:check_prop_num(PlayerId, CostItemList) of
                        true ->
                            Tran =
                                fun() ->
                                    mod_prop:decrease_player_prop(PlayerId, CostItemList, ?LOG_TYPE_MANY_PEOPLE_BOSS)
                                end,
                            db:do(Tran),
                            ?DEBUG("玩家(~p)准备进入场景:~p~n", [PlayerId, {MissionSceneWorker, SceneId, X, Y, [], null}]),
                            api_many_people_boss:notice_player_fight_start(PlayerId, ?UNDEFINED),
                            mod_scene:player_prepare_enter_scene(PlayerId, MissionSceneWorker, SceneId, X, Y, [], null),
                            api_mission:notice_challenge_mission(PlayerId, ?MISSION_TYPE_MANY_PEOPLE_BOSS, MissionId);
                        false ->
                            leave_room(PlayerId)
                    end;
                true ->
                    ?DEBUG("玩家(~p)准备进入场景:~p~n", [PlayerId, {MissionSceneWorker, SceneId, X, Y, [], null}]),
                    ?INFO("场景灵力值配置为0,~p", [SceneId]),
                    api_many_people_boss:notice_player_fight_start(PlayerId, ?UNDEFINED),
                    mod_scene:player_prepare_enter_scene(PlayerId, MissionSceneWorker, SceneId, X, Y, [], null),
                    api_mission:notice_challenge_mission(PlayerId, ?MISSION_TYPE_MANY_PEOPLE_BOSS, MissionId)
            end;
        true ->
            ?DEBUG("玩家(~p)准备进入场景:~p~n", [PlayerId, {MissionSceneWorker, SceneId, X, Y, [], null}]),
            mod_scene:player_prepare_enter_scene(PlayerId, MissionSceneWorker, SceneId, X, Y, [], null),
            api_mission:notice_challenge_mission(PlayerId, ?MISSION_TYPE_MANY_PEOPLE_BOSS, MissionId)
    end.

%% @doc 玩家进入游戏
player_enter_game(PlayerId) ->
    many_people_boss_srv:player_enter_game(PlayerId).

get_player_condition_map(PlayerId) ->
    PlayerConditionMap = maps:new(),
    get_player_condition_map_1(PlayerId, [?MANY_PEOPLE_BOSS_CONDITION_MANA, ?MANY_PEOPLE_BOSS_CONDITION_LEVEL, ?MANY_PEOPLE_BOSS_CONDITION_VIP_LEVEL], PlayerConditionMap).
get_player_condition_map_1(_PlayerId, [], PlayerConditionMap) ->
    PlayerConditionMap;
get_player_condition_map_1(PlayerId, [Key | List], PlayerConditionMap) ->
    Value =
        case Key of
            ?MANY_PEOPLE_BOSS_CONDITION_MANA ->
                mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD);
            ?MANY_PEOPLE_BOSS_CONDITION_LEVEL ->
                mod_player:get_player_data(PlayerId, level);
            ?MANY_PEOPLE_BOSS_CONDITION_VIP_LEVEL ->
                mod_vip:get_vip_level(PlayerId)
        end,
    get_player_condition_map_1(PlayerId, List, maps:put(Key, Value, PlayerConditionMap)).

get_player_data(PlayerId) ->
    ServerId = mod_player:get_player_server_id(PlayerId),
    PlatformId = mod_server_config:get_platform_id(),
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    {PlatformId, ServerId, ModelHeadFigure}.

%%put_player_many_data(Result) ->
%%    case Result of
%%        {ok, EtsRoomData} ->
%%            #ets_many_people_boss_room_data{
%%                room_id = RoomId,
%%                boss_id = BossId
%%            } = EtsRoomData,
%%            put(many_player_data, {RoomId, BossId});
%%        _ ->
%%            noop
%%    end.
%%
%%get_player_many_data() ->
%%    get(many_player_data).
%%
%%delete_player_many_data() ->
%%    erase(many_player_data).

%%%% ================================================ 模板操作 ================================================

get_t_mission_many_people_boss(BossId) ->
    t_mission_many_people_boss:assert_get({BossId}).
