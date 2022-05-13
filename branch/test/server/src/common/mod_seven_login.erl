%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         七天登錄
%%% @end
%%% Created : 10. 五月 2021 下午 12:17:49
%%%-------------------------------------------------------------------
-module(mod_seven_login).
-author("home").

%% API
-export([
    get_already_give_day_list/1,        %% 获得七天登录已领取天数列表
    give_award/2                        %% 获得七天登入奖励
]).

-export([
    get_cumulative_day/1,               %% 獲得纍計登錄天數

    login_set_day/1,                    %% 登錄設置天數
    time_0_set_day/1                    %% 0點設置天數
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

-define(DICE_TYPE, 1).                  %% 基本類型
-define(CUMULATIVE_TYPE, 2).            %% 連續登錄類型
-define(VIP_TYPE, 3).                   %% VIP類型

%% @doc 获得七天登录已领取天数列表
get_already_give_day_list(PlayerId) ->
    DbPlayerSevenLogin = get_db_seven_login_or_init(PlayerId),
    #db_player_seven_login{
        give_award_value = GiveAwardValue
    } = DbPlayerSevenLogin,
    AlreadyGiveDayList = lists:foldl(
        fun({Day}, TmpL) ->
            ?IF(get_day_is_give(GiveAwardValue, Day), [Day | TmpL], TmpL)
        end,
        [], t_seven_login:get_keys()
    ),
    AlreadyGiveDayList.

%% @doc 领取七天登入奖励
give_award(PlayerId, Today) when Today > 0 ->
    mod_function:assert_open(PlayerId, ?FUNCTION_SEVEN_LOGIN_SYS),
    CumulativeDay = get_cumulative_day(PlayerId),
    ?ASSERT(Today =< CumulativeDay, ?ERROR_NOT_AUTHORITY),
    DbPlayerSevenLogin = get_db_seven_login_or_init(PlayerId),
    #db_player_seven_login{
        give_award_value = GiveAwardValue
    } = DbPlayerSevenLogin,
    ?ASSERT(not get_day_is_give(GiveAwardValue, Today), ?ERROR_ALREADY_HAVE),
    #t_seven_login{
        award_list = AwardList
    } = get_t_seven_login(Today),
    DiceWeightList = logic_get_seven_login_laba_weight_list(Today),
    DiceId = util_random:get_probability_item(DiceWeightList),
    #t_seven_login_laba{
        dice_list = DiceList
    } = get_t_seven_login_laba(Today, DiceId),
    DiceValue = lists:sum(DiceList) * ?SD_SEVEN_LOGIN_BASE_RATE,
    VipLevel = mod_vip:get_vip_level(PlayerId),
    VipValue =
        if
            VipLevel == 0 ->
                0;
            true ->
                #t_vip_level{
                    seven_login_vip_rate = SevenLoginVipRate,
                    seven_login_vip_coin_count = SevenLoginVipCoinCount
                } = t_vip_level:assert_get({VipLevel}),
                round(DiceValue * SevenLoginVipRate / 10000) + SevenLoginVipCoinCount
        end,
    DiceAwardList = [[?ITEM_GOLD, DiceValue + VipValue]],
    NewAwardList = mod_prop:merge_prop_list(DiceAwardList ++ AwardList),
    DiceDataList = [{?DICE_TYPE, DiceValue}, {?VIP_TYPE, VipValue}],
    mod_prop:assert_give(PlayerId, NewAwardList),
    Tran =
        fun() ->
            db:write(DbPlayerSevenLogin#db_player_seven_login{give_award_value = GiveAwardValue + (1 bsl (Today - 1))}),
            mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_SEVEN_LOGIN)
        end,
    db:do(Tran),
    {ok, DiceId, DiceDataList}.

%% ================================================ 工具函数 ================================================

%% @doc 获得某天是否领取
get_day_is_give(Value, Day) when Day > 0 ->
%%    ?DEBUG("七天登录，获取某天是否领取~p", [{Value, Day}]),
    List = integer_to_list(Value, 2),
    Length = length(List),
    if
        Day > Length ->
            false;
        true ->
            IsCanGet = list_to_integer([lists:nth(Day, lists:reverse(List))]),
            ?TRAN_INT_2_BOOL(IsCanGet)
    end.

%% @doc 獲得纍計登錄天數
get_cumulative_day(PlayerId) ->
    min(7, mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY)).

%% @doc 登錄設置天數
login_set_day(PlayerId) ->
    Now = util_time:timestamp(),
    LastTime = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY_LAST_TIME),
    OldDay = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY),
    LastLoginIsToday = util_time:is_today(LastTime),
    NewDay =
        case LastLoginIsToday of
            true ->
                OldDay;
            false ->
                OldDay + 1
        end,
    Tran =
        fun() ->
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY_LAST_TIME, Now),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY, NewDay)
        end,
    db:do(Tran),
    ok.

%% @doc 0點設置天數
time_0_set_day(PlayerId) ->
    Now = util_time:timestamp(),
    OldDay = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY),
    NewDay = OldDay + 1,
    Tran =
        fun() ->
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY_LAST_TIME, Now),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEVEN_LOGIN_DAY, NewDay),
            db:tran_apply(fun() -> api_seven_login:update_cumulative_day(PlayerId, NewDay) end)
        end,
    db:do(Tran),
    ok.

%% ================================================ 数据操作 ================================================
%% @doc 获得七天登入数据
get_db_seven_login(PlayerId) ->
    db:read(#key_player_seven_login{player_id = PlayerId}).
get_db_seven_login_or_init(PlayerId) ->
    case get_db_seven_login(PlayerId) of
        SevenLoginData when is_record(SevenLoginData, db_player_seven_login) ->
            SevenLoginData;
        _ ->
            #db_player_seven_login{player_id = PlayerId}
    end.

%% ================================================ 模板操作 ================================================
%% @doc 获得七天登入模板
get_t_seven_login(Today) ->
    t_seven_login:assert_get({Today}).

%% @doc 获得七天登入模板
get_t_seven_login_laba(Today, Id) ->
    t_seven_login_laba:assert_get({Today, Id}).

%% @doc 獲得七天登錄拉霸權重列表
logic_get_seven_login_laba_weight_list(Today) ->
    logic_get_seven_login_laba_weight_list:assert_get(Today).
