%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            钩子模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(hook).

-include("common.hrl").
-include("gen/db.hrl").
-include("msg.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("scene.hrl").
-include("p_enum.hrl").
-include("client.hrl").
-include("skill.hrl").
-include("player_game_data.hrl").
-include("scene_adjust.hrl").

%% API
-export([
    before_enter_game/1,                    %% 玩家进入游戏处理数据
    after_enter_game/3,                     %% 玩家进入游戏
    before_leave_game/3,                    %% 玩家离开游戏前
    after_leave_game/1,                     %% 离开游戏后
    after_register/1,                       %% 注册后
    after_login/1,                          %% 登录后
    after_enter_scene/6,                    %% 进入场景后
    before_enter_scene/3,                   %% 进入场景前
    after_leave_scene/2,                    %% 离开场景
    after_level_upgrade/4,                  %% 等级提升
    after_kill_monster/4,                   %% 杀怪
    after_attack_monster/3,                 %% 攻击怪物
%%    after_fight_monster/2,
    after_active_function/2,                %% 激活功能
    after_create_role/7,                    %% 玩家创建角色
%%    after_passive_skill_upgrade/3,          %% 被动技能升级
%%    after_active_skill_upgrade/4,           %% 主动技能升级
    after_task_finish/2,                    %% 完成任务
%%    after_chapter_change/2,                 %% 关卡变化
    after_mission_balance/5,
    after_mission_balance/6,
    do_after_mission_balance/5,             %% 副本结算
    after_enter_mission/3,                  %% 进入副本
    after_vip_level_upgrade/3,              %% VIP等级提升
    after_kill_player/3,                    %% 击杀玩家
    be_killed/4,                            %% 被杀死
    after_power_change/3,                   %% 战力变化
%%    after_battle_ground_level_change/2,     %% 战场阶数变化
    after_change_name/2,                    %% 改名
    after_cost_prop/5,                      %% 消耗道具
    after_prop_num_charge/5,                %% 道具数量变化
    after_recharge/3,                       %% 充值
    after_fight/3                           %% 战斗后
]).

after_fight(PlayerId, SceneId, Cost) ->
    ?TRY_CATCH(mod_jiangjinchi:general_atk(PlayerId, SceneId, Cost)),
    #t_scene{
        is_hook = IsHook
    } = mod_scene:get_t_scene(SceneId),
    if
        IsHook == ?TRUE ->
            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CONSUMPTION_OF_GOLD, ?CONDITIONS_VALUE_ADD, Cost}),
            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_ATTACK_COUNT, ?CONDITIONS_VALUE_ADD, 1});
        true ->
            noop
    end,
    api_player:notice_player_xiu_zhen_value(PlayerId, []),
    ok.

%% ----------------------------------
%% @doc  进入游戏前
%% @throws 	none
%% @end
%% ----------------------------------
before_enter_game(PlayerId) ->
    %% 处理离线apply
    ?TRY_CATCH(mod_offline_apply:recovery(PlayerId)),
    %% 版本修复
    ?TRY_CATCH(version:version_repair(PlayerId)),
    %% 功能修复
    ?TRY_CATCH(mod_function:repair_all_function(PlayerId)),
    %% 资源找回
%%    ?TRY_CATCH(mod_resource_get_back:refresh(PlayerId)),
    %% 定时恢复次数 (注: 必须要先恢复次数, 然后重置次数)
    ?TRY_CATCH(mod_times_recover:try_trigger_all_times_recover_timer(PlayerId)),
    %% 每日重置次数
    ?TRY_CATCH(mod_times:flush_player_times_data(PlayerId, false)),
    %% 设置回归的时间
    ?TRY_CATCH(mod_player:set_player_return_game_time(PlayerId)),
    %% 玩家定时器
    ?TRY_CATCH(client_msg_handle:init_timer_type(PlayerId)),
    %% 玩家活动进程
%%    ?TRY_CATCH(player_activity_srv_mod:before_init_time(PlayerId)),
    %% 在线奖励登入操作
    ?TRY_CATCH(mod_online_award:login_operation_online_award(PlayerId)),
    %% 处理有效期道具
    ?TRY_CATCH(mod_prop:try_deal_expire_prop_before_enter_game(PlayerId)),
    %% 七天登錄
    ?TRY_CATCH(mod_seven_login:login_set_day(PlayerId)),
    %% 每日任务
    ?TRY_CATCH(mod_daily_task:on_before_enter_game(PlayerId)),
    %% 赏金任务
    ?TRY_CATCH(mod_bounty_task:on_before_enter_game(PlayerId)),
    %% 通行证
    ?TRY_CATCH(mod_tongxingzheng:on_before_enter_game(PlayerId)),
    %% 累充活动
    ?TRY_CATCH(mod_leichong:on_before_enter_game(PlayerId)),
    %% 处理有效期特殊道具(时空胶囊)
    ?TRY_CATCH(mod_special_prop:try_deal_expire_special_prop_before_enter_game(PlayerId)),
    %% 处理每周清理夺宝奖励数据
    ?TRY_CATCH(mod_seize_treasure:get_player_seize_times(PlayerId)),
    %% 設置登錄天數條件
    ?TRY_CATCH(mod_conditions:add_conditions(PlayerId, {?CON_ENUM_LOGIN_DAY, ?CONDITIONS_VALUE_NOT_SAME_DAY_ADD, 1})),
    %% 設置開服時間條件
    ?TRY_CATCH(mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SERVER_DAY_NUM, ?CONDITIONS_VALUE_SET_MAX, mod_server:get_server_open_day_number()})),
    %% 修复图鉴条件
    ?TRY_CATCH(mod_card:repair(PlayerId)),
    %% 初始化服务器数据
    ?TRY_CATCH(mod_player:init_server_data(PlayerId)),
    ok.
%% 红包倒计时
%%    ?TRY_CATCH(mod_red_package:start_balance_timer(PlayerId)).


%% ----------------------------------
%% @doc  注册后
%% @throws 	none
%% @end
%% ----------------------------------
after_register(#conn{acc_id = AccId, server_id = ServerId}) ->
    mod_account:try_init_account(AccId, ServerId).

%% ----------------------------------
%% @doc  登录后
%% @throws 	none
%% @end
%% ----------------------------------
after_login(#conn{sender_worker = SenderWorker, player_id = PlayerId, login_time = LoginTime, ip = Ip, acc_id = AccId, server_id = ServerId}) ->
%%    put(?DICT_CLIENT_ACC_ID, AccId),
%%    put(?DICT_CLIENT_SERVER_ID, ServerId),
    %%  设置该进程玩家id
    put(?DICT_PLAYER_ID, PlayerId),
    PlatformId = mod_server_config:get_platform_id(),
    %% 登录日志
    client_sender_worker:init_player_id(SenderWorker, PlayerId),
    mod_log:write_player_login_log(PlayerId, Ip, LoginTime),
    %% 登录成功 加载玩家数据库数据
    db_load:safe_load_hot_data(PlayerId),
    %% 记录登录信息
    {LastLoginIsToday, LastOfflineTime} = mod_player:record_login_info(PlayerId, LoginTime, Ip),

    %% 增加首充天数
    ?TRY_CATCH(mod_first_charge:add_login_day(PlayerId, LastLoginIsToday, LastOfflineTime)),

    %% 登录服更新最近登录的服务器列表
%%    PlatformId = mod_server_config:get_platform_id(),
    ?TRY_CATCH(rpc:cast(mod_server_config:get_center_node(), mod_global_account, update_recent_server_list, [PlatformId, AccId, ServerId, ?FALSE])).

%% ----------------------------------
%% @doc  进入游戏后
%% @throws 	none
%% @end
%% ----------------------------------
after_enter_game(PlayerId, AccId, ServerId) ->
%%    ?TRY_CATCH(mod_faction:notice_member_change_data(PlayerId)),
    ?TRY_CATCH(mod_player:set_player_online_status(PlayerId, ?TRUE)),
    ?TRY_CATCH(mod_brave_one:enter_game_notice_brave_one_data(PlayerId)),   %% 进游戏通知勇者对战数据
    ?TRY_CATCH(mod_account:try_record_enter_game(AccId, ServerId)),
    ?TRY_CATCH(notice_srv:get_notice(PlayerId)),
    ?TRY_CATCH(mod_tongxingzheng:on_after_enter_game(PlayerId)),
    %% 投资计划通知初始化
    ?TRY_CATCH(api_invest:init_notice_data(PlayerId)),
    %% 特殊道具通知初始化
    ?TRY_CATCH(api_special_prop:notice_init_data(PlayerId)),
    %% 首充通知初始化
    ?TRY_CATCH(api_first_charge:notice_init_data(PlayerId)),
    %% 通知匹配房间
    ?TRY_CATCH(mod_match_scene_room:get_unread_room_num(PlayerId)),
    %% 礼物盒初始化
    ?TRY_CATCH(api_gift:init_data(PlayerId)),
    %% 初始化发送聊天缓存
    ?TRY_CATCH(mod_player_chat:init(PlayerId)),
    %% 发送提示消息
    ?TRY_CATCH(chat_notice:player_login(PlayerId)),
    ok.

%% ----------------------------------
%% @doc  离开游戏前
%% @throws 	none
%% @end
%% ----------------------------------
before_leave_game(PlayerId, Reason, #conn{acc_id = _AccId, player_id = PlayerId, login_time = LoginTime}) ->
%%    PlatformId = mod_server_config:get_platform_id(),
    Now = util_time:timestamp(),
    OnlineTime = Now - LoginTime,
    %% 设置玩家在线状态
    ?TRY_CATCH(mod_player:set_player_online_status(PlayerId, ?FALSE)),
    %% 更新玩家离线时间
    ?TRY_CATCH(mod_player:update_player_offline_time(PlayerId)),
    ?TRY_CATCH(mod_scene:deal_fight_fanpai(PlayerId)),
    %% 更新玩家累计在线时间
    ?TRY_CATCH(mod_player:update_player_total_online_time(PlayerId, OnlineTime)),
    %% 记录玩家在线日志
    ?TRY_CATCH(mod_log:write_player_online_log(PlayerId, LoginTime, Now, OnlineTime, Reason)),
    %% 在线奖励设置在线时间
    ?TRY_CATCH(mod_online_award:set_today_online_time(PlayerId, {Now, LoginTime})),
    %% 离开多人boss房间
    ?TRY_CATCH(mod_many_people_boss:leave_room(PlayerId, true)),
    %% 离开多人时时房间
    ?TRY_CATCH(mod_shi_shi_room:leave_room(PlayerId, true)),
    %% 离开下注队列
%%    ?TRY_CATCH(mod_bet:player_leave_bet(PlayerId, false)),
    %% 取消房间
    ?TRY_CATCH(mod_brave_one:clean(PlayerId)),
    %% 自动结算奖金池奖励
    ?TRY_CATCH(mod_jiangjinchi:before_leave_game(PlayerId)),
    %% 取消场景匹配
    ?TRY_CATCH(mod_match_scene:cancel_match(PlayerId)),
    %% 离开匹配场房间
    ?TRY_CATCH(mod_match_scene_room:offline(PlayerId)),
    %% 离开1v1房间
    ?TRY_CATCH(mod_one_vs_one:leave_game(PlayerId)),
    %% 离开无尽对决
    ?TRY_CATCH(mod_wheel:exit_wheel(PlayerId)),
    ok.

%% ----------------------------------
%% @doc  离开游戏后
%% @throws 	none
%% @end
%% ----------------------------------
after_leave_game(_PlayerId) ->
    noop.
%%    mod_faction:notice_member_change_data(PlayerId).

%% ----------------------------------
%% @doc  升级
%% @throws 	none
%% @end
%% ----------------------------------
after_level_upgrade(PlayerId, OldLevel, NowLevel, _LogType) ->
    lists:foreach(
        fun(ThisLevel) ->
            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_LEVEL, ?CONDITIONS_VALUE_SET_MAX, ThisLevel})
        end, lists:seq(OldLevel + 1, NowLevel)
    ),
    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_LEVEL, NowLevel}]).
%%    mod_award:give(PlayerId, mod_prop:merge_prop_list(ThisLevelAwardList), ?LOG_TYPE_PLAYER_LEVEL_AWARD),
%%    ThisLevelAwardList.
%%    mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_ROLE_SYS).

%% ----------------------------------
%% @doc  杀怪
%% @throws 	none
%% @end
%% ----------------------------------
after_kill_monster(PlayerId, SceneId, MonsterId, KillNum) ->
%%    ?DEBUG("击杀怪物:~p", [{PlayerId, SceneId, MonsterId, KillNum}]),
    SceneType = mod_scene:get_scene_type(SceneId),

    #t_monster{
        is_boss = IsBoss,
        effect_list = EffectList,
        kind = Kind
    } = mod_scene_monster_manager:get_t_monster(MonsterId),

    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_KILL_SCENE_MONSTER_COUNT, SceneId}, ?CONDITIONS_VALUE_ADD, KillNum}),
    if
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            % 尝试更新任务
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_KILL, MonsterId}, ?CONDITIONS_VALUE_ADD, KillNum}),
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_KILL_KIND_COUNT, Kind}, ?CONDITIONS_VALUE_ADD, KillNum}),
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_KILL_SCENE_KIND_COUNT, SceneId, Kind}, ?CONDITIONS_VALUE_ADD, KillNum});
        true ->
            noop
    end,

    Effect =
        case EffectList of
            [ThisEffect, _] ->
                ThisEffect;
            [ThisEffect] ->
                ThisEffect;
            _ ->
                0
        end,
    if
        Effect > 0 ->
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_KILL_EFFECT_COUNT, Effect}, ?CONDITIONS_VALUE_ADD, KillNum});
        true ->
            noop
    end,
    if
        IsBoss == ?FALSE andalso SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_KILL_MONSTER_COUNT, ?CONDITIONS_VALUE_ADD, KillNum});
%%            IsBoss == ?TRUE andalso (SceneType == ?SCENE_TYPE_WORLD_SCENE orelse SceneType == ?SCENE_TYPE_BATTLE_GROUND) ->
%%                mod_conditions:add_conditions(PlayerId, {?CON_ENUM_KILL_BOSS_COUNT, ?CONDITIONS_VALUE_ADD, KillNum});
        true ->
            noop
    end.

%% ----------------------------------
%% @doc  攻击怪物
%% @throws 	none
%% @end
%% ----------------------------------
after_attack_monster(PlayerId, SceneId, MonsterId) ->
%%    ?DEBUG("攻击怪物:~p", [{PlayerId, SceneId, MonsterId}]),
    SceneType = mod_scene:get_scene_type(SceneId),

    #t_monster{
        kind = Kind
    } = mod_scene_monster_manager:get_t_monster(MonsterId),

    if
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            % 尝试更新任务
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_ATTACK_KIND_COUNT, Kind}, ?CONDITIONS_VALUE_ADD, 1});
        true ->
            noop
    end.

%% ----------------------------------
%% @doc  副本结算
%% @throws 	none
%% @end
%% ----------------------------------
after_mission_balance(PlayerId, MissionType, MissionId, Result, AwardList) ->
    after_mission_balance(null, PlayerId, MissionType, MissionId, Result, AwardList).
after_mission_balance(ClientNode, PlayerId, MissionType, MissionId, Result, AwardList) ->
    ?ASSERT(Result == ?P_SUCCESS orelse Result == ?P_FAIL, {result_error, Result}),
    if ClientNode == null ->
        mod_apply:apply_to_online_player(PlayerId, hook, do_after_mission_balance, [PlayerId, MissionType, MissionId, Result, AwardList], store);
        true ->
            mod_apply:apply_to_online_player(ClientNode, PlayerId, hook, do_after_mission_balance, [PlayerId, MissionType, MissionId, Result, AwardList], store)
    end.

%% ----------------------------------
%% @doc  副本结算
%% @throws 	none
%% @end
%% ----------------------------------
do_after_mission_balance(PlayerId, MissionType, MissionId, Result, AwardList) ->
    ?INFO("副本结算(玩家进程):~p~n", [{PlayerId, MissionType, MissionId, Result, AwardList}]),
    if
        Result == ?P_SUCCESS ->
            Tran =
                fun() ->
                    LogType = mod_mission:get_log_type_by_mission_type(MissionType),
                    if
                        true ->
                            % 给奖励
                            mod_award:give(PlayerId, AwardList, LogType)
                    end,
                    % 尝试记录通关副本id
                    mod_mission:try_update_player_passed_mission_id(PlayerId, MissionType, MissionId),
                    % 尝试扣除次数
                    mod_mission:try_del_times(PlayerId, MissionType, MissionId, finish_mission),

                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_MISSION, MissionType}, ?CONDITIONS_VALUE_SET_MAX, MissionId}),
%%                mod_conditions:add_conditions_mission(PlayerId, {?CON_ENUM_MISSION, MissionType}, MissionId),
                    % 触发条件
                    #t_mission_type{
                        conditions_count_tuple = ConditionsTuple
                    } = mod_mission:get_t_mission_type(MissionType),
                    if ConditionsTuple =/= {} ->
                        mod_conditions:add_conditions(PlayerId, {ConditionsTuple, ?CONDITIONS_VALUE_ADD, 1});
                        true ->
                            noop
                    end
                end,
            db:do(Tran);
        true ->
            noop
    end,

    mod_log:write_player_challenge_mission_log(PlayerId, MissionType, MissionId, ?IF(Result == ?P_SUCCESS, 1, 0), util_time:timestamp(), 0, AwardList).

%% ----------------------------------
%% @doc  进入副本
%% @throws 	none
%% @end
%% ----------------------------------
after_enter_mission(PlayerId, MissionType, MissionId) ->
    mod_mission:try_del_times(PlayerId, MissionType, MissionId, enter_mission),
    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_MISSION_TYPE_COUNT, MissionType}, ?CONDITIONS_VALUE_ADD, 1}),
    %% 围剿副本 和 boss 副本 特殊处理， 进入副本就算 挑战完成
    if
        MissionType == ?MISSION_TYPE_WORLD_BOSS ->
            %% 活动加条件
%%            mod_conditions:add_player_join_activity_condition(PlayerId, ?ACT_WORLD_BOSS_1, ?CON_ENUM_WORLD_BOSS_CHALLENGE_COUNT);
%%            mod_conditions:add_player_join_activity_condition(PlayerId, ?ACT_WORLD_BOSS_2, ?CON_ENUM_WORLD_BOSS_CHALLENGE_COUNT),
%%            mod_conditions:add_player_join_activity_condition(PlayerId, ?ACT_WORLD_BOSS_3, ?CON_ENUM_WORLD_BOSS_CHALLENGE_COUNT);
            ok;
        true ->
            noop
    end.


%% ----------------------------------
%% @doc  功能开启
%% @throws 	none
%% @end
%% ----------------------------------
after_active_function(_PlayerId, []) ->
    ok;
after_active_function(PlayerId, FunctionIdList) when is_list(FunctionIdList) ->
    api_player:notice_function_active(PlayerId, FunctionIdList),
    [after_active_function(PlayerId, FunctionId) || FunctionId <- FunctionIdList];
after_active_function(PlayerId, FunctionId) ->
    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_FUN_ID, ?CONDITIONS_VALUE_SET, FunctionId}),
    mod_times:init_player_times_by_function(PlayerId, FunctionId).

%%%% ----------------------------------
%%%% @doc  主动技能等级变化
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%after_active_skill_upgrade(PlayerId, ActiveSkillId, OldLevel, NewLevel) ->
%%%%    ?ASSERT(NewLevel > OldLevel, {ActiveSkillId, OldLevel, NewLevel}),
%%    if OldLevel == NewLevel ->
%%        noop;
%%        true ->
%%            IsActive = OldLevel == 0,
%%            db:tran_apply(fun() ->
%%                api_skill:notice_update_active_skill(mod_active_skill:get_player_active_skill(PlayerId, ActiveSkillId)) end),
%%            if
%%                IsActive ->
%%                    ?DEBUG("激活技能:~p", [{PlayerId, ActiveSkillId, OldLevel, NewLevel}]),
%%%%                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_ACTIVATE_SKILL, ?CONDITIONS_VALUE_ADD, 1}),
%%                    #t_active_skill{
%%                        skill_type = SkillType
%%                    } = mod_active_skill:get_t_active_skill(ActiveSkillId),
%%                    case SkillType of
%%%%                        ?SKILL_TYPE_GOD_WEAPON ->
%%%%                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_GOD_WEAPON_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%%%                        ?SKILL_TYPE_MAGIC_WEAPON ->
%%%%                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_MAGIC_WEAPON_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%                        _ ->
%%                            noop
%%                    end,
%%                    if SkillType == ?SKILL_TYPE_ROLE orelse SkillType == ?SKILL_TYPE_GOD_WEAPON ->
%%                        %% 尝试自动装备技能
%%                        ?DEBUG("主动穿戴技能:~p", [ActiveSkillId]),
%%                        mod_active_skill:try_auto_equip_skill(PlayerId, ActiveSkillId);
%%                        true ->
%%                            noop
%%                    end;
%%                true ->
%%                    noop
%%%%                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SKILL_LEVEL_UP, ?CONDITIONS_VALUE_ADD, 1})
%%            end,
%%%%            _AddLevel = NewLevel - OldLevel,
%%%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SKILL_SUM_LEVEL, ?CONDITIONS_VALUE_ADD, AddLevel}),
%%%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SKILL_LEVEL, ?CONDITIONS_VALUE_SET, NewLevel}),
%%            %% 刷新战力
%%            mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_SKILL_SYS),
%%
%%            case mod_active_skill:is_active_skill_equip(PlayerId, ActiveSkillId) of
%%                true ->
%%                    %% 通知场景更新技能
%%                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_ACTIVE_SKILL, ActiveSkillId, NewLevel}]);
%%                false ->
%%                    noop
%%            end
%%    end.


%% ----------------------------------
%% @doc  进入场景前
%% @throws 	none
%% @end
%% ----------------------------------
before_enter_scene(PlayerId, NowSceneId, ToSceneId) ->
    if NowSceneId =/= 0 ->
        IsSceneTypeChange = mod_scene:get_scene_type(NowSceneId) =/= mod_scene:get_scene_type(ToSceneId),
        %% 离开原来的场景
        try mod_scene:player_leave_scene(PlayerId, IsSceneTypeChange)
        catch
            _:Reason ->
                ?ERROR("leave old scene:~p~n", [{PlayerId, NowSceneId, ToSceneId, Reason, erlang:get_stacktrace()}])
        end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc  进入场景后
%% @throws 	none
%% @end
%% ----------------------------------
after_enter_scene(PlayerId, _OldSceneId, ToSceneId, _ToX, _ToY, _SceneWorker) ->
    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_GO_SCENE, ToSceneId}, ?CONDITIONS_VALUE_ADD, 1}),
    %%  mod_task:condition_update_player_task(PlayerId, {?CON_ENUM_GO_SCENE, ToSceneId}, 1),
    #t_scene{
        force_change_pk_mode = ForceChangePkMode,
        mana_attack_list = [PropId, _]
    } = mod_scene:get_t_scene(ToSceneId),
    if ForceChangePkMode >= 0 ->
        NowPkMode = mod_player:get_player_data(PlayerId, pk_mode),
        if NowPkMode == ForceChangePkMode ->
            noop;
            true ->
                put(recover_pk_mode, NowPkMode),
                mod_player:change_pk_mode(PlayerId, ForceChangePkMode)
        end;
        true ->
            case get(recover_pk_mode) of
                ?UNDEFINED ->
                    noop;
                RecoverPkMode ->
                    mod_player:change_pk_mode(PlayerId, RecoverPkMode)
            end
    end,
    if
        ToSceneId =:= ?SD_MY_MAIN_SCENE ->
            PlayerEnterWorldTimes = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_FIRST_INTO_WORLD_SCENE),
            ?IF(PlayerEnterWorldTimes =:= 1,
                mod_award:give(PlayerId, ?SD_INIT_REWARD, ?LOG_TYPE_SYSTEM_SEND),
%%                mod_award:give(PlayerId, logic_get_ge_xing_hua_init_award_list:assert_get(0), ?LOG_TYPE_SYSTEM_SEND),
                noop);
        true -> noop
    end,
    ?TRY_CATCH(mod_log:enter_game(PlayerId, ToSceneId)),
    ?TRY_CATCH(mod_charge_skill:init_player_charge_skill_list(PlayerId)),
    ?TRY_CATCH(api_player:notice_player_xiu_zhen_value(PlayerId, [])),
    ?TRY_CATCH(mod_jiangjinchi:after_enter_scene(PlayerId, ToSceneId)),
    ok.

%% ----------------------------------
%% @doc  离开场景后
%% @throws 	none
%% @end
%% ----------------------------------
after_leave_scene(PlayerId, _SceneId) ->
    %% 尝试领取副本缓存奖励
    ?TRY_CATCH(mod_mission:get_cache_mission_award(PlayerId, 1)),
    ?TRY_CATCH(mod_log:leave_game(PlayerId)),
    ?TRY_CATCH(mod_account:is_valid_account(PlayerId)),
    ?TRY_CATCH(mod_player:give_player_all_scene_stay_rewards()),
    Fun =
        fun() ->
            BlessCoinNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_BLESS_COIN),
            ?IF(BlessCoinNum > 0, mod_prop:decrease_player_prop(PlayerId, [{?ITEM_BLESS_COIN, BlessCoinNum}], ?LOG_TYPE_SHEN_LONG), noop)
        end,
    %% 离开场景删除神龙币
    ?TRY_CATCH(Fun()).


%% ----------------------------------
%% @doc 	创角成功上报
%% @throws 	none
%% @end
%% ----------------------------------
after_create_role(AccId, ServerId, PlayerId, Extra, FriendCode, NickName, PlatformId) ->
    %%    PlatformId = mod_server_config:get_platform_id(),
    mod_account:try_record_create_role(AccId, ServerId, PlayerId),
    %%    Via = mod_player:get_via(PlayerId),
    if Extra == "" ->
        noop;
        true ->
            mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_CREATE_EXTRA_DATA, Extra)
    end,
    if FriendCode == "" ->
        noop;
        true ->
            %% 处理好友邀请
            ?TRY_CATCH(mod_share:deal_invite(AccId, PlayerId, FriendCode, ServerId ++ "." ++ NickName))
    end,
    ?TRY_CATCH(mod_function:init_active_function(PlayerId)),
    %% 中心数据写入该玩家
    ?TRY_CATCH(mod_global_player:add_global_player(PlayerId)),
    ?TRY_CATCH(mod_server_rpc:cast_war(mod_player, update_player_server_data_init, [PlayerId, PlatformId, ServerId])),
    ?DEBUG("发送新手邮件~p", [{PlayerId, ?MAIL_NEWBIE_LOGIN_MAIL, ?LOG_TYPE_SYSTEM_SEND}]),
    ?TRY_CATCH(send_new_player_mail(PlayerId)),
    %% 玩家创角 初始化夺宝用的幸运值
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_LUCK_VALUE, 0),
    PhoneUniqueId = get(?DICT_EQUIP_ID),
    ?DEBUG("设备唯一识别码 ~p ", [PhoneUniqueId]),
    if
        PhoneUniqueId == "" ->
            noop;
        true ->
            ?TRY_CATCH(spawn(fun() ->
                mod_phone_unique_id:set_is_newbee_adjust(PlatformId, AccId, PhoneUniqueId, PlayerId) end))
    end.
%% 微信红包初始化
%%    ?TRY_CATCH(mod_red_package:init(PlayerId)).

send_new_player_mail(PlayerId) ->
    Node2 =
        case mod_server_rpc:call_center(mod_server, get_login_server_node, []) of
            null -> [];
            R ->
                #db_c_server_node{node = Node1} = R,
                Node1
        end,
    ?ASSERT(Node2 =/= null, login_server_not_exists),
    Node = util:to_atom(Node2),
    AccId = mod_player:get_player_data(PlayerId, acc_id),
    AppId =
        case rpc:call(Node, ets, lookup, [?ETS_LOGIN_CACHE, AccId]) of
            [SettingInEts] when is_record(SettingInEts, ets_login_cache) ->
                #ets_login_cache{
                    app_id = AppIdInEts
                } = SettingInEts,
                AppIdInEts;
            [] -> "com.goldknight.game"
        end,
    IsNativePay =
        case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
            [ErgetSetting] when is_record(ErgetSetting, ets_erget_setting) ->
                #ets_erget_setting{
                    status = IsNativePayInEts
                } = ErgetSetting,
                IsNativePayInEts;
            _Other ->
                1
        end,
    case IsNativePay of
        ?TRUE ->
            mod_mail:add_mail_id(PlayerId, ?MAIL_NEWBIE_LOGIN_MAIL, ?LOG_TYPE_SYSTEM_SEND);
        ?FALSE ->
            noop
    end.

%% ----------------------------------
%% @doc  完成任务
%% @throws 	none
%% @end
%% ----------------------------------
after_task_finish(PlayerId, TaskId) ->
    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_TASK, ?CONDITIONS_VALUE_SET_MAX, TaskId}),
    % 尝试更新章节
%%    mod_task:try_update_chapter(PlayerId, TaskId),
    #t_task{
        jump_scene_list = JumpSceneList
    } = t_task:get({TaskId}),
    case client_worker:is_client_worker() of
        true ->
            case JumpSceneList of
                [] ->
                    noop;
                [SceneId] ->
                    ?DEBUG("跳转场景~p~n", [SceneId]),
                    ?TRY_CATCH(mod_scene:player_enter_scene(PlayerId, SceneId)),
                    mod_scene:save_player_scene_pos(PlayerId, SceneId);
                [SceneId, X, Y] ->
                    ?DEBUG("跳转场景~p~n", [{SceneId, X, Y}]),
                    ?TRY_CATCH(mod_scene:player_enter_scene(PlayerId, SceneId, X, Y)),
                    mod_scene:save_player_scene_pos(PlayerId, SceneId, X, Y)
            end;
        false ->
            noop
    end,
    Player = mod_player:get_player(PlayerId).
%%    mod_account:try_record_finish_firsh_task(Player#db_player.acc_id, Player#db_player.server_id).

%% ----------------------------------
%% @doc     VIP等级提升
%% @throws  none
%% @end
%% ----------------------------------
after_vip_level_upgrade(PlayerId, NewVipLevel, OldVipLevel) when NewVipLevel > OldVipLevel ->
    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_VIP_LEVEL, ?CONDITIONS_VALUE_SET_MAX, NewVipLevel}),
    lists:foreach(
        fun(VipLevel) ->
            mod_vip:get_vip_award(PlayerId, VipLevel)
        end,
        lists:seq(OldVipLevel + 1, NewVipLevel)
    ).
%%    mod_function:active_function_by_condition(PlayerId, [vip_level, NewVipLevel]).

%% ----------------------------------
%% @doc     杀死玩家
%% @throws  none
%% @end
%% ----------------------------------
%% PlayerId 杀死 BeKilledPlayerId
after_kill_player(_PlayerId, _BeKilledPlayerId, _SceneId) ->
%%            #t_scene{
%%                type = SceneType,
%%                mission_type = _MissionType
%%            } = mod_scene:get_t_scene(SceneId),
%%            if MissionType =/= ?MISSION_TYPE_TEMPLE_OF_WAR ->
%%                mod_conditions:add_conditions(PlayerId, {?CON_ENUM_EVERYDAY_KILL_PLAYER, ?CONDITIONS_VALUE_ADD, 1}),
%%                mod_conditions:add_conditions(PlayerId, {?CON_ENUM_KILL_PLAYER_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%                true ->
%%                    noop
%%            end,
%%            if SceneType == ?SCENE_TYPE_MISSION ->
%%                mod_conditions:add_conditions(PlayerId, {?CON_ENUM_DLD_KILL_PLAYER_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%                true ->
%%                    noop
%%            end
%%    assassinate_srv:cast({kill_player, PlayerId, BeKilledPlayerId}),
    ok.

%% PlayerId被杀死
be_killed(PlayerId, _AttackObjType, AttackObjId, _SceneId) ->
    ?DEBUG("被杀死玩家 ~p~n", [{PlayerId, AttackObjId}]),
    noop.

%% ----------------------------------
%% @doc  战力变化
%% @throws 	none
%% @end
%% ----------------------------------
after_power_change(_PlayerId, _OldPower, _NewPower) ->
%%    mod_battle_ground:try_update_player_battle_ground_id(PlayerId, NewPower).
    noop.

%% ----------------------------------
%% @doc 	消耗道具
%% @throws 	none
%% @end
%% ----------------------------------
after_cost_prop(PlayerId, PropId, CostNum, NewNum, _LogType) ->
    if
        PropId == ?ITEM_GOLD orelse PropId == ?ITEM_RMB ->
            case mod_obj_player:get_obj_player(PlayerId) of
                null -> noop;
                PlayerObjInEts ->
                    #ets_obj_player{
                        scene_id = SceneId,
                        scene_worker = SceneWorker
                    } = PlayerObjInEts,
                    #t_scene{
                        is_hook = IsHook,
                        mana_attack_list = ManaAttackList
                    } = mod_scene:get_t_scene(SceneId),
                    [ThisPropId, AttackValueList] = ManaAttackList,
                    MinAttack = lists:min(AttackValueList),
                    if
                        PropId == ThisPropId andalso NewNum < MinAttack andalso IsHook == ?TRUE ->
                            erlang:send(SceneWorker, {apply, scene_notice, player_bankruptcy, [PlayerId]});
                        true ->
                            noop
                    end
            end,
            if
                PropId == ?ITEM_RMB ->
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TEST_COST_TOTAL_RMB, mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TEST_COST_TOTAL_RMB) + CostNum);
                true ->
                    noop
            end;
        true ->
            noop
    end.

after_prop_num_charge(PlayerId, PropId, OldNum, NewNum, _LogType) ->
    scene_adjust:try_add_exp(PlayerId, PropId, OldNum, NewNum),
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            noop;
        ObjPlayer when is_record(ObjPlayer, ets_obj_player) ->
            #ets_obj_player{
                scene_id = SceneId,
                scene_worker = SceneWorker
            } = ObjPlayer,
            T_Scene = mod_scene:get_t_scene(SceneId),
            if
                T_Scene == null ->
                    noop;
                true ->
                    #t_scene{
                        mana_attack_list = [ScenePropId, CostNumList],
                        type = SceneType,
                        is_hook = IsHook
                    } = T_Scene,
                    if
                        SceneType == ?SCENE_TYPE_WORLD_SCENE andalso IsHook == ?TRUE andalso (PropId == ?ITEM_GOLD orelse PropId == ?ITEM_RMB) andalso ?IS_DEBUG ->
                            catch mod_log:adjust_test_log(PlayerId),
                            ok;
                        true ->
                            noop
                    end,
                    if
                        SceneType == ?SCENE_TYPE_WORLD_SCENE andalso IsHook == ?TRUE andalso PropId == ScenePropId ->
                            MinCost = lists:min(CostNumList),
                            if
                                OldNum >= MinCost andalso NewNum < MinCost ->
                                    ?DEBUG("玩家破产： ~p", [{PlayerId, OldNum, NewNum, PropId, MinCost}]),
                                    scene_adjust:send_msg_pid(SceneWorker, {?SCENE_ADJUST_MSG_PLAYER_BANKRUPTRY, PlayerId});
                                OldNum < MinCost andalso NewNum >= MinCost ->
                                    ?DEBUG("玩家破产恢复： ~p", [{PlayerId, OldNum, NewNum, PropId, MinCost}]),
                                    scene_adjust:send_msg_pid(SceneWorker, {?SCENE_ADJUST_MSG_PLAYER_DEVELOP, PlayerId});
                                true ->
                                    noop
                            end;
                        true ->
                            noop
                    end
            end
    end.

%% 改名
after_change_name(PlayerId, Name) ->
    %% 改变global_player 的 玩家名字
    mod_global_player:change_player_name(PlayerId, Name),
%%    PlatformId = mod_server_config:get_platform_id(),
%%    if
%%        PlatformId == ?PLATFORM_DOULUO orelse PlatformId == ?PLATFORM_SJB ->
%%            Pf = get(?DICT_CHANNEL),
%%            #db_player{
%%                nickname = Name
%%                server_id = ServerId
%%            } = mod_player:get_player(PlayerId);
%%            OpenId = get(?DICT_PLATFORM_OPEN_ID);
%%            erlang:spawn(fun() -> douluo:report_register(OpenId, Pf, ?TRUE, PlayerId, Name, ServerId) end);
%%        true ->
    noop.
%%    end.

%% @doc 充值后(不要try_catch，任其崩溃)
after_recharge(PlayerId, RechargeId, Money) ->
    %% 尝试处理首充
%%    first_recharge:deal_charge(PlayerId, RechargeId),
    %% 尝试处理新首充
    mod_first_charge:deal_charge(PlayerId, RechargeId),
    %% 场景通知玩家充值
    ?CATCH(scene_notice:player_charge(PlayerId, Money)),
    %% 投资计划尝试开启
    mod_invest:try_open_invest(PlayerId, RechargeId),
    %% 累充任务
    mod_leichong:refresh_task(PlayerId, round(Money)),
    ok.
