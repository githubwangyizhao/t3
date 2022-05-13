%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            次数模块
%%% @end
%%% Created : 10. 八月 2016 上午 11:37
%%%-------------------------------------------------------------------
-module(mod_times).

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("msg.hrl").
%% API
-export([
    use_times/2,                            %% 使用次数
    reset_times/2,                          %% 重置次数
    buy_times/2,                            %% 购买次数
    add_times/3,                            %% 免费增加次数
    assert_times/2,                         %% 检查是否有足够次数
    get_use_times/2,                        %% 获得玩家今天使用次数
    get_left_times/2                        %% 获取剩余次数
]).


%%Internal functions
-export([
    pack_init_player_times_data/2,
    flush_player_times_data/2,              %% 刷新玩家所有次数数据
    get_all_player_times_info/1,            %% 获取次数信息
    get_player_all_times_data/1,
    get_t_times/1,
    hook_times_change/2,
    hook_times_change/3,
    delete_no_exists_times/0,
    do_delete_no_exists_times/1,
    get_none_free_times/2,                  % 获得没有免费次数时操作
    get_player_times_data/2,                %% 获取玩家次数数据
    get_max_buy_times/2,                    %% 获取最大购买次数
    init_player_times_by_function/2,        %% 功能开启初始化次数
    get_init_free_times/2,                  %% 获取初始次数
    try_update_times_after_vip_level_change/3%% vip升级后尝试更新数据
]).

-export([
    repair_top_times/2,      % 修复过高的次数
    restart_all_player_times/0,
    try_repair_all_player_times/1
]).

-define(RESET_TYPE_NONE, 0).    %% 重置类型 - 不重置
-define(RESET_TYPE_DAILY, 1).   %% 重置类型 - 每日重置
-define(RESET_TYPE_WEEK, 2).    %% 重置类型 - 每周重置

%% ----------------------------------
%% @doc 	免费增加次数
%% @throws 	none
%% @end
%% ----------------------------------
add_times(PlayerId, TimesId, Num) ->
    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
    case is_record(PlayerTimesData, db_player_times_data) of
        true ->
            #db_player_times_data{
                left_times = LeftTimes
            } = PlayerTimesData,
            NewLeftTimes = LeftTimes + Num,
            Tran = fun() ->
                NewPlayerTimesData = PlayerTimesData#db_player_times_data{
                    left_times = NewLeftTimes
                },
                db:write(NewPlayerTimesData),
                hook_times_change(PlayerId, TimesId)
                   end,
            db:do(Tran);
        _ ->
            noop
    end.


%% ----------------------------------
%% @doc 	获取玩家剩余次数
%% @throws 	none
%% @end
%% ----------------------------------
get_left_times(PlayerId, TimesId) when is_integer(PlayerId) ->
    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
    if
        PlayerTimesData == null ->
            #t_times{
                function_id = FunctionId
            } = get_t_times(TimesId),
            mod_function:assert_open(PlayerId, FunctionId),
            Tran =
                fun() ->
                    do_init_player_times(PlayerId, TimesId)
                end,
            db:do(Tran);
        true ->
            ok
    end,
    NewPlayerTimesData = get_player_times_data(PlayerId, TimesId),
%%    ?ASSERT(PlayerTimesData =/= null, {null_player_times_data, TimesId}),
    #db_player_times_data{
        left_times = LeftTimes
    } = NewPlayerTimesData,
    LeftTimes.

%% ----------------------------------
%% @doc 	校验次数是否足够
%% @throws 	none
%% @end
%% ----------------------------------
assert_times(PlayerId, TimesId) ->
    LeftTimes = get_left_times(PlayerId, TimesId),
    if
        LeftTimes =< 0 ->
            #t_times{
                buy_prop_list = BuyPropList,
                buy_times_type = BuyTimesType,
                log_type = LogType
            } = get_t_times(TimesId),
            if
                BuyTimesType == 1 ->
                    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
                    ?ASSERT(PlayerTimesData =/= null, {null_player_times_data, TimesId}),
                    #db_player_times_data{
                        buy_times = OldBuyTimes
                    } = PlayerTimesData,
                    NewBuyTimes = OldBuyTimes + 1,
                    [_, _, PropId, Num] = util_list:get_element_from_range_list(NewBuyTimes, BuyPropList),
                    ?t_assert(LogType > 0, log_type_zero),
                    MaxBuyTimes = get_max_buy_times(PlayerId, TimesId),
                    % 检查道具是否足够
                    mod_prop:assert_prop_num(PlayerId, PropId, Num),
                    % 检查最大购买次数
                    ?ASSERT(MaxBuyTimes == 0 orelse NewBuyTimes =< MaxBuyTimes, ?ERROR_TIMES_LIMIT);
                true ->
                    exit(?ERROR_TIMES_LIMIT)
            end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	获得玩家今天使用次数
%% @throws 	none
%% @end
%% ----------------------------------
get_use_times(PlayerId, TimesId) ->
    case get_player_times_data(PlayerId, TimesId) of
        null ->
            0;
        PlayerTimesData ->
            PlayerTimesData#db_player_times_data.use_times
    end.

%% ----------------------------------
%% @doc 	重置次数
%% @throws 	none
%% @end
%% ----------------------------------
reset_times(PlayerId, TimesId) ->
    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
    Tran = fun() ->
        NewPlayerTimesData = PlayerTimesData#db_player_times_data{
            use_times = 0,
            buy_times = 0,
            left_times = get_init_free_times(PlayerId, TimesId)
        },
        db:write(NewPlayerTimesData),
        hook_times_change(PlayerId, TimesId)
           end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	使用次数
%% @throws 	none
%% @end
%% ----------------------------------
use_times(PlayerId, TimesId) ->
    #t_times{
        buy_prop_list = BuyPropList,
        log_type = LogType,
        buy_times_type = BuyTimesType
    } = get_t_times(TimesId),
    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
    ?ASSERT(PlayerTimesData =/= null, {null_player_times_data, TimesId}),
    #db_player_times_data{
        use_times = OldUseTimes,
        left_times = LeftTimes,
        buy_times = OldBuyTimes
%%        buy_times = ButTimes
    } = PlayerTimesData,


    NewUseTimes = OldUseTimes + 1,
%%    NewLeftTimes = LeftTimes - 1,
    {NewLeftTimes, NewBuyTimes, BuyItemList} =
        if
            LeftTimes == 0 andalso BuyTimesType == 1 ->
                NewBuyTimes1 = OldBuyTimes + 1,
                [_, _, PropId, Num] = util_list:get_element_from_range_list(NewBuyTimes1, BuyPropList),
                ?t_assert(LogType > 0, log_type_zero),
                MaxBuyTimes = get_max_buy_times(PlayerId, TimesId),

                % 检查道具是否足够
                mod_prop:assert_prop_num(PlayerId, PropId, Num),

                % 检查最大购买次数
                ?ASSERT(MaxBuyTimes == 0 orelse NewBuyTimes1 =< MaxBuyTimes, ?ERROR_TIMES_LIMIT),
                {LeftTimes, NewBuyTimes1, [{PropId, Num}]};
            true ->
                NewLeftTimes1 = LeftTimes - 1,
                ?ASSERT(NewLeftTimes1 >= 0, ?ERROR_TIMES_LIMIT),
                {NewLeftTimes1, OldBuyTimes, []}
        end,

%%    if NewLeftTimes >= 0 -> noop;
%%        true ->
%%            ?ERROR("次数不足:~p~n", [{PlayerId, TimesId}])
%%    end,

    NewPlayerTimesData = PlayerTimesData#db_player_times_data{
        left_times = NewLeftTimes,
        buy_times = NewBuyTimes,
        use_times = NewUseTimes
    },
    Tran = fun() ->
        db:write(NewPlayerTimesData),
        mod_prop:decrease_player_prop(PlayerId, BuyItemList, LogType),
        hook_times_change(PlayerId, TimesId),
        mod_log:write_player_times_log(PlayerId, TimesId, -1, NewLeftTimes)
%%        if
%%            TimesId == ?TIMES_ARENA_TIMES orelse TimesId == ?TIMES_HUNTING_BOSS orelse TimesId == ?TIMES_ZHUANG_BEI ->
%%                db:tran_apply(fun() -> get_none_free_times(PlayerId, TimesId) end);
%%            true ->
%%                noop
%%        end
%%        mod_log:write_player_times_log(PlayerId, TimesId, LogType)
           end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	钩子:次数改变
%% @throws 	none
%% @end
%% ----------------------------------
hook_times_change(PlayerId, TimesId) ->
    hook_times_change(PlayerId, TimesId, true).
hook_times_change(PlayerId, TimesId, IsTriggerRecover) ->
    db:tran_apply(fun() -> api_times:notice_times_change(PlayerId, [TimesId]) end),
    if IsTriggerRecover ->
        mod_times_recover:trigger_recover_times_timer(PlayerId, TimesId, true);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	购买次数
%% @throws 	none
%% @end
%% ----------------------------------
buy_times(PlayerId, TimesId) ->
    #t_times{
        is_can_buy = IsCanBuy,
        buy_prop_list = BuyPropList,
        log_type = LogType
    } = get_t_times(TimesId),
    ?ASSERT(IsCanBuy == ?TRUE, not_can_buy),
    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
    ?ASSERT(PlayerTimesData =/= null, {null_player_times_data, TimesId}),
    #db_player_times_data{
        buy_times = OldBuyTimes,
        left_times = OldLeftTimes
    } = PlayerTimesData,
    [_, _, PropId, Num] = util_list:get_element_from_range_list(OldBuyTimes + 1, BuyPropList),
    ?t_assert(LogType > 0, log_type_zero),
    NewBuyTimes = OldBuyTimes + 1,
    NewLeftTimes = OldLeftTimes + 1,
    MaxBuyTimes = get_max_buy_times(PlayerId, TimesId),

    % 检查道具是否足够
    mod_prop:assert_prop_num(PlayerId, PropId, Num),

    % 检查最大购买次数
    ?ASSERT(MaxBuyTimes == 0 orelse NewBuyTimes =< MaxBuyTimes, ?ERROR_TIMES_LIMIT),

    Tran = fun() ->
        mod_prop:decrease_player_prop(PlayerId, PropId, Num, LogType),
        NewPlayerTimesData = PlayerTimesData#db_player_times_data{
            buy_times = NewBuyTimes,
            left_times = NewLeftTimes
        },
        db:write(NewPlayerTimesData),
        hook_times_change(PlayerId, TimesId),
        mod_log:write_player_times_log(PlayerId, TimesId, 1, NewLeftTimes)
%%        db:tran_apply(fun() -> api_times:notice_times_change(PlayerId, [NewPlayerTimesData]) end)
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	获取最大购买次数
%% @throws 	none
%% @end
%% ----------------------------------
get_max_buy_times(PlayerId, TimesId) ->
    #t_times{
        buy_times_limit = MaxBuyTimes,
        vip_max_add_id = VipMaxAddId
    } = get_t_times(TimesId),
    if
        VipMaxAddId =/= 0 ->
            MaxBuyTimes + mod_vip:get_player_vip_boon_value(PlayerId, VipMaxAddId);
        true ->
            MaxBuyTimes
    end.

%% ----------------------------------
%% @doc 	获取玩家所有次数数据
%% @throws 	none
%% @end
%% ----------------------------------
get_all_player_times_info(PlayerId) ->
    lists:foldl(
        fun(PlayerTimesData, Tmp) ->
            #db_player_times_data{
                times_id = TimesId
            } = PlayerTimesData,
            #t_times{
                is_notice = IsNotice
            } = get_t_times(TimesId),
            case IsNotice == ?TRUE of
                true ->
                    [PlayerTimesData | Tmp];
                false ->
                    Tmp
            end
        end,
        [],
        get_player_all_times_data(PlayerId)
    ).


%% ----------------------------------
%% @doc 	功能开启初始化次数
%% @throws 	none
%% @end
%% ----------------------------------
init_player_times_by_function(PlayerId, FunctionId) ->
%%    ?DEBUG("功能开启初始化次数:~p~n", [{PlayerId, FunctionId}]),
    case get_times_id_list_by_function_id(FunctionId) of
        [] ->
            noop;
        TimesIdList ->
            Tran = fun() ->
                lists:foreach(
                    fun(TimesId) ->
                        case get_player_times_data(PlayerId, TimesId) of
                            null ->
                                do_init_player_times(PlayerId, TimesId);
                            _ ->
                                noop
                        end
                    end,
                    TimesIdList
                )
                   end,
            db:do(Tran)
    end.

do_init_player_times(PlayerId, TimesId) ->
    InitR = pack_init_player_times_data(PlayerId, TimesId),
    db:write(InitR),
    hook_times_change(PlayerId, TimesId).

%%

%% ----------------------------------
%% @doc 	获取每日初始次数
%% @throws 	none
%% @end
%% ----------------------------------
get_init_free_times(PlayerId, TimesId) ->
    #t_times{
        free_times = InitTimes,
        vip_init_add_id = VipInitAddId
    } = get_t_times(TimesId),
    if
        VipInitAddId =/= 0 ->
            if
                VipInitAddId == ?VIP_BOON_T_BUQIAN_NUMBER ->
                    {UseTimes, UpdateTime} =
                        case get_player_times_data(PlayerId, TimesId) of
                            null ->
                                {0, util_time:timestamp()};
                            R ->
                                #db_player_times_data{
%%                                    left_times = OldLeftTimes,
                                    use_times = OldUseTimes,
                                    update_time = OldUpdateTime
                                } = R,
                                {OldUseTimes, OldUpdateTime}
                        end,
                    {Data, _} = util_time:local_datetime(),
                    Time = util_time:get_month_1_day_times(Data),
                    if
                        UpdateTime < Time ->
                            mod_vip:get_player_vip_boon_value(PlayerId, VipInitAddId);
                        true ->
                            mod_vip:get_player_vip_boon_value(PlayerId, VipInitAddId) - UseTimes
                    end;
                true ->
                    InitTimes + mod_vip:get_player_vip_boon_value(PlayerId, VipInitAddId)
            end;
        true ->
            InitTimes
    end.

%% @fun 获得没有免费次数时操作
get_none_free_times(PlayerId, TimesId) ->
    #t_times{
        free_times = FreeTimes
    } = get_t_times(TimesId),
    UserTimes = get_use_times(PlayerId, TimesId),
    if
        FreeTimes =< UserTimes ->
            mod_charge:update_is_open_charge(PlayerId);
        true ->
            noop
    end.

pack_init_player_times_data(PlayerId, TimesId) ->
    Now = util_time:timestamp(),
    LeftTimes = get_init_free_times(PlayerId, TimesId),
    #db_player_times_data{
        player_id = PlayerId,
        times_id = TimesId,
        use_times = 0,
        buy_times = 0,
        left_times = LeftTimes,
        update_time = Now,
        last_recover_time = Now
    }.

%% ----------------------------------
%% @doc 	刷新玩家所有次数数据
%% @throws 	none
%% @end
%% ----------------------------------
flush_player_times_data(PlayerId, _IsNotice) ->
    Tran = fun() ->
%%        ChangeTimesList =
        lists:foldl(
            fun(PlayerTimesData, Tmp) ->
                #db_player_times_data{
                    times_id = TimesId,
                    use_times = UseTimes,
                    update_time = UpdateTime
                } = PlayerTimesData,
                case util_time:is_today(UpdateTime) of
                    true ->
                        Tmp;
                    false ->
                        #t_times{
                            reset_type = ResetType,
                            vip_init_add_id = VipInitAddId
                        } = get_t_times(TimesId),
                        PlayerTimesData_1 = PlayerTimesData#db_player_times_data{
                            use_times = 0,
                            buy_times = 0,
                            update_time = util_time:timestamp()
                        },
                        NewPlayerTimesData =
                            if
                            %% 每日重置次数
                                ResetType == ?RESET_TYPE_DAILY ->
                                    if
                                    %% 特权卡 特殊处理
                                        VipInitAddId == ?VIP_BOON_T_BUQIAN_NUMBER ->
                                            {Date, _} = util_time:local_datetime(),
                                            Month_1_Times = util_time:get_month_1_day_times(Date),
                                            if
                                                UpdateTime < Month_1_Times ->
                                                    PlayerTimesData_1#db_player_times_data{
                                                        left_times = get_init_free_times(PlayerId, TimesId)
                                                    };
                                                true ->
                                                    PlayerTimesData_1#db_player_times_data{
                                                        left_times = get_init_free_times(PlayerId, TimesId),
                                                        use_times = UseTimes
                                                    }
                                            end;
                                        true ->
                                            PlayerTimesData_1#db_player_times_data{
                                                left_times = get_init_free_times(PlayerId, TimesId)
                                            }
                                    end;
                            %% 每周重置
                                ResetType == ?RESET_TYPE_WEEK ->
                                    case util_time:is_this_week(UpdateTime) of
                                        true ->
                                            PlayerTimesData_1;
                                        false ->
                                            PlayerTimesData_1#db_player_times_data{
                                                left_times = get_init_free_times(PlayerId, TimesId)
                                            }
                                    end;
                                true ->
                                    PlayerTimesData_1
                            end,
                        Tran = fun() ->
                            db:write(NewPlayerTimesData),
                            hook_times_change(PlayerId, TimesId)
                               end,
                        db:do(Tran),
                        [NewPlayerTimesData | Tmp]
                end
            end,
            [],
            get_player_all_times_data(PlayerId)
        )
%%        if IsNotice ->
%%            % 通知次数变化
%%            hook_times_change(PlayerId, TimesId),
%%            db:tran_apply(fun() -> api_times:notice_times_change(PlayerId, ChangeTimesList) end);
%%            true ->
%%                noop
%%        end
           end,
    db:do(Tran).

get_player_all_times_data(PlayerId) ->
    db_index:get_rows(#idx_player_times_data{player_id = PlayerId}).

%% ----------------------------------
%% @doc 	获取玩家次数数据
%% @throws 	none
%% @end
%% ----------------------------------
get_player_times_data(PlayerId, TimesId) ->
    db:read(#key_player_times_data{player_id = PlayerId, times_id = TimesId}).

%% ----------------------------------
%% @doc 	vip升级后尝试更新数据
%% @throws 	none
%% @end
%% ----------------------------------
try_update_times_after_vip_level_change(PlayerId, OleVipLevel, NewVipLevel) ->
    UpdateList = lists:foldl(
        fun(PlayerTimesData, Tmp) ->
            #db_player_times_data{
                times_id = TimesId,
                left_times = OldLeftTimes
            } = PlayerTimesData,
            #t_times{
                vip_init_add_id = VipInitAddId
            } = get_t_times(TimesId),
            if
                VipInitAddId =/= 0 ->
                    OldVipAdd = mod_vip:get_vip_boon_value(VipInitAddId, OleVipLevel),
                    NewVipAdd = mod_vip:get_vip_boon_value(VipInitAddId, NewVipLevel),
                    if NewVipAdd > OldVipAdd ->
                        NewLeftTime = OldLeftTimes + (NewVipAdd - OldVipAdd),
                        ?INFO("vip 变更加次数:~p", [{TimesId, {OleVipLevel, NewVipLevel}, {OldVipAdd, NewVipAdd}, {OldLeftTimes, NewLeftTime}}]),
                        Tran = fun() ->
                            db:write(PlayerTimesData#db_player_times_data{left_times = NewLeftTime})
                               end,
                        db:do(Tran),
                        [TimesId | Tmp];
                        true ->
                            Tmp
                    end;
                true ->
                    Tmp
            end
%%            TotalTime = get_init_free_times(PlayerId, TimesId),
%%            NewLeftTime = max(0, TotalTime - UseTime + BuyTimes),
%%
%%            if OldLeftTimes =/= NewLeftTime ->
%%                Tran = fun() ->
%%                    db:write(PlayerTimesData#db_player_times_data{left_times = NewLeftTime})
%%                       end,
%%                db:do(Tran),
%%                [TimesId | Tmp];
%%                true ->
%%                    Tmp
%%            end
        end,
        [],
        get_player_all_times_data(PlayerId)
    ),
%%    ?DEBUG("UpdateTimesList:~p~n", [UpdateList]),
    api_times:notice_times_change(PlayerId, UpdateList).

%% ----------------------------------
%% @doc 	通过功能id 获取次数列表
%% @throws 	none
%% @end
%% ----------------------------------
get_times_id_list_by_function_id(FunctionId) ->
    case logic_get_times_id_by_function_id:get(FunctionId) of
        null ->
            [];
        TimesIdList ->
            TimesIdList
    end.


get_t_times(TimesId) ->
    case t_times:get({TimesId}) of
        null ->
            ?ERROR("次数表没有数据:~p", [TimesId]),
            null;
        R ->
            R
    end.

%% ----------------------------------
%% @doc 	尝试修复玩家所有次数
%% @throws 	none
%% @end
%% ----------------------------------
try_repair_all_player_times(PlayerId) ->
    TimesIdList = logic_get_all_times_id:get(0),
    Tran = fun() ->
        lists:foreach(
            fun(TimesId) ->
                #t_times{
                    function_id = FunctionId
                } = get_t_times(TimesId),
                if FunctionId > 0 ->
                    %% 20181207 注 红包雨 老玩家不修复
                    IsIgnore = lists:member(TimesId, [10101, 10102, 10103, 10104, 10105, 10106, 10107, 10108, 10109, 10110, 10201
                        , 10202, 10203, 10204, 10205, 10206, 10207, 10208, 10209, 10210, 10211, 10301, 10302, 10303, 10304, 10305, 10306, 10307, 10308, 10309, 10310, 10311]),
                    case mod_function:is_open(PlayerId, FunctionId) andalso IsIgnore == false of
                        true ->
                            case get_player_times_data(PlayerId, TimesId) of
                                null ->
                                    do_init_player_times(PlayerId, TimesId);
                                _ ->
                                    noop
                            end;
                        false ->
                            noop
                    end;
                    true ->
                        noop
                end
            end,
            TimesIdList
        )
           end,
    db:do(Tran).

%% 删除不存在的次数数据
delete_no_exists_times() ->
    lists:foreach(
        fun(PlayerId) ->
            mod_apply:apply_to_online_player(PlayerId, ?MODULE, do_delete_no_exists_times, [PlayerId], store)
        end,
        mod_player:get_all_player_id()
    ).


do_delete_no_exists_times(PlayerId) ->
    Tran = fun() ->
        lists:foreach(
            fun(E) ->
                #db_player_times_data{
                    times_id = ThisTimesId
                } = E,
                case get_t_times(ThisTimesId) of
                    null ->
                        db:delete(E);
                    _ ->
                        noop
                end
            end,
            get_player_all_times_data(PlayerId)
        )
           end,
    db:do(Tran).
%%get_all_times_id() ->
%%    logic_get_all_times_id:get(0).

%% ================================================ 修复操作 ================================================
%% @doc 重置全部玩家次数
restart_all_player_times() ->
    lists:foreach(
        fun(PlayerId) ->
            mod_apply:apply_to_online_player(PlayerId, ?MODULE, reset_times, [PlayerId, ?TIMES_DRAW_MONEY], store)
        end,
        mod_player:get_all_player_id()
    ).

%% @doc fun 修复过高的次数
repair_top_times(PlayerId, TimesIdList) ->
    Tran =
        fun() ->
            lists:foreach(
                fun(TimesId) ->
                    PlayerTimesData = get_player_times_data(PlayerId, TimesId),
                    case PlayerTimesData of
                        #db_player_times_data{
                            left_times = LeftTimes,
                            update_time = UpdateTime
                        } ->
                            #t_times{
                                free_times = FreeTimes
                            } = get_t_times(TimesId),
                            if
                                LeftTimes > FreeTimes andalso UpdateTime > 1597658400 ->
                                    ?INFO("修复过高的次数:~p  ~p~n", [{PlayerId, TimesId}, {LeftTimes, FreeTimes}]),
                                    db:write(PlayerTimesData#db_player_times_data{left_times = FreeTimes});
                                true ->
                                    noop
                            end;
                        _ ->
                            noop
                    end
                end, TimesIdList
            )
        end,
    db:do(Tran).

