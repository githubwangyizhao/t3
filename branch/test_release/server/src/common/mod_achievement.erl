%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    成就
%%% Created : 01. 二月 2018 19:44
%%%-------------------------------------------------------------------
-module(mod_achievement).
-author("home").

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    %% function
    get_achievement_data_list/1,                        %% 获得成就数据列表
    get_award/2,                                        %% 获得成就奖励

    init_task_show/1,                                   %% 初始化任务展示
    update_achievement_type_condition/3                 %% 更新成就类型条件
]).

%% @doc 初始化任务展示
init_task_show(PlayerId) ->
    init_task_show(PlayerId, get_achievement_type_list(), ?UNDEFINED).
init_task_show(_PlayerId, [], ?UNDEFINED) ->
    ?UNDEFINED;
init_task_show(_PlayerId, [], {MinType, _MinId}) ->
    {achievement, MinType};
init_task_show(PlayerId, [Type | TypeList], MinData) ->
    DbPlayerAchievement = get_db_player_achievement_or_init(PlayerId, Type),
    #db_player_achievement{
        id = Id,
        state = State
    } = DbPlayerAchievement,
    case State of
        ?AWARD_ALREADY ->
            init_task_show(PlayerId, TypeList, MinData);
        _ ->
            case MinData of
                ?UNDEFINED ->
                    init_task_show(PlayerId, TypeList, {Type, Id});
                {_MinType, MinId} ->
                    if
                        Id < MinId ->
                            init_task_show(PlayerId, TypeList, {Type, Id});
                        true ->
                            init_task_show(PlayerId, TypeList, MinData)
                    end
            end
    end.

%% @doc 获得成就数据列表
get_achievement_data_list(PlayerId) ->
    lists:map(
        fun(Type) ->
            api_achievement:pack_achievement_data(get_achievement_tuple(PlayerId, Type))
        end,
        get_achievement_type_list()
    ).
get_achievement_tuple(PlayerId, Type) ->
    DbPlayerAchievement = get_db_player_achievement_or_init(PlayerId, Type),
    get_achievement_tuple(DbPlayerAchievement).
get_achievement_tuple(DbPlayerAchievement) ->
    #db_player_achievement{
        player_id = PlayerId,
        type = Type,
        id = Id,
        state = State
    } = DbPlayerAchievement,
    #t_achievement{
        approach_list = ConditionList
    } = get_t_achievement(Type, Id),
    [ConditionsKey, NeedValue] = logic_code:tran_condition_list(ConditionList),
    Value = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionsKey),
    NewState =
        if
            State =:= ?AWARD_ALREADY ->
                State;
            true ->
                ?IF(Value >= NeedValue, ?AWARD_CAN, ?AWARD_NONE)
        end,
    {Type, Id, Value, NewState}.

%% @doc 领取成就奖励
get_award(PlayerId, Type) ->
    DbPlayerAchievement = get_db_player_achievement_or_init(PlayerId, Type),
    #db_player_achievement{
        id = Id,
        state = State
    } = DbPlayerAchievement,
    ?ASSERT(State =/= ?AWARD_ALREADY, ?ERROR_ALREADY_GET),
    #t_achievement{
        next_id = NextId,
        approach_list = ApproachList,
        award_list = AwardList
    } = get_t_achievement(Type, Id),
    [ConditionsKey, NeedValue] = logic_code:tran_condition_list(ApproachList),
    Value = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionsKey),
    ?ASSERT(Value >= NeedValue, ?ERROR_NOT_AUTHORITY),
    mod_prop:assert_give(PlayerId, AwardList),
    NewDbPlayerAchievement =
        if
            NextId > 0 ->
                #t_achievement{
                    approach_list = NextApproachList
                } = get_t_achievement(Type, NextId),
                [NextConditionsKey, NextNeedValue] = logic_code:tran_condition_list(NextApproachList),
                NextValue = mod_conditions:get_player_conditions_data_number(PlayerId, NextConditionsKey),
                NextState = ?IF(NextValue >= NextNeedValue, ?AWARD_CAN, ?AWARD_NONE),
                DbPlayerAchievement#db_player_achievement{id = NextId, state = NextState, change_time = util_time:timestamp()};
            true ->
                DbPlayerAchievement#db_player_achievement{state = ?AWARD_ALREADY, change_time = util_time:timestamp()}
        end,

    Tran =
        fun() ->
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_ACHIEVEMENT_AWARD),
            db:write(NewDbPlayerAchievement)
        end,
    db:do(Tran),
    {ok, get_achievement_tuple(NewDbPlayerAchievement)}.

%% @doc 更新成就类型条件
update_achievement_type_condition(_PlayerId, [], _NewValue) ->
    noop;
update_achievement_type_condition(PlayerId, [{Type, Id} | TypeList], NewValue) ->
    DbPlayerAchievement = get_db_player_achievement_or_init(PlayerId, Type),
    #db_player_achievement{
        id = ThisId,
        state = State
    } = DbPlayerAchievement,
    if
        State =:= ?AWARD_NONE andalso ThisId =:= Id ->
            #t_achievement{
                approach_list = ConditionList,
                clients_type = ClientType
            } = get_t_achievement(Type, Id),
            [_ConditionKey, NeedValue] = logic_code:tran_condition_list(ConditionList),
            IsUpdateState = (NewValue >= NeedValue),
            NewState = ?IF(IsUpdateState, ?AWARD_CAN, ?AWARD_NONE),
            Tran =
                fun() ->
                    db:write(DbPlayerAchievement#db_player_achievement{state = NewState, change_time = util_time:timestamp()})
                end,
            db:do(Tran),
            if
                IsUpdateState orelse ClientType =:= 99 ->
                    api_achievement:notice_update_achievement_data(PlayerId, {Type, Id, NewValue, NewState});
                true ->
                    case mod_daily_task:get_task_show() of
                        {achievement, ThisType} ->
                            if
                                ThisType =:= Type ->
                                    api_achievement:notice_update_achievement_data(PlayerId, {Type, Id, NewValue, NewState});
                                true ->
                                    noop
                            end;
                        _ ->
                            noop
                    end
            end;
        true ->
            noop
    end,
    update_achievement_type_condition(PlayerId, TypeList, NewValue).

%% ================================================ 数据操作 ================================================
%% @doc 获取成就数据
get_db_player_achievement(PlayerId, Type) ->
    db:read(#key_player_achievement{player_id = PlayerId, type = Type}).
get_db_player_achievement_or_init(PlayerId, Type) ->
    case get_db_player_achievement(PlayerId, Type) of
        null ->
            #db_player_achievement{
                player_id = PlayerId,
                type = Type,
                id = 1,
                state = 0
            };
        R ->
            #db_player_achievement{
                id = Id,
                state = State
            } = R,
            if
                State =:= ?AWARD_ALREADY ->
                    #t_achievement{
                        next_id = NextId
                    } = get_t_achievement(Type, Id),
                    if
                        NextId > 0 ->
                            R#db_player_achievement{
                                id = NextId,
                                state = ?AWARD_NONE
                            };
                        true ->
                            R
                    end;
                true ->
                    R
            end
    end.

%% ================================================ 模板操作 ================================================

%% @doc 获得成就类型列表
get_achievement_type_list() ->
    logic_get_achievement_type_list:get(0).

%% @doc 获得成就表
get_t_achievement(Type, Id) ->
    t_achievement:assert_get({Type, Id}).
