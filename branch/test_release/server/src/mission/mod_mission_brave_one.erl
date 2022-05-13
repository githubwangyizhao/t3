%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc    勇敢者副本
%%% @end
%%% Created : 13. 3月 2021 上午 11:29:27
%%%-------------------------------------------------------------------
-module(mod_mission_brave_one).
-author("Administrator").

%% API
-export([
    handle_init_mission/1,          % 初始化副本
    monster_enter_mission/1,
    handle_monster_death/2,
    handle_assert_fight/1,          % 校验是否可以战斗
    handle_enter_mission/1,         % 玩家进入副本
    handle_leave_mission/1,         % 玩家退出副本
    handle_balance/1                % 结算副本
]).

-export([
    get_mission_scene_worker/1,     % 是否可以进入场景
    is_enter_mission/1,             % 是否可以进入场景
    ready_start/0,
    notice_start_fight/0
]).

-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("mission.hrl").
-include("brave_one.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

-define(MISSION_BRAVE_ONE_READY_START_TIME, 5).  % 副本等待开始时间(双方进入后)

-define(MISSION_BRAVE_ONE_CAN_PLAYER_LIST, mission_brave_one_can_player_list).  % 可以进入玩家列表
-define(MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, mission_brave_one_enter_player_list).  % 进入玩家列表
-define(MISSION_BRAVE_ONE_MONSTER_LIST, mission_brave_one_monster_list).  % 怪物列表


-define(MISSION_BRAVE_ONE_INIT_WAIT_TIME_DICT, mission_brave_one_init_wait_time_dict).    % 初始等待时间
-define(MISSION_BRAVE_ONE_TIMER_DICT, mission_brave_one_timer_dict).  % 时间字典记录
-define(MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT, mission_brave_one_fight_player_id_dict).    % 当前挑战玩家
-define(MISSION_BRAVE_ONE_MONSTER_ID_DICT, mission_brave_one_monster_id_dict).    % 中奖的怪物id


%% ----------------------------------
%% @doc 	初始化副本
%% ----------------------------------
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Key, Value}) ->
            put(Key, Value)
        end, ExtraDataList),

    put(?MISSION_BRAVE_ONE_CAN_PLAYER_LIST, [util:get_dict(main_player_id, 0), util:get_dict(fight_player_id, 0)]),

    InitEnterTimeRef = erlang:send_after(?SD_GROUP_MISSION_WAIT_TIME * ?SECOND_MS, self(), ?MSG_BRAVE_ONE_INIT_CHECK_SCENE),
    util:update_timer_value(?MISSION_BRAVE_ONE_TIMER_DICT, InitEnterTimeRef),
    put(?MISSION_BRAVE_ONE_INIT_WAIT_TIME_DICT, util_time:timestamp() + ?SD_GROUP_MISSION_WAIT_TIME).

%% 怪物进入副本
monster_enter_mission(MonsterObjId) ->
    MonsterObjIdList = util:get_dict(?MISSION_BRAVE_ONE_MONSTER_LIST, []),
    put(?MISSION_BRAVE_ONE_MONSTER_LIST, [MonsterObjId | MonsterObjIdList]),
    noop.

%% 处理怪物死亡
handle_monster_death(_PlayerId, MonsterObjId) ->
    AwardMonsterObjId = get(?MISSION_BRAVE_ONE_MONSTER_ID_DICT),
    if
        AwardMonsterObjId == MonsterObjId ->
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        true ->
            notice_start_fight()
    end.

%% ----------------------------------
%% @    玩家进入副本
%% ----------------------------------
handle_enter_mission(PlayerId) ->
    CanEnterScenePlayerList = get(?MISSION_BRAVE_ONE_CAN_PLAYER_LIST),
    ?ASSERT(lists:member(PlayerId, CanEnterScenePlayerList), ?ERROR_NOT_ONLINE), % 玩家不在可进入列表
    NewCanEnterScenePlayerList = CanEnterScenePlayerList -- [PlayerId],
    put(?MISSION_BRAVE_ONE_CAN_PLAYER_LIST, NewCanEnterScenePlayerList),

    EnterScenePlayerList = util:get_dict(?MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, []),
    put(?MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, [PlayerId | EnterScenePlayerList]),

    if
        NewCanEnterScenePlayerList == [] ->
            ready_start();
        true ->
            InitWaitTime = get(?MISSION_BRAVE_ONE_INIT_WAIT_TIME_DICT),
            api_brave_one:wait_scene(PlayerId, InitWaitTime)
    end.

%% 准备开始
ready_start() ->
    EnterScenePlayerList = util:get_dict(?MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, []),
    EnterLen = length(EnterScenePlayerList),
    if
        EnterLen == 2 ->   %% 两个都进来了
            EnterScenePlayerList = get(?MISSION_BRAVE_ONE_CAN_PLAYER_LIST),
            SceneMonsterRIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
            MonsterObjId = hd(util_list:shuffle(SceneMonsterRIdList)),
            put(?MISSION_BRAVE_ONE_MONSTER_ID_DICT, MonsterObjId),

            FightStartTime = util_time:timestamp() + ?MISSION_BRAVE_ONE_READY_START_TIME,
            ReadyFightTimeRef = erlang:send_after(?MISSION_BRAVE_ONE_READY_START_TIME * ?SECOND_MS, self(), ?MSG_BRAVE_ONE_NEXT_FIGHT_PLAYER),
            util:update_timer_value(?MISSION_BRAVE_ONE_TIMER_DICT, ReadyFightTimeRef),

            lists:foreach(
                fun(NoticePlayerId) ->
                    api_brave_one:ready_start(NoticePlayerId, FightStartTime)
                end, mod_scene_player_manager:get_all_obj_scene_player_id());
        true ->
            mod_mission:send_msg(?MSG_MISSION_BALANCE)
    end.

%% 通知开始战斗时间
notice_start_fight() ->
    CurrFightPlayerId = util:get_dict(?MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT, 0),
    #db_brave_one{
        id = Id,
        pos_id = PosId,
        player_id = MainPlayerId,
        fight_player_id = FightPlayerId
    } = get_db_brave_one_or_scene(),
    NextPlayerId =
        if
            CurrFightPlayerId == 0 ->
                ?IF(PosId == 1, MainPlayerId, FightPlayerId);
            true ->
                EnterScenePlayerList = util:get_dict(?MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, []),
                hd(EnterScenePlayerList -- [CurrFightPlayerId])
        end,
    #t_mission_brave_one{
        round_time = RoundTime
    } =mod_brave_one:get_t_mission_brave_one(Id),
    FightEndTime = util_time:timestamp() + RoundTime,
    ReadyFightTimeRef = erlang:send_after(RoundTime * ?SECOND_MS, self(), ?MSG_BRAVE_ONE_NEXT_FIGHT_PLAYER),
    util:update_timer_value(?MISSION_BRAVE_ONE_TIMER_DICT, ReadyFightTimeRef),
    put(?MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT, NextPlayerId),

    lists:foreach(
        fun(NoticePlayerId) ->
            api_brave_one:fight_player(NoticePlayerId, NextPlayerId, FightEndTime)
        end, mod_scene_player_manager:get_all_obj_scene_player_id()).

%% 校验是否可以战斗
handle_assert_fight(PlayerId) ->
    ?ASSERT(util:get_dict(?MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT) == PlayerId, ?ERROR_NOT_AUTHORITY).

%% 玩家退出副本
handle_leave_mission(_PlayerId) ->
    noop.


%% 结算副本
handle_balance(_) ->
    util:update_timer_value(?MISSION_BRAVE_ONE_TIMER_DICT),
    EnterScenePlayerList = util:get_dict(?MISSION_BRAVE_ONE_ENTER_PLAYER_LIST, []),
    EnterLen = length(EnterScenePlayerList),
    #db_brave_one{
        id = Id,
        player_id = CreatePlayerId,
        fight_player_id = FightPlayerId
    } = get_db_brave_one_or_scene(),
    if
%%        EnterLen == 2 ->
%%            WinPlayerId = util:get_dist(?MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT, 0),
%%            WinModelHeadFigure =
%%                if
%%                    WinPlayerId > 0 -> call_player_game_head_figure(WinPlayerId);
%%                    true -> null
%%                end,
%%            lists:foreach(
%%                fun(NoticePlayerId) ->
%%                    cast_game_player(NoticePlayerId, mod_brave_one, mission_balance, [NoticePlayerId, Id, WinPlayerId, WinModelHeadFigure])
%%                end, mod_scene_player_manager:get_all_obj_scene_player_id());
        EnterLen == 1 ->
            WinPlayerId = hd(EnterScenePlayerList),
            ?INFO("勇敢者副本结算只进一个人:~p", [WinPlayerId]),
            cast_game_player(WinPlayerId, mod_brave_one, mission_balance, [WinPlayerId, Id, WinPlayerId, WinPlayerId]);
        EnterLen == 0 orelse EnterLen == 2 ->
            WinPlayerId = util:get_dict(?MISSION_BRAVE_ONE_FIGHT_PLAYER_ID_DICT, 0),
            WinModelHeadFigure =
                if
                    WinPlayerId > 0 -> call_player_game_head_figure(WinPlayerId);
                    true -> null
                end,
            ?INFO("勇敢者副本结算EnterLen:~p WinPlayerId:~p", [EnterLen, WinPlayerId]),
            lists:foreach(
                fun(NoticePlayerId) ->
                    cast_game_player(NoticePlayerId, mod_brave_one, mission_balance, [NoticePlayerId, Id, WinPlayerId, WinModelHeadFigure])
                end, [CreatePlayerId, FightPlayerId])
    end,
    scene_worker:stop(self(), 10 * ?SECOND_MS).


%% 场景中获得数据
get_db_brave_one_or_scene() ->
    brave_one_srv_mod:get_db_brave_one(util:get_dict(main_player_id)).

%% 是否可以进入场景
is_enter_mission(PlayerId) ->
    case get_mission_scene_worker(PlayerId) of
        SceneWorker when is_pid(SceneWorker) -> true;
        _ -> false
    end.
%% 获得副本场景进程
get_mission_scene_worker(PlayerId) ->
    brave_one_srv:call({?BRAVE_ONE_GET_WORKER, PlayerId}).

%% 游戏服获得玩家头像
call_player_game_head_figure(PlayerId) ->
    util:rpc_call(mod_player:get_game_node(PlayerId), api_player, pack_model_head_figure, [PlayerId]).

-spec cast_game_player(PlayerId, M, F, A) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()].
%% 通知玩家进程处理数据
cast_game_player(PlayerId, M, F, A) ->
    mod_apply:apply_to_online_player(mod_player:get_game_node(PlayerId), PlayerId, M, F, A, store).
