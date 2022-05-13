%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc            随机
%%% @end
%%% Created : 02. 一月 2018 下午 6:16
%%%-------------------------------------------------------------------
-module(util_random).
-include("common.hrl").
%% API
-export([
    random_number/1,
    random_number/2,
    p/1,
    get_list_random_member/1,       %% 获得列表随机元素
    get_rate_list_rateNum/2,        %% 获得概率组中的概率
    get_probability_item/1,
    get_probability_item_2/1,
    get_rand_idx/1
]).

-export([
    get_probability_item_count_by_can_repeat/2,  %% 随机列表中可重复的 Num个元素
    get_probability_item_count/2    %% 随机列表中不重复的 Num个元素
]).

%% ----------------------------------
%% @doc 	获取随机数 [1, Range]
%% @throws 	none
%% @end
%% ----------------------------------
random_number([Min, Max]) when is_integer(Min) andalso is_integer(Max) ->
    random_number(Min, Max);
random_number(Range) ->
    rand:uniform(Range).

%% ----------------------------------
%% @doc 	获取随机数 [Min, Max]
%% @throws 	none
%% @end
%% ----------------------------------
random_number(Min, Min) ->
    Min;
random_number(Min, Max) ->
    NewRange = Max - Min + 1,
    random_number(NewRange) + Min - 1.

%% ----------------------------------
%% @doc 	概率
%% @throws 	none
%% @end
%% ----------------------------------
p(P) ->
    if
        P >= 10000 ->
            true;
        P =< 0 ->
            false;
        true ->
            RandomNum = rand:uniform(10000),
            if
                RandomNum =< P ->
                    true;
                true ->
                    false
            end
    end.

%% @doc  获得列表随机元素
get_list_random_member(List) ->
    lists:nth(random_number(length(List)), List).

%% 获取概率项 ProbabilityList = [{a, 20}, {b, 30}, {c, 50}]    Result:a
get_probability_item([{Value, _Weight}]) ->
    Value;
get_probability_item(ProbabilityList1) ->
    ProbabilityList = lists:map(
        fun(Data) ->
            case Data of
                [A, B] ->
                    {A, B};
                {A, B} ->
                    {A, B}
            end
        end, ProbabilityList1
    ),
    Probability = trunc(lists:sum([B || {_A, B} <- ProbabilityList])),
    RandNum = rand:uniform(Probability),
    {Result, _} = get_probability_item(RandNum, ProbabilityList, 0),
    Result.

%% @doc 随机列表中可重复的 Num个元素
get_probability_item_count_by_can_repeat(_List, 0) ->
    [];
get_probability_item_count_by_can_repeat(List, Num) ->
    Probability = trunc(lists:sum([N || {_, N} <- List])),
    ?ASSERT(Probability > 0, probability_0),
    lists:map(
        fun(_) ->
            RandNum = rand:uniform(Probability),
            {Result, _} = get_probability_item(RandNum, List, 0),
            Result
        end,
        lists:seq(1, Num)
    ).

%% @doc     随机列表中不重复的 Num个元素
get_probability_item_count(List, Num) ->
    get_probability_item_count1(List, Num, []).

get_probability_item_count1(_, 0, L) ->
    L;
get_probability_item_count1(List, Num, L) ->
    Probability = trunc(lists:sum([N || {_, N} <- List])),
    ?ASSERT(Probability > 0, probability_0),
    RandNum = rand:uniform(Probability),
    ResultTuple = get_probability_item(RandNum, List, 0),
    {Result, _} = ResultTuple,
    get_probability_item_count1(List -- [ResultTuple], Num - 1, [Result | L]).

%% @fun 获得列表中的元素
get_probability_item(_RandNum, [], _CountRandNum) ->
    {0, 0};
get_probability_item(RandNum, [{Tuple, Rate} | List], CountRandNum) ->
    NewCountRandNum = CountRandNum + Rate,
    if
        RandNum =< NewCountRandNum ->
            {Tuple, Rate};
        true ->
            get_probability_item(RandNum, List, NewCountRandNum)
    end.


%% 获取概率项 ProbabilityList = [[prop_type, prop_id, num, p]]
get_probability_item_2(List) ->
    TotalP = lists:sum([N || [_, _, _, N] <- List]),
    ?t_assert(TotalP > 1, {get_probability_item_2, List}),
    P = rand:uniform(TotalP),
    {_, Result} = lists:foldl(
        fun([PropType, PropId, Num, Rate], {TotalRate, E}) ->
            if E == null ->
                NewTotalRate = TotalRate + Rate,
                if NewTotalRate >= P ->
                    {NewTotalRate, {PropType, PropId, Num}};
                    true ->
                        {NewTotalRate, null}
                end;
                true ->
                    {TotalRate, E}
            end
        end,
        {0, null},
        List
    ),
    Result.

%% @doc     获得概率组中的概率
get_rate_list_rateNum([], _RateNum) ->
    0;
get_rate_list_rateNum([[InitNum, TopNum, RateNum1] | List], RateNum) ->
    if
        InitNum =< RateNum andalso (RateNum =< TopNum orelse TopNum == 0) ->
            RateNum1;
        true ->
            get_rate_list_rateNum(List, RateNum)
    end.

% -----------------------------------------------------------------
% 获取随机概率索引
% -----------------------------------------------------------------
get_rand_idx(WeightList) ->
    RandNum = rand:uniform(lists:sum(WeightList)),
    get_rand_idx(WeightList, RandNum, 0, 0).
get_rand_idx([Weight | _List], RandNum, BaseScore, Index) when RandNum =< (Weight + BaseScore) ->
    Index + 1;
get_rand_idx([Weight | List], RandNum, BaseScore, Index) ->
    get_rand_idx(List, RandNum, Weight + BaseScore, Index + 1).