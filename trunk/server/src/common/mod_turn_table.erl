%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         转盘抽奖
%%% @end
%%% Created : 08. 三月 2021 下午 03:25:43
%%%-------------------------------------------------------------------
-module(mod_turn_table).
-author("Administrator").

%%-include("gen/table_enum.hrl").
%%-include("gen/table_db.hrl").
%%-include("common.hrl").
%%-include("player_game_data.hrl").
%%-include("error.hrl").
%%
%%%% API
%%-export([
%%    init/1,             %% 初始化
%%    timer_reset/1,      %% 定时器重置
%%
%%    draw/2,             %% 抽奖
%%    get_award/1         %% 获得进度值奖励
%%]).
%%
%%%% @doc 初始化
%%init(PlayerId) ->
%%    case mod_function:is_open(PlayerId, ?FUNCTION_TURNTABLE_SYS) of
%%        true ->
%%            LastUpdateTime = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME),
%%            TodayUpdateTime = util_time:get_today_zero_timestamp() + 2 * ?HOUR_S,
%%            CurrTime = util_time:timestamp(),
%%            UpdateTime =
%%                if
%%                    CurrTime >= TodayUpdateTime ->
%%                        TodayUpdateTime;
%%                    true ->
%%                        TodayUpdateTime - ?DAY_S
%%                end,
%%            Tran =
%%                fun() ->
%%                    if
%%                        LastUpdateTime >= UpdateTime ->
%%                            noop;
%%                        true ->
%%                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE, 0),
%%                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME, CurrTime)
%%                    end
%%                end,
%%            db:do(Tran);
%%        false ->
%%            noop
%%    end,
%%    ok.
%%
%%%% @doc 定时器重置
%%timer_reset(PlayerId) ->
%%    case mod_function:is_open(PlayerId, ?FUNCTION_TURNTABLE_SYS) of
%%        true ->
%%            Tran =
%%                fun() ->
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE, 0),
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME, util_time:timestamp()),
%%                    db:tran_apply(fun() -> api_turn_table:notice_reset(PlayerId) end)
%%                end,
%%            db:do(Tran);
%%        false ->
%%            noop
%%    end.
%%
%%%% @doc 抽奖
%%draw(PlayerId, Times) ->
%%    FunctionId = ?FUNCTION_TURNTABLE_SYS,
%%    mod_function:assert_open(PlayerId, FunctionId),
%%    ?ASSERT(lists:member(Times, [1, 10])),
%%    CostItemList =
%%        case Times of
%%            1 ->
%%                ?SD_TURNTABLE_1_TIMES;
%%            10 ->
%%                ?SD_TURNTABLE_10_TIMES
%%        end,
%%    mod_prop:assert_prop_num(PlayerId, CostItemList),
%%    IdWeightsList = lists:map(
%%        fun({Id}) ->
%%            #t_turntable{
%%                weights = Weights
%%            } = get_t_turntable(Id),
%%            {Id, Weights}
%%        end,
%%        t_turntable:get_keys()
%%    ),
%%    IdList = util_random:get_probability_item_count_by_can_repeat(IdWeightsList, Times),
%%    NewAwardList = lists:foldl(
%%        fun(Id, AwardListTmp) ->
%%            #t_turntable{
%%                award_list = AwardList
%%            } = get_t_turntable(Id),
%%            AwardList ++ AwardListTmp
%%        end,
%%        [], IdList
%%    ),
%%    mod_prop:assert_give(PlayerId, NewAwardList),
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE),
%%    NewValue = min(Times * ?SD_TURNTABLE_EXP + Value, ?SD_TURNTABLE_MAX_POINT),
%%    Tran =
%%        fun() ->
%%            mod_prop:decrease_player_prop(PlayerId, CostItemList, ?LOG_TYPE_TURN_TABLE),
%%            mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_TURN_TABLE),
%%            if
%%                NewValue =/= Value ->
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE, NewValue),
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME, util_time:timestamp());
%%                true ->
%%                    noop
%%            end
%%        end,
%%    db:do(Tran),
%%    {ok, IdList, NewValue}.
%%
%%%% @doc 获得进度值奖励
%%get_award(PlayerId) ->
%%    FunctionId = ?FUNCTION_TURNTABLE_SYS,
%%    mod_function:assert_open(PlayerId, FunctionId),
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE),
%%    ?ASSERT(Value >= ?SD_TURNTABLE_MAX_POINT, ?ERROR_NOT_AUTHORITY),
%%    AwardList = mod_award:decode_award(?SD_TURNTABLE_REWARD),
%%    mod_prop:assert_give(PlayerId, AwardList),
%%    Tran =
%%        fun() ->
%%            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_TURN_TABLE),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_VALUE, 0),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME, util_time:timestamp())
%%        end,
%%    db:do(Tran),
%%    {ok, AwardList}.
%%
%%%% ================================================ 模板操作 ================================================
%%
%%%% @doc 获得转盘抽奖表
%%get_t_turntable(Id) ->
%%    t_turntable:assert_get({Id}).
