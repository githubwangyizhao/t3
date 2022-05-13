%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      玩家充能技能
%%% @end
%%% Created : 09. 六月 2021 下午 04:43:54
%%%-------------------------------------------------------------------
-module(mod_charge_skill).
-author("yizhao.wang").

-include("common.hrl").
-include("msg.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("client.hrl").
-include("gen/db.hrl").
-include("skill.hrl").
-include("scene.hrl").
-include("fight.hrl").
-include("system.hrl").

%% API
-export([
    use_skill/4,
    init_player_charge_skill_list/1,
    hook_skill_times_effect_change/2
]).
-export([
    on_client_worker_info/3,
    on_scene_worker_info/2
]).

-record(?MODULE, {
    skills = []             % 充能技能列表 [#r_charge_skill{} | ...]
}).

%% ----------------------------------
%% @doc     初始化玩家充能技能
%% @throws 	none
%% @end
%% ----------------------------------
init_player_charge_skill_list(PlayerId) ->
    NowMilSec = util_time:milli_timestamp(),
    lists:foreach(
        fun({SkillId}) ->
            #t_skill_charge{
                inti_times = CfgInitTimes,
                charge_time = CfgRecoverCdTime,
                charge_cd_time = CfgUseCdTime,
                times = CfgMaxTimes
            } = t_skill_charge:assert_get({SkillId}),

            {EffectRecoverTimeRatio, EffectAddTimes} = get_times_effect(PlayerId, SkillId),
            RecoverCdTime = round(CfgRecoverCdTime * 10000 / (EffectRecoverTimeRatio + 10000)),
            SkillInfo =
                #r_charge_skill{
                    skill_id = SkillId,
                    times = CfgInitTimes,
                    max_times = CfgMaxTimes + EffectAddTimes,
                    recover_cd_time = RecoverCdTime,
                    use_cd_time = CfgUseCdTime
                },
            NewSkillInfo = reset_skill_data(SkillId, NowMilSec, SkillInfo),
            api_skill:notice_active_skill_change(PlayerId, [NewSkillInfo])
        end, t_skill_charge:get_keys()),
    ok.

%% ----------------------------------
%% @doc 	重置技能
%% @throws 	none
%% @end
%% ----------------------------------
reset_skill_data(SkillId, NowMilSec, SkillInfo) ->
    #r_charge_skill{
        times = Times,
        max_times = MaxTimes,
        recover_cd_time = RecoverCdTime
    } = SkillInfo,
    NewSkillInfo =
        case Times < MaxTimes of
            true ->
                ClientWorker = self(),
                NewTimeRef = erlang:start_timer(RecoverCdTime, ClientWorker, {module_timer, {?MODULE, {skill_times_recover, SkillId}}}),
                SkillInfo#r_charge_skill{timer_ref = NewTimeRef, next_recover_time = NowMilSec + RecoverCdTime};
            false ->
                SkillInfo
        end,

    OldSkills = ?getModDict(skills),
    case lists:keytake(SkillId, #r_charge_skill.skill_id, OldSkills) of
        false ->
            ?setModDict(skills, [NewSkillInfo | OldSkills]);
        {value, OldSkillInfo, Left} ->
            #r_charge_skill{
                timer_ref = OldTimerRef
            } = OldSkillInfo,
            if
                OldTimerRef /= ?UNDEFINED ->    % 取消旧的定时器
                    erlang:cancel_timer(OldTimerRef);
                true ->
                    skip
            end,
            ?setModDict(skills, [NewSkillInfo | Left])
    end,
    NewSkillInfo.

%% ----------------------------------
%% @doc 	更新技能数据
%% @throws 	none
%% @end
%% ----------------------------------
update_skill_data(SkillId, NowMilSec, SkillInfo) ->
    #r_charge_skill{
        times = Times,
        timer_ref = OldTimerRef,
        max_times = MaxTimes,
        recover_cd_time = RecoverCdTime
    } = SkillInfo,

    NewSkillInfo =
        case Times < MaxTimes of
            true when OldTimerRef == ?UNDEFINED ->
                % 启动回复定时器
                ClientWorker = self(),
                NewTimeRef = erlang:start_timer(RecoverCdTime, ClientWorker, {module_timer, {?MODULE, {skill_times_recover, SkillId}}}),
                SkillInfo#r_charge_skill{timer_ref = NewTimeRef, next_recover_time = NowMilSec + RecoverCdTime};
            false when OldTimerRef /= ?UNDEFINED ->
                % 取消旧的定时器
                erlang:cancel_timer(OldTimerRef),
                SkillInfo#r_charge_skill{timer_ref = ?UNDEFINED, next_recover_time = 0};
            _ ->
                SkillInfo
        end,

    OldSkills = ?getModDict(skills),
    ?setModDict(skills, lists:keyreplace(SkillId, #r_charge_skill.skill_id, OldSkills, NewSkillInfo)),
    NewSkillInfo.

%% ----------------------------------
%% @doc 	获取技能数据
%% @throws 	none
%% @end
%% ----------------------------------
get_skill_data(SkillId) ->
    case lists:keyfind(SkillId, #r_charge_skill.skill_id, ?getModDict(skills)) of
        false ->
            null;
        SkillInfo ->
            SkillInfo
    end.

%% ----------------------------------
%% @doc 	使用技能
%% @throws 	none
%% @end
%% ----------------------------------
use_skill(PlayerId, SkillId, Dir, ReqParams) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
%%    ?t_assert(util:is_pid_alive(SceneWorker)),

    #t_skill_charge{
        parameter_list = SkillParams
    } = t_skill_charge:assert_get({SkillId}),

    OldSkillInfo = get_skill_data(SkillId),
    ?ASSERT(OldSkillInfo /= null),
    #r_charge_skill{
        times = OldTimes,
        use_cd_time = UseCdTime,
        next_use_time = CanUseTime
    } = OldSkillInfo,

    ?ASSERT(OldTimes > 0, ?ERROR_NOT_AUTHORITY),
    NowMilSec = util_time:milli_timestamp(),
    ?ASSERT(NowMilSec >= CanUseTime, ?ERROR_SKILL_CD_TIME),

    %% 场景内使用技能
    case scene_worker:sync_to_scene_worker(SceneWorker, {?MODULE, {scene_use_skill, PlayerId, SkillId, Dir, SkillParams, ReqParams}}) of
        {ok, Rewards, LogType} ->
            Tran =
                fun() ->
                    case Rewards of
                        [] -> skip;
                        _ ->
                            mod_prop:decrease_player_prop(PlayerId, Rewards, LogType)
                    end,
                    mod_conditions:add_conditions(PlayerId, {getConditionParams(SkillId), ?CONDITIONS_VALUE_ADD, 1}),
                    NewSkillInfo = update_skill_data(SkillId, NowMilSec, OldSkillInfo#r_charge_skill{times = OldTimes - 1, next_use_time = NowMilSec + UseCdTime}),
                    {ok, NewSkillInfo}
                end,
            db:do(Tran);
        {error, _Reason} ->
            exit(?ERROR_NOT_AUTHORITY)
    end.

%% ----------------------------------
%% @doc 	技能次数加成变更
%% @throws 	none
%% @end
%% ----------------------------------
hook_skill_times_effect_change(PlayerId, SkillId) ->
    OldSkillInfo = get_skill_data(SkillId),
    #r_charge_skill{
        times = OldTimes,
        next_recover_time = OldRecoverTime
    } = OldSkillInfo,

    #t_skill_charge{
        charge_time = CfgRecoverCdTime,
        times = CfgMaxTimes
    } = t_skill_charge:assert_get({SkillId}),

    {EffectRecoverTimeRatio, EffectAddTimes} = get_times_effect(PlayerId, SkillId),
    SkillInfo =
        OldSkillInfo#r_charge_skill{
            times = min(CfgMaxTimes + EffectAddTimes, OldTimes),
            max_times = CfgMaxTimes + EffectAddTimes,
            recover_cd_time = round(CfgRecoverCdTime * 10000 / (EffectRecoverTimeRatio + 10000))
        },

    NowMilSec = util_time:milli_timestamp(),
    case SkillInfo == OldSkillInfo of
        true ->
            skip;
        false ->
            NewSkillInfo = update_skill_data(SkillId, NowMilSec, SkillInfo),
            #r_charge_skill{
                times = NewTimes,
                next_recover_time = NewRecoverTime
            } = NewSkillInfo,
%%            ?DEBUG("NewSkillInfo ： ~p~n, OldSkillInfo: ~p~n, SkillInfo : ~p~n", [NewSkillInfo, OldSkillInfo, SkillInfo]),
            if
                NewTimes =/= OldTimes orelse NewRecoverTime =/= OldRecoverTime ->
                    api_skill:notice_active_skill_change(PlayerId, [NewSkillInfo]);
                true ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	技能恢复加速比和最大次数加成
%% @throws 	none
%% @end
%% ----------------------------------
get_times_effect(PlayerId, ?CHARGE_SKILL_TELEPORT) ->
    {RecoverTimeRatio, AddTimes} = mod_hero:get_parts_add_attr(PlayerId),
    {RecoverTimeRatio, AddTimes};
get_times_effect(_PlayerId, ?CHARGE_SKILL_SINGLE_GOAL) ->
    {0, 0}.

%% ----------------------------------
%% @doc 	条件枚举类型
%% @throws 	none
%% @end
%% ----------------------------------
getConditionParams(?CHARGE_SKILL_TELEPORT) -> ?CON_ENUM_DASH_COUNT;
getConditionParams(?CHARGE_SKILL_SINGLE_GOAL) -> ?CON_ENUM_SINGLE_SKILL_COUNT.

%%%===================================================================
%%% 处理玩家进程模块消息
%%%===================================================================
%% 恢复次数
on_client_worker_info({skill_times_recover, SkillId}, TimerRef, _ConnState = #conn{player_id = PlayerId}) ->
    SkillInfo = get_skill_data(SkillId),
    case SkillInfo of
        #r_charge_skill{timer_ref = TimerRef, times = OldTimes, max_times = MaxTimes} when OldTimes < MaxTimes ->
            NowMilSec = util_time:milli_timestamp(),
            erlang:cancel_timer(TimerRef),
            NewSkillInfo = update_skill_data(SkillId, NowMilSec, SkillInfo#r_charge_skill{times = OldTimes + 1, timer_ref = ?UNDEFINED}),
            api_skill:notice_active_skill_change(PlayerId, [NewSkillInfo]);
        _ ->
            skip
    end.

%%%===================================================================
%%% 处理场景进程模块消息
%%%===================================================================
%% 使用技能
on_scene_worker_info({scene_use_skill, PlayerId, SkillId, Dir, SkillParams, ReqParams}, SceneState) ->
    handle_scene_use_skill(SkillId, PlayerId, Dir, SkillParams, ReqParams, SceneState).

%% 处理闪现技能逻辑
handle_scene_use_skill(?CHARGE_SKILL_TELEPORT, PlayerId, Dir0, [Distance] = _SkillParams, _ReqParams, #scene_state{map_id = MapId}) ->
    Dir = Dir0 + 90,
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            #obj_scene_actor{
                grid_id = OldGridId,
                x = OldX,
                y = OldY,
                can_action_time = CanActionTime,
                dizzy_close_time = DizzyCloseTime,
                hp = Hp
            } = R,

            ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),

            Now = util_time:milli_timestamp(),
            ?ASSERT(Now >= CanActionTime, ?ERROR_NOT_AUTHORITY),
            ?ASSERT(Now >= DizzyCloseTime, ?ERROR_NOT_AUTHORITY),

            {NewX, NewY} = get_can_walk_pos(MapId, OldX, OldY, Dir, Distance),  %% 计算闪现后的位置

            NewGridId = ?PIX_2_GRID_ID(NewX, NewY),
            NewObjScenePlayer =
                R#obj_scene_actor{
                    x = NewX,
                    y = NewY,
                    grid_id = NewGridId
                },
            ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
            api_scene:notice_player_teleport(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, NewX, NewY),
            mod_scene_grid_manager:handle_player_grid_change(NewObjScenePlayer, OldGridId, NewGridId, walk),
            mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_DASH_SKILLS_USE_COUNT)
    end,
    {ok, [], 0};
%% 处理单体技能逻辑
handle_scene_use_skill(?CHARGE_SKILL_SINGLE_GOAL, PlayerId, Dir, [AttackNum] = _SkillParams, [TargetType, TargetId, Cost] = _ReqParams, SceneState = #scene_state{scene_id = SceneId}) ->
    #t_scene{
        mana_attack_list = [PropId, AttackCostList]
    } = t_scene:assert_get({SceneId}),
    ?ASSERT(lists:member(Cost, AttackCostList), cost_error),

    RequestFightParam =
        #request_fight_param{
            attack_type = ?OBJ_TYPE_PLAYER,
            obj_type = ?OBJ_TYPE_PLAYER,
            obj_id = PlayerId,
            skill_id = ?ACTIVE_SKILL_5,     %% 单体技能id
            dir = Dir,
            target_type = TargetType,
            target_id = TargetId,
            cost = Cost,
            player_left_coin =
            case mod_server_config:get_server_type() of
                ?SERVER_TYPE_GAME ->
                    mod_prop:get_player_prop_num(PlayerId, PropId);
                ?SERVER_TYPE_WAR_AREA ->
                    rpc:call(mod_player:get_game_node(PlayerId), mod_prop, get_player_prop_num, [PlayerId, PropId])
            end,
            single_goal_attack_num = AttackNum
        },
    Tran =
        fun() ->
            case mod_fight:fight(RequestFightParam, SceneState) of
                {success, TotalCost} ->
                    match_scene:handle_use_skill(PlayerId, ?ACTIVE_SKILL_5),
                    {ok, [{PropId, TotalCost}], ?LOG_TYPE_FIGHT};
                Err ->
                    exit(Err)
            end
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	计算闪现后的位置
%% @throws 	none
%% @end
%% ----------------------------------
get_can_walk_pos(MapId, OldX, OldY, Dir, Distance) ->
    get_can_walk_pos(MapId, OldX, OldY, Dir, Distance, 9).

get_can_walk_pos(_MapId, OldX, OldY, _Dir, _Distance, 0) -> {OldX, OldY};
get_can_walk_pos(MapId, OldX, OldY, Dir, Distance, Times) ->
    {NewX, NewY} = {OldX + round(math:sin(Dir * math:pi() / 180) * Distance), OldY - round(math:cos(Dir * math:pi() / 180) * Distance)},
    case mod_map:can_walk(?PIX_2_MASK_ID(MapId, NewX, NewY)) of
        true ->
            {NewX, NewY};
        false ->
            get_can_walk_pos(MapId, OldX, OldY, Dir, round(Distance - (Distance / 10)), Times - 1)
    end.