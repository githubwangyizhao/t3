%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 23. 一月 2018 17:52
%%%-------------------------------------------------------------------
-module(mod_conditions).
-author("home").

%% API
-export([
    add_conditions/2,                       %% 条件添加对应数据
    add_conditions1/2,                      %% 条件添加对应数据(直接处理)
    restart_conditions_data/2,              %% 重置条件数据
%%    add_conditions_mission/3,               %% 副本条件添加对应数据
%%    clean_player_conditions_data/3,         %% 玩家条件清除
    get_player_conditions_data_number/2,    %% 获得对应的数据
    get_player_conditions_record/2,         %% 获得条件数据记录
    is_player_conditions_state/2,           %% 玩家是否满足条件
    is_conditions_state/2,                  %% 玩家是否满足条件
    is_condition_add/1,                     % 条件是否为增加方式
    test_fun_change/3,
    get_conditions_id/1,
    get_conditions_list/2,
    get_player_condition_activity/2,
    add_player_join_activity_condition/3      %% 判断是否增加玩家活动条件
]).

%% @fun 修复条件
-export([
]).

-include("error.hrl").
-include("client.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% @doc 条件添加对应数据
add_conditions(PlayerId, {Param, Type, Value}) ->
    case get(?DICT_PLAYER_ID) == PlayerId of
        true ->
            add_conditions1(PlayerId, {Param, Type, Value});
        _ ->
            mod_apply:apply_to_online_player(PlayerId, ?MODULE, add_conditions1, [PlayerId, {Param, Type, Value}], store)
    end.

add_conditions1(PlayerId, {Param, Type, Value}) ->
    {ConditionsId, ParamType, ParamType2} = get_conditions_id(Param),
    InitConditions = get_player_conditions_data_init(PlayerId, ParamType, ParamType2, ConditionsId),
    #db_player_conditions_data{
        count = OldValue,
        change_time = OldChangeTime
    } = InitConditions,
    OldState = true,
    {NewState, NewValue} =
        case Type of
            ?CONDITIONS_VALUE_ADD ->
                {OldState, OldValue + Value};
            ?CONDITIONS_VALUE_DECREASE ->
                V1 = OldValue - Value,
                ?ASSERT(V1 >= 0, ?ERROR_NOT_ENOUGH_NUMBER),
                {OldState, V1};
            ?CONDITIONS_VALUE_SET ->
                {OldState, Value};
            ?CONDITIONS_VALUE_SET_MAX ->
                {OldValue < Value, Value};
            ?CONDITIONS_VALUE_SET_MIN ->
                {Value > 0 andalso ?IF(OldValue > 0, OldValue > Value, true), Value};
            ?CONDITIONS_VALUE_NOT_SAME_DAY_ADD ->
                {util_time:is_today(OldChangeTime) == false, OldValue + Value}
        end,
    if
        NewState == true ->
            CurrTime = util_time:timestamp(),
            % 功能
            FunctionList = case logic_get_conditions_function_list(Param) of
                               FunctionList1 when is_list(FunctionList1) ->
                                   get_conditions_list(FunctionList1, NewValue);
                               _ ->
                                   []
                           end,
            % 成就
            AchievementList = logic_get_conditions_achievement_list(Param),
            % 每日任务
            DailyTaskIdList = logic_get_conditions_daily_task_list:get(Param, []),
            % 任务
            TaskList = logic_get_conditions_task_list:get(Param, []),
            % 投资计划
            InvestList = logic_get_conditions_invest_list:get(Param, []),
            % 分享任务类型
            ShareTaskList = logic_get_conditions_share_task_list:get(Param, []),
%%            IndividualRedConditionIdList = logic_get_conditions_individual_red_packet_id_list(Param),
%%            RedConditionIdList = logic_get_conditions_red_packet_id_list(Param),
            %% 通行证任务列表
            TxzDailyTaskList = logic_get_condition_txz_daily_task_list:get(Param, []),
            TxzId = mod_tongxingzheng:get_player_txz_id(PlayerId),
            TxzTaskType = mod_tongxingzheng:get_cfg_tongxingzheng_task_type(TxzId),
            TxzTaskList = logic_get_condition_txz_task_list:get({TxzTaskType, Param}, []),
            %% 场景事件任务
            SceneEventTaskList = logic_get_condition_monster_function_task_list:get(Param, []),
            %% 赏金任务
            BountyTaskList = logic_get_condition_bounty_task_list:get(Param, []),

            Tran =
                fun() ->
                    if
                        OldValue == NewValue ->
                            ok;
                        true ->
                            db:write(InitConditions#db_player_conditions_data{count = NewValue, change_time = CurrTime})
                    end,
                    mod_function:active_function(PlayerId, FunctionList),                   % 激活功能
                    mod_achievement:update_achievement_type_condition(PlayerId, AchievementList, NewValue),
                    mod_daily_task:trigger_task(PlayerId, DailyTaskIdList, NewValue - OldValue),
                    mod_task:try_update_player_task(PlayerId, TaskList, {Type, Value}),
                    mod_platform_function:add_share(PlayerId, ShareTaskList, NewValue),
                    mod_invest:condition_update(PlayerId, InvestList, {Type, Value}),
%%                    mod_red_packet:add_send_individual_red(PlayerId, IndividualRedConditionIdList, Value),
%%                    mod_red_packet:add_red_packet_condition(RedConditionIdList, Value),
                    mod_tongxingzheng:trigger_task_daily(PlayerId, TxzDailyTaskList, Value),
                    mod_tongxingzheng:trigger_task_month(PlayerId, TxzTaskList, Value),
                    mod_scene_event_manager:trigger_task(PlayerId, SceneEventTaskList, Value),
                    mod_bounty_task:try_update_player_task(PlayerId, BountyTaskList, {Type, Value})
                end,
            db:do(Tran),
            ok;
        true ->
            noop
    end.

%% 判断是否增加玩家活动条件
add_player_join_activity_condition(PlayerId, ActivityId, ConditionStr) ->
    {State, {StartTime, _}} = activity:get_activity_state_and_time_range(ActivityId),
%%    {StartTime, _EndTime} = mod_activity:get_activity_start_and_end_time(ActivityId),
    if
        State == true ->
            ConditionData = get_player_condition_activity_init(PlayerId, ActivityId),
            ActivityTime = ConditionData#db_player_condition_activity.activity_time,
            if
                StartTime =/= ActivityTime ->
                    Tran =
                        fun() ->
                            db:write(ConditionData#db_player_condition_activity{activity_time = StartTime, change_time = util_time:timestamp()}),
                            add_conditions(PlayerId, {ConditionStr, ?CONDITIONS_VALUE_ADD, 1})
                        end,
                    db:do(Tran),
                    ok;
                true ->
                    noop
            end;
        true ->
            noop
    end.

%%
%%%% @doc     副本条件添加对应数据
%%add_conditions_mission(PlayerId, Param, MissionId) ->
%%% 成就
%%    AchievementList = case logic_get_conditions_achievement_list(Param) of
%%                          AchievementList1 when is_list(AchievementList1) ->
%%                              get_conditions_list(AchievementList1, MissionId);
%%                          _ ->
%%                              []
%%                      end,
%%    % 开服目标
%%    OpenServiceTargetList = case logic_get_open_service_target_list(Param) of
%%                                OpenServiceTargetList1 when is_list(OpenServiceTargetList1) ->
%%                                    get_conditions_list(OpenServiceTargetList1, MissionId);
%%                                _ ->
%%                                    []
%%                            end,
%%    % 充值活动条件列表
%%    ChargeActivityList = case logic_get_conditions_charge_activity_type_list(Param) of
%%                             ChargeActivityList1 when is_list(ChargeActivityList1) ->
%%                                 ChargeActivityList1;
%%                             _ ->
%%                                 Param
%%                         end,
%%    % 排行榜
%%    RankId = case logic_get_conditions_rank_fun_id(Param) of
%%                 RankId1 when is_integer(RankId1) ->
%%                     RankId1;
%%                 _ ->
%%                     0
%%             end,
%%    CurrTime = util_time:timestamp(),
%%
%%    Tran =
%%        fun() ->
%%%%            mod_time_limit_task:add_conditions(PlayerId, TimeLimitTaskList),
%%            mod_achievement:add_achievement(PlayerId, AchievementList, CurrTime),
%%            mod_charge_activity:add_conditions(PlayerId, ChargeActivityList, MissionId, CurrTime),
%%            mod_rank:enter_rank(PlayerId, RankId, MissionId),
%%            mod_service_goals:add_service_goal_value(PlayerId, OpenServiceTargetList, CurrTime)
%%        end,
%%    db:do(Tran).


% 获得满足条件的列表和之前 的列表 (防止值跳过中间的问题)
get_conditions_list(List, Value) ->
    get_conditions_list(List, Value, []).
get_conditions_list([], _Value, L) ->
    L;
get_conditions_list([Tuple | List], Value, L) ->
    {ValueKey, ValueKeyList} = change_to_tuple(Tuple),
%%	List1 =
%%		case ValueKey of
%%			[InitNum, Limit] ->
%%				if
%%					InitNum >= Limit andalso
%%						(Limit == 0 andalso InitNum =< Value  % 最后一组
%%							orelse Limit > 0 andalso InitNum >= Value andalso Value >= Limit) % 排名条件
%%						orelse InitNum < Limit andalso Limit =< Value       % 当前之前的条件
%%						orelse InitNum =< Value andalso Value =< Limit      % 满足的条件
%%						->
%%						ValueKeyList;
%%					true ->
%%						[]
%%				end;
%%			Value ->
%%				ValueKeyList;
%%			_ ->
%%				[]
%%		end,
    List1 =
        case is_conditions_state(ValueKey, Value) of
            true ->
                ValueKeyList;
            _ ->
                []
        end,
    get_conditions_list(List, Value, List1 ++ L).

%% @doc     玩家是否满足条件 ConditionsEnum:条件枚举; Tuple:比较条件
is_player_conditions_state(_PlayerId, []) ->
    true;
is_player_conditions_state(PlayerId, [ConditionsEnum, ConditionsEnum1, Tuple]) ->
    is_player_conditions_state(PlayerId, [{ConditionsEnum, ConditionsEnum1}, Tuple]);
is_player_conditions_state(PlayerId, [ConditionsEnum, Tuple]) ->
    Value = get_player_conditions_data_number(PlayerId, ConditionsEnum),
    is_conditions_state(Tuple, Value).

%% @fun 是否满足条件
is_conditions_state(Tuple, Value) ->
    case Tuple of
        [InitNum, Limit] ->
            if
                InitNum >= Limit andalso
                    (Limit == 0 andalso InitNum =< Value  % 最后一组
                        orelse Limit > 0 andalso InitNum >= Value andalso Value >= Limit) % 排名条件
%%                    orelse InitNum < Limit andalso Limit =< Value       % 当前之前的条件
                    orelse InitNum =< Value andalso Value =< Limit      % 满足的条件
                    ->
                    true;
                true ->
                    false
            end;
        Value1 when is_integer(Value1) andalso Value1 =/= 0 ->       % 2018-02-03 修改完全匹配
            Value >= Value1;
        _ ->
            false
    end.

%% @doc fun 条件是否为增加方式
is_condition_add(Condition) ->
    Condition == ?CONDITIONS_VALUE_ADD orelse Condition == ?CONDITIONS_VALUE_NOT_SAME_DAY_ADD.

%%%% @fun 玩家条件清除
%%clean_player_conditions_data(PlayerId, Type, ConditionsId) when is_integer(ConditionsId) ->
%%    InitConditions = get_player_conditions_data_init(PlayerId, Type, ConditionsId),
%%    if
%%        InitConditions#db_player_conditions_data.count > 0 ->
%%            Tran =
%%                fun() ->
%%                    db:write(InitConditions#db_player_conditions_data{count = 0, change_time = util_time:timestamp()})
%%                end,
%%            db:do(Tran),
%%            ok;
%%        true ->
%%            noop
%%    end;
%%clean_player_conditions_data(PlayerId, Type, Param) ->
%%    {ConditionsId, Type} = get_conditions_id({Param, Type}),
%%    clean_player_conditions_data(PlayerId, Type, ConditionsId).

%% 获得累计条件数据值
get_player_conditions_data_number(_, '') ->
    0;
get_player_conditions_data_number(_, {}) ->
    0;
get_player_conditions_data_number(PlayerId, Param) ->
%%    case Param of
%%        {?CON_ENUM_MISSION, MissionType} ->
%%            mod_mission:get_player_passed_mission_id(PlayerId, MissionType);
%%        _ ->
    {ConditionsId, Type, Type2} = get_conditions_id(Param),
    InitConditions = get_player_conditions_data_init(PlayerId, Type, Type2, ConditionsId),
    InitConditions#db_player_conditions_data.count.
%%    end.

%% 获得条件数据记录
get_player_conditions_record(PlayerId, Param) ->
    {ConditionsId, Type, Type2} = get_conditions_id(Param),
    get_player_conditions_data(PlayerId, Type, Type2, ConditionsId).

%% @fun 获得条件id
get_conditions_id(Param) ->
    case Param of
        {ConditionsKey, Type} ->
            case is_integer(ConditionsKey) of
                true ->
                    {ConditionsKey, Type, 0};
                _ ->
                    {logic_get_conditions_sign_id(ConditionsKey), Type, 0}
            end;
        {ConditionsKey, Type, Type2} ->
            case is_integer(ConditionsKey) of
                true ->
                    Param;
                _ ->
                    {logic_get_conditions_sign_id(ConditionsKey), Type, Type2}
            end;
        _ ->
            case is_integer(Param) of
                true ->
                    {Param, 0, 0};
                _ ->
                    {logic_get_conditions_sign_id(Param), 0, 0}
            end
    end.

%% @fun 重置条件数据
restart_conditions_data(PlayerId, ConditionsKey) ->
    ConditionValue = get_player_conditions_data_number(PlayerId, ConditionsKey),
    ?IF(ConditionValue > 0, add_conditions(PlayerId, {ConditionsKey, ?CONDITIONS_VALUE_SET, ConditionValue}), noop).

%% 测试使用的功能
test_fun_change(PlayerId, ConditionsId, Value) ->
    Param = logic_get_conditions_id_to_sign(ConditionsId),
    add_conditions(PlayerId, {Param, ?CONDITIONS_VALUE_SET, Value}).

%% @fun 转换成元组
change_to_tuple(Tuple) ->
    case Tuple of
        [Key1, Value1] ->
            {Key1, Value1};
        {_, _} ->
            Tuple
    end.

%% ================================================ 数据操作 ================================================
% 获得累计记录得数据
get_player_conditions_data(PlayerId, Type, Type2, ConditionsId) ->
    db:read(#key_player_conditions_data{player_id = PlayerId, type = Type, type2 = Type2, conditions_id = ConditionsId}).

%%%% 获得累计记录得数据   并初始化
%%get_player_conditions_data_init(PlayerId, Type, ConditionsId) ->
%%    get_player_conditions_data_init(PlayerId, Type, 0, ConditionsId).
get_player_conditions_data_init(PlayerId, Type, Type2, ConditionsId) ->
    case get_player_conditions_data(PlayerId, Type, Type2, ConditionsId) of
        T when is_record(T, db_player_conditions_data) ->
            case T#db_player_conditions_data.conditions_type of
                1 ->
                    case util_time:is_today(T#db_player_conditions_data.change_time) of
                        true ->
                            T;
                        _ ->
                            T#db_player_conditions_data{count = 0}
                    end;
                _ ->
                    T
            end;
        _ ->
            T_C = get_try_t_conditions(ConditionsId),
            #db_player_conditions_data{player_id = PlayerId, type = Type, type2 = Type2, conditions_id = ConditionsId, conditions_type = T_C#t_conditions_enum.data_restart_type}
    end.

%% 获得活动任务条件数据
get_player_condition_activity(PlayerId, ActivityId) ->
    db:read(#key_player_condition_activity{player_id = PlayerId, activity_id = ActivityId}).

%% 获得活动任务条件数据       并初始化
get_player_condition_activity_init(PlayerId, ActivityId) ->
    case get_player_condition_activity(PlayerId, ActivityId) of
        C when is_record(C, db_player_condition_activity) ->
            C;
        _ ->
            #db_player_condition_activity{player_id = PlayerId, activity_id = ActivityId}
    end.


%% ================================================ 模板操作 ================================================
%% @fun 获得条件表的模板
get_try_t_conditions(Id) ->
    Table = t_conditions_enum:get({Id}),
    ?IF(is_record(Table, t_conditions_enum), Table, exit({null_t_conditions_enum, {Id}})).

%% 获得条件表的id
logic_get_conditions_sign_id(Param) ->
    ConditionsId = logic_get_conditions_sign_id:get(Param),
    ?IF(is_integer(ConditionsId), ConditionsId, exit({null_logic_get_conditions_sign_id, {Param}})).

% 获得条件id的sign
logic_get_conditions_id_to_sign(ConditionsId) ->
    logic_get_conditions_id_to_sign:get(ConditionsId).

% 获得功能列表数据
logic_get_conditions_function_list(Param) ->
    logic_get_conditions_function_list:get(Param).

% 成就数据
logic_get_conditions_achievement_list(Param) ->
    logic_get_conditions_achievement_list:get(Param, []).

logic_get_conditions_individual_red_packet_id_list(Param) ->
    logic_get_conditions_individual_red_packet_id_list:get(Param, []).
logic_get_conditions_red_packet_id_list(Param) ->
    logic_get_conditions_red_packet_id_list:get(Param, []).