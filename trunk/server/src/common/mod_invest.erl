%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         投资计划
%%% @end
%%% Created : 15. 三月 2021 下午 03:40:42
%%%-------------------------------------------------------------------
-module(mod_invest).
-author("Administrator").

-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("player_game_data.hrl").
-include("common.hrl").
-include("error.hrl").

%% API
-export([
    get_player_invest_type_data_list/1,         %% 获得玩家投资列表

    try_open_invest/2,                          %% 尝试开启投资计划
    condition_update/3,                         %% 条件更新

    get_award/3,                                %% 获得投资奖励

    get_t_tou_zi_ji_hua/2                       %% 获得投资计划表

%%    get_db_player_invest_list/1               %% DB 获得玩家投资数据列表
]).

%% @doc 获得玩家投资列表
get_player_invest_type_data_list(PlayerId) ->
    lists:map(
        fun(Type) ->
            #db_player_invest_type{
                is_buy = IsBuy
            } = get_db_player_invest_type_init(PlayerId, Type),
            InvestDataList =
%%                if
%%                    IsBuy == ?TRUE ->
            lists:map(
                fun(Id) ->
                    #db_player_invest{
                        status = Status
                    } = get_db_player_invest_init(PlayerId, Type, Id),
                    {Id, Status}
                end,
                logic_get_invest_task_id_list_by_type(Type)
            ),
%%                    true ->
%%                        []
%%                end,
            {Type, IsBuy, InvestDataList}
        end,
        logic_get_invest_task_type_list()
    ).

%% @doc 开启投资计划
try_open_invest(PlayerId, ChargeId) ->
    case util_list:opt(ChargeId, ?SD_TOU_ZI_JI_HUA) of
        ?UNDEFINED ->
            noop;
        Type ->
            DbPlayerInvestType = get_db_player_invest_type_init(PlayerId, Type),
            #db_player_invest_type{
                is_buy = IsBuy
            } = DbPlayerInvestType,
            if
                IsBuy == ?FALSE ->
                    Tran =
                        fun() ->
                            db:write(DbPlayerInvestType#db_player_invest_type{is_buy = ?TRUE, update_time = util_time:timestamp()}),
%%                                lists:foldl(
%%                                    fun(Id, TmpL) ->
%%                                        #t_tou_zi_ji_hua{
%%                                            is_condition = IsCondition,
%%                                            condition_list = ConditionList
%%                                        } = get_t_tou_zi_ji_hua(Type, Id),
%%                                        if
%%                                            ConditionList =:= [] ->
%%                                                db:write(#db_player_invest{player_id = PlayerId, type = Type, id = Id, status = ?AWARD_CAN}),
%%                                                [{Id, ?AWARD_CAN} | TmpL];
%%                                            true ->
%%                                                if
%%                                                %% 未解锁时的条件也计入
%%                                                    IsCondition == ?FALSE ->
%%                                                        {ConditionKey, NeedValue} =
%%                                                            case ConditionList of
%%                                                                [Key, _Value] ->
%%                                                                    Key;
%%                                                                [Key1, Key2, _Value] ->
%%                                                                    {Key1, Key2}
%%                                                            end,
%%                                                        PlayerValue = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionKey),
%%                                                        Status =
%%                                                            case mod_conditions:is_conditions_state(PlayerValue, NeedValue) of
%%                                                                true ->
%%                                                                    ?AWARD_CAN;
%%                                                                false ->
%%                                                                    ?AWARD_NONE
%%                                                            end,
%%                                                        db:write(#db_player_invest{player_id = PlayerId, type = Type, id = Id, value = PlayerValue, status = Status}),
%%                                                        ?IF(Status == ?AWARD_CAN, [{Id, ?AWARD_CAN} | TmpL], TmpL);
%%                                                    true ->
%%                                                        TmpL
%%                                                end
%%                                        end
%%                                    end, [], logic_get_invest_task_id_list_by_type(Type)
%%                                ),
                            db:tran_apply(fun() ->
                                api_invest:notice_invest_type_data_update(PlayerId, Type, ?TRUE, []) end),
                            List =
                                lists:foldl(
                                    fun(Id, TmpL) ->
                                        #t_tou_zi_ji_hua{
                                            is_condition = IsCondition,
                                            condition_list = ConditionList
                                        } = get_t_tou_zi_ji_hua(Type, Id),
                                        if
                                            IsCondition == 1 ->
                                                ConditionKey =
                                                    case ConditionList of
                                                        [Key, _Value] ->
                                                            Key;
                                                        [Key1, Key2, _Value] ->
                                                            {Key1, Key2}
                                                    end,
                                                if
                                                    ConditionKey == ?CON_ENUM_LOGIN_DAY ->
                                                        [Id | TmpL];
                                                    true ->
                                                        TmpL
                                                end;
                                            true ->
                                                TmpL
                                        end
                                    end,
                                    [], logic_get_invest_task_id_list_by_type(Type)
                                ),
                            condition_update(PlayerId, [{Type, List}], {?CONDITIONS_VALUE_ADD, 1})
                        end,
                    db:do(Tran),
                    ok;
                true ->
                    noop
            end
    end.

%% @doc 条件更新
condition_update(_PlayerId, [], _Condition) ->
    noop;
condition_update(PlayerId, [{Type, IdList} | InvestTypeIdList], Condition) ->
    #db_player_invest_type{
        is_buy = IsBuy
    } = get_db_player_invest_type_init(PlayerId, Type),
%%    IsFunctionOpen = mod_function:is_open(PlayerId, ?FUNCTION_TOU_ZI_JI_HUA),
%%    if
%%        IsBuy =:= ?TRUE andalso IsFunctionOpen ->
%%        IsFunctionOpen ->
    Tran =
        fun() ->
            condition_update_1(PlayerId, Type, IdList, Condition, [], IsBuy)
        end,
    db:do(Tran),
%%        true ->
%%            noop
%%    end,
    condition_update(PlayerId, InvestTypeIdList, Condition).
condition_update_1(_PlayerId, _Type, [], _AddValue, [], _IsBuy) ->
    ok;
condition_update_1(PlayerId, Type, [], _Condition, NoticeInvestList, IsBuy) ->
    #db_player_invest_type{
        is_buy = IsBuy
    } = get_db_player_invest_type_init(PlayerId, Type),
    db:tran_apply(fun() -> api_invest:notice_invest_type_data_update(PlayerId, Type, IsBuy, NoticeInvestList) end);
condition_update_1(PlayerId, Type, [Id | InvestIdList], {ConType, ConValue} = Condition, NoticeInvestList, IsBuy) ->
    DbPlayerInvest = get_db_player_invest_init(PlayerId, Type, Id),
    #db_player_invest{
        value = Value,
        status = Status
    } = DbPlayerInvest,
    #t_tou_zi_ji_hua{
        is_condition = IsCondition
    } = get_t_tou_zi_ji_hua(Type, Id),
    NewNoticeInvestList =
        if
            Status =:= ?AWARD_NONE andalso (IsBuy == ?TRUE orelse IsCondition == 0) ->
                NewValue =
                    if
                        ConType == ?CONDITIONS_VALUE_ADD orelse ConType == ?CONDITIONS_VALUE_NOT_SAME_DAY_ADD ->
                            Value + ConValue;
                        ConType == ?CONDITIONS_VALUE_DECREASE ->
                            max(Value - ConValue, 0);
                        true ->
                            ConValue
                    end,
                #t_tou_zi_ji_hua{
                    condition_list = ConditionList
                } = get_t_tou_zi_ji_hua(Type, Id),
                ValueTuple =
                    case ConditionList of
                        [_Key1, _Key2, ConditionValue] ->
                            ConditionValue;
                        [_Key, ConditionValue] ->
                            ConditionValue
                    end,
                IsConditionState = mod_conditions:is_conditions_state(ValueTuple, NewValue),
                NewStatus = ?IF(IsConditionState, ?AWARD_CAN, ?AWARD_NONE),
                db:write(DbPlayerInvest#db_player_invest{value = NewValue, status = NewStatus}),
                ?IF(NewStatus == ?AWARD_CAN, [{Id, ?AWARD_CAN} | NoticeInvestList], NoticeInvestList);
            true ->
                NoticeInvestList
        end,
    condition_update_1(PlayerId, Type, InvestIdList, Condition, NewNoticeInvestList, IsBuy).

%% @doc 获得投资奖励
get_award(PlayerId, Type, Id) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_TOU_ZI_JI_HUA),
    #db_player_invest_type{
        is_buy = IsBuy
    } = get_db_player_invest_type_init(PlayerId, Type),
    ?ASSERT(IsBuy =:= ?TRUE, ?ERROR_NONE),
    DbPlayerInvest = get_db_player_invest_init(PlayerId, Type, Id),
    #db_player_invest{
        status = Status
    } = DbPlayerInvest,
    case Status of
        ?AWARD_NONE ->
            exit(?ERROR_NOT_AUTHORITY);
        ?AWARD_CAN ->
            #t_tou_zi_ji_hua{
                reward_list = RewardList
            } = get_t_tou_zi_ji_hua(Type, Id),
            Tran =
                fun() ->
                    mod_award:give(PlayerId, RewardList, ?LOG_TYPE_INVETS_AWARD),
                    db:write(DbPlayerInvest#db_player_invest{status = ?AWARD_ALREADY, update_time = util_time:timestamp()})
                end,
            db:do(Tran),
            ok;
        ?AWARD_ALREADY ->
            exit(?ERROR_ALREADY_GET);
        _ ->
            exit(?ERROR_FAIL)
    end.

%% ================================================ 数据操作 ================================================

%% @doc 获得玩家投资类型数据
get_db_player_invest_type(PlayerId, Type) ->
    db:read(#key_player_invest_type{player_id = PlayerId, type = Type}).
get_db_player_invest_type_init(PlayerId, Type) ->
    case get_db_player_invest_type(PlayerId, Type) of
        R when is_record(R, db_player_invest_type) ->
            R;
        _ ->
            #db_player_invest_type{
                player_id = PlayerId,
                type = Type
            }
    end.

%% @doc 获得玩家投资数据
get_db_player_invest(PlayerId, Type, Id) ->
    db:read(#key_player_invest{player_id = PlayerId, type = Type, id = Id}).
get_db_player_invest_init(PlayerId, Type, Id) ->
    case get_db_player_invest(PlayerId, Type, Id) of
        R when is_record(R, db_player_invest) ->
            R;
        _ ->
            #db_player_invest{
                player_id = PlayerId,
                type = Type,
                id = Id,
                status = 0
            }
    end.

%% ================================================ 模板操作 ================================================

%% @doc 获得投资计划表
get_t_tou_zi_ji_hua(Type, Id) ->
    t_tou_zi_ji_hua:assert_get({Type, Id}).

%% @doc 获得投资计划任务id列表 根据类型
logic_get_invest_task_id_list_by_type(Type) ->
    logic_get_invest_task_id_list_by_type:get(Type).

%% @doc 获得投资计划任务类型列表
logic_get_invest_task_type_list() ->
    logic_get_invest_task_type_list:get(0).