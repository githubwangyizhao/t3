%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            属性模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_attr).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("p_enum.hrl").
-include("msg.hrl").

-export([
%%    refresh_player_data/2,
    sync_player_data/2,             %% 同步玩家数据
    robot_get_sys_attr_list/3,      %% 机器人算属性
    get_player_sys_attr/2,
    get_power_by_attr_list/1,       %% 属性列表 => 战力
    refresh_player_attr/1,          %% 刷新玩家总属性
    refresh_player_all_attr/1,       %% 刷新玩家全部系统属性
    refresh_player_sys_attr/2,       %% 属性玩家系统属性
%%    refresh_player_sys_attr/3       %% 属性玩家系统属性
    get_player_attr/2,               %% 获得玩家属性数据
    get_server_player_attr/1,
    get_player_attr/1
]).

%% @fun 条件 各系统战力处理
-define(CONDITIONS_SYS_POWER_LIST, [
%%    {?FUNCTION_ROLE_SYS, ?CON_ENUM_POWER}                      %% 人物系统
%%    {?FUNCTION_JADE_SYS, ?CON_ENUM_JADE_POWER},                 %% 玉佩系统
]).


%% @fun 机器人算属性
robot_get_sys_attr_list(RobotId, {Level, _BodyGodWeaponId}, AttrList) ->
    TotalPlayerSysAttr = tran_attr_list_2_player_sys_attr(#db_player_sys_attr{}, AttrList),
    #db_player_sys_attr{
        attack = Attack,
        defense = Defense,
        hp = Hp,
        dodge = Dodge,
        hit = Hit,
        critical = Critical,
        tenacity = Tenacity,
        crit_time = CritTime,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        hp_reflex = HpReflex,
        power = Power
    } = TotalPlayerSysAttr,
    #db_player_data{
        row_key = {RobotId},
        level = Level,
        player_id = RobotId,
        attack = Attack,
        defense = Defense,
        hp = Hp,
        max_hp = Hp,
        dodge = Dodge,
        hit = Hit,
        critical = Critical,
        tenacity = Tenacity,
        crit_time = CritTime,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        hp_reflex = HpReflex,
        power = Power
    }.

%%%% ----------------------------------
%%%% @doc 	获取该系统属性列表
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_SYS) ->        % 人物系统
%%    mod_player:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_EQUIP_SYS) ->        % 装备系统
%%    mod_equip:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_TITLE_SYS) ->        % 称号系统
%%    mod_title:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_MAGIC_WEAPON) ->    % 法宝系统
%%    mod_magic_weapon:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_GOD_WEAPON) ->    % 神兵系统
%%    mod_god_weapon:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_MELTING_SYS) ->     % 熔炼系统
%%    mod_equip:get_melting_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_BREACH) ->     % 渡劫系统
%%    mod_dujie:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_STATE_SYS) ->         % 境界系统
%%    mod_jing_jie:get_sys_attr_list(PlayerId);
get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_WING = FunctionId) ->            % 翅膀系统
    mod_sys_common:get_sys_attr_list(PlayerId, FunctionId);
get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_WEAPON = FunctionId) ->          % 武器系统
    mod_sys_common:get_sys_attr_list(PlayerId, FunctionId);
get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_CLOTHES = FunctionId) ->         % 时装系统
    mod_sys_common:get_sys_attr_list(PlayerId, FunctionId);
get_sys_attr_list(PlayerId, ?FUNCTION_ROLE_MAGIC = FunctionId) ->           % 法宝系统
    mod_sys_common:get_sys_attr_list(PlayerId, FunctionId);

%%get_sys_attr_list(PlayerId, ?FUNCTION_GHOST_SYS = FunctionId) ->            % 妖灵系统
%%    mod_ghost:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_MOUNT_SYS = FunctionId) ->            % 坐骑系统
%%    mod_mount:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_WINGS_SYS = FunctionId) ->            % 翅膀系统
%%    mod_wings:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_GOD_FOOTPRINTS_SYS = FunctionId) ->   % 神印系统
%%    mod_god_footprints:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_GHOST_WEAPON_SYS = FunctionId) ->     % 灵武系统
%%    mod_ghost_weapon:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_GHOST_WINGS_SYS = FunctionId) ->      % 灵羽系统
%%    mod_ghost_wings:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_GHOST_ARRAY_SYS = FunctionId) ->      % 灵阵系统
%%    mod_ghost_array:get_sys_attr_list(PlayerId, FunctionId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_EIGHT_DOOR) ->        % 八门系统
%%    mod_eight_door:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_SKILL_SYS) ->         % 技能系统
%%    mod_active_skill:get_sys_attr_list(PlayerId);
get_sys_attr_list(PlayerId, ?FUNCTION_PASSIVE_SKILL_SYS) -> % 被动技能系统
    mod_passive_skill:get_sys_attr_list(PlayerId).
%%get_sys_attr_list(PlayerId, ?FUNCTION_BRANCH_TASK) ->       % 支线系统
%%    mod_branch_task:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_JADE_SYS) ->          % 玉佩系统
%%    mod_jade:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_HONE_SYS) ->          % 历练系统
%%mod_hone:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_HEART_SYS) ->         % 心法系统
%%    mod_heart:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_CLOTHES_SYS) ->       % 时装系统
%%    mod_clothes:get_sys_attr_list(PlayerId);
%%get_sys_attr_list(PlayerId, ?FUNCTION_MAGIC_THUNDER) ->       % 法宝闪电链系统
%%    mod_magic_thunder:get_sys_attr_list(PlayerId)
%%get_sys_attr_list(PlayerId, ?FUNCTION_HUAN_XING_SYS) ->       % 幻形系统
%%    mod_huan_xing:get_sys_attr_list(PlayerId)


%% @fun 刷新玩家全部系统属性
refresh_player_all_attr(PlayerId) ->
    Tran =
        fun() ->
            UpdateList =
                lists:foldl(
                    fun(#db_player_sys_attr{fun_id = FunId, power = OldPower}, UpdateL) ->
                        refresh_player_sys_attr(PlayerId, FunId, false),
                        OldPlayerAttr = get_player_sys_attr(PlayerId, FunId),
                        NewPower = OldPlayerAttr#db_player_sys_attr.power,
                        if
                            OldPower =/= NewPower ->
                                [{FunId, OldPower, NewPower} | UpdateL];
                            true ->
                                UpdateL
                        end
                    end, [], get_all_player_sys_attr_fun(PlayerId)),
            case UpdateList of
                [] ->
                    noop;
                _ ->
                    ?INFO("刷新玩家全部系统属性~p:~p", [PlayerId, UpdateList]),
                    {ok, _Power} = refresh_player_attr(PlayerId)
%%                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_POWER, ?CONDITIONS_VALUE_SET_MAX, Power})
            end
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	刷新玩家系统属性
%% @throws 	none
%% @end
%% ----------------------------------
refresh_player_sys_attr(PlayerId, FunId) ->
    refresh_player_sys_attr(PlayerId, FunId, true).
refresh_player_sys_attr(PlayerId, FunId, IsRefreshRole) ->
    Result = refresh_player_sys_attr(PlayerId, FunId, get_sys_attr_list(PlayerId, FunId), IsRefreshRole),
    if
        IsRefreshRole == true ->
            {ok, _Power} = Result;
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_POWER, ?CONDITIONS_VALUE_SET_MAX, Power});
        true ->
            noop
    end.
%% @fun 刷新系统属性并 刷新玩家总属性
refresh_player_sys_attr(PlayerId, FunId, AttrList, IsRefreshRole) ->
    PlayerSysAttr = get_clean_player_sys_attr(PlayerId, FunId),
    NewPlayerSysAttr = tran_attr_list_2_player_sys_attr(PlayerSysAttr, AttrList),
    OldPlayerAttr = get_player_sys_attr(PlayerId, FunId),
    if
        OldPlayerAttr =/= NewPlayerSysAttr ->
            Tran =
                fun() ->
                    db:write(NewPlayerSysAttr#db_player_sys_attr{change_time = util_time:timestamp()}),
                    mod_log:write_attr_log(PlayerId, FunId, NewPlayerSysAttr#db_player_sys_attr.power, NewPlayerSysAttr#db_player_sys_attr.power - PlayerSysAttr#db_player_sys_attr.power, NewPlayerSysAttr#db_player_sys_attr.attack, NewPlayerSysAttr#db_player_sys_attr.defense),
                    conditions_sys_power(PlayerId, FunId, NewPlayerSysAttr#db_player_sys_attr.power)
                end,
            db:do(Tran);
        true ->
            noop
    end,
    if
        IsRefreshRole == true ->
            refresh_player_attr(PlayerId);
        true ->
            noop
    end.

%% @fun 战力系统触发的条件
conditions_sys_power(PlayerId, FunId, Power) ->
    case lists:keyfind(FunId, 1, ?CONDITIONS_SYS_POWER_LIST) of
        {FunId, ConditionsKey} ->
            mod_conditions:add_conditions(PlayerId, {ConditionsKey, ?CONDITIONS_VALUE_SET_MAX, Power});
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	刷新玩家总属性
%% @throws 	none
%% @end
%% ----------------------------------
refresh_player_attr(PlayerId) ->
    PlayerData = mod_player:get_db_player_data(PlayerId),
    AllPlayerSysAttr = get_all_player_sys_attr_fun(PlayerId),
    TotalPlayerSysAttr = merge_player_sys_attr(AllPlayerSysAttr),
    #db_player_sys_attr{
        attack = Attack,
        defense = Defense,
        hp = Hp,
        dodge = Dodge,
        hit = Hit,
        critical = Critical,
        tenacity = Tenacity,
        crit_time = CritTime,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        hp_reflex = HpReflex,
        rate_resist_block = RateResistBlock,
        rate_block = RateBlock,
        power = Power
    } = TotalPlayerSysAttr,
    NewPlayerData = PlayerData#db_player_data{
        attack = Attack,
        defense = Defense,
        hp = Hp,
        max_hp = Hp,
        dodge = Dodge,
        hit = Hit,
        critical = Critical,
        tenacity = Tenacity,
        crit_time = CritTime,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        hp_reflex = HpReflex,
        rate_resist_block = RateResistBlock,
        rate_block = RateBlock,
        power = Power
    },
    Tran =
        fun() ->
            db:write(NewPlayerData),
            if Power =/= PlayerData#db_player_data.power ->
                %% 战力发生变化
                hook:after_power_change(PlayerId, PlayerData#db_player_data.power, Power);
                true ->
                    noop
            end,
            sync_player_data(PlayerData, NewPlayerData),
            {ok, Power}
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	整合各系统属性
%% @throws 	none
%% @end
%% ----------------------------------
merge_player_sys_attr(PlayerSysAttrList) ->
    arrange_player_sys_attr(PlayerSysAttrList, #db_player_sys_attr{}).

arrange_player_sys_attr([], ResultPlayerSysAttr) ->
    update_player_sys_attr_power(ResultPlayerSysAttr);
arrange_player_sys_attr([ThisPlayerSysAttr | T], PlayerSysAttr) ->
    #db_player_sys_attr{
        attack = ThisAttack,
        defense = ThisDefense,
        hp = ThisHp,
        dodge = ThisDodge,
        hit = ThisHit,
        critical = ThisCritical,
        tenacity = ThisTenacity,
        crit_time = ThisCritTime,
        hurt_add = ThisHurtAdd,
        hurt_reduce = ThisHurtReduce,
        crit_hurt_add = ThisCritHurtAdd,
        crit_hurt_reduce = ThisCritHurtReduce,
        hp_reflex = ThisHpReflex,
        rate_resist_block = ThisRateResistBlock,
        rate_block = ThisRateBlock
    } = ThisPlayerSysAttr,
    #db_player_sys_attr{
        attack = Attack,
        defense = Defense,
        hp = Hp,
        dodge = Dodge,
        hit = Hit,
        critical = Critical,
        tenacity = Tenacity,
        crit_time = CritTime,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        hp_reflex = HpReflex,
        rate_resist_block = RateResistBlock,
        rate_block = RateBlock
    } = PlayerSysAttr,
    PlayerSysAttr_2 =
        PlayerSysAttr#db_player_sys_attr{
            attack = Attack + ThisAttack,
            defense = Defense + ThisDefense,
            hp = Hp + ThisHp,
            dodge = Dodge + ThisDodge,
            hit = Hit + ThisHit,
            critical = Critical + ThisCritical,
            tenacity = Tenacity + ThisTenacity,
            crit_time = CritTime + ThisCritTime,
            hurt_add = HurtAdd + ThisHurtAdd,
            hurt_reduce = HurtReduce + ThisHurtReduce,
            crit_hurt_add = CritHurtAdd + ThisCritHurtAdd,
            crit_hurt_reduce = CritHurtReduce + ThisCritHurtReduce,
            hp_reflex = HpReflex + ThisHpReflex,
            rate_resist_block = RateResistBlock + ThisRateResistBlock,
            rate_block = RateBlock + ThisRateBlock
        },
    arrange_player_sys_attr(T, PlayerSysAttr_2).

%% ----------------------------------
%% @doc 	属性列表 => 战力
%% @throws 	none
%% @end
%% ----------------------------------
get_power_by_attr_list(AttrList) ->
    R = tran_attr_list_2_player_sys_attr(#db_player_sys_attr{}, AttrList),
    R#db_player_sys_attr.power.

%% ----------------------------------
%% @doc 	转换属性列表
%% @throws 	none
%% @end
%% ----------------------------------
tran_attr_list_2_player_sys_attr(PlayerSysAttr, []) ->
    update_player_sys_attr_power(PlayerSysAttr);
tran_attr_list_2_player_sys_attr(PlayerSysAttr, [AttrTuple | T]) ->
    PlayerSysAttr_1 =
        case AttrTuple of
            {AttIdList1, Param} when is_list(AttIdList1) ->        % 对属性列表另外处理
                calc_db_player_sys_attr_list(PlayerSysAttr, AttIdList1, Param);
            _ ->
                calc_db_player_sys_attr(PlayerSysAttr, AttrTuple)
        end,
    tran_attr_list_2_player_sys_attr(PlayerSysAttr_1, T).

%% @fun 计算属性列表
calc_db_player_sys_attr_list(PlayerSysAttr, [], _Param) ->
    PlayerSysAttr;
calc_db_player_sys_attr_list(PlayerSysAttr, [AttrTuple | AttrList], Param) ->
    PlayerSysAttr1 = calc_db_player_sys_attr(PlayerSysAttr, AttrTuple, Param),
    calc_db_player_sys_attr_list(PlayerSysAttr1, AttrList, Param).
%% @fun 计算单个属性
calc_db_player_sys_attr(PlayerSysAttr, AttrTuple) ->
    calc_db_player_sys_attr(PlayerSysAttr, AttrTuple, noop).
calc_db_player_sys_attr(PlayerSysAttr, _AttrTuple, _Param) ->
    PlayerSysAttr.
%%    {AttId, Value0} =
%%        case AttrTuple of
%%            [AttId1, Value1] ->                % 配表时的属性内容
%%                {AttId1, Value1};
%%            _ ->
%%                AttrTuple
%%        end,
%%    Value = change_prob_num_value(Value0, Param),
%%        case Param of
%%            {?ATTR_ADD_RATIO, AddRatio} ->            % 属性提升万分比
%%                change_prob_num_value(Value0, AddRatio);
%%            _ ->
%%                Value0
%%    #db_player_sys_attr{
%%        attack = Attack,
%%        defense = Defense,
%%        hp = Hp,
%%        dodge = Dodge,
%%        hit = Hit,
%%        critical = Critical,
%%        tenacity = Tenacity,
%%        crit_time = CritTime,
%%        hurt_add = HurtAdd,
%%        hurt_reduce = HurtReduce,
%%        crit_hurt_add = CritHurtAdd,
%%        crit_hurt_reduce = CritHurtReduce,
%%        hp_reflex = HpReflex,
%%        rate_resist_block = RateResistBlock,
%%        rate_block = RateBlock
%%    } = PlayerSysAttr,
%%    case AttId of
%%        ?ATTR_DODGE ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                dodge = Dodge + Value
%%            };
%%        ?ATTR_HP ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                hp = Hp + Value
%%            };
%%        ?ATTR_HIT ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                hit = Hit + Value
%%            };
%%        ?ATTR_RESIST_CRIT ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                tenacity = Tenacity + Value
%%            };
%%        ?ATTR_ATTACK ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                attack = Attack + Value
%%            };
%%        ?ATTR_DEFENSE ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                defense = Defense + Value
%%            };
%%        ?ATTR_CRIT ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                critical = Critical + Value
%%            };
%%        ?ATTR_CRIT_TIME ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                crit_time = CritTime + Value
%%            };
%%        ?ATTR_HURT_ADD ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                hurt_add = HurtAdd + Value
%%            };
%%        ?ATTR_HURT_REDUCE ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                hurt_reduce = HurtReduce + Value
%%            };
%%        ?ATTR_CRIT_HURT_ADD ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                crit_hurt_add = CritHurtAdd + Value
%%            };
%%        ?ATTR_CRIT_HURT_REDUCE ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                crit_hurt_reduce = CritHurtReduce + Value
%%            };
%%        ?ATTR_HP_REFLEX ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                hp_reflex = HpReflex + Value
%%            };
%%        ?ATTR_RESIST_BLOCK ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                rate_resist_block = RateResistBlock + Value
%%            };
%%        ?ATTR_BLOCK ->
%%            PlayerSysAttr#db_player_sys_attr{
%%                rate_block = RateBlock + Value
%%            };
%%        _ ->
%%            ?ERROR("计算属性项出错{AttId, {AttrTuple, Param}}: ~p~n", [{AttId, {AttrTuple, Param}}]),
%%            exit(error_calc_attr_fail)
%%    end.

%%%% @fun 比率属性转换
%%change_prob_num_value(Value, Param) ->
%%    case Param of
%%        {?ATTR_ADD_RATIO, AddRatio} ->            % 属性提升万分比
%%            Ratio1 = AddRatio + ?PROP_NUM_10000,
%%            trunc(Value * Ratio1 / ?PROP_NUM_10000);
%%        {?ATTR_RATIO, Ratio} ->            % 属性万分比
%%            trunc(Value * Ratio / ?PROP_NUM_10000);
%%        _ ->
%%            Value
%%    end.

%% ----------------------------------
%% @doc 	更新属性战力
%% @throws 	none
%% @end
%% ----------------------------------
update_player_sys_attr_power(PlayerSysAttr) ->
%%    #db_player_sys_attr{
%%        attack = Attack,
%%        defense = Defense,
%%        hp = Hp,
%%        dodge = Dodge,
%%        hit = Hit,
%%        critical = Critical,
%%        tenacity = Tenacity,
%%        crit_time = CritTime,
%%        hurt_add = HurtAdd,
%%        hurt_reduce = HurtReduce,
%%        crit_hurt_add = CritHurtAdd,
%%        crit_hurt_reduce = CritHurtReduce,
%%        hp_reflex = HpReflex,
%%        rate_resist_block = RateResistBlock,
%%        rate_block = RateBlock
%%
%%    } = PlayerSysAttr,
    Power = 0,
%%        (?ATTR_POWER_RATE_ATTACK * Attack +
%%            ?ATTR_POWER_RATE_DODGE * Dodge +
%%            ?ATTR_POWER_RATE_HP * Hp +
%%            ?ATTR_POWER_RATE_HIT * Hit +
%%            ?ATTR_POWER_RATE_RESIST_CRIT * Tenacity +
%%            ?ATTR_POWER_RATE_DEFENSE * Defense +
%%            ?ATTR_POWER_RATE_CRIT * Critical +
%%            ?ATTR_POWER_RATE_CRIT_TIME * CritTime +
%%            ?ATTR_POWER_RATE_HURT_ADD * HurtAdd +
%%            ?ATTR_POWER_RATE_HURT_REDUCE * HurtReduce +
%%            ?ATTR_POWER_RATE_CRIT_HURT_ADD * CritHurtAdd +
%%            ?ATTR_POWER_RATE_CRIT_HURT_REDUCE * CritHurtReduce +
%%            ?ATTR_POWER_RATE_HP_REFLEX * HpReflex +
%%            ?ATTR_POWER_RATE_RESIST_BLOCK * RateResistBlock +
%%            ?ATTR_POWER_RATE_BLOCK * RateBlock
%%        ) div 1000,
    PlayerSysAttr#db_player_sys_attr{
        power = Power
    }.

%% ----------------------------------
%% @doc 	同步玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
sync_player_data(OldPlayerData, NewPlayerData) ->
    #db_player_data{
        player_id = PlayerId,
        level = OldLevel,
%%        power = OldPower,
        max_hp = OldMaxHp,
        attack = OldAttack,
        defense = OldDefense,
        hit = OldHit,
        dodge = OldDodge,
        critical = OldCritical,
        tenacity = OldTenacity,
        crit_time = OldCritTime,
        hurt_add = OldHurtAdd,
        hurt_reduce = OldHurtReduce,
        crit_hurt_add = OldCritHurtAdd,
        crit_hurt_reduce = OldCritHurtReduce,
        hp_reflex = OldHpReflex,
        rate_resist_block = OldRateResistBlock,
        rate_block = OldRateBlock
    } = OldPlayerData,

    #db_player_data{
        player_id = PlayerId,
        level = NewLevel,
%%        power = NewPower,
        max_hp = NewMaxHp,
        attack = NewAttack,
        defense = NewDefense,
        hit = NewHit,
        dodge = NewDodge,
        critical = NewCritical,
        tenacity = NewTenacity,
        crit_time = NewCritTime,
        hurt_add = NewHurtAdd,
        hurt_reduce = NewHurtReduce,
        crit_hurt_add = NewCritHurtAdd,
        crit_hurt_reduce = NewCritHurtReduce,
        hp_reflex = NewHpReflex,
        rate_resist_block = NewRateResistBlock,
        rate_block = NewRateBlock
    } = NewPlayerData,
    {RealSyncDataList, NoticeDataList} =
        lists:foldl(
            %% 同步场景     %% 通知玩家自己
            fun({IsChange, Meta, NoticeData}, {TmpSyncDataList, TmpNoticeDataList}) ->
                if IsChange ->
                    if NoticeData == noop ->
                        {[Meta | TmpSyncDataList], TmpNoticeDataList};
                        true ->
                            {[Meta | TmpSyncDataList], [NoticeData | TmpNoticeDataList]}
                    end;
                    true ->
                        {TmpSyncDataList, TmpNoticeDataList}
                end
            end,
            {[], []},
            [
                %%%%%%%%%%% 玩家数据 同步到 场景玩家 和通知客户端%%%%%%%%%%
                {OldLevel =/= NewLevel, {?MSG_SYNC_LEVEL, NewLevel}, noop},
%%                {OldPower =/= NewPower, {?MSG_SYNC_POWER, NewPower}, {?P_POWER, NewPower}},
                {OldMaxHp =/= NewMaxHp, {?MSG_SYNC_MAX_HP, NewMaxHp}, noop},
                {OldAttack =/= NewAttack, {?MSG_SYNC_ATTACK, NewAttack}, noop},
                {OldDefense =/= NewDefense, {?MSG_SYNC_DEFENSE, NewDefense}, noop},
                {OldHit =/= NewHit, {?MSG_SYNC_HIT, NewHit}, noop},
                {OldDodge =/= NewDodge, {?MSG_SYNC_DODGE, NewDodge}, noop},
                {OldCritical =/= NewCritical, {?MSG_SYNC_CRITICAL, NewCritical}, noop},
                {OldTenacity =/= NewTenacity, {?MSG_SYNC_TENACITY, NewTenacity}, noop},

                {OldCritTime =/= NewCritTime, {?MSG_SYNC_CRIT_TIME, NewCritTime}, noop},
                {OldHurtAdd =/= NewHurtAdd, {?MSG_SYNC_HURT_ADD, NewHurtAdd}, noop},
                {OldHurtReduce =/= NewHurtReduce, {?MSG_SYNC_HURT_REDUCE, NewHurtReduce}, noop},
                {OldCritHurtAdd =/= NewCritHurtAdd, {?MSG_SYNC_CRIT_HURT_ADD, NewCritHurtAdd}, noop},
                {OldCritHurtReduce =/= NewCritHurtReduce, {?MSG_SYNC_CRIT_HURT_REDUCE, NewCritHurtReduce}, noop},
                {OldHpReflex =/= NewHpReflex, {?MSG_SYNC_HP_REFLEX, NewHpReflex}, noop},
                {OldRateResistBlock =/= NewRateResistBlock, {?MSG_SYNC_RATE_RESIST_BLOCK, NewRateResistBlock}, noop},
                {OldRateBlock =/= NewRateBlock, {?MSG_SYNC_RATE_BLOCK, NewRateBlock}, noop}

            ]
        ),
%%    ?DEBUG("~p~n", [{PlayerId, RealSyncDataList}]),
    mod_scene:push_player_data_2_scene(PlayerId, RealSyncDataList),
    api_player:notice_player_attr_change(PlayerId, NoticeDataList).


%% ----------------------------------
%% @doc 	获得玩家属性数据
%% @throws 	none
%% @end
%% ----------------------------------
get_player_attr(PlayerId, AimPlayerId) ->
    if
        AimPlayerId == 0 ->
            get_player_attr(PlayerId);
        true ->
            case mod_player:get_db_player1(AimPlayerId) of
                AimData when is_record(AimData, db_player) ->
                    get_player_attr(AimPlayerId);
                _ ->
                    F = fun() ->
                        mod_server_rpc:call_center(mod_attr, get_server_player_attr, [AimPlayerId]) end,
                    Key = {?MODULE, get_player_attr, AimPlayerId},
                    mod_cache:cache_data(Key, F, 10)
            end
    end.

%% 中心服获取玩家属性
get_server_player_attr(PlayerId) ->
    GlobalData = mod_global_player:get_global_player(PlayerId),
    if
        GlobalData == null ->
            [];
        true ->
            #db_global_player{
                platform_id = PlatformId,
                server_id = ServerId
            } = GlobalData,
            Node = mod_server:get_game_node(PlatformId, ServerId),
            ?TRY_CATCH(util:rpc_call(Node, mod_attr, get_player_attr, [PlayerId]))
    end.

%% 获得玩家属性
get_player_attr(_PlayerId) ->
%%    #db_player_data{
%%        hp = Hp,
%%        defense = Defense,
%%        attack = Attack,
%%        critical = Critical,
%%        tenacity = Tenacity,
%%        hit = Hit,
%%        dodge = Dodge,
%%        rate_resist_block = RateResistBlock,
%%        rate_block = RateBlock,
%%        crit_hurt_add = CritHurtAdd,
%%        crit_hurt_reduce = CritHurtReduce
%%    } = mod_player:get_player_data(PlayerId),
    [
%%        {?ATTR_HP, Hp},
%%        {?ATTR_DEFENSE, Defense},
%%        {?ATTR_ATTACK, Attack},
%%        {?ATTR_CRIT, Critical},
%%        {?ATTR_RESIST_CRIT, Tenacity},
%%        {?ATTR_HIT, Hit},
%%        {?ATTR_DODGE, Dodge},
%%        {?ATTR_RESIST_BLOCK, RateResistBlock},
%%        {?ATTR_BLOCK, RateBlock},
%%        {?ATTR_CRIT_HURT_ADD, CritHurtAdd},
%%        {?ATTR_CRIT_HURT_REDUCE, CritHurtReduce}
    ].

%% ================================================ 数据操作 ================================================

%% ----------------------------------
%% @doc 	获取玩家系统属性
%% @throws 	none
%% @end
%% ----------------------------------
get_player_sys_attr(PlayerId, FunId) ->
    case db:read(#key_player_sys_attr{player_id = PlayerId, fun_id = FunId}) of
        null ->
            #db_player_sys_attr{
                player_id = PlayerId,
                fun_id = FunId
            };
        R ->
            R
    end.

%% @fun 清空数据
get_clean_player_sys_attr(PlayerId, FunId) ->
    case db:read(#key_player_sys_attr{player_id = PlayerId, fun_id = FunId}) of
        null ->
            #db_player_sys_attr{
                player_id = PlayerId,
                fun_id = FunId
            };
        R ->
            R#db_player_sys_attr{
                attack = 0,
                defense = 0,
                hp = 0,
                dodge = 0,
                hit = 0,
                critical = 0,
                tenacity = 0,
                crit_time = 0,
                hurt_add = 0,
                hurt_reduce = 0,
                crit_hurt_add = 0,
                crit_hurt_reduce = 0,
                hp_reflex = 0,
                rate_resist_block = 0,
                rate_block = 0
            }
    end.

%% @fun 获得全部系统数据
get_all_player_sys_attr_fun(PlayerId) ->
    db_index:get_rows(#idx_player_sys_attr_1{player_id = PlayerId}).
%%    db:select(player_sys_attr, [{#db_player_sys_attr{player_id = PlayerId, _ = '_'}, [], ['$_']}]).


%% ================================================ 模板操作 ================================================
