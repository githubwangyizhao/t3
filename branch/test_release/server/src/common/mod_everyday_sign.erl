%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc            每天签到
%%% Created : 28. 三月 2018 16:30
%%%-------------------------------------------------------------------
-module(mod_everyday_sign).
-author("home").

%% API
-export([
    get_everyday_sign_info/1,   %% 获得每日签到数据
    everyday_sign/3             %% 每日签到/补签
]).

-export([
    notice_day/2                %% 当前天数
]).

-define(SIGN_AGAIN_DAY, 30).
-define(SIGNED_IN, 1).          %% 已签到

-define(HAVE_PREROGATIVE, 2).   %% 有特权卡奖励倍数
-define(NOT_PREROGATIVE, 1).    %% 无特权卡奖励倍数

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 获得每日签到数据
get_everyday_sign_info(PlayerId) ->
    {Day, NewRound} = get_day_and_round(PlayerId),
    CurrTime = util_time:timestamp(),                               %% 获得当前时间
    AgainTime = CurrTime - (Day - 1) * 86400,
    AgainNewTime = util_time:get_today_zero_timestamp(AgainTime),   %% 获得新一轮的零点
    Today =
        lists:foldl(
            fun(Today, List) ->
                EverydaySignInit = get_everyday_sign_init(PlayerId, Today),
                ChangeTime = EverydaySignInit#db_player_everyday_sign.change_time,
                if
                    ChangeTime >= AgainNewTime andalso Today =< Day ->
                        [Today | List];
                    true ->
                        List
                end
            end, [], logic_get_everyday_sign_day_list()),
    {Day, Today, NewRound}.

%% 每日签到/补签     (0:等待领取，1:已领取)
everyday_sign(PlayerId, Round, ToDay) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_EVERYDAY_SIGN_SYS),
    {Day, NewRound} = get_day_and_round(PlayerId),
    ?ASSERT(Round == NewRound, ?ERROR_NOT_AUTHORITY),
    ?ASSERT(ToDay =< Day, ?ERROR_NOT_AUTHORITY),
    {NewPropList, Type} =
        if
            Day == ToDay ->
                {[], ?FALSE};
            true ->
                LeftTimes = mod_times:get_left_times(PlayerId, ?TIMES_VIP_EVERYDAY_TIMES),
                if
                    LeftTimes > 0 ->
                        {[], ?TRUE};
                    true ->
                        exit(?ERROR_NO_ENOUGH_PROP)
%%                        PropList = [{?PROP_TYPE_ITEM, ?ITEM_BU_QIAN, 1}],
%%                        case mod_prop:check_prop_num(PlayerId, PropList) of
%%                            true ->
%%                                {PropList, ?FALSE};
%%                            false ->
%%                                PayPropList = [{?PROP_TYPE_RESOURCES, ?RES_INGOT, ?SD_EVERYDAY_SIGN_BUQIAN_PAY}],
%%                                mod_prop:assert_prop_num(PlayerId, PayPropList),
%%                                {[], ?FALSE}
%%                        end
                end
        end,
    SignData = get_everyday_sign_init(PlayerId, ToDay),
%%    State = SignData#db_player_everyday_sign.state,
    ?ASSERT(SignData#db_player_everyday_sign.state =/= ?SIGNED_IN, ?ERROR_ALREADY_HAVE),
%%    PrerogativeList = mod_prerogative_card:get_all_prerogative_card_id_list(PlayerId),
%%    Multiple = if
%%                   PrerogativeList =/= [] ->
%%                       ?HAVE_PREROGATIVE;
%%                   true ->
%%                       ?NOT_PREROGATIVE
%%               end,
%%    SignValue = mod_vip:get_vip_boon_value(PlayerId, ?VIP_BOON_T_QIANDAOSHUANGBEI),
%%    Multiple =
%%        if
%%            SignValue == ?TRUE ->
%%                ?HAVE_PREROGATIVE;
%%            true ->
%%                ?NOT_PREROGATIVE
%%        end,
%%    NewPropNum = PropNum * Multiple,
%%    ItemList = [AwardList],
    VipLevel = mod_vip:get_vip_level(PlayerId),
    #t_everyday_sign{
        award_list = AwardList,
        vip_multiple_list = VipList
    } = try_get_t_everyday_sign(NewRound, ToDay),
    ItemList =
        if
            VipList =/= [] ->
                [NeedVipLevel, Multiple] = VipList,
                if
                    VipLevel >= NeedVipLevel ->
                        mod_prop:rate_prop(AwardList, Multiple);
                    true ->
                        AwardList
                end;
            true ->
                AwardList
        end,
    mod_prop:assert_give(PlayerId, ItemList),
    CurrTime = util_time:timestamp(),
    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, NewPropList, ?LOG_TYPE_EVERYDAY_SIGN),
            if
                Type == ?TRUE ->
                    mod_times:use_times(PlayerId, ?TIMES_VIP_EVERYDAY_TIMES);
                true ->
                    noop
            end,
            db:write(SignData#db_player_everyday_sign{today = ToDay, state = ?SIGNED_IN, change_time = CurrTime}),
            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_EVERYDAY_SIGN),
            ok
        end,
    db:do(Tran).

%% 当前天数
notice_day(PlayerId, _) ->
    {Day, NewRound} = get_day_and_round(PlayerId),
    api_everyday_sign:notice_time(PlayerId, Day, NewRound).
%%    NewDay =
%%        if
%%            Day == 1 ->
%%                lists:foreach(
%%                    fun(Today) ->
%%                        EverydaySignInit = get_everyday_sign_init(PlayerId, Today),
%%                        ChangeTime = EverydaySignInit#db_player_everyday_sign.change_time,
%%                        case util_time:is_today(ChangeTime) of
%%                            true ->
%%                                ok;
%%                            _ ->
%%                                Tran =
%%                                    fun() ->
%%                                        db:delete(EverydaySignInit)
%%                                    end,
%%                                db:do(Tran),
%%                                ok
%%                        end
%%                    end, logic_get_everyday_sign_day_list()),
%%                1;
%%            true ->
%%                Day
%%        end,

%% 获得天数和轮数
get_day_and_round(PlayerId) ->
    RegTime = mod_player:get_player_data(PlayerId, reg_time),       %% 获取注册时间
    LoginDay = util_time:get_abs_interval_day(RegTime) + 1,             %% 登入天数
    Day = case LoginDay rem ?SIGN_AGAIN_DAY of
              0 ->
                  ?SIGN_AGAIN_DAY;
              R ->
                  R
          end,
    [Min, Max] = ?SD_EVERYDAY_SIGN_ROUND,
    Round1 = util_time:get_abs_interval_day(RegTime) div 30 + 1,
    NewRound =
        if
            Round1 > Max ->
                NotRound = Min - 1,
                case (Round1 - NotRound) rem (Max - Min + 1) of
                    0 ->
                        Max;
                    Round2 ->
                        Round2 + NotRound
                end;
            true ->
                Round1
        end,
    {Day, NewRound}.

%% ================================================ 数据操作 ================================================
%% 每日签到数据
get_everyday_sign(PlayerId, ToDay) ->
    db:read(#key_player_everyday_sign{player_id = PlayerId, today = ToDay}).

%% 每日签到数据       并初始化
get_everyday_sign_init(PlayerId, ToDay) ->
    {Day, _NewRound} = get_day_and_round(PlayerId),
    CurrTime = util_time:timestamp(),                               %% 获得当前时间
    AgainTime = CurrTime - (Day - 1) * 86400,
    AgainNewTime = util_time:get_today_zero_timestamp(AgainTime),   %% 获得新一轮的零点
    case get_everyday_sign(PlayerId, ToDay) of
        EveryDaySign when is_record(EveryDaySign, db_player_everyday_sign) ->
            ChangeTime = EveryDaySign#db_player_everyday_sign.change_time,
            if
                ChangeTime >= AgainNewTime ->
            EveryDaySign;
                true ->
                    EveryDaySign#db_player_everyday_sign{state = 0}
            end;
        _ ->
            #db_player_everyday_sign{player_id = PlayerId, today = ToDay}
    end.

%% ================================================ 模板操作 ================================================
%% 获得每日签到模板
try_get_t_everyday_sign(Count, ToDay) ->
    T_ToDay = t_everyday_sign:get({Count, ToDay}),
    ?IF(is_record(T_ToDay, t_everyday_sign), T_ToDay, exit({null_t_every_sign, {Count, ToDay}})).

logic_get_everyday_sign_day_list() ->
    case logic_get_everyday_sign_day_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.
