%%%%%-------------------------------------------------------------------
%%%%% @author
%%%%% @copyright (C) 2016,
%%%%% @doc            时时副本
%%%%% @end
%%%%% Created : 14. 六月 2016 下午 3:34
%%%%%-------------------------------------------------------------------
-module(mod_mission_shi_shi).

-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("mission.hrl").
-include("p_message.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    handle_enter_mission/2,             % 进入副本
    handle_init_mission/1,              % 初始化副本
    handle_deal_cost/3,                 % 处理消耗
    handle_destroy_all_monster/0,       % 销毁所有怪物
    handle_balance_single/1,            % 时时副本小结算
    handle_assert_fight/1,              % 校验战斗
    handle_robot/0                      % 机器人
]).

-export([
%%    init/0,                             % 初始活动时验证是否创建场景
    notice_shi_shi_value/0,             % 通知时时副本的值
    open_mission/0,
%%    open_action/1,                      % 活动开始 创建boss
%%    close_action/1,                     % 活动结束 调用boss结算
    is_enter_mission/2                  % 是否能进入副本
]).

%%-export([
%%    get_cost_mana/1
%%]).

-define(MISSION_SHI_SHI_TOTAL_VALUE, mission_shi_shi_total_value).          % 时时副本总值
-define(MISSION_SHI_SHI_STEP, mission_shi_shi_step).                        % 时时副本阶段
-define(MISSION_SHI_SHI_NEXT_STEP_TIME, mission_shi_shi_next_step_time).    % 时时副下阶段时间
-define(NOTICE_SHI_SHI_VALUE_TIME_MS, 500).                                 % 通知时时总值时间

%% @fun 初始活动时验证是否创建场景
%%init() ->
%%    ActivityIdList = lists:filter(
%%        fun(ActivityId) ->
%%            mod_activity:is_open(ActivityId)
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)
%%    ),
%%    Length = length(ActivityIdList),
%%    if
%%        Length > 0 ->
%%            open_action(hd(ActivityIdList));
%%        true ->
%%            noop
%%    end,
%%    ok.

%%%% @fun 活动开始时时副本
%%open_action(Id) ->
%%    ?INFO("活动开始时时副本 ~p~n", [Id]),
%%    {MissionId, SceneId} = get_mission_scene_id_By_ActivityId(Id),
%%    {ActivityOpenTime, ActivityCloseTime} = mod_activity:get_activity_start_and_end_time(Id),
%%    BigRoundTime = lists:sum([Time || [Time | _] <- ?SD_SHISHI_REWARLD_LIST]),
%%    CurrTime = util_time:timestamp(),
%%    if
%%        ActivityCloseTime > CurrTime + (BigRoundTime div ?SECOND_MS) ->
%%            scene_master:create_mulit_mission_worker(SceneId,
%%                [
%%                    {mission_id, MissionId},
%%                    {?DICT_ACTIVITY_ID, Id},
%%                    {?DICT_ACTIVITY_START_TIME, ActivityOpenTime},
%%                    {?DICT_ACTIVITY_CLOSE_TIME, ActivityCloseTime}
%%                ]
%%            );
%%        true ->
%%            activity_srv_mod:gm_close_activity(util:get_dist(Id))
%%    end.

%% @fun 活动开始时时副本
open_mission() ->
    MissionIdList = logic_get_all_mission_id_by_mission_type:assert_get(?MISSION_TYPE_SHISHI_BOSS),
    lists:foreach(
        fun(MissionId) ->
            SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_SHISHI_BOSS, MissionId),
            scene_master:create_mulit_mission_worker(SceneId,
                [
                    {mission_id, MissionId}
                ]
            )
        end,
        MissionIdList
    ),
    ok.
%% @fun 活动结束调用时时副本结算
%%close_action({ActivityId, _ActivityStartTime}) ->
%%    ?DEBUG("时时副本结算~p", [ActivityId]),
%%    ActivityIdList = lists:filter(
%%        fun(ThisActivityId) ->
%%            mod_activity:is_open(ThisActivityId) andalso ThisActivityId =:= ActivityId
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)
%%    ),
%%    Length = length(ActivityIdList),
%%    if
%%        Length > 0 ->
%%            noop;
%%        true ->
%%            {_, SceneId} = get_mission_scene_id_By_ActivityId(ActivityId),
%%            case scene_master:get_scene_worker(SceneId) of
%%                {ok, SceneWorker} ->
%%                    scene_worker:stop(SceneWorker, ?SCENE_STOP_TIME);
%%%%            mod_mission:send_msg(SceneWorker, ?MSG_MISSION_BALANCE);
%%                _ ->
%%                    noop
%%            end
%%    end.

handle_assert_fight(SkillId0) ->
    ?ASSERT(SkillId0 =/= ?ACTIVE_SKILL_4 andalso SkillId0 =/= ?ACTIVE_SKILL_5),
    ?ASSERT(get(shi_shi_is_fight) =/= false).

%% ----------------------------------
%% @doc 	初始化副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Key, Value}) ->
            put(Key, Value)
        end,
        ExtraDataList
    ),
    [Time, _Rate, InitStep] = hd(?SD_SHISHI_REWARLD_LIST),
    mod_mission:send_msg_delay(shi_shi_single_settle, Time),
    put(?MISSION_SHI_SHI_STEP, InitStep),
    put(?MISSION_SHI_SHI_NEXT_STEP_TIME, util_time:timestamp() + (Time div ?SECOND_MS)),
    is_next_click_refresh(false),
    mission_ranking:init(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), 1),

    init_robot().


%% ----------------------------------
%% @doc 	进入副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_enter_mission(PlayerId, _State) ->
    TotalValue = util:get_dict(?MISSION_SHI_SHI_TOTAL_VALUE, 0),
    NextStepTime = util:get_dict(?MISSION_SHI_SHI_NEXT_STEP_TIME),
    Step = util:get_dict(?MISSION_SHI_SHI_STEP),
    ?DEBUG("玩家进入场景~p", [{PlayerId, Step, NextStepTime, TotalValue}]),
    api_mission:notice_shi_shi_time(PlayerId, Step, NextStepTime, TotalValue),
    mission_ranking:notice_ranking([PlayerId], ?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), 1),

    mod_robot_player_scene_cache:update(?GET_OBJ_SCENE_PLAYER(PlayerId)).

%% @doc 通知时时副本的值(实时通知)
notice_shi_shi_value(NewValue) ->
    put(?MISSION_SHI_SHI_TOTAL_VALUE, NewValue),
    lists:foreach(
        fun(PlayerId) ->
            api_mission:notice_shi_shi_value(PlayerId, NewValue)
        end, mod_scene_player_manager:get_all_obj_scene_player_id()),
    is_next_click_refresh(false).
notice_shi_shi_value() ->
    TotalValue = util:get_dict(?MISSION_SHI_SHI_TOTAL_VALUE, 0),
    lists:foreach(
        fun(PlayerId) ->
            api_mission:notice_shi_shi_value(PlayerId, TotalValue)
        end, mod_scene_player_manager:get_all_obj_scene_player_id()),
    is_next_click_refresh(false).

%% @doc 处理消耗
handle_deal_cost(AttObjId, AttNickName, Cost) ->
    mission_ranking:update_hurt(1, AttObjId, AttNickName, Cost),
    OldTotalValue = util:get_dict(?MISSION_SHI_SHI_TOTAL_VALUE, 0),
    NewTotalValue = OldTotalValue + trunc(Cost * ?SD_SHISHI_RATE div ?PROP_NUM_10000),
    mod_log:add_mission_cost(AttObjId, Cost),
    if
        NewTotalValue =/= OldTotalValue ->
            handle_deal_cost(NewTotalValue);
        true ->
            noop
    end.
handle_deal_cost(Cost) ->
    put(?MISSION_SHI_SHI_TOTAL_VALUE, Cost),
    case is_need_refresh() of
        true ->
            noop;
        false ->
            is_next_click_refresh(true),
            mod_mission:send_msg_delay(notice_shi_shi_value, ?NOTICE_SHI_SHI_VALUE_TIME_MS)
    end.

%% ----------------------------------
%% @doc 	设置下一个心跳是否刷新排行榜
%% @throws 	none
%% @end
%% ----------------------------------
is_next_click_refresh(Bool) ->
    put(mission_shishi_is_need_refresh, Bool).

is_need_refresh() ->
    get(mission_shishi_is_need_refresh).

%% ----------------------------------
%% @doc 	销毁所有怪物
%% @throws 	none
%% @end
%% ----------------------------------
handle_destroy_all_monster() ->
    erase(shi_shi_is_fight),
    mod_scene_monster_manager:destroy_all_monster().    % 销毁所有怪物

%% ----------------------------------
%% @doc 	时时副本小结算
%% @throws 	none
%% @end
%% ----------------------------------
handle_balance_single(State) ->
    Step = util:get_dict(?MISSION_SHI_SHI_STEP),
%%    BigRoundTime = lists:sum([Time || [Time | _] <- ?SD_SHISHI_REWARLD_LIST]),
    NextStep =
        if
            Step =< 0 ->
%%                       CurrTime = util_time:timestamp(),
%%                       ActivityCloseTime = util:get_dist(?DICT_ACTIVITY_CLOSE_TIME),
%%                       if
%%                           CurrTime + (BigRoundTime div ?SECOND_MS) > ActivityCloseTime ->
%%                               -1;
%%                           true ->
                [_, _, FirstStep] = hd(?SD_SHISHI_REWARLD_LIST),
                FirstStep;
%%                       end;
            true ->
                Step - 1
        end,
%%    if
%%        NextStep =< -1 ->
%%            activity_srv_mod:gm_close_activity(util:get_dist(?DICT_ACTIVITY_ID)),
%%            put(?MISSION_SHI_SHI_STEP, -1),
%%            put(?MISSION_SHI_SHI_NEXT_STEP_TIME, 0);
%%        true ->
    [NextSleepTime, _Rate, NextStep] = get_step_data(NextStep),
    mod_mission:send_msg_delay(shi_shi_single_settle, NextSleepTime),
    put(?MISSION_SHI_SHI_STEP, NextStep),
    NextTime1 = util_time:timestamp() + (NextSleepTime div ?SECOND_MS),
    put(?MISSION_SHI_SHI_NEXT_STEP_TIME, NextTime1),
%%            NextTime1,
%%    end,
    settle_mission_win_player(Step, State).

settle_mission_win_player(1, _State) ->
    put(shi_shi_is_fight, false),        %% 需求，结算两秒后再销毁怪物，这期间不能让怪能被打
    mod_mission:send_msg_delay(shi_shi_destroy_all_monster, 2000),
    settle_mission_win_player(1),
    notice_shi_shi_value(0),            %% 清除累计积分
    put(last_win_player_list, []),      %% 清除小奖列表
    mission_ranking:clean_ranking(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), 1),
    mission_ranking:notice_ranking(mod_scene_player_manager:get_all_obj_scene_player_id(), ?MISSION_TYPE_SHISHI_BOSS, 1, 1),    %% 重置排行
    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), ?LOG_TYPE_SHISHI_BOSS));
settle_mission_win_player(0, State) ->
    #t_mission{
        scene_id = SceneId
    } = mod_mission:get_t_mission(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID)),
    SceneMonsterIdList = scene_data:get_scene_monster_id_list(SceneId),
    mod_scene_monster_manager:create_monster_list(SceneMonsterIdList, State),   % 创建所有怪物
    init_robot(),
    settle_mission_win_player(0),
    mission_ranking:handle_refresh_ranking(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), 1);
settle_mission_win_player(Step, _State) ->
    settle_mission_win_player(Step).
settle_mission_win_player(Step) ->
    [_NextTime, Rate, Step] = get_step_data(Step),
    RankingList = mission_ranking:get_ranking_list(?MISSION_TYPE_SHISHI_BOSS, get(?DICT_MISSION_ID), 1),
    NextTime = util:get_dict(?MISSION_SHI_SHI_NEXT_STEP_TIME),
    NextStep = util:get_dict(?MISSION_SHI_SHI_STEP),
    if
        RankingList =:= [] ->
            lists:foreach(
                fun(ThisPlayerId) ->
                    api_mission:notice_shi_shi_settle(ThisPlayerId, 0, <<>>, 0, NextStep, Step, NextTime, ?UNDEFINED)
                end,
                mod_scene_player_manager:get_all_obj_scene_player_id()
            );
        true ->
            RateList = [{CurrPlayerId, CurrHurt} || #hurtranking{player_id = CurrPlayerId, hurt = CurrHurt} <- RankingList],
            WinPlayerId = util_random:get_probability_item(RateList),
            #hurtranking{
                player_name = WinPlayerName
            } = lists:keyfind(WinPlayerId, #hurtranking.player_id, RankingList),

%%            ?DEBUG("查看时时彩，伤害排行和，胜利玩家 ~p", [{RankingList, WinPlayerId, WinPlayerName}]),

            TotalValue = util:get_dict(?MISSION_SHI_SHI_TOTAL_VALUE, 0),

            CalcValue = erlang:trunc(TotalValue * Rate div ?PROP_NUM_10000),

            case get(?DICT_SCENE_COST_PROP_ID) of
                ?ITEM_GOLD ->
                    chat_notice:shi_shi_cai_gold(WinPlayerName, CalcValue);
                ?ITEM_RUCHANGJUAN ->
                    chat_notice:shi_shi_cai_red_gem(WinPlayerName, CalcValue)
            end,

            ?IF(Step >= 2, put(last_win_player_list, [{WinPlayerName, CalcValue} | util:get_dict(last_win_player_list, [])]), noop),

            WinAwardList = [{get(?DICT_SCENE_COST_PROP_ID), CalcValue}],
            notice_shi_shi_value(TotalValue - CalcValue),

            MailId = ?MAIL_SHISHI_MISSION_MAIL,
            LogType = ?LOG_TYPE_SHISHI_BOSS,

            if
                WinPlayerId >= 10000 ->
                    mod_log:add_mission_award(WinPlayerId, CalcValue),
                    WinNode = mod_player:get_game_node(WinPlayerId),
                    mod_apply:apply_to_online_player(WinNode, WinPlayerId, mod_conditions, add_conditions, [WinPlayerId, {?CON_ENUM_SHISHI_BOSS_WIN, ?CONDITIONS_VALUE_ADD, 1}], store),
                    case ?GET_OBJ_SCENE_PLAYER(WinPlayerId) of
                        ?UNDEFINED ->
                            mod_apply:apply_to_online_player(WinNode, WinPlayerId, mod_mail, add_mail_item_list, [WinPlayerId, MailId, WinAwardList, LogType], game_worker);
                        _ObjScenePlayer ->
                            mod_apply:apply_to_online_player(WinNode, WinPlayerId, mod_award, give, [WinPlayerId, WinAwardList, LogType], game_worker)
                    end;
                true ->
                    noop
            end,
            lists:foreach(
                fun(ThisPlayerId) ->
                    PlayerTotalCost =
%%                        if
%%                            Step =:= 1 ->
                    util_list:opt(ThisPlayerId, RateList),
%%                            true ->
%%                                ?UNDEFINED
%%                        end,
%%                    ?DEBUG("debug WinPlayerName: ~p", [{WinPlayerName, is_binary(WinPlayerName)}]),
                    api_mission:notice_shi_shi_settle(ThisPlayerId, WinPlayerId, list_to_binary(WinPlayerName), CalcValue, NextStep, Step, NextTime, PlayerTotalCost)
                end,
                mod_scene_player_manager:get_all_obj_scene_player_id()
            ),
            NoticeId =
                if
                    Step > 1 ->
                        case get(?DICT_SCENE_COST_PROP_ID) of
                            ?ITEM_GOLD ->
                                ?NOTICE_SHISHI_MISSION_NOTICE_1;
                            ?ITEM_RUCHANGJUAN ->
                                ?NOTICE_SHISHI_MISSION_NOTICE_3
                        end;
                    Step =:= 1 ->
                        case get(?DICT_SCENE_COST_PROP_ID) of
                            ?ITEM_GOLD ->
                                ?NOTICE_SHISHI_MISSION_NOTICE_2;
                            ?ITEM_RUCHANGJUAN ->
                                ?NOTICE_SHISHI_MISSION_NOTICE_4
                        end;
                    true ->
                        ?WARNING("不应该出现的错误")
                end,
            #t_notice{
                notice_type = NoticeType
            } = t_notice:assert_get({NoticeId}),
%%            ArgList = [util_string:string_to_binary(WinPlayerName), util:to_binary(CalcValue)],
            ArgList = [list_to_binary(WinPlayerName), util:to_binary(CalcValue)],
            api_chat:notice_system_template_message(NoticeId, ArgList, NoticeType)
%%            ?INFO("结算副本数据:~p ~p~n", [util_time:local_datetime(), {WinNode, WinPlayerId, {TotalValue, -CalcValue}, WinAwardList}])
    end.

%%% 获得阶段数据
%%get_step_data() ->
%%    Step = util:get_dist(?MISSION_SHI_SHI_STEP),
%%    get_step_data(Step).
get_step_data(Step) ->
    get_step_data(Step, ?SD_SHISHI_REWARLD_LIST).
get_step_data(Step, [[StepTime, Rate, Step] | _L]) ->
    [StepTime, Rate, Step];
get_step_data(_Step, []) ->
    [];
get_step_data(Step, [_ | L]) ->
    get_step_data(Step, L).

%% @fun 根据活动id获得副本场景id
%%get_mission_scene_id_By_ActivityId(_ActivityId) ->
%%    MissionId = 1,
%%    {MissionId, get_mission_scene_id(MissionId)}.
get_mission_scene_id(MissionId) ->
    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_SHISHI_BOSS, MissionId),
    SceneId.

%% @fun 是否能进入副本
is_enter_mission(_PlayerId, MissionId) ->
%%    ?ASSERT(
%%        lists:any(
%%        fun(ActivityId) ->
%%            mod_activity:is_open(PlayerId, ActivityId)
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)), ?ERROR_ACTIVITY_NO_OPEN),
    SceneId = get_mission_scene_id(MissionId),
    case scene_master:get_scene_worker(SceneId) of
        {ok, SceneWorker} ->
            KeyValue = scene_worker:get_dict(SceneWorker, ?DICT_KILL_DIE_LAST),
            ?ASSERT(is_integer(KeyValue) == false, ?ERROR_NOT_ONLINE);
        _ ->
            ?ERROR("时时副本异常未开启"),
            exit(?ERROR_NOT_ONLINE)
    end.

%%init_robot() ->
%%    noop.

init_robot() ->
    RobotBirthTimeList = ?SD_SHISHI_ROBOT_BIRTH_TIME,
    BirthTimeList = lists:sort(lists:foldl(
        fun([TimeA, TimeB, TimesA, TimesB], TmpL) ->
            Times = util_random:random_number(TimesA, TimesB),
            if
                Times > 0 ->
                    TimeList =
                        lists:map(
                            fun(_) ->
                                util_random:random_number(TimeA, TimeB)
                            end,
                            lists:seq(1, Times)
                        ),
                    TimeList ++ TmpL;
                true ->
                    TmpL
            end
        end,
        [], RobotBirthTimeList
    )),
    lists:foreach(
        fun(BirthTime) ->
%%            NewBirthTime =
%%                if
%%                    BirthTime < 50 ->
%%                        util_random:random_number(50, 100);
%%                    true ->
%%                        BirthTime
%%                end,
            mod_mission:send_msg_delay(?MSG_SHI_SHI_MISSION_ROBOT, BirthTime)
        end,
        BirthTimeList
    ).

handle_robot() ->
    List = mod_scene_player_manager:get_all_obj_scene_player(),
    PlayerNum = length([ObjSceneActor || ObjSceneActor = #obj_scene_actor{is_robot = IsRobot} <- List, IsRobot =:= false]),
    RobotNum = length([ObjSceneActor || ObjSceneActor = #obj_scene_actor{is_robot = IsRobot} <- List, IsRobot]),
    RobotNumLimit = util_list:get_value_from_range_list(PlayerNum, ?SD_SHISHI_ROBOT_PLAYER_NUM),
    if
        RobotNum < RobotNumLimit ->
            RobotId = util:get_dict(shi_shi_scene_robot_id, 1),
            put(shi_shi_scene_robot_id, ?IF(RobotId > 5000, 1, RobotId + 1)),
            DelayTime = get_delay_time(),
            {FightTime, StayTime} = get_stay_time(),
            TimesMs = util_time:milli_timestamp(),
            mod_scene_robot_manager:create_robot(RobotId, DelayTime, TimesMs + FightTime, TimesMs + FightTime + StayTime);
        true ->
            noop
    end,
    ok.

%% @doc 机器人创建发呆时间
%% @doc 实时彩机器人创建发呆时间[[时间下限,时间上限,概率]..]
get_delay_time() ->
    List = [{{_TimeMin, _TimeMax}, P} || [_TimeMin, _TimeMax, P] <- ?SD_SHISHI_ROBOT_DELAY_TIME],
    {TimeMin, TimeMax} = util_random:get_probability_item(List),
    util_random:random_number(TimeMin, TimeMax).

%% @doc 实时彩机器人时间
%% @doc [[战斗时间下限,战斗时间上限,发呆时间下限,发呆时间上限,概率],…]
get_stay_time() ->
    List = [{{_FightTimeMin, _FightTimeMax, _StayTimeMin, _StayTimeMax}, P} || [_FightTimeMin, _FightTimeMax, _StayTimeMin, _StayTimeMax, P] <- ?SD_SHISHI_ROBOT_STAY_TIME],
    {FightTimeMin, FightTimeMax, StayTimeMin, StayTimeMax} = util_random:get_probability_item(List),
    FightTime = util_random:random_number(FightTimeMin, FightTimeMax),
    StayTime = util_random:random_number(StayTimeMin, StayTimeMax),
    {FightTime, StayTime}.

%%get_cost_mana(Mana) ->
%%%%    MissionType = ?MISSION_TYPE_SHISHI_BOSS,
%%%%    MissionId = 1,
%%%%    #t_mission{
%%%%        mana_attack_list = ManaAttackList
%%%%    } = mod_mission:get_t_mission(MissionType, MissionId),
%%%%    [Mana, _] = ManaAttackList,
%%
%%    Rate = util_random:get_probability_item(?SD_SHISHI_ROBOT_MANA_MULTIPLE),
%%    {Mana * Rate, Rate}.
