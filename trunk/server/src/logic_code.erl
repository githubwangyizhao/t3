%%%-------------------------------------------------------------------
%%% @author
%%% @copyright
%%% @doc            生成逻辑数据代码
%%% @end
%%% Created : 02. 六月 2016 下午 4:11
%%%-------------------------------------------------------------------
-module(logic_code).
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("scene.hrl").
%% API
-compile(export_all).

%% 场景逻辑定义 (生成场景数据 时调用)
scene_logic() ->
    [
        get_map_node_path,                                      %% 获取地图路径点
        get_mission_total_monster_num                           %% 获取副本怪物总数量
    ].

%% 逻辑定义 (生成csv数据时调用)
logic() ->
    [
        is_in_balance_grid,                                     %% 是否在结算的格子里面
        get_conditions_function_list,                           %% 获得条件的功能列表
        get_conditions_achievement_list,                        %% 获得条件的成就列表
        get_conditions_daily_task_list,                         %% 获得条件的每日任务列表
        get_conditions_sign_id,                                 %% 根据条件sign获得id
        get_conditions_id_to_sign,                              %% 根据条件id获得sign
        get_conditions_share_task_list,
        get_shop_activity_reset_list,                           %% 商店活动重置列表
        get_shop_day_reset_list,                                %% 商店每日重置列表

        get_achievement_type_list,                              %% 成就类型列表
        get_robot_attr_id_list,                                 %% 获得机器人属性列表
%%        get_activity_id_all_list,                               %% 获得全部活动id列表
%%        get_activity_new_server_not_have_list,                  %% 获得新服不存在列表
%%        get_activity_time_type_info_list,                       %% 获得活动时间类型内容列表
        get_function_have_fun_id_list,                          %% 可存在的功能列表
        get_function_not_have_fun_id_list,                      %% 不可存在的功能列表
        get_function_have_init_list,                            %% 初始时的功能可存在列表
        get_vip_level_exp,                                      %% vip等级经验
        get_function_id_module,                                 %% 获取功能对应模块
        get_function_id_list,                                   %% 获取功能id列表
        get_auto_shop_id_list,                                  %% 获得自动购买时间表的编号列表
        get_shop_type_id_list,                                  %% 获得商店对应id列表
        get_shop_charge_shop_id,                                %% 获得充值商店id
        get_shop_charge_id_list,                                %% 获得商店充值id的商品列表
        get_recharge_charge_type_list,                          %% 平台充值商品类型列表
        get_recharge_type_list,                                 %% 支付类型
        get_can_be_traded_items,
        get_is_conditions_item,                                 %% 获得是条件道具id
        get_charge_http_type_value_list,                        %% 充值活动类型值列表
        get_charge_http_type_list,                              %% 充值http活动类型值列表
        get_charge_http_recharge_id_list,                       %% 充值http充值id的值列表

        %%  场景 地图相关 生成顺序有特殊要求

        %%  场景地图相关 BEGIN %%
        get_all_map_id,                                         %% 获取所有地图id
        get_all_common_map_id,                                  %% 获取所有本服地图id
        get_all_cross_map_id,                                   %% 获取所有跨服地图id
        get_all_war_map_id,                                     %% 获取所有战区地图id
        get_all_world_map_id,                                   %% 获取所有世界地图id
        get_all_scene_id,                                       %% 获取所有场景id
        get_all_world_scene_id,                                 %% 获取所有世界场景id
        get_all_hook_scene_id,                                  %% 获取所有挂机场景id
        get_all_world_hook_scene_id,                            %% 获取所有世界挂机场景id
        get_all_world_scene_id_by_server_type,
        get_times_id_by_function_id,                            %% 通过功能id获取次数列表
        get_all_times_id,                                       %% 获取所有次数id
        get_all_mission,
        get_all_mission_id_by_mission_type,
        get_scene_id_list_by_map_id,                            %% 通过map_id  获取scene_id 列表
        get_skill_slot_id_list_by_condition,                    %% 通过激活条件获取技能槽id列表
%%        get_scene_monster_pos_info,
        get_skill_shift_info,
        %%  场景地图相关 END %%
%%        get_mystery_shop_id_list,
        get_everyday_sign_day_list,                             %% 获得每日签到天数表
        get_online_award_day_list,                              %% 获得在线奖励天数
        get_effect_id_by_effect_sign,
        get_all_platform_id,                                    %% 获取所有平台id
        get_slot_id_by_type,
        merge_skill_balance_list,
        get_all_award_id,                                       %% 获取所有奖励id列表
        get_channel_list_by_platform_id,                        %% 获取该平台所有渠道
        get_share_type_task_id,                                 %% 获得分享有礼任务类型对应编号id
        get_invite_task_type_list,                              %% 获得邀请任务类型列表
        get_platform_id_by_channel,
        get_monster_ai_args,
        get_share_id_list,                                      %% 获得邀请任务id列表
        get_max_mission_id_by_mission_type,                     %% 获取最大的副本id
        get_many_people_boss_id_by_mission_id,                  %% 根据多人boss副本id获得boss_id
        get_conditions_task_list,                               %% 获得条件的任务列表
%%        get_activity_id_list_by_mod_name,
        get_red_packet_id_by_type_list,                         %% 根据红包类型获得id列表
        get_conditions_invest_list,                             %% 获得条件的投资返利id列表
        get_conditions_individual_red_packet_id_list,           %% 根据红包条件获得单人红包条件id列表
        get_conditions_red_packet_id_list,                      %% 根据红包条件获得红包条件id列表
%%        get_shop_item_money,                                    %% 获得商店道具金钱价格
        get_sys_common_id_list_by_func_id,                      %% 根据功能id获得公共系统id列表

%%        get_activity_check_type_time_list,
%%        get_activity_check_type_list,
%%        get_activity_check_type_check_time_list,
%%        get_activity_close_time_list,
%%        get_activity_check_type_close_time_list,
%%        get_activity_activity_server_type,
        get_seven_login_laba_weight_list,                       %% 获得七天登陸拉霸權重列表
        get_function_monster_fanpai_weights_list,               %% 获得功能怪翻牌权重列表
        get_function_monster_laba_weights_list,                 %% 获得功能怪拉霸权重列表
        get_function_monster_zhuanpan_weights_list,             %% 获得功能怪转盘权重列表
        get_function_monster_task_reward_weights_list,          %% 获得功能怪任务奖励权重列表
        get_seize_treasure_list_by_type_id,                     %% 通过treasure_hunt_type表的id（关联到treasure_hunt表的type_id字段）
        %% 读取treasure_hunt表的指定记录们
        get_seize_treasure_achievement_list_by_pos,             %% 通过下标，获取treasure_hunt_type表的achievement_list里的值
        get_seize_treasure_id_by_award_list,
        get_seize_treasure_cost_list_by_pos,                    %% 通过下标，获取treasure_hunt_type表的cost_list里的值

        get_card_summon_list_by_type,                           %% 根据类型获得抽奖卡池列表
        get_can_bet_mission_id,                                 %% 获取允许投注的mission id
        get_card_summon_list_by_type,                           %% 根据类型获得抽奖卡池列表
        get_shenlongzhufu_weights_list,                         %% 获得神龙权重列表
        get_ge_xing_hua_init_award_list,                        %% 获得个性化初始奖励列表

        get_scene_robot_id_weight_list,                         %% 获得场景机器人id权重列表
        get_tongxingzheng_month_tasks_by_type_and_day,          %% 根据 月度任务类型 和 解锁天数 获取月度任务
        get_condition_txz_daily_task_list,
        get_condition_txz_task_list,
        get_activity_id_all_list,
        get_activity_id_list_by_type,
        get_invest_task_id_list_by_type,                        %% 获得 投资计划任务id列表 根据类型
        get_invest_task_type_list,                              %% 获得 投资计划任务类型列表

        get_function_monster_blind_box_weights_list,            %% 获取 箱子权重列表
        get_function_monster_effect_by_type,                    %% 通过type获取功能怪信息
        get_condition_monster_function_task_list,               %% 根据任务条件获取相关任务列表
        get_scene_robot_weights_list,                           %% 获得场景机器人权重列表
        get_card_title_list_by_card_id,                         %% 获得图鉴目录列表 根据 图鉴卡牌id

        get_condition_bounty_task_list,                         %% 根据任务条件获取赏金任务列表
        get_region_by_currency,                                 %% 通过货币缩写获取国家地区名称
        get_big_wheel_icon_weight_list,                         %% 获得无尽对决权重列表
        get_big_wheel_bet_list,
        get_bettle_skill_data,
        get_wheel_type_or_unique_id_list
    ].

%% ----------------------------------
%% @doc 	整合技能结算列表
%% @throws 	none
%% @end
%% ----------------------------------
merge_skill_balance_list() ->
    L = ets:tab2list(t_active_skill),
    lists:sort(lists:foldl(
        fun(E, Tmp) ->
            #t_active_skill{
                id = SkillId,
                balance_list = BalanceList
            } = E,
            L2 = lists:reverse(lists:foldl(
                fun({N, GridId, Delay, Rate}, TmpList) ->
                    if TmpList == [] ->
                        [{1, Rate, Delay, [{N, GridId, Delay, Rate}]}];
                        true ->
                            O = hd(TmpList),
                            {BalanceId, SumRate, SumDelay, LL} = O,
                            MergeTime =
                                if SkillId == 2 ->
                                    500;
                                    true ->
                                        1000
                                end,
                            if SumDelay + Delay > MergeTime ->
                                [{BalanceId + 1, Rate, Delay, [{N, GridId, Delay, Rate}]} | TmpList];
                                true ->
                                    [{BalanceId, SumRate + Rate, SumDelay + Delay, lists:sort([{N, GridId, SumDelay + Delay, Rate} | LL])} | lists:delete(O, TmpList)]
                            end
                    end
                end,
                [],
                BalanceList
            )),
            [{SkillId, L2} | Tmp]
        end,
        [],
        L
    )).

is_prop_exists(PropId) ->
    t_item:get({PropId}) =/= null.

%% @fun 检查模板表数据
check_table() ->
    io:format("~n\tcheck_table ---"),
    check_all_award(),
%%    case ?IS_DEBUG of
%%        true ->
%%            check_recharge();
%%        _ ->
%%            noop
%%    end,
    check_shop(),
    check_all_activity(),
    check_monster(),
    check_monster_award(),
%%    check_scene_config_pos(),

    check_robot(),
    ok.

%% ----------------------------------
%% @doc 	检查奖励组
%% @throws 	none
%% @end
%% ----------------------------------
check_all_award() ->
    io:format("~nCheck award ............................................. "),
    L = logic_get_all_award_id:get(0),
    lists:foreach(
        fun(Id) ->
            #t_reward{
                random_reward_list = RandomAwardList,
                weights_reward_list = WeightAwardList
            } = t_reward:get({Id}),
            lists:foreach(
                fun(R) ->
                    case R of
                        [PropId, _Num, _P] ->
                            case is_prop_exists(PropId) of
                                true ->
                                    noop;
                                false ->
                                    io:format("~n[ERROR] award no exists!!! ~naward_id:~p, prop_id:~p~n", [Id, PropId]),
                                    halt(1)
                            end;
                        _ ->
                            io:format("~n[ERROR] award error: ~p~n", [R]),
                            halt(1)
                    end
                end,
                RandomAwardList
            ),
            if WeightAwardList == [] ->
                [];
                true ->
                    [[_P1], [_Min, _Max], _IsUnique, List] = WeightAwardList,
                    lists:foreach(
                        fun([PropId, _Num, _]) ->
                            case is_prop_exists(PropId) of
                                true ->
                                    noop;
                                false ->
                                    io:format("~n[ERROR] award no exists!!!~naward_id:~p, prop_id:~p~n", [Id, PropId]),
                                    halt(1)
                            end
                        end,
                        List
                    )
            end
        end,
        L
    ),
    io:format("[ok]~n").

check_monster() ->
    io:format("Check monster ......................................... "),
    List = ets:tab2list(t_scene),
    lists:foreach(
        fun(T_Scene) ->
            #t_scene{
                id = SceneId,
                monster_born_list = MonsterBornList,
                function_monster_list = FunctionMonsterList,
                boss_time_monster_born_list = BossMonsterBornList
            } = T_Scene,
            lists:foreach(
                fun([_, MonsterList, _]) ->
                    lists:foreach(
                        fun(MonsterId) ->
                            case t_monster:get({MonsterId}) of
                                Table when is_record(Table, t_monster) ->
                                    ok;
                                _ ->
                                    io:format("scene_id :~p, function_monster_list monster no exists:~p", [SceneId, MonsterId]),
                                    halt(1)
                            end
                        end,
                        MonsterList
                    )
                end,
                FunctionMonsterList
            ),
            lists:foreach(
                fun([Mid, _, _, _]) ->
                    case t_monster:get({Mid}) of
                        Table when is_record(Table, t_monster) ->
                            ok;
                        _ ->
                            io:format("scene_id :~p, monster_born_list monster no exists:~p", [SceneId, Mid]),
                            halt(1)
                    end
                end,
                MonsterBornList
            ),
            lists:foreach(
                fun([Mid, _, _, _]) ->
                    case t_monster:get({Mid}) of
                        Table when is_record(Table, t_monster) ->
                            ok;
                        _ ->
                            io:format("scene_id :~p, boss_time_monster_born_list monster no exists:~p", [SceneId, Mid]),
                            halt(1)
                    end
                end,
                lists:foldl(
                    fun([_BossId, BossMonsterBorns], TmpL) ->
                        BossMonsterBorns ++ TmpL
                    end,
                    [], BossMonsterBornList
                )
            )
        end, List),
    io:format("[ok]~n").

%% @doc 检查怪物表奖励
check_monster_award() ->
    io:format("Check monster award ......................................... "),
    List = ets:tab2list(t_monster),
    lists:foreach(
        fun(Table) ->
            #t_monster{
                id = Id,
%%                new_reward_1 = NewReward1,
                new_reward_2 = NewReward2
            } = Table,
%%            case t_reward:get({NewReward1}) of
%%                null when NewReward1 > 0 ->
%%                    io:format("monster new_reward_1 in t_reward no exists: (monster:~p),(reward:~p)", [Id, NewReward1]),
%%                    halt(1);
%%                _ ->
%%                    noop
%%            end,
            case t_reward:get({NewReward2}) of
                null when NewReward2 > 0 ->
                    io:format("monster new_reward_2 in t_reward no exists: (monster:~p),(reward:~p)", [Id, NewReward2]),
                    halt(1);
                _ ->
                    noop
            end,
            ok
        end, List),
    io:format("[ok]~n").

check_robot() ->
    io:format("Check robot config ......................................... "),
    List = ets:tab2list(t_robot),
    lists:foreach(
        fun(Table) ->
            #t_robot{
                id = Id,
                scene = SceneId,
                cost_list = CostList
            } = Table,
            #t_scene{
                mana_attack_list = [_, SceneCostList]
            } = t_scene:assert_get({SceneId}),
            lists:foreach(
                fun([_, Cost, _]) ->
                    case lists:member(Cost, SceneCostList) of
                        true ->
                            noop;
                        false ->
                            io:format("robot config cost_list error . error arg : (robot_id:~p),(cost:~p),(scene:~p)", [Id, Cost, SceneId]),
                            halt(1)
                    end
                end,
                CostList
            )
        end, List),
    io:format("[ok]~n").

%% @fun 查检商店表数据
check_shop() ->
    io:format("Check shop_type ......................................... "),
    List = ets:tab2list(t_shop),
    lists:foreach(
        fun(#t_shop{id = Id, type = ShopType}) ->
            case t_shop_type:get({ShopType}) of
                Table when is_record(Table, t_shop_type) ->
                    ok;
                _ ->
                    io:format("~n[ERROR]shop id:~p;商店类型表t_shop_type缺少:~p~n", [Id, ShopType]),
                    halt(1)
            end
        end, List),
    io:format("[ok]~n").

%%%% @fun 查检充值表数据
%%check_recharge() ->
%%    io:format("Check recharge .......................................... "),
%%%%    lists:foreach(
%%%%        fun(#t_recharge{id = Id, cash = Money}) ->
%%%%
%%%%        end, ets:tab2list(t_recharge)),
%%    io:format("[ok]~n").

%% @fun 查检活动表数据
check_all_activity() ->
    qmake:compilep("../src/server/mod_server_config.erl", ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    qmake:compilep("../src/activity/activity_time_parse.erl", ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    L = ets:tab2list(t_activity_info),
    lists:foreach(
        fun(E) ->
            #t_activity_info{
                id = ActivityId
            } = E,
            activity_time_parse:parse_activity_time(ActivityId, util_time:timestamp()),
            activity_time_parse:is_server_limit(ActivityId)
        end,
        L
    ).
%%check_activity_info() ->
%%    io:format("Check activity_info ..................................... "),
%%    lists:foreach(
%%        fun(#t_activity_info{id = ActivityId, server_type = ServerType, time_type = TimeType, start_time_list = StartTimeList, end_time = EndTime, open_server = OpenStartServerDay, open_server_end = OpenEndServerDay}) ->
%%            #t_activity_time_type{
%%                unit_time_type = UnitTimeType
%%            } = t_activity_time_type:get({TimeType}),
%%            if
%%                TimeType == ?ACT_T_PLAYER_RETURN_GAME_MULTI_DAY andalso ServerType =/= 1 ->
%%                    io:format("~n[ERROR]\tid: ~p 玩家回归只能在游戏服{TimeType,ServerType}~p~n", [ActivityId, {TimeType, ServerType}]),
%%                    halt(1);
%%                true ->
%%                    noop
%%            end,
%%            case TimeType of
%%                3 ->
%%                    case StartTimeList of
%%                        [[_, _, _], [_, _, _]] ->
%%                            noop;
%%                        _ ->
%%                            io:format("~n[ERROR]\tid:~p TimeType:~p:时间格式错误~p~n", [ActivityId, TimeType, StartTimeList]),
%%                            halt(1)
%%                    end;
%%                _ ->
%%                    case StartTimeList of
%%                        [_, _, _] ->
%%                            noop;
%%                        [] ->
%%                            noop;
%%                        _ ->
%%                            io:format("~n[ERROR]\tid:~p TimeType:~p:时间格式错误~p~n", [ActivityId, TimeType, StartTimeList]),
%%                            halt(1)
%%                    end
%%            end,
%%            if
%%                state == 0 orelse TimeType == 1 andalso OpenStartServerDay == 0 andalso OpenEndServerDay == 0 orelse UnitTimeType == 2 andalso EndTime < 30 orelse UnitTimeType == 1 andalso EndTime >= 60 ->
%%                    noop;
%%                true ->
%%                    io:format("~n[ERROR]\tid: ~p end_time结束时间不是范围内(天小于30，秒大于60)~n", [ActivityId]),
%%                    halt(1)
%%            end
%%        end, ets:tab2list(t_activity_info)),
%%    io:format("[ok]~n").

%%get_xiu_xian_need_num() ->
%%    List = ets:tab2list(t_xiu_xian_reward),
%%    lists:foldl(
%%        fun(R, Tmp) ->
%%            #t_xiu_xian_reward{
%%                id = Id
%%            } = R,
%%            Num =
%%                lists:foldl(
%%                    fun(R1, Tmp1) ->
%%                        if R1#t_xiu_xian_reward.id =< Id ->
%%                            Tmp1 + R1#t_xiu_xian_reward.kill_num;
%%                            true ->
%%                                Tmp1
%%                        end
%%                    end,
%%                    0,
%%                    List
%%                ),
%%            [{Id, Num} | Tmp]
%%        end,
%%        [],
%%        lists:sort(List)
%%    ).

%% @doc 检查场景配置位置是否有错误
check_scene_config_pos() ->
    if
        ?IS_DEBUG ->
            io:format("Check scene_config_pos ......................................... "),
            mod_map:init_all(),
            List = [t_scene:get({SceneId}) || {SceneId} <- t_scene:get_keys()],
            lists:foreach(
                fun(Table) ->
                    #t_scene{
                        id = SceneId,
                        boss_x_y_list = BossXYList,
                        random_birth_list = RandomBirthList,
                        gold_monster_move_list = GoldMonsterMoveList,
                        new_monster_x_y_list = NewMonsterXYList,

                        monster_count = MonsterCount,
                        boss_time_monster_born_list = BossTimeMonsterBornList,
                        boss_time_monster_count = BossTimeMonsterCount,
                        map_id = MapId,
                        is_hook = IsHook,
                        type = SceneType,
                        is_valid = IsValid
                    } = Table,
                    if
                        IsHook == ?TRUE andalso IsValid == ?TRUE andalso SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                            lists:foreach(
                                fun(BossXYList1) ->
                                    lists:foreach(
                                        fun([BossX, BossY]) ->
                                            case mod_map:can_walk_pix(MapId, BossX, BossY) of
                                                true ->
                                                    noop;
                                                false ->
                                                    io:format("[SCENE_ERROR] boss_x_y_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, BossX, BossY]),
                                                    halt(1)
                                            end
                                        end,
                                        BossXYList1
                                    )
                                end,
                                BossXYList
                            ),
                            lists:foreach(
                                fun({MonsterX, MonsterY}) ->
                                    case mod_map:can_walk_pix(MapId, MonsterX, MonsterY) of
                                        true ->
                                            noop;
                                        false ->
                                            io:format("[SCENE_ERROR] random_birth_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, MonsterX, MonsterY]),
                                            halt(1)
                                    end
                                end, RandomBirthList
                            ),
                            lists:foreach(
                                fun(GoldMonsterMoveList1) ->
                                    lists:foreach(
                                        fun([BossX, BossY]) ->
                                            case mod_map:can_walk_pix(MapId, BossX, BossY) of
                                                true ->
                                                    noop;
                                                false ->
                                                    io:format("[SCENE_ERROR] gold_monster_move_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, BossX, BossY]),
                                                    halt(1)
                                            end
                                        end,
                                        GoldMonsterMoveList1
                                    )
                                end,
                                GoldMonsterMoveList
                            ),
                            {MonsterCountMin, MonsterCountMax} =
                                lists:foldl(
                                    fun([_, Min, Max, GoldMonsterMoveList1], {TmpMin, TmpMax}) ->
                                        lists:foreach(

                                            fun([X, Y]) ->
                                                case mod_map:can_walk_pix(MapId, X, Y) of
                                                    true ->
                                                        noop;
                                                    false ->

                                                        io:format("[SCENE_ERROR] new_monster_x_y_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, X, Y]),
                                                        halt(1)
                                                end
                                            end,
                                            GoldMonsterMoveList1

                                        ),
                                        {TmpMin + Min, TmpMax + Max}
                                    end,

                                    {0, 0}, NewMonsterXYList
                                ),
                            if
                                MonsterCount < MonsterCountMin ->
                                    io:format("[SCENE_ERROR] monster_count < new_monster_x_y_list min_total_num,scene_id:~p, monster_count: ~p, monster_count_min: ~p ~n", [SceneId, MonsterCount, MonsterCountMin]),
                                    halt(1);
                                MonsterCount > MonsterCountMax ->
                                    io:format("[SCENE_ERROR] monster_count > new_monster_x_y_list max_total_num,scene_id:~p, monster_count: ~p, monster_count_max: ~p ~n", [SceneId, MonsterCount, MonsterCountMax]),
                                    halt(1);
                                true ->
                                    noop
                            end,
                            {BossTimeMonsterCountMin, BossTimeMonsterCountMax} =
                                lists:foldl(
                                    fun([_BossId, BossTimeMonsterBornList1], {TmpMin1, TmpMax1}) ->
                                        {BossTimeMonsterCountMin1, BossTimeMonsterCountMax1} =
                                            lists:foldl(
                                                fun([_, _, Min, Max], {TmpMin, TmpMax}) ->
                                                    {TmpMin + Min, TmpMax + Max}
                                                end,
                                                {0, 0}, BossTimeMonsterBornList1
                                            ),
                                        {min(BossTimeMonsterCountMin1, TmpMin1), max(TmpMax1, BossTimeMonsterCountMax1)}
                                    end,
                                    {0, 0}, BossTimeMonsterBornList
                                ),

                            if
                                BossTimeMonsterCount < BossTimeMonsterCountMin ->
                                    io:format("[SCENE_ERROR] boss_time_monster_count < boss_time_monster_born_list min_total_num,scene_id:~p, boss_time_monster_count: ~p, boss_time_monster_count_min: ~p ~n", [SceneId, BossTimeMonsterCount, BossTimeMonsterCountMin]),
                                    halt(1);
                                BossTimeMonsterCount > BossTimeMonsterCountMax ->
                                    io:format("[SCENE_ERROR] boss_time_monster_count > boss_time_monster_born_list max_total_num,scene_id:~p, boss_time_monster_count: ~p, boss_time_monster_count_max: ~p ~n", [SceneId, BossTimeMonsterCount, BossTimeMonsterCountMax]),
                                    halt(1);
                                true ->
                                    noop
                            end;
                        true ->
                            noop
                    end
                end, List),
            io:format("[ok]~n");
        true ->
            noop
    end.

get_all_award_id() ->
    List = ets:tab2list(t_reward),
    IdList = lists:sort([E#t_reward.id || E <- List]),
    [{0, IdList}].

get_all_scene_id() ->
    List = ets:tab2list(t_scene),
    IdList = [Scene#t_scene.id || Scene <- List, Scene#t_scene.is_valid =/= 0],
    [{0, IdList}].

get_all_world_scene_id() ->
    List = ets:tab2list(t_scene),
    IdList = [Scene#t_scene.id || Scene <- List, Scene#t_scene.is_valid =/= 0, Scene#t_scene.type == 1],
    [{0, IdList}].

get_all_hook_scene_id() ->
    List = ets:tab2list(t_scene),
    IdList = [Scene#t_scene.id || Scene <- List, Scene#t_scene.is_valid =/= 0, Scene#t_scene.is_hook == 1],
    [{0, IdList}].

get_all_world_hook_scene_id() ->
    List = ets:tab2list(t_scene),
    IdList = [Scene#t_scene.id || Scene <- List, Scene#t_scene.is_valid =/= 0, Scene#t_scene.is_hook == 1, Scene#t_scene.type == 1],
    [{0, IdList}].

get_all_world_scene_id_by_server_type() ->
    List = ets:tab2list(t_scene),
    lists:foldl(
        fun(Element, TempList) ->
            if Element#t_scene.is_valid =/= 0 andalso Element#t_scene.type == 1 ->
                util_list:key_insert({Element#t_scene.server_type, Element#t_scene.id}, TempList);
                true ->
                    TempList
            end
        end,
        [],
        List
    ).

get_all_mission_id_by_mission_type() ->
    L = ets:tab2list(t_mission),
    MissTypeList =
        lists:foldl(
            fun(Element, TempList) ->
                util_list:key_insert({Element#t_mission.mission_type, Element#t_mission.id}, TempList)
            end,
            [],
            L
        ),
    %% @fun 用于取第一个到最后一个的副本数据
    [{MissionType, lists:sort(MissionList)} || {MissionType, MissionList} <- MissTypeList].

get_max_mission_id_by_mission_type() ->
    L = ets:tab2list(t_mission),
    lists:foldl(
        fun(Element, TempList) ->
            case lists:keytake(Element#t_mission.mission_type, 1, TempList) of
                {value, {_, Max}, Left} ->
                    if Element#t_mission.id > Max ->
                        [{Element#t_mission.mission_type, Element#t_mission.id} | Left];
                        true ->
                            TempList
                    end;
                _ ->
                    [{Element#t_mission.mission_type, Element#t_mission.id} | TempList]
            end
        end,
        [],
        L
    ).

get_all_mission() ->
    L = ets:tab2list(t_mission),
    [{0, [{E#t_mission.mission_type, E#t_mission.id} || E <- L]}].

%% ----------------------------------
%% @doc 	获取副本怪物总数
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_total_monster_num() ->
    L = logic_get_all_mission:get(0),
    lists:foldl(
        fun({MissionType, MissionId}, TempList) ->
            #t_mission{
                scene_id = SceneId
            } = t_mission:assert_get({MissionType, MissionId}),
            #t_mission_type{
                is_notice_round = NoticeRoundType
            } = t_mission_type:assert_get({MissionType}),
            if NoticeRoundType == 2 ->
                [{{MissionType, MissionId}, get_round_monster_total_num(SceneId, MissionId)} | TempList];
                true ->
                    TempList
            end
        end,
        [],
        L
    ).

get_round_monster_total_num(SceneId, MissionId) ->
    get_round_monster_total_num(SceneId, MissionId, 1, 0).
get_round_monster_total_num(SceneId, MissionId, Round, Total) ->
    case scene_data:get_scene_monster_list_by_round({SceneId, MissionId, Round}) of
        [] ->
            Total;
        List ->
            get_round_monster_total_num(SceneId, MissionId, Round + 1, Total + length(List))
    end.

get_scene_id_list_by_map_id() ->
    L = ets:tab2list(t_scene),
    lists:foldl(
        fun(Element, TempList) ->
%%            if Element#t_scene.id < 9999 ->
            util_list:key_insert({Element#t_scene.map_id, Element#t_scene.id}, TempList)
%%                true ->
%%                    TempList
%%            end
        end,
        [],
        L
    ).

%%get_scene_monster_pos_info() ->
%%    L = ets:tab2list(t_scene),
%%    lists:foldl(
%%        fun(Element, TempList) ->
%%            #t_scene{
%%                type = SceneType,
%%                monster_list = MonsterList,
%%                id = SceneId
%%            } = Element,
%%            if SceneType == 1 orelse SceneType == 3 ->
%%                lists:foldl(
%%                    fun(MonsterInfo, TempList_1) ->
%%                        MonsterId = util_list:opt(monster_id, MonsterInfo),
%%                        MonsterX = util_list:opt(x, MonsterInfo),
%%                        MonsterY = util_list:opt(y, MonsterInfo),
%%                        util_list:key_insert({{SceneId, MonsterId}, {MonsterX, MonsterY}}, TempList_1)
%%                    end,
%%                    TempList,
%%                    MonsterList
%%                );
%%                true ->
%%                    TempList
%%            end
%%        end,
%%        [],
%%        L
%%    ).

get_platform_id_by_channel() ->
    L = ets:tab2list(t_channel),
%%    io:format("~p~n",[L2]),
    lists:foldl(
        fun(C, Tmp) ->
            #t_channel{
                channel = Channel,
                platform_id = PlatformId
            } = C,
            case lists:keyfind(Channel, 1, Tmp) of
                false ->
                    [{Channel, PlatformId} | Tmp];
                _ ->
                    exit(channel_repeated)
            end
        end,
        [],
        L
    ).
%%get_scene_monster_seq_info() ->
%%    L = lists:sort(ets:tab2list(t_task)),
%%    L1 = lists:foldl(
%%        fun(Element, TempList) ->
%%            #t_task{
%%                content_list = ContentList
%%            } = Element,
%%            case ContentList of
%%                [kill, SceneId, MonsterId, Num] ->
%%                    util_list:key_insert({SceneId, {kill, MonsterId, Num}}, TempList);
%%                [collect, SceneId, CollectId, Num] ->
%%                    util_list:key_insert({SceneId, {collect, CollectId, Num}}, TempList);
%%                [dialog, SceneId, NpcId, _] ->
%%                    util_list:key_insert({SceneId, {dialog, NpcId}}, TempList);
%%                _ ->
%%                    TempList
%%            end
%%        end,
%%        [],
%%        L
%%    ),
%%    [{Key, lists:reverse(LL)} || {Key, LL} <- L1].

get_skill_shift_info() ->
%%    ActiveSkillLevelMapList = ets:tab2list(t_active_skill_level_map),
    SkillList = ets:tab2list(t_skill),
    SkillAssemblyList = ets:tab2list(t_skill_assembly),
    lists:foldl(
        fun(Skill, Tmp) ->
%%            #t_active_skill_level_map{
%%                skill_res = SkillRes
%%            } = ActiveSkillLevelMap,
%%            IntSkillRes = util:to_int(SkillRes),
            #t_skill{
                shootid = ShootId
            } = Skill,
            [{ShootId,
                lists:foldl(
                    fun(SkillAssembly, Tmp1) ->
                        #t_skill_assembly{
                            id = Id,
                            startshowtime = StartShowTime,
                            playermove = PlayerMove
                        } = SkillAssembly,
                        if Id == ShootId andalso PlayerMove =/= "-1" ->
                            [A, B0] = string:split(PlayerMove, "|"),
                            [B, C] = string:split(B0, "|"),
%%                            io:format("~p~n", [string:split(B, "|")]),
                            [{StartShowTime, util:to_int(A), util:to_int(B), util:to_int(C)} | Tmp1];
                            true ->
                                Tmp1
                        end
                    end,
                    [],
                    SkillAssemblyList
                )} | Tmp]
        end,
        [],
        SkillList
    ).
%%is_task_no_check() ->
%%    L = lists:sort(ets:tab2list(t_task)),
%%    lists:foldl(
%%        fun(Element, TempList) ->
%%            #t_task{
%%                id = TaskId,
%%                content_list = ContentList
%%            } = Element,
%%            case ContentList of
%%                [dialog, _SceneId, _NpcId, _DialogId] ->
%%                    [{TaskId, true} | TempList];
%%                _ ->
%%                    TempList
%%            end
%%        end,
%%        [],
%%        L
%%    ).

%% ----------------------------------
%% @doc 	通过激活条件获取技能槽id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_skill_slot_id_list_by_condition() ->
    FunctionList = ets:tab2list(t_skill_slot),
    List = lists:foldl(
        fun(SkillSlot, TempList) ->
            lists:foldl(
                fun(Condition, TempList_2) ->
                    util_list:key_insert({Condition, SkillSlot#t_skill_slot.id}, TempList_2)
                end,
                TempList,
                [SkillSlot#t_skill_slot.open_list]
            )
        end,
        [],
        FunctionList
    ),
    [{Key, lists:sort(L)} || {Key, L} <- List].


%% @fun 获取功能对应模块
get_function_id_module() ->
    FunctionList = ets:tab2list(t_function),
    lists:sort([{Function#t_function.id, {ok, Function#t_function.module_tuple}} || Function <- FunctionList, Function#t_function.module_tuple =/= {}]).

%% @fun 获取功能id列表
get_function_id_list() ->
    FunctionList = ets:tab2list(t_function),
    [{0, lists:sort([Function#t_function.id || Function <- FunctionList, Function#t_function.activate_condition_list =/= []])}].

get_sort_node_list() ->
%%    MapIdList = [1008],
    MapIdList = mod_map:get_all_map_id(),
    Out = lists:foldl(
        fun(MapId, Tmp) ->
%%            ?DEBUG("create_scene_path:~p~n", [SceneId]),
            mod_map:unload(),
            mod_map:load(MapId),
            create_sort_node_list(MapId) ++ Tmp
        end,
        [],
        MapIdList
    ),
%%    io:format("Out:~p~n", [Out]),
    Out.
create_sort_node_list(MapId) ->
    EtsTableName = ?MAP_MART_TABLE(MapId),
    lists:foldl(
        fun(Grid, Tmp) ->
            #map{
                id = {X, Y}
%%                obstacle = Obstacle
            } = Grid,
%%            {X, Y} = {90,27},
            case mod_map:can_walk({MapId, {X, Y}}) of
                true ->
                    L =
                        lists:foldl(
                            fun({X1, Y1}, Tmp1) ->
                                case mod_map:can_walk({MapId, {X1, Y1}}) of
                                    true ->
                                        [{X1, Y1, false} | Tmp1];
                                    false ->
                                        Tmp1
                                end
                            end,
                            [],
                            [
                                {X - 1, Y - 1},
                                {X - 1, Y},
                                {X - 1, Y + 1},
                                {X, Y - 1},
                                {X, Y + 1},
                                {X + 1, Y - 1},
                                {X + 1, Y + 1},
                                {X + 1, Y}
                            ]
                        ),
                    [{{MapId, {X, Y}}, L} | Tmp];
                false ->
                    Tmp
            end
        end,
        [],
        ets:tab2list(EtsTableName)
    ).

get_map_node_path() ->
    MapIdList = lists:usort(logic_get_all_map_id:get(0)),
    Ref = erlang:make_ref(),
    wait_get_map_node_path(MapIdList, 0, Ref, []).

wait_get_map_node_path([], 0, _Ref, Result) ->
    Result;
wait_get_map_node_path([], WaitNum, Ref, Result) ->
    {NewResult, NewWaitNum} = do_waiting(WaitNum, Ref, Result),
    wait_get_map_node_path([], NewWaitNum, Ref, NewResult);
wait_get_map_node_path([MapId | Left], WaitNum, Ref, Result) ->
%%    #t_scene{
%%        map_id = MapId
%%    } = db_t_scene:get({SceneId}),
    if WaitNum < 6 ->
        Self = self(),
        spawn_link(fun() -> create_scene_path(MapId, Self, Ref) end),
        wait_get_map_node_path(Left, WaitNum + 1, Ref, Result);
        true ->
            {NewResult, NewWaitNum} = do_waiting(WaitNum, Ref, Result),
            wait_get_map_node_path([MapId | Left], NewWaitNum, Ref, NewResult)
    end.

do_waiting(WaitNum, Ref, Result) ->
    receive
        {ok, Out, Ref} ->
            {[Out | Result], WaitNum - 1};
        {'EXIT', _P, normal} ->
            {Result, WaitNum};
        Other ->
            exit(Other)
    end.

create_scene_path(MapId, Parent, Ref) ->

    Result = lists:usort(do_create_scene_path(MapId)),
    Parent ! {ok, {MapId, Result}, Ref}.

get_point_list(MapId) ->
    SceneIdList = case logic_get_scene_id_list_by_map_id:get(MapId) of
                      null ->
                          [];
                      L ->
                          L
                  end,
    lists:foldl(
        fun(SceneId, {SceneDoorPosList, BirthPosList, MonsterPosList, NpcPosList}) ->
            #t_scene{
                map_id = MapId,
%%                birth_pos_list = BirthPosList_,
%%                npc_list = NpcList,
                birth_x = BirthX,
                birth_y = BirthY,
                random_birth_list = RandomBirthList
            } = t_scene:get({SceneId}),
            BirthPosList_ =
                if RandomBirthList == [] -> [{BirthX, BirthY}];
                    true -> RandomBirthList
                end,
%%            BirthPosList_ = [{BirthX, BirthY}],
            NpcPosList_ = [],
%%            NpcPosList_ = lists:foldl(
%%                fun(NpcInfo, Tmp) ->
%%                    X = util_list:opt(x, NpcInfo),
%%                    Y = util_list:opt(y, NpcInfo),
%%                    ?ASSERT(is_integer(X) andalso is_integer(Y)),
%%                    [{X, Y} | Tmp]
%%                end,
%%                [],
%%                NpcList
%%            ),
            SceneDoorPosList_ = [],
%%                case logic_get_scene_door_list:get(SceneId) of
%%                    null ->
%%                        [];
%%                    SceneDoorList ->
%%
%%                        lists:foldl(
%%                            fun(SceneDoor, Tmp) ->
%%                                #t_scene_door{
%%                                    x = X,
%%                                    y = Y
%%                                } = SceneDoor,
%%                                [{X, Y} | Tmp]
%%                            end,
%%                            [],
%%                            SceneDoorList
%%                        )
%%
%%                end,
            {
                    SceneDoorPosList_ ++ SceneDoorPosList,
                    BirthPosList_ ++ BirthPosList,
                MonsterPosList,
                    NpcPosList_ ++ NpcPosList
            }
        end,
        {[], [], [], []},
        SceneIdList
    ).

do_create_scene_path(MapId) ->
    ConfigList = case MapId of
                     _ ->
                         []
                 end,

    {SceneDoorPosList, BirthPosList, MonsterPosList, NpcPosList} = get_point_list(MapId),
    PosList = lists:usort(SceneDoorPosList ++ BirthPosList ++ MonsterPosList ++ NpcPosList ++ ConfigList),
    if PosList =/= [] ->
        mod_map:load_jump_data(MapId),
        SceneIdList = case logic_get_scene_id_list_by_map_id:get(MapId) of
                          null ->
                              [];
                          L ->
                              L
                      end,
        lists:foreach(
            fun(SceneId) ->
                SceneMonsterIdList = scene_data:get_scene_monster_id_list(SceneId),
                lists:foreach(
                    fun(SceneMonsterId) ->
                        #r_scene_monster{
                            monster_id = MonsterId,
                            x = X,
                            y = Y
                        } = scene_data:get_scene_monster({SceneId, SceneMonsterId}),
                        case mod_map:can_walk_pix(MapId, X, Y) of
                            true ->
                                noop;
                            false ->
                                io:format("monster rebirth no walk:~p~n", [{{scene_id, SceneId}, {monster_id, MonsterId}, {x, X}, {y, Y}}]),
                                halt(1)
                        end
                    end,
                    SceneMonsterIdList
                )
            end,
            SceneIdList
        ),
        PathList = do_create_path(MapId, PosList, []),
        lists:foldl(
            fun(Path, Tmp) ->
%%                arrange(MapId, Path, MonsterPosList ++ NpcPosList) ++ Tmp
                arrange(MapId, Path, []) ++ Tmp
            end,
            [],
            PathList
        );
        true ->
            []
    end.

arrange(MapId, PathList, RemoveList) ->
    arrange(MapId, PathList, RemoveList, []).
arrange(_MapId, [], _RemoveList, R) ->
    R;
arrange(_MapId, [{_X, _Y}], _RemoveList, R) ->
    R;
arrange(MapId, [{X0, Y0}, {X1, Y1} | Left], RemoveList, R) ->
    Dis = util_math:get_distance({X0, Y0}, {X1, Y1}),
    if Dis > 10 ->
%%        case navigate:check_line(MapId, {X0, Y0}, {X1, Y1}) of
%%            true ->
%%                noop;
%%            false ->
%%                ?DEBUG("~p~n", [{MapId, {X0, Y0}, {X1, Y1}}])
%%        end,
        IsRemove = lists:member({X0, Y0}, RemoveList) orelse lists:member({X1, Y1}, RemoveList),
        if IsRemove ->
            arrange(MapId, Left, RemoveList, R);
            true ->
                arrange(MapId, Left, RemoveList, [{X0, Y0, X1, Y1} | R])
        end;
        true ->
            arrange(MapId, Left, RemoveList, R)
    end.

do_create_path(MapId, [S | L], R) ->
    do_create_path(MapId, L, R ++ do_create_path_1(MapId, S, L));
%%do_create_path(_MapId, [_L], R) ->
%%    R;
do_create_path(_MapId, [], R) ->
    R.

do_create_path_1(MapId, {FX, FY}, L) ->
    case mod_map:can_walk(?PIX_2_MASK_ID(MapId, FX, FY)) of
        true ->
            lists:foldl(
                fun({TX, TY}, Tmp) ->
                    case mod_map:can_walk(?PIX_2_MASK_ID(MapId, TX, TY)) of
                        true ->
                            L0 = case navigate:start_2(MapId, {FX, FY}, {TX, TY}, true, true, 30000) of
                                     {success, _Path_0} ->
                                         _Path_0;
                                     Other_0 ->
                                         io:format("LINE:~p Error:~p~n", [?LINE, {MapId, {FX, FY}, {TX, TY}, Other_0}]),
                                         []
                                 end,
                            L1 = case
                                     navigate:start_2(MapId, {TX, TY}, {FX, FY}, true, true, 30000) of
                                     {success, _Path_1} ->
                                         _Path_1;
                                     Other_1 ->
                                         io:format("LINE:~p Error:~p~n", [?LINE, {MapId, {TX, TY}, {FX, FY}, Other_1}]),
                                         []
                                 end,
                            Path0 = [?PIX_2_TILE(FX, FY)] ++ [?PIX_2_TILE(X0, Y0) || {X0, Y0} <- L0],
                            Path1 = [?PIX_2_TILE(TX, TY)] ++ [?PIX_2_TILE(X0, Y0) || {X0, Y0} <- L1],
                            [
                                Path0,
                                Path1
                                |
                                Tmp
                            ];
                        false ->
                            io:format("~n LINE:~p not_can_walk_1:~p~n", [?LINE, {MapId, ?PIX_2_TILE(TX, TY), {TX, TY}}]),
                            halt(1),
                            Tmp
                    end
%%            ?ASSERT(mod_map:can_walk(?PIX_2_MASK_ID(MapId, TX, TY)), {not_can_walk1, MapId, TX, TY}),
%%            #t_scene_door{
%%                x = TX,
%%                y = TY
%%            } = B,
%%            ?DEBUG("~p~n", [{?PIX_2_TILE(FX, FY), ?PIX_2_TILE(TX, TY)}]),

                end,
                [],
                L
            );
        false ->
            io:format("~n LINE:~p not_can_walk:~p~n", [?LINE, {MapId, ?PIX_2_TILE(FX, FY), {FX, FY}}]),
            halt(1),
            []
    end.

get_all_map_id() ->
    List = ets:tab2list(t_scene),
    MapIdList = [Scene#t_scene.map_id || Scene <- List, Scene#t_scene.is_valid > 0],
    [{0, lists:usort(MapIdList)}].

get_all_common_map_id() ->
    List = ets:tab2list(t_scene),
    MapIdList = [Scene#t_scene.map_id || Scene <- List, Scene#t_scene.is_valid > 0, Scene#t_scene.server_type == 1],
    [{0, lists:usort(MapIdList)}].

get_all_cross_map_id() ->
    List = ets:tab2list(t_scene),
    MapIdList = [Scene#t_scene.map_id || Scene <- List, Scene#t_scene.is_valid > 0, Scene#t_scene.server_type == 2],
    [{0, lists:usort(MapIdList)}].

get_all_war_map_id() ->
    List = ets:tab2list(t_scene),
    MapIdList = [Scene#t_scene.map_id || Scene <- List, Scene#t_scene.is_valid > 0, Scene#t_scene.server_type == 7],
    [{0, lists:usort(MapIdList)}].

get_all_world_map_id() ->
    List = ets:tab2list(t_scene),
    MapIdList = [Scene#t_scene.map_id || Scene <- List, Scene#t_scene.is_valid > 0, Scene#t_scene.type == 1],
    [{0, lists:usort(MapIdList)}].


tran_skill_balance_grids(Dir, GridList) ->
    lists:usort(
        lists:foldl(
            fun({X, Y}, Tmp) ->
                util_math:tran_pos_by_dir({X, Y}, Dir) ++ Tmp
            end,
            [],
            GridList
        )
    ).

%%is_in_balance_grid() ->
%%    List = ets:tab2list(t_skill_balance_grid),
%%
%%    Skill = ets:tab2list(t_active_skill),
%%    BalanceGridIdList = lists:usort(lists:foldl(
%%        fun(E, Tmp) ->
%%            lists:foldl(
%%                fun(E1, Tmp1) ->
%%                    {_, BalanceGridId, _, _} = E1,
%%                    if BalanceGridId > 0 ->
%%                        [BalanceGridId | Tmp1];
%%                        true ->
%%                            Tmp1
%%                    end
%%                end,
%%                Tmp,
%%                E#t_active_skill.balance_list
%%            )
%%        end,
%%        [],
%%        Skill
%%    )),
%%    E = lists:flatten(lists:foldl(
%%        fun(R, Tmp) ->
%%            #t_skill_balance_grid{
%%                id = Id,
%%                grid_list = GridList
%%            } = R,
%%%%            io:format("~na:~p~n", [Id]),
%%            [case lists:member(Id, BalanceGridIdList) of
%%                 true ->
%%%%                     io:format("~nb:~p~n", [Id]),
%%                     L3 = [{-1, GridList} | [{ThisDir, tran_skill_balance_grids(ThisDir, GridList)} || ThisDir <- [0, 1, 2, 3, 4, 5, 6, 7]]],
%%%%                     io:format("~ngo:~p~n", [{Id, length(lists:flatten(L3))}]),
%%                     lists:foldl(
%%                         fun({Dir, GridIdList}, Tmp2) ->
%%%%                             io:format("~p~n", [length(GridIdList)]),
%%                             [[{{Id, Dir, GridId}, 1} || GridId <- GridIdList] | Tmp2]
%%                         end,
%%                         [],
%%                         L3
%%                     );
%%                 false ->
%%                     []
%%             end | Tmp]
%%
%%        end,
%%        [],
%%        List
%%    )),
%%    E.

is_in_balance_grid() ->
    List = ets:tab2list(t_skill_balance_grid),

    Skill = ets:tab2list(t_active_skill),
    BalanceGridIdList = lists:usort(
        lists:foldl(
            fun(E, Tmp) ->
                lists:foldl(
                    fun(E1, Tmp1) ->
                        {_, BalanceGridId, _, _} = E1,
                        if BalanceGridId > 0 ->
                            [BalanceGridId | Tmp1];
                            true ->
                                Tmp1
                        end
                    end,
                    Tmp,
                    E#t_active_skill.balance_list
                )
            end,
            [],
            Skill
        )
    ),
    E = lists:foldl(
        fun(R, Tmp) ->
            #t_skill_balance_grid{
                id = Id,
                grid_list = GridList
            } = R,
            case lists:member(Id, BalanceGridIdList) of
                true ->
                    L3 = [{-1, GridList} | [{ThisDir, tran_skill_balance_grids(ThisDir, GridList)} || ThisDir <- [0, 1, 2, 3, 4, 5, 6, 7]]],
                    lists:foldl(
                        fun({Dir, GridIdList}, Tmp2) ->
                            [{{Id, Dir, GridId}, 1} || GridId <- GridIdList] ++ Tmp2
                        end,
                        [],
                        L3
                    );
                false ->
                    []
            end ++ Tmp
        end,
        [],
        List
    ),
    E.


get_balance_grid_list_by_dir() ->
    List = ets:tab2list(t_skill_balance_grid),

    SkillLevelMap = ets:tab2list(t_active_skill),
    BalanceGridIdList = lists:usort(lists:foldl(
        fun(E, Tmp) ->
            lists:foldl(
                fun(E1, Tmp1) ->
                    {_, BalanceGridId, _, _} = E1,
                    if BalanceGridId > 0 ->
                        [BalanceGridId | Tmp1];
                        true ->
                            Tmp1
                    end
                end,
                Tmp,
                E#t_active_skill.balance_list
            )
        end,
        [],
        SkillLevelMap
    )),
    lists:foldl(
        fun(R, Tmp) ->
            #t_skill_balance_grid{
                id = Id,
                grid_list = GridList
            } = R,

            case lists:member(Id, BalanceGridIdList) of
                true ->
                    [
                        begin
                            {
                                {Id, Dir},
                                tran_skill_balance_grids(Dir, GridList)
                            }
                        end
                        || Dir <- [0, 1, 2, 3, 4, 5, 6, 7]
                    ] ++ Tmp;
%%                    lists:foldl(
%%                        fun(Dir, Tmp_1) ->
%%                            [
%%                                {
%%                                    {Id, Dir},
%%                                    tran_skill_balance_grids(Dir, GridList)
%%                                }
%%                                | Tmp_1
%%                            ]
%%                        end,
%%                        [],
%%                        [0, 1, 2, 3, 4, 5, 6, 7]
%%                    ) ++
%%                    Tmp;
                false ->
                    Tmp
            end

        end,
        [],
        List
    ).


%% ----------------------------------
%% @doc 	获取该平台所有渠道
%% @throws 	none
%% @end
%% ----------------------------------
get_channel_list_by_platform_id() ->
    L = ets:tab2list(t_channel),
    lists:foldl(
        fun(Element, TempList) ->
            util_list:key_insert({Element#t_channel.platform_id, Element#t_channel.channel}, TempList)
        end,
        [],
        L
    ).

%% ----------------------------------
%% @doc 	通过功能id获取次数列表
%% @throws 	none
%% @end
%% ----------------------------------
get_times_id_by_function_id() ->
    L = ets:tab2list(t_times),
    lists:foldl(
        fun(Element, TempList) ->
            util_list:key_insert({Element#t_times.function_id, Element#t_times.id}, TempList)
        end,
        [],
        L
    ).

get_all_times_id() ->
    L = ets:tab2list(t_times),
    [{0, [E#t_times.id || E <- L]}].

get_slot_id_by_type() ->
    L = ets:tab2list(t_skill_slot),
    lists:foldl(
        fun(Element, TempList) ->
            util_list:key_insert({Element#t_skill_slot.type, Element#t_skill_slot.id}, TempList)
        end,
        [],
        L
    ).

%% ----------------------------------
%% @doc
%% @throws 	none
%% @end
%% ----------------------------------
get_effect_id_by_effect_sign() ->
    L = ets:tab2list(t_effect_type),
    [{util:to_atom(E#t_effect_type.sign), E#t_effect_type.id} || E <- L].

%% @doc     获得条件的功能列表
get_conditions_function_list() ->
    List = ets:tab2list(t_function),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                if
                    Element#t_function.have_pf_list == [] ->
                        lists:foldl(
                            fun(ConditionsList, L1) ->
                                calc_list_merge(ConditionsList, Element#t_function.id, L1)
                            end, TempList, Element#t_function.activate_condition_list);
                    true ->
                        TempList
                end
            end, [], List),
    [
        {
            Key,
            lists:sort([{Key1, lists:sort(L1)} || {Key1, L1} <- L])
        } || {Key, L} <- ListSort].

%% 获得条件的成就列表
get_conditions_achievement_list() ->
    List = ets:tab2list(t_achievement),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                {Key, _Value} =
                    case Element#t_achievement.approach_list of
                        [Conditions, ValueKey] ->
                            {Conditions, ValueKey};
                        [Conditions, Key1, ValueKey] ->
                            {{Conditions, Key1}, ValueKey};
                        R ->
                            R
                    end,
                util_list:key_insert({Key, {Element#t_achievement.type, Element#t_achievement.id}}, TempList)
%%                calc_list_merge(Element#t_achievement.approach_list, {Element#t_achievement.type, Element#t_achievement.id}, TempList)

            end, [], List),
    [{Key, lists:sort(L)} || {Key, L} <- ListSort].

%% 获得条件的每日任务列表
get_conditions_daily_task_list() ->
    List = ets:tab2list(t_daily_task),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                #t_daily_task{
                    id = Id,
                    approach_list = ConditionList
                } = Element,
                [ConditionKey, _ConditionValue] = get_conditions_key(ConditionList),
                util_list:key_insert({ConditionKey, Id}, TempList)
            end, [], List),
    [{Key, lists:sort(L)} || {Key, L} <- ListSort].

%% 获得条件的历练列表 (有条件的都有发给列表)
get_conditions_share_task_list() ->
    List = ets:tab2list(t_share_task_type),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                case get_conditions_key(Element#t_share_task_type.approach_list) of
                    [Conditions, _ValueKey] ->
                        case lists:keytake(Conditions, 1, TempList) of
                            {value, {Conditions, ConditionsList}, List1} ->
                                [
                                    {
                                        Conditions,
                                        [Element#t_share_task_type.task_type | ConditionsList]
                                    } | List1
                                ];
                            _ ->
                                [{Conditions, [Element#t_share_task_type.task_type]} | TempList]
                        end;
                    _ ->
                        TempList
                end
            end, [], List),
    [{Key, lists:sort(L)} || {Key, L} <- ListSort].

%% @doc     根据条件sign获得id
get_conditions_sign_id() ->
    List = ets:tab2list(t_conditions_enum),
    lists:keysort(2, [
        {
            util:to_atom(Element#t_conditions_enum.sign),
            Element#t_conditions_enum.id
        }
        || Element <- List
    ]).

%% @doc     根据条件id获得sign
get_conditions_id_to_sign() ->
    List = ets:tab2list(t_conditions_enum),
    lists:keysort(1, [
        {
            Element#t_conditions_enum.id,
            util:to_atom(Element#t_conditions_enum.sign)
        }
        || Element <- List
    ]).

%% @fun 获得条件key
get_conditions_key(ConditionsList) ->
    case ConditionsList of
        [Conditions1, Type1, ValueKey1] ->
            [{Conditions1, Type1}, ValueKey1];
        [_, _] ->
            ConditionsList;
        _ ->
            ConditionsList
    end.

%% @fun 计算列表整合
calc_list_merge([], _Value, TempList) ->
    TempList;
calc_list_merge(ConditionsList, Value, TempList) ->
    [Conditions, ValueKey] = get_conditions_key(ConditionsList),
    calc_list_merge1(Conditions, ValueKey, Value, TempList).
calc_list_merge1(Conditions, ValueKey, Value, TempList) ->
    case lists:keytake(Conditions, 1, TempList) of
        {value, {Conditions, ConditionsList}, List1} ->
            case lists:keytake(ValueKey, 1, ConditionsList) of
                {value, {ValueKey, ConditionsValueList}, ValueList1} ->
                    [
                        {
                            Conditions,
                            [{
                                ValueKey,
                                [Value | ConditionsValueList]
                            } | ValueList1]
                        } | List1
                    ];
                _ ->
                    [
                        {
                            Conditions,
                            [{
                                ValueKey,
                                [Value]
                            } | ConditionsList]
                        } | List1
                    ] end;
        _ ->
            [{Conditions, [{ValueKey, [Value]}]} | TempList]
    end.

%% @doc     成就类型列表
get_achievement_type_list() ->
    List = ets:tab2list(t_achievement),
    [{
        0,
        lists:usort([Element#t_achievement.type || Element <- List])
    }].

%% @doc     获得机器人属性列表
get_robot_attr_id_list() ->
    List = ets:tab2list(t_robot),
    ListSort = lists:sort([Element#t_robot.id || Element <- List]),
    [
        {
            0,
            ListSort
        }
    ].

%%%% @fun 排行榜功能列表
%%get_rank_all_fun_id_list() ->
%%    List = ets:tab2list(t_rank),
%%    [
%%        {
%%            0,
%%            lists:sort([Element#t_rank.id || Element <- List])
%%        }
%%    ].

%%%% @fun 排行榜功能有奖励列表
%%get_rank_all_award_list() ->
%%    List = ets:tab2list(t_rank),
%%    [
%%        {
%%            0,
%%            lists:sort([Element#t_rank.id || Element <- List, Element#t_rank.award_list =/= []])
%%        }
%%    ].

%% 获得自动购买时间表的编号列表
get_auto_shop_id_list() ->
    List = ets:tab2list(t_shop),
    ListSort =
        lists:foldl(
            fun(#t_shop{id = Id, type = Type, item_list = ItemList}, TempList) ->
                if
                    Type == 1 ->
                        [{{ItemType, ItemId}, {ItemNum, Id}} || [ItemType, ItemId, ItemNum] <- ItemList] ++ TempList;
%%                        [ItemType, ItemId, ItemNum] = ItemList,
%%                        Key = {ItemType, ItemId},
%%                        [{Key, {ItemNum, Id}} | TempList];
                    true ->
                        TempList
                end
            end, [], List),
    lists:sort(ListSort).


%% 获得商店对应id列表
get_shop_type_id_list() ->
    List = ets:tab2list(t_shop),
    ListSort =
        lists:foldl(
            fun(#t_shop{id = Id, type = Type}, TempList) ->
                ConditionsKey = Type,
                util_list:key_insert({ConditionsKey, Id}, TempList)
            end, [], List),
    lists:sort(ListSort).

%% 获得商店充值id的商品列表
get_shop_charge_id_list() ->
    List = ets:tab2list(t_shop),
    ListSort =
        lists:foldl(
            fun(#t_shop{id = Id, type = Type, buy_item_list = BuyItemList}, TempList) ->
                case BuyItemList of
                    [ChargeId] ->
                        ConditionsKey = ChargeId,
                        util_list:key_insert({ConditionsKey, {Type, Id}}, TempList);
                    _ ->
                        TempList
                end
            end, [], List),
    lists:sort([{NewConditionsKey, lists:usort(ValueL)} || {NewConditionsKey, ValueL} <- ListSort]).

%% 获得充值商店id
get_shop_charge_shop_id() ->
    List = ets:tab2list(t_shop),
    ListSort =
        lists:foldl(
            fun(#t_shop{id = Id, buy_item_list = BuyItemList}, TempList) ->
                case BuyItemList of
                    [ItemId] when is_integer(ItemId) ->
                        [{Id, true} | TempList];
                    _ ->
                        TempList
                end
            end, [], List),
    lists:sort(ListSort).

%% 获得功能奖励id
%%get_fun_award_id() ->
%%    List = ets:tab2list(t_guide_preview),
%%    lists:sort([{Element#t_guide_preview.function_id, Element#t_guide_preview.reward_id} || Element <- List, Element#t_guide_preview.reward_id > 0]).

%%%% 获得平台功能奖励id列表
%%get_platform_function_reward_id_list() ->
%%    List = ets:tab2list(t_platform_function_reward),
%%    [{
%%        0,
%%        lists:sort([Element#t_platform_function_reward.fun_id || Element <- List])
%%    }].
%%

%%%% 获得全部活动id列表
%%get_activity_id_all_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    [
%%        {0,
%%            lists:sort([Element#t_activity_info.id || Element <- List, Element#t_activity_info.state == ?TRUE])
%%        }
%%    ].

%%%% 获得新服不存在列表
%%get_activity_new_server_not_have_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    lists:sort([{Element#t_activity_info.id, true} || Element <- List, Element#t_activity_info.state == 1 andalso Element#t_activity_info.new_server_have == 0]).

%%%% 获得活动时间类型内容列表
%%get_activity_time_type_info_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            Key = {Element#t_activity_info.time_type, Element#t_activity_info.server_type},
%%            if
%%                Element#t_activity_info.state == 1 ->
%%                    case lists:keytake(Key, 1, NewList) of
%%                        {value, {Key, List21}, List2} ->
%%                            [{Key, [Element#t_activity_info.id | List21]} | List2];
%%                        _ ->
%%                            [{Key, [Element#t_activity_info.id]} | NewList]
%%                    end;
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    lists:sort([{Key, lists:sort(L)} || {Key, L} <- SortList]).

%% 获得功能奖励id
get_all_ring_task() ->
    List = ets:tab2list(t_ring_task),
    [{0, List}].

%% @fun 可存在的功能列表
get_function_have_fun_id_list() ->
    List = ets:tab2list(t_function),
    lists:sort([{FunId, HavePfList} || #t_function{id = FunId, have_pf_list = HavePfList} <- List, HavePfList =/= []]).


%% @fun 不可存在的功能列表
get_function_not_have_fun_id_list() ->
    List = ets:tab2list(t_function),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                if
                    Element#t_function.not_have_pf_list =/= [] ->
                        lists:foldl(
                            fun(NotHavePf, L) ->
                                util_list:key_insert({NotHavePf, Element#t_function.id}, L)
                            end, TempList, Element#t_function.not_have_pf_list);
                    true ->
                        TempList
                end
            end, [], List),
    lists:sort([{Key, lists:sort(L)} || {Key, L} <- ListSort]).

%% @fun 初始时的功能列表
get_function_have_init_list() ->
    List = ets:tab2list(t_function),
    [{
        0,
        lists:sort([FunId || #t_function{id = FunId, have_pf_list = HavePfList, not_have_pf_list = NotHavePfList} <- List, NotHavePfList =/= [] orelse HavePfList =/= []])
    }].
%%    lists:sort([{Key, lists:sort(Value)} || {Key, Value} <- ListSort]).

%% @fun vip等级经验
get_vip_level_exp() ->
    List = ets:tab2list(t_vip_level),
    [
        {
            0,
            lists:reverse(lists:sort([{Level, Exp} || #t_vip_level{level = Level, exp = Exp} <- List]))
        }
    ].

%% @fun 平台充值商品类型列表
get_recharge_charge_type_list() ->
    List = ets:tab2list(t_recharge),
    ListSort =
        lists:foldl(
            fun(#t_recharge{recharge_type = ChargeType, id = Id, is_show = IsShow}, TempList) ->
                ConditionsKey = ChargeType,
                if
                    IsShow == ?TRUE ->
                        util_list:key_insert({ConditionsKey, Id}, TempList);
                    true ->
                        TempList
                end
            end, [], List),
    lists:sort([{Key, lists:sort(Value)} || {Key, Value} <- ListSort]).

%% @fun 平台充值商品类型列表
get_recharge_type_list() ->
    List = ets:tab2list(t_recharge),
    ListSort =
        lists:foldl(
            fun(#t_recharge{type = Type, id = Id, is_show = IsShow}, TempList) ->
                ConditionsKey = Type,
                if
                    IsShow == ?TRUE ->
                        util_list:key_insert({ConditionsKey, Id}, TempList);
                    true ->
                        TempList
                end
            end, [], List),
    lists:sort([{Key, lists:sort(Value)} || {Key, Value} <- ListSort]).

%% 获得每日签到天数表
get_everyday_sign_day_list() ->
    List = ets:tab2list(t_everyday_sign),
    [{
        0,
        lists:usort([Element#t_everyday_sign.today || Element <- List])
    }].

%% 获得在线奖励天数
get_online_award_day_list() ->
    List = ets:tab2list(t_online_award),
    [{
        0,
        lists:usort([Element#t_online_award.id || Element <- List])
    }].

%% 整合心法属性列表
merge_heart_attr_list(List) ->
    merge_heart_attr_list(List, []).

merge_heart_attr_list([], List) ->
    List;
merge_heart_attr_list([[ThisType, ThisValue] | L], List) ->
    NewList =
        case util_list:key_take(ThisType, 1, List) of
            {value, [AttrId, AttrValue], NewList1} ->
                SumAttrValue = AttrValue + ThisValue,
                [[AttrId, SumAttrValue] | NewList1];
            _ ->
                [[ThisType, ThisValue] | List]
        end,
    merge_heart_attr_list(L, NewList).

get_all_platform_id() ->
    L = ets:tab2list(t_platform),
    L2 = [E#t_platform.id || E <- L],
    [{0, L2}].

%% 获得邀请任务类型列表
get_invite_task_type_list() ->
    List = ets:tab2list(t_share_task_type),
    [
        {
            0,
            lists:usort([Element#t_share_task_type.task_type || Element <- List])
        }
    ].

%% 获得分享有礼任务类型对应编号id
get_share_type_task_id() ->
    List = ets:tab2list(t_share_task),
    ListSort =
        lists:foldl(
            fun(#t_share_task{task_type_id = TaskTypeId, id = Id, need_num = Num}, L) ->
                util_list:key_insert({TaskTypeId, {Id, Num}}, L)
            end, [], List
        ),
    lists:sort([{Key, lists:sort(L)} || {Key, L} <- ListSort]).

%% @fun 获得邀请任务id列表
get_share_id_list() ->
    List = ets:tab2list(t_share_task_type),
    [{
        0,
        lists:sort([TaskTypeId || #t_share_task_type{task_type = TaskTypeId, is_share = IsShare} <- List, IsShare == ?TRUE])
    }].

%% 根据can_be_traded字段对items数据进行筛选
get_can_be_traded_items() ->
    List = ets:tab2list(t_item),
    ListSort =
        lists:foldl(
            fun(#t_item{id = Id, can_be_traded = IsConditions, icon = Icon, name = Name}, L) ->
                util_list:key_insert({IsConditions, {Id, {IsConditions, 2, Icon, Name}}}, L)
            end, [], List
        ),
    lists:sort(ListSort).

%% 获得是条件道具id
get_is_conditions_item() ->
    List = ets:tab2list(t_item),
    ListSort =
        lists:foldl(
            fun(#t_item{id = Id, is_conditions = IsConditions}, L) ->
                if
                    IsConditions == 1 ->
                        [{Id, true} | L];
                    true ->
                        L
                end
            end, [], List
        ),
    lists:sort(ListSort).

%% @fun 充值http活动类型值列表
get_charge_http_type_value_list() ->
    ShopList =
        lists:foldl(
            fun(#t_shop{id = ShopId, type = ShopType, buy_item_list = BuyItemList, condition_list = ConditionList}, TempList) ->
                case BuyItemList of
                    [ShopChargeItemId] ->
                        case t_recharge:get({ShopChargeItemId}) of
                            #t_recharge{is_show = IsShopShow} when IsShopShow == ?TRUE ->
                                #t_shop_type{
                                    activity_id = ShopActivityId
                                } = t_shop_type:get({ShopType}),
                                {ShopTypeList, ShopTypeOtherList} =
                                    case lists:keytake(ShopType, 1, TempList) of
                                        {value, {ShopType, ShopActivityId, ShopTypeL}, ShopTypeOtherL} ->
                                            {ShopTypeL, ShopTypeOtherL};
                                        _ ->
                                            {[], TempList}
                                    end,
                                [{ShopType, ShopActivityId, [{ShopChargeItemId, ConditionList, ShopId} | ShopTypeList]} | ShopTypeOtherList];
                            _ ->
                                TempList
                        end;
                    _ ->
                        TempList
                end
            end, [], ets:tab2list(t_shop)),
    ChargeList =
        lists:foldl(
            fun(#t_recharge{id = ChargeItemId, recharge_type = RechargeType, is_show = IsShow}, ChargeTempList) ->
                if
                    IsShow == ?TRUE andalso (RechargeType == ?CHARGE_GAME_FIRST_CHARGE orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_DIAMOND orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_COIN) ->
                        {ShopTypeList, ShopTypeOtherList} =
                            case lists:keytake(RechargeType, 1, ChargeTempList) of
                                {value, {RechargeType, _, ChargeTypeL}, ShopTypeOtherL} ->
                                    {ChargeTypeL, ShopTypeOtherL};
                                _ ->
                                    {[], ChargeTempList}
                            end,
                        [{RechargeType, 0, [{ChargeItemId, [], 0} | ShopTypeList]} | ShopTypeOtherList];
                    true ->
                        ChargeTempList
                end
            end, ShopList, ets:tab2list(t_recharge)),
    lists:sort([{Type, {ActivityId, lists:sort(ValueList)}} || {Type, ActivityId, ValueList} <- ChargeList]).

%% @fun 充值http活动类型值列表
get_charge_http_type_list() ->
    ShopList =
        lists:foldl(
            fun(#t_shop{type = ShopType, buy_item_list = BuyItemList}, TempList) ->
                case BuyItemList of
                    [ShopChargeItemId] ->
                        case t_recharge:get({ShopChargeItemId}) of
                            #t_recharge{is_show = IsChargeShow} when IsChargeShow == ?TRUE ->
                                #t_shop_type{
                                    name = ShopTypeName,
                                    activity_id = ShopActivityId
                                } = t_shop_type:get({ShopType}),
                                if
                                    ShopActivityId > 0 ->
                                        [{ShopType, ShopTypeName, ShopActivityId} | TempList];
                                    true ->
                                        TempList
                                end;
                            _ ->
                                TempList
                        end;
                    _ ->
                        TempList
                end
            end, [], ets:tab2list(t_shop)),
    ChargeList =
        lists:foldl(
            fun(#t_recharge{recharge_type = RechargeType, is_show = IsChargeShow}, ChargeTempList) ->
                if
                    IsChargeShow == ?TRUE andalso (RechargeType == ?CHARGE_GAME_FIRST_CHARGE orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_DIAMOND orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_COIN) ->
                        #t_charge_game{
                            name = RechargeTypeName
                        } = t_charge_game:get({RechargeType}),

                        [{RechargeType, RechargeTypeName, 0} | ChargeTempList];
                    true ->
                        ChargeTempList
                end
            end, ShopList, ets:tab2list(t_recharge)),
    [{
        0,
        lists:usort(ChargeList)
    }].

%% @fun 充值http充值id的值列表
get_charge_http_recharge_id_list() ->
    ShopList =
        lists:foldl(
            fun(#t_shop{id = ShopId, type = ShopType, buy_item_list = BuyItemList, condition_list = ConditionList}, TempList) ->
                case BuyItemList of
                    [ShopChargeItemId] ->
                        case t_recharge:get({ShopChargeItemId}) of
                            #t_recharge{is_show = IsShopShow} when IsShopShow == ?TRUE ->
                                #t_shop_type{
                                    activity_id = ShopActivityId
                                } = t_shop_type:get({ShopType}),
                                {ShopTypeList, ShopTypeOtherList} =
                                    case lists:keytake(ShopChargeItemId, 1, TempList) of
                                        {value, {ShopChargeItemId, ShopTypeL}, ShopTypeOtherL} ->
                                            {ShopTypeL, ShopTypeOtherL};
                                        _ ->
                                            {[], TempList}
                                    end,
                                [{ShopChargeItemId, [{ShopActivityId, ConditionList, ShopId} | ShopTypeList]} | ShopTypeOtherList];
                            _ ->
                                TempList
                        end;
                    _ ->
                        TempList
                end
            end, [], ets:tab2list(t_shop)),
    ChargeList =
        lists:foldl(
            fun(#t_recharge{id = ChargeItemId, recharge_type = RechargeType, is_show = IsChargeShow}, ChargeTempList) ->
                if
                    IsChargeShow == ?TRUE andalso (RechargeType == ?CHARGE_GAME_FIRST_CHARGE orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_DIAMOND orelse RechargeType == ?CHARGE_GAME_COMMON_CHARGE_COIN) ->
                        {ShopTypeList, ShopTypeOtherList} =
                            case lists:keytake(ChargeItemId, 1, ChargeTempList) of
                                {value, {ChargeItemId, ChargeTypeL}, ShopTypeOtherL} ->
                                    {ChargeTypeL, ShopTypeOtherL};
                                _ ->
                                    {[], ChargeTempList}
                            end,
                        [{ChargeItemId, [{0, [], 0} | ShopTypeList]} | ShopTypeOtherList];
                    true ->
                        ChargeTempList
                end
            end, ShopList, ets:tab2list(t_recharge)),
    lists:sort([{Type, lists:sort(ValueList)} || {Type, ValueList} <- ChargeList]).

%% @fun 商店活动重置列表
get_shop_activity_reset_list() ->
    ShopList =
        lists:foldl(
            fun(#t_shop{id = ShopId, type = ShopType, buy_item_list = BuyItemList, limit_type = LimitType}, TempList) ->
                if
                    LimitType == 3 ->
                        case BuyItemList of
                            [ShopChargeItemId] ->
                                case t_recharge:get({ShopChargeItemId}) of
                                    #t_recharge{is_show = IsShopShow} when IsShopShow == ?TRUE ->
                                        #t_shop_type{
                                            activity_id = ShopActivityId
                                        } = t_shop_type:get({ShopType}),
                                        case lists:keytake(ShopActivityId, 1, TempList) of
                                            {value, {ShopActivityId, ShopTypeL}, ShopTypeOtherL} ->
                                                [{ShopActivityId, [{ShopId, ShopChargeItemId} | ShopTypeL]} | ShopTypeOtherL];
                                            _ ->
                                                [{ShopActivityId, [{ShopId, ShopChargeItemId}]} | TempList]
                                        end;
                                    _ ->
                                        TempList
                                end;
                            _ ->
                                TempList
                        end;
                    true ->
                        TempList
                end
            end, [], ets:tab2list(t_shop)),
    lists:sort([{Type, lists:sort(ValueList)} || {Type, ValueList} <- ShopList]).

%% @fun 商店每日重置列表
get_shop_day_reset_list() ->
    ShopList =
        lists:foldl(
            fun(#t_shop{id = ShopId, type = ShopType, buy_item_list = BuyItemList, limit_type = LimitType}, TempList) ->
                if
                    LimitType == 1 ->
                        case BuyItemList of
                            [ShopChargeItemId] ->
                                case t_recharge:get({ShopChargeItemId}) of
                                    #t_recharge{is_show = IsShopShow} when IsShopShow == ?TRUE ->
                                        #t_shop_type{
                                            activity_id = ShopActivityId
                                        } = t_shop_type:get({ShopType}),
                                        case lists:keytake(ShopActivityId, 1, TempList) of
                                            {value, {ShopActivityId, ShopTypeL}, ShopTypeOtherL} ->
                                                [{ShopActivityId, [{ShopId, ShopChargeItemId} | ShopTypeL]} | ShopTypeOtherL];
                                            _ ->
                                                [{ShopActivityId, [{ShopId, ShopChargeItemId}]} | TempList]
                                        end;
                                    _ ->
                                        TempList
                                end;
                            _ ->
                                TempList
                        end;
                    true ->
                        TempList
                end
            end, [], ets:tab2list(t_shop)),
    [{
        0,
        lists:sort([{Type, lists:sort(ValueList)} || {Type, ValueList} <- ShopList])
    }].

get_monster_ai_args() ->
    List = ets:tab2list(t_monster),
    %% PatrolRange, TrackRange, WarnRange
    [{E#t_monster.id, {
        E#t_monster.patrol_range,
        E#t_monster.track_range,
        E#t_monster.warn_range
    }} || E <- List].

%% @doc 根据多人boss副本id获得多人boss_id
get_many_people_boss_id_by_mission_id() ->
    List = ets:tab2list(t_mission_many_people_boss),
    ListSort =
        lists:map(
            fun(#t_mission_many_people_boss{id = BossId, mission_id = MissionId}) ->
                {MissionId, BossId}
            end, List),
    lists:sort([{Key, ValueList} || {Key, ValueList} <- ListSort]).

%% 获得条件的任务列表 (有条件的都有发给列表)
get_conditions_task_list() ->
    List = ets:tab2list(t_task),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                case Element#t_task.content_list of
                    [Conditions, _ValueKey] ->
                        case lists:keytake(Conditions, 1, TempList) of
                            {value, {Conditions, ConditionsList}, List1} ->
                                [
                                    {
                                        Conditions,
                                        [Element#t_task.id | ConditionsList]
                                    } | List1
                                ];
                            _ ->
                                [{Conditions, [Element#t_task.id]} | TempList]
                        end;
                    [Key1, Key2, _ValueKey] ->
                        Conditions = {Key1, Key2},
                        case lists:keytake(Conditions, 1, TempList) of
                            {value, {Conditions, ConditionsList}, List1} ->
                                [
                                    {
                                        Conditions,
                                        [Element#t_task.id | ConditionsList]
                                    } | List1
                                ];
                            _ ->
                                [{Conditions, [Element#t_task.id]} | TempList]
                        end;
                    _ ->
                        TempList
                end
            end, [], List),
    [{Key, lists:sort(L)} || {Key, L} <- ListSort].

%%%% @doc 根据模块名获得获得活动id列表
%%get_activity_id_list_by_mod_name() ->
%%    List = ets:tab2list(t_activity_info),
%%    ListSort =
%%        lists:foldl(
%%            fun(
%%                #t_activity_info{id = Id, m_tuple = M_Tuple, state = State},
%%                TmpList
%%            ) ->
%%                if
%%                    State == 1 andalso M_Tuple =/= {} ->
%%                        util_list:key_insert({M_Tuple, Id}, TmpList);
%%                    true ->
%%                        TmpList
%%                end
%%            end,
%%            [], List
%%        ),
%%    [{Key, lists:sort(L)} || {Key, L} <- ListSort].

%% @doc 根据红包类型获得id列表
get_red_packet_id_by_type_list() ->
    List = ets:tab2list(t_red_package),
    ListSort =
        lists:foldl(
            fun(#t_red_package{id = Id, type = Type}, TmpList) ->
                util_list:key_insert({Type, Id}, TmpList)
            end,
            [], List
        ),
    lists:sort([{Key, lists:sort(L)} || {Key, L} <- ListSort]).

%% @doc 获得条件的投资返利的id列表
get_conditions_invest_list() ->
    List = ets:tab2list(t_tou_zi_ji_hua),
    ListSort =
        lists:foldl(
            fun(Element, TempList) ->
                #t_tou_zi_ji_hua{
                    type_id = Type,
                    id = Id,
                    condition_list = ConditionList
                } = Element,

                case ConditionList of
                    [Conditions, _ValueKey] ->
                        util_list:key_insert({Conditions, {Type, Id}}, TempList);
                    [Key1, Key2, _ValueKey] ->
                        Conditions = {Key1, Key2},
                        util_list:key_insert({Conditions, {Type, Id}}, TempList);
                    _ ->
                        TempList
                end
            end, [], List),
    Fun =
        fun({Type, Id}, TmpL) ->
            util_list:key_insert({Type, Id}, TmpL)
        end,
    [{Key, lists:sort([{ThisKey, lists:sort(ThisValueList)} || {ThisKey, ThisValueList} <- lists:foldl(Fun, [], L)])} || {Key, L} <- ListSort].


%% @doc 根据红包条件获得单人红包id列表
get_conditions_individual_red_packet_id_list() ->
    List = ets:tab2list(t_red_condition),
    ListSort =
        lists:foldl(
            fun(#t_red_condition{content_list = ConditionList, is_individual = IsIndividual, id = Id}, TempList) ->
                case get_conditions_key(ConditionList) of
                    [Conditions, Value] when IsIndividual == 0 ->
                        case lists:keytake(Conditions, 1, TempList) of
                            {value, {Conditions, ConditionsList}, List1} ->
                                [{Conditions, [{Id, Value} | ConditionsList]} | List1];
                            _ ->
                                [{Conditions, [{Id, Value}]} | TempList]
                        end;
                    _ ->
                        TempList
                end
            end,
            [], List
        ),
    lists:sort([{Key, lists:sort(L)} || {Key, L} <- ListSort]).

%% @doc 根据红包条件获得红包id列表
get_conditions_red_packet_id_list() ->
    List = ets:tab2list(t_red_condition),
    ListSort =
        lists:foldl(
            fun(#t_red_condition{content_list = ConditionList, is_individual = IsIndividual, id = Id}, TempList) ->
                case get_conditions_key(ConditionList) of
                    [Conditions, Value] when IsIndividual =/= 0 ->
                        case lists:keytake(Conditions, 1, TempList) of
                            {value, {Conditions, ConditionsList}, List1} ->
                                [{Conditions, [{Id, Value} | ConditionsList]} | List1];
                            _ ->
                                [{Conditions, [{Id, Value}]} | TempList]
                        end;
                    _ ->
                        TempList
                end
            end,
            [], List
        ),
    lists:sort([{Key, lists:sort(L)} || {Key, L} <- ListSort]).

%%%% @doc 获得商店物品金钱价格
%%get_shop_item_money() ->
%%    List = ets:tab2list(t_shop),
%%    ListSort =
%%        lists:foldl(
%%            fun(#t_shop{type = Type, item_list = ItemList, buy_item_list = BuyItemList}, TempList) ->
%%                [[PropId, PropNum]] = ItemList,
%%                #t_item{
%%                    type = ItemType
%%                } = t_item:get({PropId}),
%%                if
%%                    Type =:= 2 andalso ItemType =:= 5 andalso PropNum =:= 1 ->
%%%%                        [[?RES_GOLD, BuyMoney]] = BuyItemList,
%%                        [[1, BuyMoney]] = BuyItemList,
%%                        [{PropId, round(BuyMoney / 500)} | TempList];
%%                    true ->
%%                        TempList
%%                end
%%            end,
%%            [], List
%%        ),
%%    lists:sort(ListSort).

%% @doc 获得公共系统id列表 根据功能id
get_sys_common_id_list_by_func_id() ->
    List = ets:tab2list(t_sys_common),
    ListSort =
        lists:foldl(
            fun(#t_sys_common{id = Id, func_id = FuncId}, TempList) ->
                util_list:key_insert({FuncId, Id}, TempList)
            end,
            [], List
        ),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- ListSort]).

%%%% 获得活动检测类型活动时间列表
%%get_activity_check_type_time_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            #t_activity_time_type{
%%                check_type = CheckType
%%            } = t_activity_time_type:get({Element#t_activity_info.time_type}),
%%            Key = {Element#t_activity_info.server_type, CheckType},
%%            if
%%                Element#t_activity_info.state == 1 ->
%%                    case lists:keytake(Key, 1, NewList) of
%%                        {value, {Key, List21}, List2} ->
%%                            [{Key, [Element#t_activity_info.id | List21]} | List2];
%%                        _ ->
%%                            [{Key, [Element#t_activity_info.id]} | NewList]
%%                    end;
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    [{KeyTime, lists:sort(TimeList)} || {KeyTime, TimeList} <- SortList].

%%%% 获得活动验证类型列表
%%get_activity_check_type_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            #t_activity_time_type{
%%                check_type = CheckType
%%            } = t_activity_time_type:get({Element#t_activity_info.time_type}),
%%            Key = CheckType,
%%            if
%%                Element#t_activity_info.state == 1 ->
%%                    case lists:keytake(Key, 1, NewList) of
%%                        {value, {Key, List21}, List2} ->
%%                            [{Key, [Element#t_activity_info.id | List21]} | List2];
%%                        _ ->
%%                            [{Key, [Element#t_activity_info.id]} | NewList]
%%                    end;
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    [{KeyTime, lists:sort(TimeList)} || {KeyTime, TimeList} <- SortList].

%%%% 获得检查类型检测开启的活动时间列表
%%get_activity_check_type_check_time_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(
%%            fun(#t_activity_info{id = Id, server_type = ServerType, state = State, time_type = TimeType, activity_server_type = ActivityServerType,
%%                month_day_list = MonthDayList, week_list = WeekList, notice_time = NoticeTime, start_time_list = StartTimeList,
%%                end_time = EndTime, open_server = OpenServerStartDay, open_server_end = OpenServerEndDay}, NewList) ->
%%                TimeTypeTable = t_activity_time_type:get({TimeType}),
%%                ?ASSERT(is_record(TimeTypeTable, t_activity_time_type), {t_activity_time_type, {TimeType}, {Id, TimeType}}),
%%                #t_activity_time_type{
%%                    check_type = CheckType
%%                } = TimeTypeTable,
%%                Key = {ServerType, CheckType},
%%                if
%%                    State == 1 ->
%%                        Tuple = {Id, NoticeTime, StartTimeList, EndTime, OpenServerStartDay, OpenServerEndDay, MonthDayList, WeekList, TimeType, ActivityServerType},
%%                        case lists:keytake(Key, 1, NewList) of
%%                            {value, {Key, List21}, List2} ->
%%                                [{Key, [Tuple | List21]} | List2];
%%                            _ ->
%%                                [{Key, [Tuple]} | NewList]
%%                        end;
%%                    true ->
%%                        NewList
%%                end end, [], List),
%%    [{KeyTime, lists:usort(TimeList)} || {KeyTime, TimeList} <- SortList].

%%%% 获得关闭活动时间列表
%%get_activity_close_time_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            Key = Element#t_activity_info.server_type,
%%            #t_activity_time_type{
%%                check_type = CheckType
%%            } = t_activity_time_type:get({Element#t_activity_info.time_type}),
%%            if
%%                Element#t_activity_info.state =/= 1 andalso CheckType == 1 ->
%%                    util_list:key_insert({Key, Element#t_activity_info.id}, NewList);
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    [{KeyTime, lists:sort(TimeList)} || {KeyTime, TimeList} <- SortList].

%%%% 获得检测类型关闭活动时间列表
%%get_activity_check_type_close_time_list() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            #t_activity_time_type{
%%                check_type = CheckType
%%            } = t_activity_time_type:get({Element#t_activity_info.time_type}),
%%            Key = {Element#t_activity_info.server_type, CheckType},
%%            if
%%                Element#t_activity_info.state =/= 1 ->
%%                    util_list:key_insert({Key, Element#t_activity_info.id}, NewList);
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    [{KeyTime, lists:sort(TimeList)} || {KeyTime, TimeList} <- SortList].

%%%% 获得活动方式类型
%%get_activity_activity_server_type() ->
%%    List = ets:tab2list(t_activity_info),
%%    SortList =
%%        lists:foldl(fun(Element, NewList) ->
%%            #t_activity_time_type{
%%                check_type = CheckType
%%            } = t_activity_time_type:get({Element#t_activity_info.time_type}),
%%            Key = Element#t_activity_info.id,
%%            Value = {CheckType, Element#t_activity_info.activity_server_type},
%%            if
%%                Element#t_activity_info.state == 1 ->
%%                    [{Key, Value} | NewList];
%%                true ->
%%                    NewList
%%            end end, [], List),
%%    lists:sort(SortList).

%% 获得七天登陸拉霸權重列表
get_seven_login_laba_weight_list() ->
    List = ets:tab2list(t_seven_login_laba),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_seven_login_laba{
                    today = Today,
                    id = Id,
                    weights = Weights
                } = Element,
                util_list:key_insert({Today, {Id, Weights}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得功能怪翻牌權重列表
get_function_monster_fanpai_weights_list() ->
    List = ets:tab2list(t_monster_function_fanpai),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_fanpai{
                    fanpai_type = Type,
                    id = Id,
                    reward_per = RewardPer,
                    reward_item_list = RewardItemList,
                    xiuzheng_weights_list = [Weight1, Weight2]
                } = Element,
                util_list:key_insert({Type, {Id, RewardPer, RewardItemList, Weight1, Weight2}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得功能怪拉霸權重列表
get_function_monster_laba_weights_list() ->
    List = ets:tab2list(t_monster_function_laba),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_laba{
                    laba_type = Type,
                    id = Id,
                    reward_per = RewardPer,
                    reward_item_list = RewardItemList,
                    xiuzheng_weights_list = [Weight1, Weight2]
                } = Element,
                util_list:key_insert({Type, {Id, RewardPer, RewardItemList, Weight1, Weight2}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得箱子权重列表
get_function_monster_blind_box_weights_list() ->
    List = ets:tab2list(t_monster_function_xiangzi),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_xiangzi{
                    xiangzi_type = Type,
                    id = Id,
                    reward_per = RewardPer,
                    reward_item_list = RewardItemList,
                    xiuzheng_weights_list = [Weight1, Weight2]
                } = Element,
                util_list:key_insert({Type, {Id, RewardPer, RewardItemList, Weight1, Weight2}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得功能怪转盘權重列表
get_function_monster_zhuanpan_weights_list() ->
    List = ets:tab2list(t_monster_function_zhuanpan),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_zhuanpan{
                    zhuanpan_type = Type,
                    id = Id,
                    reward_per = RewardPer,
                    reward_item_list = RewardItemList,
                    xiuzheng_weights_list = [Weight1, Weight2]
                } = Element,
                util_list:key_insert({Type, {Id, RewardPer, RewardItemList, Weight1, Weight2}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得功能怪任务奖励权重列表
get_function_monster_task_reward_weights_list() ->
    List = ets:tab2list(t_monster_function_task_rand_list),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_task_rand_list{
                    task_type = Type,
                    id = Id,
                    reward_per = RewardPer,
                    reward_item_list = RewardItemList,
                    xiuzheng_weights_list = [Weight1, Weight2]
                } = Element,
                util_list:key_insert({Type, {Id, RewardPer, RewardItemList, Weight1, Weight2}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

get_seize_treasure_id_by_award_list() ->
    List = ets:tab2list(t_treasure_hunt),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_treasure_hunt{
                    type_id = TypeId,
                    id = Id,
                    award_list = [[ItemId, Num]],
                    weights = Weights,
                    need_luck = Minimum
                } = Element,
                lists:keystore(TypeId, 1, TmpList, {{ItemId, Num, TypeId}, Id - 1})
            end,
            [],
            List
        ),
    SortList.

get_seize_treasure_list_by_type_id() ->
    List = ets:tab2list(t_treasure_hunt),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_treasure_hunt{
                    type_id = TypeId,
                    award_list = [[ItemId, Num]],
                    weights = Weights,
                    need_luck = Minimum
                } = Element,

                RealTmpList =
                    case lists:keytake(TypeId, 1, TmpList) of
                        false -> [{{{ItemId, Num}, Weights}, Minimum}];
                        {value, {_, RealListInTmp}, _} -> [{{{ItemId, Num}, Weights}, Minimum} | RealListInTmp]
                    end,
                lists:keystore(TypeId, 1, TmpList, {TypeId, RealTmpList})
            end,
            [], List),
    SortList.

get_seize_treasure_cost_list_by_pos() ->
    List = ets:tab2list(t_treasure_hunt_type),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_treasure_hunt_type{
                    cost_list = CostList,
                    id = TreasureTypeId
                } = Element,
                TempList =
                    lists:foldl(
                        fun([Times, ItemId, ItemNum], Tmp) ->
                            [{{TreasureTypeId, length(Tmp)}, {Times, ItemId, ItemNum}} | Tmp]
                        end,
                        [],
                        CostList
                    ),
                lists:merge(TempList, TmpList)
            end,
            [],
            List
        ),
    SortList.


get_seize_treasure_achievement_list_by_pos() ->
    List = ets:tab2list(t_treasure_hunt_type),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_treasure_hunt_type{
                    id = TreasureTypeId,
                    achievement_list = AchievementList
                } = Element,
                TempList =
                    lists:foldl(
                        fun([Times, AwardList], Tmp) ->
                            [{{TreasureTypeId, length(Tmp)}, {Times, AwardList}} | Tmp]
                        end,
                        [],
                        AchievementList
                    ),
                lists:merge(TempList, TmpList)
            end,
            [],
            List
        ),
    SortList.

%% 根据类型获得抽奖卡池列表
get_card_summon_list_by_type() ->
    CfgList = ets:tab2list(t_card_summon),
    Func =
        fun(Element, Acc) ->
            #t_card_summon{
                type = Type,
                reward_list = RewardList,
                weights = Weight
            } = Element,
            case lists:keyfind(Type, 1, Acc) of
                false ->
                    [{Type, [{RewardList, Weight}]} | Acc];
                {Type, L} ->
                    lists:keyreplace(Type, 1, Acc, {Type, [{RewardList, Weight} | L]})
            end
        end,
    lists:ukeysort(1, lists:foldl(Func, [], CfgList)).

%% 获得神龙权重列表
get_shenlongzhufu_weights_list() ->
    List = ets:tab2list(t_monster_function_shenlongzhufu),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_monster_function_shenlongzhufu{
                    shenlongzhufu_type = Type,
                    id = Id,
                    weights = Weights
                } = Element,
                util_list:key_insert({Type, {Id, Weights}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% 获得个性化初始奖励列表
get_ge_xing_hua_init_award_list() ->
    List = ets:tab2list(t_ge_xing_hua),
    IdList =
        lists:filtermap(
            fun(Element) ->
                #t_ge_xing_hua{
                    item_id = ItemId,
                    is_initial = IsInitial
                } = Element,
                ?IF(IsInitial =:= 1, {true, {ItemId, 1}}, false)
            end,
            List),
    [{0, IdList}].

get_can_bet_mission_id() ->
    MissionList = ets:tab2list(t_mission_type),
    SortList =
        lists:foldl(
            fun(Element, Tmp) ->
                #t_mission_type{
                    id = Id,
                    is_can_be_bet = CanBeBet
                } = Element,
                case lists:keyfind(CanBeBet, 1, Tmp) of
                    false -> [{CanBeBet, [Id]} | Tmp];
                    {CanBeBetInTmp, L} ->
                        lists:keyreplace(CanBeBetInTmp, 1, Tmp, {CanBeBetInTmp, [Id | L]})
                end
            end,
            [],
            MissionList
        ),
    lists:ukeysort(1, SortList).

%% @doc 获得场景机器人id权重列表
get_scene_robot_id_weight_list() ->
    List = ets:tab2list(t_robot),
    Func =
        fun(Element, TmpList) ->
            #t_robot{
                id = Id,
                scene = SceneId,
                weights = Weights
            } = Element,
            util_list:key_insert({SceneId, {Id, Weights}}, TmpList)
        end,
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- lists:foldl(Func, [], List)]).

%% 根据 月度任务类型 和 解锁天数 获取月度任务
get_tongxingzheng_month_tasks_by_type_and_day() ->
    List = ets:tab2list(t_tongxingzheng_task),
    lists:keysort(1,
        lists:foldl(
            fun(Element, Acc) ->
                #t_tongxingzheng_task{
                    id = Id,
                    type = Type,
                    day = Day
                } = Element,
                Key = {Type, Day},
                util_list:key_insert({Key, Id}, Acc)
            end,
            [], List)
    ).

%% 按任务条件获取每日任务列表
get_condition_txz_daily_task_list() ->
    List = ets:tab2list(t_tongxingzheng_daily_task),
    lists:foldl(
        fun(E, Acc) ->
            #t_tongxingzheng_daily_task{
                id = Id,
                condition_list = ConditionList
            } = E,
            [Key, _Value] = tran_condition_list(ConditionList),
            util_list:key_insert({Key, Id}, Acc)
        end,
        [], List
    ).

%% 按任务条件获取赏金任务列表
get_condition_bounty_task_list() ->
    List = ets:tab2list(t_money_reward),
    lists:foldl(
        fun(E, Acc) ->
            #t_money_reward{
                id = Id,
                approach_list = ConditionList
            } = E,
            [Key, _Value] = tran_condition_list(ConditionList),
            util_list:key_insert({Key, Id}, Acc)
        end,
        [], List
    ).

%% 按任务条件获取任务列表
get_condition_txz_task_list() ->
    List = ets:tab2list(t_tongxingzheng_task),
    lists:foldl(
        fun(E, Acc) ->
            #t_tongxingzheng_task{
                id = Id,
                type = Type,
                condition_list = ConditionList
            } = E,
            [Key0, _Value] = tran_condition_list(ConditionList),
            Key = {Type, Key0},
            util_list:key_insert({Key, Id}, Acc)
        end,
        [], List
    ).

%% 按任务条件获取任务列表
get_condition_monster_function_task_list() ->
    List = ets:tab2list(t_monster_function_task),
    lists:foldl(
        fun(E, Acc) ->
            #t_monster_function_task{
                id = Id,
                task_list = ConditionList
            } = E,
            [Key0, _Value] = tran_condition_list(ConditionList),
            util_list:key_insert({Key0, Id}, Acc)
        end,
        [], List
    ).

tran_condition_list(ConditionList) ->
    case ConditionList of
        [Key, Value] ->
            [Key, Value];
        [Key1, Key2, Value] ->
            [{Key1, Key2}, Value];
        [Key1, Key2, Key3, Value] ->
            [{Key1, Key2, Key3}, Value]
    end.

%% 获得全部活动id列表
get_activity_id_all_list() ->
    List = ets:tab2list(t_activity_info),
    [
        {0,
            lists:sort([Element#t_activity_info.id || Element <- List, Element#t_activity_info.is_valid == ?TRUE])
        }
    ].

%% @doc 获取同类型的活动ID列表
get_activity_id_list_by_type() ->
    List = ets:tab2list(t_activity_info),
    lists:foldl(
        fun(Element, TempList) ->
            #t_activity_info{
                id = ActivityId,
                is_valid = IsValid,
                type = Type
            } = Element,
            if IsValid == ?TRUE ->
                util_list:key_insert({Type, ActivityId}, TempList);
                true ->
                    TempList
            end
        end, [], List).

%% @doc 获得 投资计划id列表 根据 类型
get_invest_task_id_list_by_type() ->
    List = ets:tab2list(t_tou_zi_ji_hua),
    Func =
        fun(Element, TmpList) ->
            #t_tou_zi_ji_hua{
                type_id = TypeId,
                id = Id
            } = Element,
            util_list:key_insert({TypeId, Id}, TmpList)
        end,
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- lists:foldl(Func, [], List)]).

%% @doc 获得 投资计划id列表 根据 类型
get_invest_task_type_list() ->
    List = ets:tab2list(t_tou_zi_ji_hua),
    Func =
        fun(Element) ->
            #t_tou_zi_ji_hua{
                type_id = TypeId
            } = Element,
            TypeId
        end,
    [{0, lists:usort(lists:map(Func, List))}].

get_function_monster_effect_by_type() ->
    List = ets:tab2list(t_monster_effect),
    Func =
        fun(Element, TmpList) ->
            #t_monster_effect{
                type = Type,
                skill_id = SkillId
            } = Element,
            util_list:key_insert({{Type}, SkillId}, TmpList)
        end,
    lists:sort([{Key, ValueRecord} || {Key, ValueRecord} <- lists:foldl(Func, [], List)]).

%% @doc 获得场景机器人
get_scene_robot_weights_list() ->
    List = ets:tab2list(t_robot),
    Func =
        fun(Element, TmpList) ->
            #t_robot{
                id = RobotId,
                weights = Weights,
                scene = SceneId
            } = Element,
            util_list:key_insert({SceneId, {RobotId, Weights}}, TmpList)
        end,
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- lists:foldl(Func, [], List)]).

%% @doc 获得图鉴目录列表 根据图鉴卡牌id
get_card_title_list_by_card_id() ->
    List = ets:tab2list(t_card_title),
    Func =
        fun(Element, TmpList) ->
            #t_card_title{
                card_title_id = CardTitleId,
                card_item_list = CardItemIdList
            } = Element,
            lists:foldl(
                fun(CardItemId, TmpL) ->
                    util_list:key_insert({CardItemId, CardTitleId}, TmpL)
                end,
                TmpList, CardItemIdList
            )
        end,
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- lists:foldl(Func, [], List)]).


%% @doc 通过国家/地区货币单货获取该国家/地区的名字（字符串，繁体中文或英文）
get_region_by_currency() ->
    List = ets:tab2list(t_platform),
    Func =
        fun(Ele, TmpList) ->
            #t_platform{currency = Currency, region = Region} = Ele,
            case lists:keyfind(Currency, 1, TmpList) of
                false -> util_list:key_insert({Currency, Region}, TmpList);
                {Currency, _} -> TmpList
            end
        end,
    lists:sort([{Key, lists:sort(Value)} || {Key, Value} <- lists:foldl(Func, [], List)]).

%% @doc 获得无尽对决权重列表
get_big_wheel_icon_weight_list() ->
    List = ets:tab2list(t_big_wheel_icon),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_big_wheel_icon{
                    big_wheel_type = WheelType,
                    type_id = TypeId,
                    id = Id,
                    weight = Weight
                } = Element,
                util_list:key_insert({WheelType, {{Id, TypeId}, Weight}}, TmpList)
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

%% @doc 获得无尽对决权重列表
get_big_wheel_bet_list() ->
    List = ets:tab2list(t_big_wheel),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_big_wheel{
                    big_wheel_type = WheelType,
                    odds_list = OddsList
                } = Element,
                lists:foldl(
                    fun([BetId, TypeRateList], TmpL) ->
                        lists:foldl(
                            fun([TypeId, Rate], TmpL1) ->
                                util_list:key_insert({{WheelType, TypeId}, {BetId, Rate}}, TmpL1)
                            end,
                            TmpL, TypeRateList
                        )
                    end,
                    TmpList, OddsList
                )
            end,
            [], List),
    lists:sort([{Key, lists:sort(ValueList)} || {Key, ValueList} <- SortList]).

get_bettle_skill_data() ->
    List = ets:tab2list(t_bettle),
    SortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_bettle{
                    scene = SceneId,
                    skill_list = SkillList
                } = Element,
                lists:foldl(
                    fun([SkillId, SkillTimes], TmpL) ->
                        [{{SceneId, SkillId}, SkillTimes} | TmpL]
                    end,
                    TmpList, SkillList
                )
            end,
            [], List),
    lists:sort(SortList).

get_wheel_type_or_unique_id_list() ->
    List = ets:tab2list(t_big_wheel_icon),
    IdSortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_big_wheel_icon{
                    big_wheel_type = BigWheelType,
                    type_id = TypeId
                } = Element,
                util_list:key_insert({BigWheelType, TypeId}, TmpList)
            end,
            [], List),
    TypeSortList =
        lists:foldl(
            fun(Element, TmpList) ->
                #t_big_wheel_icon{
                    big_wheel_type = BigWheelType,
                    leixing = LeiXing
                } = Element,
                util_list:key_insert({BigWheelType, LeiXing}, TmpList)
            end,
            [], List),
    [
        {id_list, lists:sort([{Key, lists:usort(ValueList)} || {Key, ValueList} <- IdSortList])},
        {type_list, lists:sort([{Key, lists:usort(ValueList)} || {Key, ValueList} <- TypeSortList])}
    ].