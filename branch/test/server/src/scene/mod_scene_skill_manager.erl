%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%       场景技能效果管理
%%% @end
%%% Created : 11. 8月 2021 下午 05:12:48
%%%-------------------------------------------------------------------
-module(mod_scene_skill_manager).
-author("yizhao.wang").

-include("common.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("scene_monster.hrl").
-include("fight.hrl").
-include("msg.hrl").
-include("p_message.hrl").

%% API
-export([
    player_kill_function_monster/7,     % 玩家击杀功能怪
    get_player_all_skill_buff/1,        % 获取玩家所有技能buff
    get_player_common_skill_id/1,       % 获取玩家普攻技能id
    delete_player_all_skill_buff/1      % 删除玩家所有技能buff
]).

%% 处理模块消息
-export([
    send_msg/1,
    send_msg/2,
    on_scene_worker_info/2,
    on_scene_worker_info/3
]).

-record(?MODULE, {
    skill_buff_map = []        %% 玩家技能效果映射 [{玩家id, [{技能id, 技能类型, 结束时间, buff唯一引用}]} | ...]
}).

-define(EFFECT_TYPE_MONSTER_SKILL_1, 1).   % 修改普攻攻击
-define(EFFECT_TYPE_MONSTER_SKILL_2, 2).   % 角色周围持续
-define(EFFECT_TYPE_MONSTER_SKILL_3, 3).   % 死亡坐标
-define(EFFECT_TYPE_MONSTER_SKILL_4, 4).   % 死亡坐标持续
-define(EFFECT_TYPE_MONSTER_SKILL_5, 5).   % 角色周围随机延迟释放

%% ----------------------------------
%% @doc 	发送消息
%% @throws 	none
%% @end
%% ----------------------------------
send_msg(Info) ->
    send_msg(self(), Info).
send_msg(ScenePid, Info) when is_pid(ScenePid) ->
    ScenePid ! {notify, {?MODULE, Info}}.

%% ----------------------------------
%% @doc 	功能怪死亡后，推送击杀信息到场景内给其他玩家
%% @throws 	none
%% @end
%% ----------------------------------
notice_function_monster_dead(Effect, AwardPlayerId) ->
    case Effect of
        ?MONSTER_EFFECT_13 -> scene_notice:kill_huoqiu_monster(AwardPlayerId);
        ?MONSTER_EFFECT_14 -> scene_notice:kill_dizhen_monster(AwardPlayerId);
        ?MONSTER_EFFECT_5 -> scene_notice:kill_shandian_monster(AwardPlayerId);
        _Other -> noop
    end.

%% ----------------------------------
%% @doc 	获取技能施放位置
%% @throws 	none
%% @end
%% ----------------------------------
getSkillPointList(?EFFECT_TYPE_MONSTER_SKILL_3, _AttCurX, _AttCurY, DefDeathX, DefDeathY) -> [{DefDeathX, DefDeathY}];
getSkillPointList(?EFFECT_TYPE_MONSTER_SKILL_4, _AttCurX, _AttCurY, DefDeathX, DefDeathY) -> [{DefDeathX, DefDeathY}];
getSkillPointList(?EFFECT_TYPE_MONSTER_SKILL_5, AttCurX, AttCurY, _, _) ->     %% 攻击者位置周围
    Func = fun(I) -> I + lists:nth(rand:uniform(3), [0, 80, -80]) end,
    [{Func(AttCurX), Func(AttCurY)}];
getSkillPointList(_, AttCurX, AttCurY, _, _) ->     %% 攻击者位置
    [{AttCurX, AttCurY}].

%%% ----------------------------------
%% @doc     是否延迟战斗
%% @throws 	none
%% @end
%% ----------------------------------
is_delay_fight(?EFFECT_TYPE_MONSTER_SKILL_5) -> true;
is_delay_fight(_OtherEffectType) -> false.

%% ----------------------------------
%% @doc 	是否自动战斗
%% @throws 	none
%% @end
%% ----------------------------------
is_auto_fight(?EFFECT_TYPE_MONSTER_SKILL_1) -> false;
is_auto_fight(_OtherEffectType) -> true.

%% ----------------------------------
%% @doc 	处理玩家击杀功能怪
%% @throws 	none
%% @end
%% ----------------------------------
player_kill_function_monster(AttObjSceneActor, DefObjId, Effect, Cost, MonsterId, DefDeathX, DefDeathY) ->
    Now = util_time:milli_timestamp(),

    #obj_scene_actor{
        obj_id = PlayerId,
        x = X,
        y = Y
    } = AttObjSceneActor,

    #t_monster_effect{
        time = Duration,
        skill_id = SkillId,
        type = SkillType
    } = t_monster_effect@key_index:get(Effect),

    #t_active_skill{
        cd_time = SkillCdTime0
    } = t_active_skill:assert_get({SkillId}),
    SkillCdTime = max(SkillCdTime0, 200),      %% 技能cd时间
    EndTime = Now + Duration,
    SkillPointList = getSkillPointList(SkillType, X, Y, DefDeathX, DefDeathY),        % 技能释放位置
    {MonsterLogObjId, MonsterLogId} =
        case util_list:opt(monster_log, get(?DICT_FIGHT_OTHER_DATA_LIST)) of
            ?UNDEFINED ->
                {DefObjId, MonsterId};
            {ThisObjId, ThisId} ->
                {ThisObjId, ThisId}
        end,

    RequestFightParam =
        #request_fight_param{
            attack_type = ?OBJ_TYPE_FUNCTION_MONSTER_SKILL,
            obj_type = ?OBJ_TYPE_PLAYER,
            obj_id = PlayerId,
            skill_id = SkillId,
            skill_level = 1,
            skill_point_list = SkillPointList,
            cost = Cost,
            dir = ?DIR_UP,
            other_data_list = [{monster_log, {MonsterLogObjId, MonsterLogId}}]
        },
    IsAutoFight = is_auto_fight(SkillType),
    case IsAutoFight of
        true ->     % 发起一次自动战斗
            do_fighting(PlayerId, SkillType, SkillId, SkillPointList, RequestFightParam);
        false ->
            skip
    end,

    case Duration > 0 of
        true ->   % BUFF持续一段时间
            TimerRef = erlang:start_timer(Duration, self(), {module_timer, {?MODULE, {timeout_buff, PlayerId, SkillId}}}),      %% buff过期定时器
            update_player_skill_buff(PlayerId, SkillType, SkillId, EndTime, TimerRef),
            case IsAutoFight of
                true ->     % 持续自动战斗
                    erlang:send_after(SkillCdTime, self(), {notify, {?MODULE, {trigger_next_auto_fight, PlayerId, SkillId, SkillCdTime, DefDeathX, DefDeathY, TimerRef, RequestFightParam}}});
                false ->
                    skip
            end,
            api_scene:notice_special_skill_change(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, DefObjId, SkillId, round(EndTime / 1000));
        false ->
            skip
    end,

    %% 通知场景内其他玩家，功能怪死了
    ?CATCH(notice_function_monster_dead(Effect, PlayerId)),
    Effect.

%% ----------------------------------
%% @doc 	更新玩家技能buff
%% @throws 	none
%% @end
%% ----------------------------------
update_player_skill_buff(PlayerId, SkillType, SkillId, EndTime, Ref) ->
    case SkillType of
        ?EFFECT_TYPE_MONSTER_SKILL_1 ->     % 同类型buff互斥
            SkillIdList = logic_get_function_monster_effect_by_type:get({SkillType}),
            case SkillIdList of
                null ->
                    skip;
                _ ->
                    delete_player_skill_buff(PlayerId, SkillIdList)
            end;
        _ ->     % 同技能id互斥
            delete_player_skill_buff(PlayerId, [SkillId])
    end,
    OldBuffMap = ?getModDict(skill_buff_map),
    NewPlayerBuff = {SkillId, SkillType, EndTime, Ref},
    case lists:keytake(PlayerId, 1, OldBuffMap) of
        false ->
            ?setModDict(skill_buff_map, [{PlayerId, [NewPlayerBuff]} | OldBuffMap]);
        {value, {PlayerId, OldPlayerBuffList}, RestBuffInfo} ->
            ?setModDict(skill_buff_map, [{PlayerId, [NewPlayerBuff | OldPlayerBuffList]} | RestBuffInfo])
    end.

%% ----------------------------------
%% @doc 	删除玩家技能buff
%% @throws 	none
%% @end
%% ----------------------------------
delete_player_skill_buff(PlayerId, DelSkillIdList) ->
    OldBuffMap = ?getModDict(skill_buff_map),
    case lists:keytake(PlayerId, 1, OldBuffMap) of
        false -> skip;
        {value, {PlayerId, OldPlayerBuffList}, RestBuffInfo} ->
            NewPlayerBuffList =
                lists:foldl(
                    fun(DelSkillId, TempPlayerBuffList) ->
                        lists:keydelete(DelSkillId, 1, TempPlayerBuffList)
                    end,
                    OldPlayerBuffList,
                    DelSkillIdList
                ),
            ?setModDict(skill_buff_map, [{PlayerId, NewPlayerBuffList} | RestBuffInfo])
    end.

%% ----------------------------------
%% @doc 	删除玩家所有技能buff
%% @throws 	none
%% @end
%% ----------------------------------
delete_player_all_skill_buff(PlayerId) ->
    OldBuffMap = ?getModDict(skill_buff_map),
    case lists:keytake(PlayerId, 1, OldBuffMap) of
        false -> skip;
        {value, {PlayerId, _}, RestBuffMap} ->
            ?setModDict(skill_buff_map, RestBuffMap)
    end.

%% ----------------------------------
%% @doc 	检查玩家是否存在技能buff
%% @throws 	none
%% @end
%% ----------------------------------
check_player_skill_buff(PlayerId, SkillId) ->
    case lists:keyfind(PlayerId, 1, ?getModDict(skill_buff_map)) of
        false ->
            false;
        {PlayerId, PlayerBuffList} ->
            case lists:keyfind(SkillId, 1, PlayerBuffList) of
                false ->
                    false;
                {SkillId, _SkillType, _EndTime, TimerRef} ->
                    {true, TimerRef}
            end
    end.

%% ----------------------------------
%% @doc 	获取玩家所有技能buff
%% @throws 	none
%% @end
%% ----------------------------------
get_player_all_skill_buff(PlayerId) ->
    case lists:keyfind(PlayerId, 1, ?getModDict(skill_buff_map)) of
        false -> [];
        {PlayerId, PlayerBuffList} -> PlayerBuffList
    end.

%% ----------------------------------
%% @doc 	获取玩家普攻技能效果id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_common_skill_id(PlayerId) ->
    case lists:keyfind(PlayerId, 1, ?getModDict(skill_buff_map)) of
        false -> 0;
        {PlayerId, PlayerBuffList} ->
            case lists:keyfind(?EFFECT_TYPE_MONSTER_SKILL_1, 2, PlayerBuffList) of
                false -> 0;
                {SkillId, _SkillType, _EndTime, _Ref} -> SkillId
            end
    end.

%% ----------------------------------
%% @doc 	触发一次战斗
%% @throws 	none
%% @end
%% ----------------------------------
do_fighting(PlayerId, SkillType, SkillId, SkillPointList, RequestFightParam) ->
    Now = util_time:milli_timestamp(),
    case is_delay_fight(SkillType) of
        true ->    % 延迟释放
            api_fight:notice_fight_wait_skill(mod_scene_player_manager:get_all_obj_scene_player_id(), ?OBJ_TYPE_PLAYER, PlayerId, SkillId, ?DIR_UP, Now + 1000, SkillPointList),
            erlang:send_after(1000, self(), {notify, {?MODULE, {fighting, RequestFightParam}}});
        false ->
            self() ! {?MSG_FIGHT, RequestFightParam}
    end.

%%%===================================================================
%%% 处理场景进程模块消息
%%%===================================================================
%% 触发自动战斗
on_scene_worker_info({trigger_next_auto_fight, PlayerId, SkillId, SkillCdTime, DefDeathX, DefDeathY, TimerRef, RequestFightParam0}, _SceneState) ->
    #t_monster_effect{
        type = SkillType
    } = t_monster_effect:assert_get({SkillId}),
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        undefined ->
            delete_player_all_skill_buff(PlayerId),     % 删除玩家所有buff
            erlang:erase(TimerRef);
        ObjScenePlayer ->
            #obj_scene_actor{
                x = X,
                y = Y
            } = ObjScenePlayer,
            case check_player_skill_buff(PlayerId, SkillId) of
                {true, TimerRef} ->
                    %% 修改技能施放位置
                    SkillPointList = getSkillPointList(SkillType, X, Y, DefDeathX, DefDeathY),
                    RequestFightParam =
                        RequestFightParam0#request_fight_param{
                            skill_point_list = SkillPointList
                        },
                    do_fighting(PlayerId, SkillType, SkillId, SkillPointList, RequestFightParam),
                    %% 触发下一次技能释放
                    erlang:send_after(SkillCdTime, self(), {notify, {?MODULE, {trigger_next_auto_fight, PlayerId, SkillId, SkillCdTime, DefDeathX, DefDeathY, TimerRef, RequestFightParam}}});
                _ ->
                    skip
            end
    end;
%% 发起战斗
on_scene_worker_info({fighting, RequestFightParam}, SceneState) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId
    } = RequestFightParam,
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED -> skip;
        _ ->
            mod_fight:fight(RequestFightParam, SceneState)
    end;
on_scene_worker_info(_Info, _SceneState) ->
    ?ERROR("unknow info: ~p", [_Info]).

%% 处理buff过期
on_scene_worker_info({timeout_buff, PlayerId, SkillId}, TimerRef, _SceneState) ->
    OldBuffMap = ?getModDict(skill_buff_map),
    case lists:keytake(PlayerId, 1, OldBuffMap) of
        false -> skip;
        {value, {PlayerId, OldPlayerBuffList}, _} ->
            case lists:keyfind(SkillId, 1, OldPlayerBuffList) of
                {SkillId, _SkillType, _EndTime, TimerRef} ->
%%                    ?DEBUG("buff过期删除 ==> SkillId ~p, TimerRef ~p", [SkillId, TimerRef]),
                    delete_player_skill_buff(PlayerId, [SkillId]);
                _ ->  % 旧buff被覆盖
                    skip
            end
    end,
    ok;
on_scene_worker_info(_Info, _TimerRef, _SceneState) ->
    ?ERROR("unknow info: ~p, timerref ~p ", [_Info, _TimerRef]).