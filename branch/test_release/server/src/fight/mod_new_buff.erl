%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 7月 2021 上午 11:48:42
%%%-------------------------------------------------------------------
-module(mod_new_buff).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("fight.hrl").
-include("scene.hrl").
-include("common.hrl").

%% API
-export([
    try_attack_add_buff/3
]).

-define(TARGET_BUFF_TYPE_ATT, 0).
-define(TARGET_BUFF_TYPE_DEF, 1).

%% @doc 攻击后尝试添加buff
try_attack_add_buff(AttObj, DefObj, SkillId) when is_integer(SkillId) ->
    #t_active_skill{
        addbuff_list = AddBuffList
    } = mod_active_skill:get_t_active_skill(SkillId),
    try_add_buff_list(AttObj, DefObj, AddBuffList).
try_add_buff_list(AttObj, DefObj, []) ->
    {AttObj, DefObj};
try_add_buff_list(AttObj, DefObj, [[?TARGET_BUFF_TYPE_ATT, AddBuffList] | AllAddBuffList]) ->
    {NewAttObj, NewDefObj} = add_buff_list(AttObj, DefObj, AddBuffList),
    try_add_buff_list(NewAttObj, NewDefObj, AllAddBuffList);
try_add_buff_list(AttObj, DefObj, [[?TARGET_BUFF_TYPE_DEF, AddBuffList] | AllAddBuffList]) ->
    {NewDefObj, NewAttObj} = add_buff_list(DefObj, AttObj, AddBuffList),
    try_add_buff_list(NewAttObj, NewDefObj, AllAddBuffList).

add_buff_list(ActorObj, OtherActorObj, []) ->
    {ActorObj, OtherActorObj};
add_buff_list(ActorObj, OtherActorObj, [BuffId | List]) ->
    #t_buff_new{
        effect_list = EffectList,
        trigger_node_list = TriggerNodeList,
        continue_time = ContinueTime,
        success_rate = SuccessRate
    } = get_t_buff_new(BuffId),
%%    CdTime =
%%        if
%%            TriggerNodeList == ?EFFECT_TRIGGER_NODE_ADD ->
%%                Now;
%%            true ->
%%                0
%%        end,
%%    NewBuffList =
%%        case lists:keytake(BuffId, #r_buff.id, BuffList) of
%%            false ->
%%                [#r_new_buff{
%%                    id = BuffId,
%%                    ref = make_ref(),
%%                    invalid_ms = Now + ContinueTime,
%%                    cd_time = CdTime
%%                } | BuffList];
%%            {value, _OldBuff, BuffList1} ->
%%                [#r_new_buff{
%%                    id = BuffId,
%%                    ref = make_ref(),
%%                    invalid_ms = Now + ContinueTime,
%%                    cd_time = CdTime
%%                } | BuffList1]
%%        end,
%%        ActorObj#obj_scene_actor{
%%            new_buff_list = NewBuffList
%%        },
    Now = get(?DICT_NOW_MS),
    ActorObj2 =
        if
            TriggerNodeList == ?EFFECT_TRIGGER_NODE_ADD ->
                case util_random:p(SuccessRate) of
                    true ->
                        add_effect_list(ActorObj, OtherActorObj, EffectList, Now, ContinueTime);
                    false ->
                        ActorObj
                end;
            true ->
                ActorObj
        end,
    add_buff_list(ActorObj2, OtherActorObj, List).

add_effect_list(ActorObj, _OtherActorObj, [], _Now, _ContinueTime) ->
    ActorObj;
add_effect_list(ActorObj, OtherActorObj, [EffectInfo | List], Now, ContinueTime) ->
%%    ?DEBUG("查看对象 ： ~p",[ActorObj]),
    NewActorObj =
        case EffectInfo of
            %% 【停止】眩晕,冰冻   【[dizzy]】
            [?SKILL_EFFECT_DIZZY] ->
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_DIZZY, time = ContinueTime}),
                ActorObj#obj_scene_actor{
%%                can_action_time = Now + ContinueTime,
                    dizzy_close_time = Now + ContinueTime
                };
            %% 【击飞-眩晕】击飞接眩晕（击飞期间无法操作）（击飞时间=填表参数）（其他时间眩晕）    【[knock1,击飞时间]】
            [?SKILL_EFFECT_KNOCK1, KnockTime] ->
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK1, time = KnockTime}),
                ActorObj#obj_scene_actor{
                    can_action_time = Now + KnockTime,
                    dizzy_close_time = Now + KnockTime + ContinueTime
                };
            %% 【击退-反方向-眩晕】（击退期间无法操作）（击退方向为BUFF的反方向）（击退时间=填表参数）（其他时间眩晕）    【[knock2,击退像素,击退时间]】
            [?SKILL_EFFECT_KNOCK2, Range, KnockTime] ->
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK2, time = KnockTime}),
                #obj_scene_actor{
                    x = OtherX,
                    y = OtherY
                } = OtherActorObj,
                #obj_scene_actor{
                    x = X,
                    y = Y
                } = ActorObj,
                {NewX, NewY} = util_math:get_direct_target_pos_by_direction(get(?DICT_MAP_ID), X, Y, util_math:get_angle({OtherX, OtherY}, {X, Y}), Range),
%%                ?DEBUG("击退2 ： Old: ~p, New: ~p", [{X, Y}, {NewX, NewY}]),
                ActorObj#obj_scene_actor{
%%                can_action_time = Now + KnockTime + ContinueTime,
                    dizzy_close_time = Now + KnockTime + ContinueTime,
                    x = NewX,
                    y = NewY
                };
            %% 【击退-固定值-眩晕】（击退期间无法操作）（击退方向为参数）（击退时间=填表参数）（其他时间眩晕）   【[knock3,击退像素,方向角度,击退时间]】
            [?SKILL_EFFECT_KNOCK3, Range, Direction, KnockTime] ->
                #obj_scene_actor{
                    x = X,
                    y = Y
                } = ActorObj,
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK3, time = KnockTime}),
                {NewX, NewY} = util_math:get_direct_target_pos_by_direction(get(?DICT_MAP_ID), X, Y, Direction, Range),
%%                ?DEBUG("击退3 ： Old: ~p, New: ~p", [{X, Y}, {NewX, NewY}]),
                ActorObj#obj_scene_actor{
%%                can_action_time = Now + KnockTime + ContinueTime,
                    dizzy_close_time = Now + KnockTime + ContinueTime,
                    x = NewX,
                    y = NewY
                };
            %% 【击飞】纯击飞（击飞期间无法操作）（击飞时间=buff持续时间）【[knock4]】
            [?SKILL_EFFECT_KNOCK4] ->
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK1, time = ContinueTime}),
                ActorObj#obj_scene_actor{
                    can_action_time = Now + ContinueTime
                };
            %% 【击退-反方向】（击退期间无法操作）（击退方向为BUFF的反方向）（击退时间=buff持续时间）    【[knock5,击退像素]】
            [?SKILL_EFFECT_KNOCK5, Range] ->
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK2, time = ContinueTime}),
                #obj_scene_actor{
                    x = OtherX,
                    y = OtherY
                } = OtherActorObj,
                #obj_scene_actor{
                    x = X,
                    y = Y
                } = ActorObj,
                {NewX, NewY} = util_math:get_direct_target_pos_by_direction(get(?DICT_MAP_ID), X, Y, util_math:get_angle({OtherX, OtherY}, {X, Y}), Range),
%%                ?DEBUG("击退2 ： Old: ~p, New: ~p", [{X, Y}, {NewX, NewY}]),
                ActorObj#obj_scene_actor{
                    can_action_time = Now + ContinueTime,
                    x = NewX,
                    y = NewY
                };
            %% 【击退-固定值-眩晕】（击退期间无法操作）（击退方向为参数）（击退时间=buff持续时间）   【[knock6,击退像素,方向角度]】
            [?SKILL_EFFECT_KNOCK3, Range, Direction] ->
                #obj_scene_actor{
                    x = X,
                    y = Y
                } = ActorObj,
                ?UPDATE_TRIGGER_EFFECT_LIST(?DEFENSER, #r_new_effect{id = ?EFFECT_KNOCK3, time = ContinueTime}),
                {NewX, NewY} = util_math:get_direct_target_pos_by_direction(get(?DICT_MAP_ID), X, Y, Direction, Range),
%%                ?DEBUG("击退3 ： Old: ~p, New: ~p", [{X, Y}, {NewX, NewY}]),
                ActorObj#obj_scene_actor{
                    can_action_time = Now + ContinueTime,
                    x = NewX,
                    y = NewY
                }
        end,
    add_effect_list(NewActorObj, OtherActorObj, List, Now, ContinueTime).

%% ================================================ 模板操作 ================================================

%% @doc 获得新buff表
get_t_buff_new(BuffId) ->
    t_buff_new:assert_get({BuffId}).