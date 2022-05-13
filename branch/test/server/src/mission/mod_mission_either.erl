%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         二选一副本
%%% @end
%%% Created : 22. 三月 2021 下午 05:31:23
%%%-------------------------------------------------------------------
-module(mod_mission_either).
-author("Administrator").

%%-include("msg.hrl").
-include("mission.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    either_either/2
]).

%% Handle
-export([
    handle_init_mission/1,
    handle_deal_cost/2,
    handle_enter_mission/1,
    handle_leave_mission/1,
    handle_balance/1,
    handle_either/2,
    handle_next_end/0,
    handle_timer/2
]).

-define(EITHER_PLAYER, either_player).      %% 选择副本玩家
-define(EITHER_COST, either_cost).          %% 选择副本消耗
-define(EITHER_AWARD, either_award).        %% 选择副本奖励
-define(EITHER_STATE, either_state).        %% 选择副本状态
-define(EITHER_END_TIME, either_end_time).  %% 选择副本结束时间
-define(EITHER_RESULT, either_result).      %% 选择副本结果
-define(EITHER_COST_TIMES, either_cost_times).  %% 选择副本怪物消耗次数

%% @doc 选择副本选择
either_either(PlayerId, EitherValue) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    SceneWorker ! {either_either, ?TRAN_INT_2_BOOL(EitherValue)}.

%% @doc 初始化副本
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Type, Value}) ->
            put(Type, Value)
        end, ExtraDataList),
    put(?EITHER_COST, 0),
    put(?EITHER_AWARD, 0),
    put(?EITHER_STATE, {0, 0}),
    put(?EITHER_RESULT, 0),
    put(?EITHER_COST_TIMES,[]),
    #t_mission_either_or{
        time_list = TimeList
    } = get_t_mission_either_or(get(?DICT_MISSION_ID)),
    AddTime = util_list:opt(0, TimeList),
    EndTime = util_time:timestamp() + AddTime,
    put(?EITHER_END_TIME, EndTime),
    mod_mission:send_msg_delay({?MSG_EITHER_TIMER, 0, 0}, AddTime * 1000).
%%    mission_ranking:clean_ranking(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dist(?DICT_MISSION_ID), util:get_dist(room_id)),
%%    mission_ranking:init(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dist(?DICT_MISSION_ID), util:get_dist(room_id)).

%% @doc 处理消耗
handle_deal_cost(DefObjId, Cost) ->
    {Round, _Type} = get(?EITHER_STATE),
    ?DEBUG("处理消耗~p", [{Cost, get(?EITHER_COST)}]),
    put(?EITHER_COST, get(?EITHER_COST) + Cost),
    if
        Round == 0 ->
            noop;
        true ->
            TimesList = get(?EITHER_COST_TIMES),
            case lists:keytake(DefObjId, 1, TimesList) of
                false ->
                    NewTimesList = [{DefObjId, 1} | TimesList],
                    put(?EITHER_COST_TIMES, NewTimesList);
                {value, {DefObjId, OldTimes}, TimesList2} ->
                    NewTimesList = [{DefObjId, OldTimes + 1} | TimesList2],
                    if
                        OldTimes >= 2 ->
                            put(?EITHER_COST_TIMES, []),
                            handle_next_end();
                        true ->
                            put(?EITHER_COST_TIMES, NewTimesList)
                    end
            end
    end.

%% @doc 进入副本
handle_enter_mission(PlayerId) ->
    put(?EITHER_PLAYER, PlayerId),
    {Round, Type} = get(?EITHER_STATE),
    AwardValue = get(?EITHER_AWARD),
    EndTime = get(?EITHER_END_TIME),
%%    put(?EITHER_PLAYER, PlayerId),
    api_mission:either_notice_state(PlayerId, Round, Type, AwardValue, EndTime).
%%    api_shi_shi_room:notice_shi_shi_value(PlayerId, TotalValue),
%%    mission_ranking:notice_ranking([PlayerId], ?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dist(?DICT_MISSION_ID), util:get_dist(room_id)).

%% @doc 选择副本选择是否继续
handle_either(IsNext, State) ->
    {Round, Type} = get(?EITHER_STATE),
    IsBalance = mod_mission:is_balance(),
    Award = get(?EITHER_AWARD),
    ?DEBUG("选择副本是否继续~p", [{Round, Type, IsBalance, Award}]),
    if
        Type =:= 1 andalso IsBalance =:= false ->
            if
                IsNext ->
                    #t_mission_either_or{
%%                        multiple_list = MultipleList,
                        time_list = TimeList,
                        box_list = [[A_X, A_Y], [B_X, B_Y]],
                        box_monster_list = [A_MonsterId, B_MonsterId]
                    } = get_t_mission_either_or(get(?DICT_MISSION_ID)),
%%                    ?DEBUG("参数~p", [{Award, util_list:opt(Round, MultipleList)}]),
%%                    NewAward = round(Award * util_list:opt(Round, MultipleList) / 10000),
                    NewRound = Round + 1,
%%                    put(?EITHER_AWARD, NewAward),
                    put(?EITHER_STATE, {NewRound, 0}),
                    %% 创建两个箱子
                    mod_scene_monster_manager:create_monster(A_MonsterId, A_X, A_Y, State),
                    mod_scene_monster_manager:create_monster(B_MonsterId, B_X, B_Y, State),
                    AddTime = util_list:opt(NewRound, TimeList),
                    EndTime = util_time:timestamp() + AddTime,
                    api_mission:either_notice_state(get(?EITHER_PLAYER), Round, 0, Award, EndTime),
                    mod_mission:send_msg_delay({?MSG_EITHER_TIMER, NewRound, 0}, AddTime * 1000);
                true ->
                    %% 自己离开
                    put(?EITHER_RESULT, 0),
                    mod_mission:send_msg(?MSG_MISSION_BALANCE)
            end;
        true ->
            noop
    end.

%% @doc 打怪阶段结束
handle_next_end() ->
    {Round, Type} = get(?EITHER_STATE),
    IsBalance = mod_mission:is_balance(),
    ?DEBUG("打怪阶段结束~p", [{Round, Type, IsBalance}]),
    if
        Type =:= 0 andalso IsBalance =:= false ->
            PlayerId = get(?EITHER_PLAYER),
            MissionId = get(?DICT_MISSION_ID),
            #t_mission_either_or{
%%                multiple_list = MultipleList,
%%                max_times = MaxTimes,
                random_list = [FirstMinRate, FirstMaxRate]
            } = get_t_mission_either_or(MissionId),
            MultipleList =[],
            MaxTimes = 1,
            Cost = get(?EITHER_COST),
            NewCost = 0,
            put(?EITHER_COST, NewCost),
            Award = get(?EITHER_AWARD),
            CurrTime = util_time:timestamp(),
            if
            %% 第0轮，不可能失败
                Round =:= 0 ->
                    RandomRate = util_random:random_number(FirstMinRate, FirstMaxRate),
                    NewAward = round(Cost * RandomRate / 10000),
                    put(?EITHER_AWARD, NewAward),
                    NewType = 1,
                    put(?EITHER_STATE, {Round, NewType}),
                    EndTime = CurrTime + 10,
                    api_mission:either_notice_state(PlayerId, Round, NewType, NewAward, EndTime),
                    mod_mission:send_msg_delay({?MSG_EITHER_TIMER, Round, NewType}, 10 * 1000);
            %% 后面的轮，可能会失败
                true ->
                    IsNext = ?IF(Round =:= 0, true, util_random:p(5000)),
                    if
                    %% 成功
                        IsNext ->
                            ?DEBUG("选成功了"),
                            NewType = 1,
                            NewAward = round((Award + Cost) * util_list:opt(Round, MultipleList) / 10000),
                            put(?EITHER_AWARD, NewAward),
                            if
                                Round =:= MaxTimes ->
                                    %% 通关
                                    put(?EITHER_RESULT, 3),
                                    mod_mission:send_msg(?MSG_MISSION_BALANCE);
                                true ->
                                    put(?EITHER_STATE, {Round, NewType}),
                                    EndTime = CurrTime + 10,
                                    api_mission:either_notice_state(PlayerId, Round, NewType, NewAward, EndTime),
                                    mod_mission:send_msg_delay({?MSG_EITHER_TIMER, Round, NewType}, 10 * 1000)
                            end;
                    %% 失败
                        true ->
                            ?DEBUG("选失败了"),
                            NewAward = 0,
                            put(?EITHER_AWARD, NewAward),
                            %% 猜错了
                            put(?EITHER_RESULT, 1),
                            mod_mission:send_msg(?MSG_MISSION_BALANCE)
                    end
            end,
            mod_scene_monster_manager:destroy_all_monster();
        true ->
            noop
    end.

%% @doc 定时器回调
handle_timer(OldRound, OldType) ->
    {Round, Type} = get(?EITHER_STATE),
    IsBalance = mod_mission:is_balance(),
    ?DEBUG("定时器回调~p", [{OldRound, OldType, Round, Type, IsBalance}]),
    if
        IsBalance =:= false andalso Round =:= OldRound andalso Type =:= OldType ->
            Award = get(?EITHER_AWARD),
            NewAward = round(Award / 2),
            put(?EITHER_AWARD, NewAward),
            put(?EITHER_RESULT, 2),
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        true ->
            noop
    end.

%% @doc 玩家离开副本
handle_leave_mission(_PlayerId) ->
    ?DEBUG("玩家离开副本~p", [_PlayerId]),
    case mod_mission:is_balance() of
        false ->
%%            {Round, Type} = get(?EITHER_STATE),
            Award = get(?EITHER_AWARD),
            NewAward = round(Award / 2),
            put(?EITHER_AWARD, NewAward),
            put(?EITHER_RESULT, 0),
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        true ->
            noop
    end.

%% @doc 副本结算
handle_balance(_) ->
    ?DEBUG("二选一副本结算"),
    Result = get(?EITHER_RESULT),
    AwardValue = get(?EITHER_AWARD),
    ?DEBUG("二选一副本结算 ,~p", [{Result, AwardValue}]),
    api_mission:either_notice_result(get(?EITHER_PLAYER), Result, AwardValue),
    ?IF(AwardValue > 0, mod_apply:apply_to_online_player(get(?EITHER_PLAYER), mod_award, give, [get(?EITHER_PLAYER), [{?ITEM_GOLD, AwardValue}], ?LOG_TYPE_MISSION_EITHER_OR], game_worker), noop),
    ?DEBUG("关闭场景"),
    scene_worker:stop(self(), 10 * ?SECOND_MS).

%% ================================================ 模板操作 ================================================

%% @doc 获得二选一副本表
get_t_mission_either_or(MissionId) ->
    t_mission_either_or:assert_get({MissionId}).
