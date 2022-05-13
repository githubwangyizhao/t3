%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc    步步紧逼副本
%%% @end
%%% Created : 13. 3月 2021 下午 06:40:19
%%%-------------------------------------------------------------------
-module(mod_mission_step_by_step_sy).
-author("Administrator").

%% API
-export([
    enter/2,
    fight/1,
    get_award/1,
    fail_mission/2
]).

-export([
    mission_start_fight/0,
    mission_get_award/0
]).

-export([
    handle_init_mission/1,          % 初始化副本
    handle_monster_death/2,
    handle_assert_fight/1,          % 校验是否可以战斗
    handle_enter_mission/1,         % 玩家进入副本
    handle_leave_mission/1,         % 玩家退出副本
    handle_balance/1                % 结算副本
]).

-include("msg.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("mission.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").


-define(MISSION_STEP_BY_STEP_SY_FIGHT_TIME, 30).  % 多久内打死

-define(STEP_BY_STEP_SY_ID, step_by_step_sy_id).  % 时间字典记录
-define(MISSION_STEP_BY_STEP_SY_TIMER_DICT, mission_step_by_step_sy_timer_dict).  % 时间字典记录
-define(MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, mission_step_by_step_sy_monster_die_count_dict).    % 副本怪物死亡数量
-define(MISSION_STEP_BY_STEP_SY_MONSTER_AWARD_COUNT_DICT, mission_step_by_step_sy_monster_award_count_dict).% 副本怪物死亡数量中奖

%% 进入副本
enter(PlayerId, Id) ->
    OldId = util:get_dict(?STEP_BY_STEP_SY_ID, 0),
    ?ASSERT(OldId == 0, ?ERROR_ALREADY_HAVE),
    #t_mission_step_by_step_sy{
        cost_list = ItemList,
        enter_conditions_list = EnterConditionsList
    } = get_t_mission_step_by_step_sy(Id),

    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList) == true, ?ERROR_NOT_AUTHORITY),
    mod_prop:assert_prop_num(PlayerId, ItemList),
    {MissionType, MissionId} = get_mission_data(),

    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    ExtraDataList = [{?STEP_BY_STEP_SY_ID, Id}],
    put(?STEP_BY_STEP_SY_ID, Id),

    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, ItemList, ?LOG_TYPE_MISSION_STEP_BY_STEP_SY_FIGHT),
            mod_scene:player_enter_scene(PlayerId, SceneId, ExtraDataList)
        end,
    db:do(Tran),
    put(?STEP_BY_STEP_SY_ID, Id),
    ok.

%% 继续挑战
fight(PlayerId) ->
    OldId = util:get_dict(?STEP_BY_STEP_SY_ID, 0),
    ?ASSERT(OldId > 0, ?ERROR_NONE),
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    case gen_server:call(SceneWorker, ?MSG_SCENE_STEP_BY_STEP_SY_FIGHT_MSG) of
        {ok, Result} ->
            {ok, Result};
        {'EXIT', Exit} ->
            exit(Exit);
        Reason ->
            exit(Reason)
    end.


%% 领取奖励
get_award(PlayerId) ->
    OldId = util:get_dict(?STEP_BY_STEP_SY_ID, 0),
    ?ASSERT(OldId > 0, ?ERROR_NONE),
    erase(?STEP_BY_STEP_SY_ID),
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    case gen_server:call(SceneWorker, ?MSG_SCENE_STEP_BY_STEP_SY_GET_AWARD_MSG) of
        {ok, Result1} ->
            {ok, Result1};
        {'EXIT', Exit} ->
            exit(Exit);
        Reason ->
            exit(Reason)
    end.

%% 失败
fail_mission(PlayerId, DieCount) ->
    erase(?STEP_BY_STEP_SY_ID),
    api_step_by_step_sy:fight_result(PlayerId, DieCount, ?FALSE),
    ok.



get_mission_data() ->
    {?MISSION_TYPE_STEP_BY_STEP_SYS, 1}.

%% -------------------------------副本进程----------------------------------------------------------

%% 继续开始挑战
mission_start_fight() ->
    FightCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, 0) + 1,
    FightEndTime = notice_start_fight(),
    {ok, {FightCount, FightEndTime}}.

%% 领取奖励
mission_get_award() ->
    scene_worker:stop(self(), 15 * ?SECOND_MS),
    {ok, util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, 0)}.

%% ----------------------------------
%% @doc 	初始化副本
%% ----------------------------------
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Key, Value}) ->
            put(Key, Value)
        end, ExtraDataList).

%% 处理怪物死亡
handle_monster_death(PlayerId, _MonsterObjId) ->
    DieCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, 0) + 1,
    AwardDirCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_AWARD_COUNT_DICT, 0),
    put(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, DieCount),
    if
        DieCount == AwardDirCount ->
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        true ->
            api_step_by_step_sy:fight_result(PlayerId, DieCount, ?TRUE)
    end.


%% ----------------------------------
%% @    玩家进入副本
%% ----------------------------------
handle_enter_mission(_PlayerId) ->
    noop.


%% 通知开始战斗时间
notice_start_fight() ->
    FightEndTime = util_time:timestamp() + ?MISSION_STEP_BY_STEP_SY_FIGHT_TIME,
    ReadyFightTimeRef = erlang:send_after(?MISSION_STEP_BY_STEP_SY_FIGHT_TIME * ?SECOND_MS, self(), ?MSG_BRAVE_ONE_NEXT_FIGHT_PLAYER),
    util:update_timer_value(?MISSION_STEP_BY_STEP_SY_TIMER_DICT, ReadyFightTimeRef),
    FightEndTime.

%% 校验是否可以战斗
handle_assert_fight(_PlayerId) ->
    DieCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, 0),
    AwardDirCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_AWARD_COUNT_DICT, 0),
    ?ASSERT(DieCount >= AwardDirCount, ?ERROR_NOT_AUTHORITY).
%% 玩家退出副本
handle_leave_mission(_PlayerId) ->
    mod_mission:send_msg(?MSG_MISSION_BALANCE).


%% 结算副本
handle_balance(_) ->
    DieCount = util:get_dict(?MISSION_STEP_BY_STEP_SY_MONSTER_DIE_COUNT_DICT, 0),
%%    api_step_by_step_sy:fight_result(PlayerId, DieCount, ?FALSE),
    lists:foreach(
        fun(PlayerId) ->
            mod_apply:apply_to_online_player(PlayerId, mod_mission_step_by_step_sy, fail_mission, [PlayerId, DieCount], game_worker)
        end, mod_scene_player_manager:get_all_obj_scene_player_id()),
    scene_worker:stop(self(), 10 * ?SECOND_MS).


%% ================================================================== 模板操作 =============================================
%% tmp步步紧逼副本
get_t_mission_step_by_step_sy(Id) ->
    t_mission_step_by_step_sy:get({Id}).
