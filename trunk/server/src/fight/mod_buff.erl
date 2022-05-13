%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            效果
%%% @end
%%% Created : 27. 十一月 2017 下午 9:01
%%%-------------------------------------------------------------------
-module(mod_buff).
-include("common.hrl").
-include("scene.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("skill.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("fight.hrl").
-include("msg.hrl").
%% API
-export([
    try_trigger_passive_list/3,
    deal_buff_list/3,
    handle_add_passive_skill_list/2,
    handle_remove_buff/4,
    handle_interval_buff/3,
    tran_effect_sign_2_effect_id/1,
    deal_hurt/6
]).

%% ----------------------------------
%% @doc 	添加被动技能列表
%% @throws 	none
%% @end
%% ----------------------------------
handle_add_passive_skill_list(ObjSceneActor, []) ->
    ObjSceneActor;
handle_add_passive_skill_list(ObjSceneActor, PassiveSkillList) ->
    lists:foldl(
        fun({PassiveSkillId, PassiveSkillLevel}, TmpObjSceneActor) ->
            handle_add_passive_skill(TmpObjSceneActor, PassiveSkillId, PassiveSkillLevel)
        end,
        ObjSceneActor,
        PassiveSkillList
    ).

handle_add_passive_skill(ObjSceneActor, PassiveSkillId, 0) ->
    #obj_scene_actor{
        r_passive_skill_list = PassiveSkillList
    } = ObjSceneActor,
    %% 等级为0 移除被动技能
    NewPassiveSkillList = lists:keydelete(PassiveSkillId, #r_passive_skill.id, PassiveSkillList),
    ObjSceneActor#obj_scene_actor{
        r_passive_skill_list = NewPassiveSkillList
    };
handle_add_passive_skill(ObjSceneActor, PassiveSkillId, PassiveSkillLevel) ->
    #obj_scene_actor{
        obj_type = ObjType,
        obj_id = ObjId,
        r_passive_skill_list = PassiveSkillList
    } = ObjSceneActor,
    {NewPassiveSkill, NewPassiveSkillList} =
        case lists:keytake(PassiveSkillId, #r_passive_skill.id, PassiveSkillList) of
            {value, PassiveSkill, Left} ->
                R = PassiveSkill#r_passive_skill{level = PassiveSkillLevel},
                {R, [R | Left]};
            false ->
                R = #r_passive_skill{id = PassiveSkillId, level = PassiveSkillLevel},
                {R, [#r_passive_skill{id = PassiveSkillId, level = PassiveSkillLevel} | PassiveSkillList]}
        end,
    ObjSceneActor_0 =
        ObjSceneActor#obj_scene_actor{
            r_passive_skill_list = NewPassiveSkillList
        },
    {ObjSceneActor_1, _, _PassiveSkill} = try_trigger_passive(ObjSceneActor_0, NewPassiveSkill, #obj_scene_actor{}, ObjType, ObjId, ?EFFECT_TRIGGER_NODE_ADD),
    ObjSceneActor_1.

%% ----------------------------------
%% @doc 	尝试触发被动技能列表
%% @throws 	none
%% @end
%% ----------------------------------
try_trigger_passive_list(ObjSceneActor, OtherObjSceneActor, _Node) ->
    try_trigger_passive_list(ObjSceneActor, ObjSceneActor#obj_scene_actor.r_passive_skill_list, [], OtherObjSceneActor, _Node).

try_trigger_passive_list(ObjSceneActor, [], NewPassiveSkillList, OtherObjSceneActor, _Node) ->
    {ObjSceneActor#obj_scene_actor{
        r_passive_skill_list = NewPassiveSkillList
    }, OtherObjSceneActor};
try_trigger_passive_list(ObjSceneActor, [H | Left], NewPassiveSkillList, OtherObjSceneActor, Node) ->
    {NewObjSceneActor, NewOtherObjSceneActor, NewPassiveSkill} = try_trigger_passive(ObjSceneActor, H, OtherObjSceneActor, ObjSceneActor#obj_scene_actor.obj_type, ObjSceneActor#obj_scene_actor.obj_id, Node),
%%    ?DEBUG("NewPassiveSkill:~p", [{NewPassiveSkill, Node}]),
    try_trigger_passive_list(NewObjSceneActor, Left, [NewPassiveSkill | NewPassiveSkillList], NewOtherObjSceneActor, Node).

%% 是否目标可以触发buff
check_target_type(_TargetObjType, _IsBoss, []) ->
    true;
check_target_type(TargetObjType, IsBoss, TargetTypeLimitList) ->
    lists:any(
        fun(T) ->
            if
                T == 1 andalso TargetObjType == ?OBJ_TYPE_PLAYER ->
                    %% 玩家有效
                    true;
                T == 2 andalso TargetObjType == ?OBJ_TYPE_MONSTER ->
                    %% 怪物有效
                    true;
                T == 3 andalso IsBoss == true ->
                    %% boss 有效
                    true;
                true ->
                    false
            end
        end,
        TargetTypeLimitList
    ).
%% ----------------------------------
%% @doc 	尝试触发被动技能
%% @throws 	none
%% @end
%% ----------------------------------
try_trigger_passive(ObjSceneActor, PassiveSkill, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Node) ->
%%    ?DEBUG("PassiveSkill:~p~n", [PassiveSkill]),
    #r_passive_skill{
        id = PassiveSkillId,
        level = SkillLevel,
        last_trigger_time = LastTriggerTime
    } = PassiveSkill,
    #t_buff{
        id = Id,
        trigger_rate = P,
        arg_list = EffectArgList,
        trigger_node_list = TriggerNode,
        type = Type,
        target_type_limit_list = TargetTypeLimitList,
        is_permanent_attr = IsPermanentAttr,
        hp_limit_list = HpLimitList,
        attack_times_limit = AttackTimesLimit,
        skill_id_limit = SkillIdLimit,
%%        continue_time = ContinueTime,
%%        interval_time = IntervalTime,
        target = Target,
        cd_time = CdTime
    } = get_t_buff(PassiveSkillId, SkillLevel),
    #obj_scene_actor{
        max_hp = MaxHp,
        hp = Hp,
        attack_times = AttackTimes
    } = ObjSceneActor,
    #obj_scene_actor{
        obj_type = OtherObjType,
        is_boss = OtherIsBoss,
        max_hp = OtherMaxHp,
        hp = OtherHp
    } = OtherObjSceneActor,
    if
        (TriggerNode == Node orelse Node == force) andalso IsPermanentAttr == ?FALSE ->


            IsFight = get(?DICT_IS_FIGHT),
            NowMs =
                if IsFight ->
                    get(?DICT_NOW_MS);
                    true ->
                        util_time:milli_timestamp()
                end,
            IsGo =
                if (Node == ?EFFECT_TRIGGER_NODE_BEFORE_ATTACK orelse Node == ?EFFECT_TRIGGER_NODE_AFTER_ATTACK) andalso Id =/= 19001 ->
                    BalanceRound = get(?DICT_FIGHT_BALANCE_ROUND),
                    if BalanceRound == 1 ->
                        %% 只在第一回合触发
                        true;
                        true ->
                            false
                    end;
                    true ->
                        true
                end,

            HpCheckFun =
                fun() ->
                    if HpLimitList == [] ->
                        true;
                        true ->
                            [HpTarget, {Compare, NeedHpRate}] = HpLimitList,
                            HpRate = case HpTarget of
                                         self ->
                                             Hp / MaxHp;
                                         target ->
                                             OtherHp / OtherMaxHp
                                     end,
                            case Compare of
                                '>' ->
                                    HpRate * 100 >= NeedHpRate;
                                '<' ->
                                    HpRate * 100 < NeedHpRate
                            end

                    end
                end,
            AttackTimesCheck =
                if AttackTimesLimit == 0 ->
                    true;
                    true ->
%%                        ?DEBUG("AttackTimesLimit:~p~n", [{AttackTimes, AttackTimesLimit}]),
                        AttackTimes >= AttackTimesLimit
                end,
%%                if TargetTypeLimit == [] ->
%%                    true;
%%                    true ->
%%                        if TargetTypeLimit == 1 ->
%%                            %% 只有对方是玩家才会触发
%%                            OtherObjType == ?OBJ_TYPE_PLAYER;
%%                            true ->
%%                                %% 只有对方是怪物才会触发
%%                                OtherObjType == ?OBJ_TYPE_MONSTER
%%                        end
%%                end,
            SkillIdCheck =
                if SkillIdLimit == 0 ->
                    true;
                    true ->
%%                        ?DEBUG("SkillIdLimit:~p~n", [{SkillIdLimit, get(?DICT_FIGHT_SKILL_ID), IsGo, NowMs >= CdTime + LastTriggerTime, check_target_type(OtherObjType, OtherIsBoss, TargetTypeLimitList), get(?DICT_FIGHT_BALANCE_ROUND)}]),
                        SkillIdLimit == get(?DICT_FIGHT_SKILL_ID)
                end,
            case IsGo
                andalso NowMs >= CdTime + LastTriggerTime
                andalso util_random:p(P)
                andalso check_target_type(OtherObjType, OtherIsBoss, TargetTypeLimitList)
                andalso HpCheckFun()
                andalso AttackTimesCheck
                andalso SkillIdCheck
            of
                true ->

                    {NewObjSceneActor, NewOtherObjSceneActor} =
                        case Type of
                            ?EFFECT_TRIGGER_TYPE_ONE ->
                                if Target == 0 ->
                                    deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, EffectArgList);
                                    true ->
                                        {OtherObjSceneActor_1, ObjSceneActor_1} = deal_effect(OtherObjSceneActor, ObjSceneActor, ReleaserObjType, ReleaserObjId, EffectArgList),
                                        {ObjSceneActor_1, OtherObjSceneActor_1}
                                end;
                            ?EFFECT_TRIGGER_TYPE_INTERVAL ->
                                if Target == 0 ->
                                    handle_add_buf(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, PassiveSkillId, SkillLevel);
                                    true ->
                                        {OtherObjSceneActor_1, ObjSceneActor_1} = handle_add_buf(OtherObjSceneActor, ObjSceneActor, ReleaserObjType, ReleaserObjId, PassiveSkillId, SkillLevel),
                                        {ObjSceneActor_1, OtherObjSceneActor_1}
                                end;
                            ?EFFECT_TRIGGER_TYPE_BUFF ->
                                if Target == 0 ->
                                    handle_add_buf(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, PassiveSkillId, SkillLevel);
                                    true ->
                                        {OtherObjSceneActor_1, ObjSceneActor_1} = handle_add_buf(OtherObjSceneActor, ObjSceneActor, ReleaserObjType, ReleaserObjId, PassiveSkillId, SkillLevel),
                                        {ObjSceneActor_1, OtherObjSceneActor_1}
                                end
                        end,
                    NewObjSceneActor_1 =
                        if AttackTimesLimit > 0 ->
%%                            ?DEBUG("666:~p", [{NewObjSceneActor#obj_scene_actor.obj_type, NewObjSceneActor#obj_scene_actor.obj_id}]),
                            NewObjSceneActor#obj_scene_actor{
                                attack_times = 0
                            };
                            true ->
                                NewObjSceneActor
                        end,
                    {NewObjSceneActor_1, NewOtherObjSceneActor, PassiveSkill#r_passive_skill{last_trigger_time = NowMs}};
                false ->
                    {ObjSceneActor, OtherObjSceneActor, PassiveSkill}
            end;
        true ->
            {ObjSceneActor, OtherObjSceneActor, PassiveSkill}
    end.


%% ----------------------------------
%% @doc 	尝试触发被动技能列表
%% @throws 	none
%% @end
%% ----------------------------------
deal_buff_list(ObjSceneActor, OtherObjSceneActor, _Node) ->
    deal_buff_list(ObjSceneActor, ObjSceneActor#obj_scene_actor.buff_list, OtherObjSceneActor, _Node).

deal_buff_list(ObjSceneActor, [], OtherObjSceneActor, _Node) ->
    {ObjSceneActor, OtherObjSceneActor};
deal_buff_list(ObjSceneActor, [H | Left], OtherObjSceneActor, Node) ->
    {NewObjSceneActor, NewOtherObjSceneActor} = deal_buff(ObjSceneActor, H, OtherObjSceneActor, Node),
    deal_buff_list(NewObjSceneActor, Left, NewOtherObjSceneActor, Node).

deal_buff(ObjSceneActor, Buff, OtherObjSceneActor, Node) ->
    #r_buff{
        id = PassiveSkillId,
        level = SkillLevel,
        release_type = ReleaserObjType,
        releaser_id = ReleaserObjId
    } = Buff,
    #obj_scene_actor{
%%        obj_type = ObjType,
%%        obj_id = ObjId
    } = ObjSceneActor,

    #obj_scene_actor{
        obj_type = OtherObjType,
        is_boss = OtherIsBoss
    } = OtherObjSceneActor,

    #t_buff{
        trigger_rate = P,
        arg_list = EffectArgList,
        trigger_node_list = TriggerNode,
        target = Target,
        target_type_limit_list = TargetTypeLimitList
    } = get_t_buff(PassiveSkillId, SkillLevel),
    if
        TriggerNode == Node ->
            IsTargetTypeEffect = check_target_type(OtherObjType, OtherIsBoss, TargetTypeLimitList),
%%                if TargetTypeLimit == 0 ->
%%                    true;
%%                    true ->
%%                        if TargetTypeLimit == 1 ->
%%                            %% 只有对方是玩家才会触发
%%                            OtherObjType == ?OBJ_TYPE_PLAYER;
%%                            true ->
%%                                %% 只有对方是怪物才会触发
%%                                OtherObjType == ?OBJ_TYPE_MONSTER
%%                        end
%%                end,

            case util_random:p(P) andalso IsTargetTypeEffect of
                true ->
                    if Target == 0 ->
                        deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, EffectArgList);
                        true ->
                            deal_effect(OtherObjSceneActor, ObjSceneActor, ReleaserObjType, ReleaserObjId, EffectArgList)
                    end;
                false ->
                    {ObjSceneActor, OtherObjSceneActor}
            end;
        true ->
            {ObjSceneActor, OtherObjSceneActor}
    end.

%% ----------------------------------
%% @doc 	添加buff
%% @throws 	none
%% @end
%% ----------------------------------
handle_add_buf(ObjSceneActor, OtherObjSceneActor, ReleaseObjType, ReleaseObjId, BuffId, BUffLevel) ->
    #obj_scene_actor{
        obj_type = ObjType,
        obj_id = ObjId,
        buff_list = BuffList,
        r_passive_skill_list = PassiveSkillList,
        attack_type = AttackType
    } = ObjSceneActor,
%%    if ObjId == ?PLAYERID ->
%%        ?DEBUG("添加buff:~p", [{{ObjType, ObjId}, {ReleaseObjType, ReleaseObjId}, BuffId, BUffLevel}]),
%%        true ->
%%            noop
%%    end,
%%    if BuffId == 11102 ->
%%        ?DEBUG("吸血效果~n");
%%        true ->
%%            noop
%%    end,
    Now = util_time:milli_timestamp(),
    Ref = erlang:make_ref(),

%%    #obj_scene_actor{
%%        obj_type = OtherObjType,
%%        obj_id = OtherObjId
%%    } = OtherObjSceneActor,

    #t_buff{
        continue_time = ContinueTime,
        interval_time = IntervalTime,
        arg_list = EffectArgList
    } = get_t_buff(BuffId, BUffLevel),

    IsImmune = case EffectArgList of
                   [[?EFFECT_TYPE_DIZZY]] ->
                       %% 晕眩
                       IsImmuneDizzy = lists:any(
                           fun(ThisPassiveSkill) ->
                               #r_passive_skill{
                                   id = ThisPassiveSkillId,
                                   level = ThisSkillLevel,
                                   last_trigger_time = _ThisLastTriggerTime
                               } = ThisPassiveSkill,
                               #t_buff{
                                   arg_list = ThisEffectArgList,
                                   trigger_rate = ThisRate
                               } = get_t_buff(ThisPassiveSkillId, ThisSkillLevel),
                               case ThisEffectArgList of
                                   [[?EFFECT_TYPE_IMMUNE_DIZZY]] ->
                                       util_random:p(ThisRate);
                                   _ ->
                                       false
                               end
                           end,
                           PassiveSkillList
                       ),
                       if IsImmuneDizzy ->
                           AddEffect = #r_effect{
                               id = tran_effect_sign_2_effect_id(?EFFECT_TYPE_IMMUNE_DIZZY),
                               data = 0
                           },
%%                           ?DEBUG("免疫晕眩:~p", [{{ObjType, ObjId}, {OtherObjType, OtherObjId}}]),
                           ?UPDATE_TRIGGER_EFFECT_LIST(AttackType, AddEffect);
                           true ->
                               noop
                       end,
                       IsImmuneDizzy;
                   _ ->
                       false
               end,
    if
        IsImmune == true ->
            %% 免疫
            {ObjSceneActor, OtherObjSceneActor};
        true ->
            {AddBuff, NewBuffList} =
                case lists:keytake(BuffId, #r_buff.id, BuffList) of
                    {value, Buff, Left} ->
                        AddBuff_ = Buff#r_buff{level = BUffLevel, invalid_ms = Now + ContinueTime, ref = Ref, release_type = ReleaseObjType, releaser_id = ReleaseObjId},
                        {AddBuff_, [AddBuff_ | Left]};
                    false ->
                        AddBuff_ = #r_buff{id = BuffId, level = BUffLevel, invalid_ms = Now + ContinueTime, ref = Ref, release_type = ReleaseObjType, releaser_id = ReleaseObjId},
                        {AddBuff_, [AddBuff_ | BuffList]}
                end,
            ?UPDATE_TRIGGER_BUFF_LIST(AttackType, AddBuff),
            if ContinueTime > 0 ->
                erlang:send_after(ContinueTime, self(), {?MSG_SCENE_REMOVE_BUFF, ObjType, ObjId, Ref, false});
                true ->
                    noop
            end,
            if IntervalTime > 0 ->
                erlang:send_after(IntervalTime + 200, self(), {?MSG_SCENE_CLOCK_INTERVAL_BUFF, ObjType, ObjId, Ref});
                true ->
                    noop
            end,
            ObjSceneActor_1 =
                case EffectArgList of
                    [[?EFFECT_TYPE_DIZZY]] ->
                        ObjSceneActor#obj_scene_actor{
                            can_action_time = Now + ContinueTime,
                            move_path = [],
                            go_x = 0,
                            go_y = 0
                        };
                    [[?EFFECT_TYPE_CHEN_MO]] ->
                        AddChenMoEffect = #r_effect{
                            id = tran_effect_sign_2_effect_id(?EFFECT_TYPE_CHEN_MO),
                            data = 0
                        },
%%                        ?DEBUG("吸血:~p", [{Rate, RealAddHp}]),
                        ?UPDATE_TRIGGER_EFFECT_LIST(AttackType, AddChenMoEffect),
                        ObjSceneActor#obj_scene_actor{
                            can_use_skill_time = Now + ContinueTime
                        };
%%                    [[?EFFECT_TYPE_FENG_YIN_PET]] ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            pet_can_fight_time = Now + ContinueTime
%%                        };
%%                    [[?EFFECT_TYPE_FENG_YIN_FA_BAO]] ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            magic_weapon_can_fight_time = Now + ContinueTime
%%                        };
%%                    [[?EFFECT_TYPE_DIZZY]] ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            move_path = [],
%%                            go_x = 0,
%%                            go_y = 0
%%                        };
                    [[?EFFECT_TYPE_HU_DUN, HuDun]] ->
                        ?DEBUG("添加护盾:~p", [HuDun]),
                        ObjSceneActor#obj_scene_actor{
                            hu_dun = HuDun,
                            hu_dun_ref = Ref
                        };
                    _ ->
                        ObjSceneActor
                end,
            {
                ObjSceneActor_1#obj_scene_actor{
                    buff_list = NewBuffList
                },
                OtherObjSceneActor
            }
    end.

%% ----------------------------------
%% @doc 	移除buff
%% @throws 	none
%% @end
%% ----------------------------------
handle_remove_buff(ObjType, ObjId, Ref, IsForce) ->
%%    ?DEBUG("移除buff:~p", [{ObjType, ObjId, Ref, IsForce}]),
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                buff_list = BuffList,
                grid_id = GridId
            } = ObjSceneActor,
%%            ?DEBUG("移除buff:~p", [{BuffList, Ref}]),
            case lists:keytake(Ref, #r_buff.ref, BuffList) of
                {value, Buff, Left} ->
                    #r_buff{
                        id = BuffId,
                        level = BuffLevel
                    } = Buff,
                    #t_buff{
                        arg_list = EffectArgList
                    } = get_t_buff(BuffId, BuffLevel),
                    ObjSceneActor_1 =
                        case EffectArgList of
                            [[?EFFECT_TYPE_HU_DUN, _]] ->
%%                                ?DEBUG("移除护盾:~p", [{ObjType, ObjId, Ref, IsForce}]),
                                ObjSceneActor#obj_scene_actor{
                                    hu_dun = 0
                                };
                            _ ->
                                ObjSceneActor
                        end,
%%                    NewBuffList = lists:keydelete(Ref, #r_buff.ref, BuffList),
                    NewObjSceneActor =
                        ObjSceneActor_1#obj_scene_actor{
                            buff_list = Left
                        },
                    ?UPDATE_OBJ_SCENE_ACTOR(NewObjSceneActor),
                    if IsForce ->
                        api_fight:notice_remove_buff(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), ObjType, ObjId, [BuffId]);
                        true ->
                            noop
                    end;
                false ->
                    noop
%%                    ?WARNING("buff不存在:~p", [{ObjType, ObjId, Ref, IsForce}])
            end
    end.

%% ----------------------------------
%% @doc 	间隔buff
%% @throws 	none
%% @end
%% ----------------------------------
handle_interval_buff(ObjType, ObjId, Ref) ->
%%    ?DEBUG("间隔buff:~p", [{ObjType, ObjId, Ref}]),
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                buff_list = BuffList
            } = ObjSceneActor,
            case lists:keytake(Ref, #r_buff.ref, BuffList) of
                {value, Buff, _Left} ->
                    #r_buff{
                        id = Id,
                        level = Level,
                        release_type = ReleaserObjType,
                        releaser_id = ReleaserObjId
                    } = Buff,
%%                    ?DEBUG("间隔buff:~p", [{Buff}]),
                    #t_buff{
                        arg_list = EffectArgList,
                        interval_time = IntervalTime
                    } = get_t_buff(Id, Level),
                    {NewObjSceneActor, _} =
                        if {ObjType, ObjId} == {ReleaserObjType, ReleaserObjId} ->
                            deal_effect(ObjSceneActor, #obj_scene_actor{}, ReleaserObjType, ReleaserObjId, EffectArgList);
                            true ->
%%                                ?DEBUG("6666::~p", [{ReleaserObjType, ReleaserObjId}]),
                                case ?GET_OBJ_SCENE_ACTOR(ReleaserObjType, ReleaserObjId) of
                                    ?UNDEFINED ->
                                        %% 施法者不存在，则buff 无效
                                        {ObjSceneActor, null};
%%                                        deal_effect(ObjSceneActor, #obj_scene_actor{obj_id = 0}, ReleaserObjType, ReleaserObjId, EffectArgList);
                                    R ->
                                        deal_effect(ObjSceneActor, R, ReleaserObjType, ReleaserObjId, EffectArgList)
                                end
                        end,
                    if NewObjSceneActor =/= death ->
                        ?UPDATE_OBJ_SCENE_ACTOR(NewObjSceneActor),
                        erlang:send_after(IntervalTime, self(), {?MSG_SCENE_CLOCK_INTERVAL_BUFF, ObjType, ObjId, Ref});
                        true ->
                            noop
                    end;
                false ->
                    noop
            end
    end.

deal_effect(ObjSceneActor, OtherObjSceneActor, _ReleaserObjType, _ReleaserObjId, []) ->
    {ObjSceneActor, OtherObjSceneActor};
deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, [Effect | Left]) ->
    #obj_scene_actor{
        hp = Hp,
        obj_id = ObjId,
        obj_type = ObjType,
        max_hp = MaxHp,
        attack_type = AttackType,
        x = X,
        y = Y,
        grid_id = GridId,
        fight_attr_param = FightAttrParam
    } = ObjSceneActor,

    #obj_scene_actor{
        obj_id = OtherObjId,
        obj_type = OtherObjType,
        attack_type = OtherAttackType,
        x = OtherX,
        y = OtherY,
        fight_attr_param = OtherFightAttrParam,
        hp = _OtherHp
    } = OtherObjSceneActor,

    #fight_attr_param{
        attack = Attack
%%        defense = Defense,
%%        critical = Critical,
%%        crit_hurt_add = CritHurtAdd,
%%        hit = Hit,
%%        rate_resist_block = RateResistBlock,
%%        dodge = Dodge,
%%        rate_block = RateBlock,
%%        tenacity = Tenacity,
%%        hurt_add = HurtAdd,
%%        hurt_reduce = HurtReduce,
%%        crit_hurt_reduce = CritHurtReduce
    } = FightAttrParam,

    #fight_attr_param{
        attack = OtherAttack
    } = OtherFightAttrParam,
    case Effect of
        [?EFFECT_TYPE_ADD_HP_RATE, Rate] ->
            %% 加血
            if
                Hp > 0 andalso Hp < MaxHp ->
                    NewHp = min(MaxHp, Hp + trunc(MaxHp * Rate / 10000)),
%%                    ?DEBUG("回血:~p~n", [NewHp - Hp]),
                    api_scene:notice_player_attr_change(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), ObjId, [{?P_HP, NewHp}]),
                    deal_effect(ObjSceneActor#obj_scene_actor{
                        hp = NewHp
                    }, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
                true ->
                    deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left)
            end;
        [?EFFECT_TYPE_ADD_BUFF, AddEffectId, AddEffectLevel] ->
            %% 加buff
%%            ?DEBUG("添加buff:~p", [{AddEffectId, AddEffectLevel}]),
            {NewObjSceneActor, NewOtherObjSceneActor, _} = try_trigger_passive(ObjSceneActor, #r_passive_skill{id = AddEffectId, level = AddEffectLevel}, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, force),
            deal_effect(NewObjSceneActor, NewOtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_ATTR, AttrId, _Value] ->
            %% 加减属性
            NewObjSceneActor =
                case AttrId of
%%                    %% 攻击
%%                    ?ATTR_ATTACK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                attack = max(0, Attack + Value)
%%                            }
%%                        };
%%                    %% 防御
%%                    ?ATTR_DEFENSE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                defense = max(0, Defense + Value)
%%                            }
%%                        };
%%                    %% 暴击
%%                    ?ATTR_CRIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                critical = max(0, Critical + Value)
%%                            }
%%                        };
%%                    %% 命中
%%                    ?ATTR_HIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hit = max(0, Hit + Value)
%%                            }
%%                        };
%%                    %% 闪避
%%                    ?ATTR_DODGE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                dodge = max(0, Dodge + Value)
%%                            }
%%                        };
%%                    %% 破击
%%                    ?ATTR_RESIST_BLOCK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                rate_resist_block = max(0, RateResistBlock + Value)
%%                            }
%%                        };
%%                    %% 格挡
%%                    ?ATTR_BLOCK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                rate_block = max(0, RateBlock + Value)
%%                            }
%%                        };
%%                    %% 韧性
%%                    ?ATTR_RESIST_CRIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                tenacity = max(0, Tenacity + Value)
%%                            }
%%                        };
%%                    %% 守护
%%                    ?ATTR_CRIT_HURT_REDUCE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                crit_hurt_reduce = max(0, CritHurtReduce + Value)
%%                            }
%%                        };
%%                    %% 必杀
%%                    ?ATTR_CRIT_HURT_ADD ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                crit_hurt_add = max(0, CritHurtAdd + Value)
%%                            }
%%                        };
%%                    %% 伤害加成
%%                    ?ATTR_HURT_ADD ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hurt_add = max(0, HurtAdd + Value)
%%                            }
%%                        };
%%                    %% 伤害减免
%%                    ?ATTR_HURT_REDUCE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hurt_reduce = max(0, HurtReduce + Value)
%%                            }
%%                        };
%%                    %% 速度
%%                    ?ATTR_SPEED ->
%%                        ObjSceneActor_0 =
%%                            ObjSceneActor#obj_scene_actor{
%%                                buff_add_speed = max(0, BuffAddSpeed + Value)
%%                            },
%%                        ObjSceneActor_1 = mod_scene:update_move_speed(ObjSceneActor_0, true),
%%                        ObjSceneActor_1;
                    _ ->
                        ?WARNING("被动技能加减属性未实现:~p", [{Effect}]),
                        ObjSceneActor
                end,
            deal_effect(NewObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_ATTR_RATE, AttrId, _Rate] ->
            %% 加减百分比属性
            NewObjSceneActor =
                case AttrId of
%%%%                     攻击
%%                    ?ATTR_ATTACK ->
%%                        if Rate > 0 ->
%%                            ObjSceneActor#obj_scene_actor{
%%                                fight_attr_param = FightAttrParam#fight_attr_param{
%%                                    attack = Attack + trunc(Attack * (0.7 + Rate / 10000))
%%                                }
%%                            };
%%                            true ->
%%                                ObjSceneActor#obj_scene_actor{
%%                                    fight_attr_param = FightAttrParam#fight_attr_param{
%%                                        attack = max(Attack - trunc(Attack * (0.7 + erlang:abs(Rate) / 10000)), 0)
%%                                    }
%%                                }
%%                        end;
%%                    %% 防御
%%                    ?ATTR_DEFENSE ->
%%                        if Rate > 0 ->
%%                            ObjSceneActor#obj_scene_actor{
%%                                fight_attr_param = FightAttrParam#fight_attr_param{
%%                                    defense = Defense + trunc(Defense * (0.7 + Rate / 10000))
%%                                }
%%                            };
%%                            true ->
%%                                ObjSceneActor#obj_scene_actor{
%%                                    fight_attr_param = FightAttrParam#fight_attr_param{
%%                                        defense = max(Defense - trunc(Defense * (0.7 + erlang:abs(Rate) / 10000)), 0)
%%                                    }
%%                                }
%%                        end;
%%                    %% 暴击
%%                    ?ATTR_CRIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                critical = trunc(Critical * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 命中
%%                    ?ATTR_HIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hit = trunc(Hit * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 闪避
%%                    ?ATTR_DODGE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                dodge = trunc(Dodge * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 破击
%%                    ?ATTR_RESIST_BLOCK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                rate_resist_block = trunc(RateResistBlock * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 格挡
%%                    ?ATTR_BLOCK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                rate_block = trunc(RateBlock * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 韧性
%%                    ?ATTR_RESIST_CRIT ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                tenacity = trunc(Tenacity * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 守护
%%                    ?ATTR_CRIT_HURT_REDUCE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                crit_hurt_reduce = trunc(CritHurtReduce * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 必杀
%%                    ?ATTR_CRIT_HURT_ADD ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                crit_hurt_add = trunc(CritHurtAdd * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 伤害加成
%%                    ?ATTR_HURT_ADD ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hurt_add = trunc(HurtAdd * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 伤害减免
%%                    ?ATTR_HURT_REDUCE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                hurt_reduce = trunc(HurtReduce * (1 + Rate / 10000))
%%                            }
%%                        };
%%                    %% 速度
%%                    ?ATTR_SPEED ->
%%                        ObjSceneActor_0 =
%%                            ObjSceneActor#obj_scene_actor{
%%                                buff_add_speed = trunc(BuffAddSpeed * (1 + Rate / 10000))
%%                            },
%%                        ObjSceneActor_1 = mod_scene:update_move_speed(ObjSceneActor_0, true),
%%                        ObjSceneActor_1;
                    _ ->
                        ?ERROR("被动技能加减万分比属性未实现:~p", [{Effect}]),
                        ObjSceneActor
                end,
            deal_effect(NewObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
%%        [?EFFECT_TYPE_DEL_ATTR_PROPORTION, AttrId, Rate] ->
%%            %% 减百分比属性
%%            NewObjSceneActor =
%%                case AttrId of
%%                    ?ATTR_ATTACK ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                attack = max(Attack - trunc(Attack * (0.7 + Rate / 10000)), 0)
%%                            }
%%                        };
%%                    ?ATTR_DEFENSE ->
%%                        ObjSceneActor#obj_scene_actor{
%%                            fight_attr_param = FightAttrParam#fight_attr_param{
%%                                defense = max(Defense - trunc(Defense * (0.7 + Rate / 10000)), 0)
%%                            }
%%                        };
%%                    _ ->
%%                        ?ERROR("被动技能加属性未实现:~p", [{Effect}]),
%%                        ObjSceneActor
%%                end,
%%            deal_effect(NewObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_TRIGGER_SKILL, TriggerActiveSkillId, SkillLevel] ->
            %% 释放主动技能
            SkillId = get(?DICT_FIGHT_SKILL_ID),
            #t_active_skill{
                is_common_skill = IsCommonSkill
            } = mod_active_skill:get_t_active_skill(SkillId),
            if IsCommonSkill == ?TRUE ->
                ?DEBUG("触发主动技能:~p", [{ObjType, ObjId, TriggerActiveSkillId}]),
                Dir = util_math:get_direction({X, Y}, {OtherX, OtherY}),
                RequestFightParam =
                    #request_fight_param{
                        attack_type = ObjType,
                        obj_type = ObjType,
                        obj_id = ObjId,
                        skill_id = TriggerActiveSkillId,
                        skill_level = SkillLevel,
                        dir = Dir,
                        target_type = OtherObjType,
                        target_id = OtherObjId
                    },
%%                ?DEBUG("触发主动技能:~p", [{RequestFightParam}]),
                self() ! {?MSG_FIGHT, RequestFightParam};
                true ->
                    noop
            end,
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_XI_XUE, Rate] ->
            %% 吸血
            if Hp >= MaxHp orelse Hp =< 0 ->
                deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
                true ->
                    RealHurt = get(?DICT_RESULT_HURT),
                    AddHp = max(1, trunc(RealHurt * Rate / 10000)),
                    NewHp = min(MaxHp, AddHp + Hp),
                    RealAddHp = NewHp - Hp,
                    AddEffect = #r_effect{
                        id = tran_effect_sign_2_effect_id(?EFFECT_TYPE_XI_XUE),
                        data = RealAddHp
                    },
                    ?DEBUG("吸血:~p", [{Rate, RealAddHp}]),
                    ?UPDATE_TRIGGER_EFFECT_LIST(OtherAttackType, AddEffect),
                    deal_effect(ObjSceneActor#obj_scene_actor{
                        hp = NewHp
                    }, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left)
            end;
        [?EFFECT_TYPE_LIU_XUE, Rate] ->
            %% 流血
            if OtherObjId == 0 orelse Hp =< 0 ->
                deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
                true ->
                    Hurt = max(1, trunc(OtherAttack * Rate / 10000)),
%%                    ?DEBUG("流血:~p", [{Hurt, Rate, {ObjType, ObjId}, OtherAttack, {OtherObjType, OtherObjId}}]),
                    NewObjSceneActor = mod_fight:deal_hurt(ObjSceneActor, OtherObjSceneActor, Hurt, true),
                    if NewObjSceneActor =/= death ->
                        api_scene:api_notice_obj_hp_change(
                            mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                            tran_effect_sign_2_effect_id(?EFFECT_TYPE_LIU_XUE),
                            ObjType,
                            ObjId,
                            -Hurt,
                            NewObjSceneActor#obj_scene_actor.hp,
                            OtherObjType,
                            OtherObjId
                        ),
                        deal_effect(NewObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
                        true ->
                            api_scene:api_notice_obj_hp_change(
                                mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                                tran_effect_sign_2_effect_id(?EFFECT_TYPE_LIU_XUE),
                                ObjType,
                                ObjId,
                                -Hurt,
                                0,
                                OtherObjType,
                                OtherObjId
                            ),
                            {death, OtherObjSceneActor}
                    end
            end;
        [?EFFECT_TYPE_EXTRA_HURT, Rate] ->
            %% 额外伤害
            RealHurt = get(?DICT_RESULT_HURT),
            ExtraHurt = max(1, trunc(Attack * Rate / 10000)),
            put(?DICT_RESULT_HURT, RealHurt + ExtraHurt),
            AddEffect = #r_effect{
                id = tran_effect_sign_2_effect_id(?EFFECT_TYPE_EXTRA_HURT),
                data = ExtraHurt
            },
%%            ?DEBUG("额外伤害:~p", [{Rate, Attack, RealHurt, ExtraHurt}]),
            ?UPDATE_TRIGGER_EFFECT_LIST(AttackType, AddEffect),
%%            self() ! {?MSG_SCENE_DEAL_BUFF_HURT, ObjType, ObjId, ?EFFECT_TYPE_EXTRA_HURT, ExtraHurt, OtherObjType, OtherObjId},
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_REBOUND_HURT, Rate] ->
            %% 反弹伤害
            RealHurt = get(?DICT_RESULT_HURT),
            ReboundHurt = max(1, trunc((RealHurt * Rate / 10000))),
            ?DEBUG("反弹伤害:~p", [{Rate, RealHurt, ReboundHurt, {ObjType, ObjId}, {OtherObjType, OtherObjId}}]),
            self() ! {?MSG_SCENE_DEAL_BUFF_HURT, ObjType, ObjId, ?EFFECT_TYPE_REBOUND_HURT, ReboundHurt, OtherObjType, OtherObjId},
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_KILL] ->
            ?DEBUG("必杀:~p", [{?MSG_SCENE_DEAL_BUFF_HURT, ObjType, ObjId, ?EFFECT_TYPE_KILL, Hp, OtherObjType, OtherObjId}]),
            %% 必杀
            self() ! {?MSG_SCENE_DEAL_BUFF_HURT, ObjType, ObjId, ?EFFECT_TYPE_KILL, Hp, OtherObjType, OtherObjId},
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_REDUCE_CD] ->
            %% 清理技能cd
%%            ?DEBUG("清理技能cd"),
            AddEffect = #r_effect{
                id = tran_effect_sign_2_effect_id(?EFFECT_TYPE_REDUCE_CD),
                data = 0
            },
%%            ?DEBUG("额外伤害:~p", [{Rate, Attack, RealHurt, ExtraHurt}]),
            ?UPDATE_TRIGGER_EFFECT_LIST(AttackType, AddEffect),
            self() ! {?MSG_SCENE_CLEAR_ALL_SKILL_CD, ObjType, ObjId},
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        [?EFFECT_TYPE_CALL_MONSTER, MonsterId] ->
            %% 召唤怪物
            ?DEBUG("召唤怪物:~p", [{{ObjType, ObjId}, {ReleaserObjType, ReleaserObjId}, MonsterId}]),
            case get({is_call_monster, ObjId, MonsterId}) of
                true ->
                    ?WARNING("已经召唤怪物:~p", [{ObjId, MonsterId}]);
                _ ->
                    {RandomX, RandomY} = mod_scene:get_random_pos(get(?DICT_MAP_ID), X, Y, 150),
                    mod_scene_monster_manager:call_monster(ObjId, MonsterId, RandomX, RandomY)
            end,
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left);
        _ ->
            ?DEBUG("效果未实现:~p", [{Effect}]),
            deal_effect(ObjSceneActor, OtherObjSceneActor, ReleaserObjType, ReleaserObjId, Left)
    end.

deal_hurt(ObjType, ObjId, EffectId, Hurt, ReleaserObjType, ReleaserObjId) ->
%%    ?DEBUG("处理buff 伤害:~p", [{{ObjType, ObjId}, {ReleaserObjType, ReleaserObjId}, EffectId, Hurt}]),
    ?ASSERT({ObjType, ObjId} =/= {ReleaserObjType, ReleaserObjId}),
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                hp = Hp,
                grid_id = GridId
            } = ObjSceneActor,
            if Hp > 0 ->
                case ?GET_OBJ_SCENE_ACTOR(ReleaserObjType, ReleaserObjId) of
                    ?UNDEFINED ->
                        noop;
                    AttackerObjSceneActor ->
                        NewObjSceneActor = mod_fight:deal_hurt(ObjSceneActor, AttackerObjSceneActor, Hurt, true),
                        if NewObjSceneActor =/= death ->
                            ?UPDATE_OBJ_SCENE_ACTOR(NewObjSceneActor),
                            api_scene:api_notice_obj_hp_change(
                                mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                                tran_effect_sign_2_effect_id(EffectId),
                                ObjType,
                                ObjId,
                                -Hurt,
                                NewObjSceneActor#obj_scene_actor.hp,
                                ReleaserObjType,
                                ReleaserObjId
                            );
                            true ->
                                api_scene:api_notice_obj_hp_change(
                                    mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                                    tran_effect_sign_2_effect_id(EffectId),
                                    ObjType,
                                    ObjId,
                                    -Hurt,
                                    0,
                                    ReleaserObjType,
                                    ReleaserObjId
                                )
                        end
                end;
                true ->
                    noop
            end
    end.


get_t_buff(BuffId, BuffLevel) ->
%%    RealBuffId = get_real_buff_id(BuffId),
    case t_buff:get({BuffId, BuffLevel}) of
        null ->
            ?DEBUG("被动未配置:~p", [{BuffId, BuffId, BuffLevel}]),
            null;
        R ->
            R
    end.

tran_effect_sign_2_effect_id(EffectSign) ->
    logic_get_effect_id_by_effect_sign:get(EffectSign).
