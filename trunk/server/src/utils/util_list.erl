%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc            列表
%%% @end
%%% Created : 02. 一月 2018 下午 6:17
%%%-------------------------------------------------------------------
-module(util_list).

%% API
-export([
    opt/2,                              %% 获取key 对应的value
    opt/3,
    shuffle/1,                          %% 打乱列表
    key_insert/2,
    key_find/3,
    key_take/3,
    key_delete/3,
    get_element_index/2,
    rkeysort/2,
    rSortKeyList/2,
    splitwith2/2,
    subtract/2,
    key_sum/2,                          %% 获取列表对应key值的和
    calc_two_key_list/4,                %% 计算双key处理
    get_value_from_range_list/2,
    get_value_from_range_list_1/2,
    get_value_from_range_list/3,
    get_element_from_range_list/2,      %% 获取列表范围内的Element
    unique/1
]).

-export([
    change_list_join_null/1,            %% 参数拼接为空
    change_list_url/1,                  %% url参数
    change_list_url/2,                  %% url参数
    change_list/3                       %% url参数
]).

%% ----------------------------------
%% @doc 	打乱列表
%% @throws 	none
%% @end
%% ----------------------------------
shuffle(L) ->
    List1 = [{rand:uniform(), X} || X <- L],
    List2 = lists:keysort(1, List1),
    [E || {_, E} <- List2].

%% ----------------------------------
%% @doc 	获取key 对应的value
%% @throws 	none
%% @end
%% ----------------------------------
opt(Key, Options) ->
    opt(Key, Options, undefined).
opt(Key, [{Key, Value} | _], _Default) ->
    Value;
opt(Key, [[Key, Value] | _], _Default) ->
    Value;
opt(Key, [_ | Options], Default) ->
    opt(Key, Options, Default);
opt(_, [], Default) ->
    Default.


%% list查找列表中的值
key_find(_Key, _PosId, []) ->
    false;
key_find(Key, PosId, [L1 | List]) ->
    K1 = lists:nth(PosId, L1),
    if
        K1 == Key ->
            L1;
        true ->
            key_find(Key, PosId, List)
    end.
%% list查找列表中的值
key_take(Key, Pos, List) ->
    key_take1(Key, Pos, List, []).
key_take1(_, _, [], _) ->
    false;
key_take1(Key, PosId, [L1 | List], NewList) ->
    K1 = lists:nth(PosId, L1),
    if
        K1 == Key ->
            {value, L1, NewList ++ List};
        true ->
            key_take1(Key, PosId, List, [L1 | NewList])
    end.

%% @doc list删除列表中的值
key_delete(Key, Pos, List) ->
    key_delete1(Key, Pos, List, []).
key_delete1(_Key, _Pos, [], TmpList) ->
    lists:reverse(TmpList);
key_delete1(Key, Pos, [DataList | List], TmpList) ->
    K1 = lists:nth(Pos, DataList),
    if
        K1 == Key ->
            lists:reverse(TmpList) ++ List;
        true ->
            key_delete1(Key, Pos, List, [DataList | TmpList])
    end.

%% ----------------------------------
%% @doc 	获取列表对应key值的和
%% @throws 	none
%% @end
%% ----------------------------------
key_sum(N, L) ->
    do_key_sum(N, L, 0).
do_key_sum(_N, [], Sum) ->
    Sum;
do_key_sum(N, [E | L], Sum) ->
    do_key_sum(N, L, Sum + erlang:element(N, E)).


%% ----------------------------------
%% @doc 	列表去重 (列表数量比较大时, 性能比 --好很多)
%% @throws 	none
%% @end
%% ----------------------------------
subtract(L1, L2) ->
    HugeSet1 = ordsets:from_list(L1),
    HugeSet2 = ordsets:from_list(L2),
    ordsets:subtract(HugeSet1, HugeSet2).

%% ----------------------------------
%% @doc 	把列表分成两部分 List => {List1, List2}
%% @throws 	none
%% @end
%% ----------------------------------
splitwith2(Fun, List) when is_function(Fun) ->
    do_splitwith2(Fun, List, {[], []}).
do_splitwith2(_Fun, [], {L1, L2}) ->
    {L1, L2};
do_splitwith2(Fun, [H | T], {L1, L2}) ->
    case Fun(H) of
        true ->
            do_splitwith2(Fun, T, {[H | L1], L2});
        false ->
            do_splitwith2(Fun, T, {L1, [H | L2]})
    end.


%% input {Key, Value} out:[{Key, [Value1,Value2,Value3.......]} ...]
key_insert({Key, Value}, Lists) ->
    key_insert({Key, Value}, Lists, []).
%%key_insert({Key, Value}, [{Key, Source} | T], []) -> [{Key, [Value | Source]} | T];
key_insert({Key, Value}, [{Key, ValueList} | T], L) -> [{Key, [Value | ValueList]} | lists:append(T, L)];
key_insert({Key, Value}, [H | T], L) -> key_insert({Key, Value}, T, [H | L]);
key_insert({Key, Value}, [], L) -> [{Key, [Value]} | L].
%%key_insert(_Value, [], L) -> L.

%% ----------------------------------
%% @doc 	获取element在列表里面的索引
%% @throws 	none
%% @end
%% ----------------------------------
get_element_index(Element, L) ->
    get_element_index(Element, L, 0).
get_element_index(_Element, [], _N) ->
    none;
get_element_index(Element, [Element | _L], N) ->
    {index, N + 1};
get_element_index(Element, [_H | L], N) ->
    get_element_index(Element, L, N + 1).


%% ----------------------------------
%% @doc 	列表从大到小排序
%% @throws 	none
%% @end
%% ----------------------------------
rkeysort(Key, L) ->
    F = fun(A, B) ->
        I_A = element(Key, A),
        I_B = element(Key, B),
        if I_A > I_B ->
            true;
            true ->
                false
        end
        end,
    lists:sort(F, L).


%% ----------------------------------
%% @doc 	多条件列表从大到小排序 State1:false(单项从小到大)
%   ZeroType:zeroMax(0:为最大值)
%% @throws 	none
%% @end KeyList[key1, key2]
%% ----------------------------------
rSortKeyList(KeyList, L) ->
    F = fun(A, B) ->
        rSortKeyList1(KeyList, A, B)
        end,
    lists:sort(F, L).
rSortKeyList1([], A, B) ->
    A > B;
rSortKeyList1([Key | KeyList], A, B) ->
    % State:true(从大到小)， false(从小到大)
    % ZeroType:0(0:为最大值), =/= 0(正常)
    {State, ZeroType, NewKey} =
        case Key of
            {_State1, Key1} ->
                {false, 1, Key1};
            {State1, zeroMax, Key1} ->
                {State1 == true, 0, Key1};
            _ ->
                {true, 1, Key}
        end,
    I_A = element(NewKey, A),
    I_B = element(NewKey, B),
    if
        I_A == I_B ->
            rSortKeyList1(KeyList, A, B);
        State == true ->
            if
                ZeroType == 0 ->
                    if
                        I_A == ZeroType ->
                            true;
                        I_B == ZeroType ->
                            false;
                        true ->
                            I_A > I_B
                    end;
                true ->
                    I_A > I_B
            end;
%%            I_A > I_B andalso ZeroType =/= 0 orelse I_A == ZeroType andalso ZeroType == 0;
        State == false ->
            if
                ZeroType == 0 ->
                    if
                        I_A == ZeroType ->
                            false;
                        I_B == ZeroType ->
                            true;
                        true ->
                            I_A < I_B
                    end;
                true ->
                    I_A < I_B
            end;
%%%%%%            I_A < I_B  andalso ZeroType =/= 0 orelse I_A =/= ZeroType andalso ZeroType == 0;
%%        I_A > I_B andalso State == true orelse State == false andalso I_A < I_B ->
%%            true;
        true ->
            false
    end.

%% ----------------------------------
%% @doc 	获取列表范围内的value
%% @throws 	none
%% @end
%% ----------------------------------
%% RangList: [[Min, Max, Value]]    Element:固定三个
%% return: value
get_value_from_range_list(I, RangList) ->
    get_value_from_range_list(I, RangList, undefined).
get_value_from_range_list(_I, [], Default) ->
    Default;
get_value_from_range_list(I, [Element | RangList], Default) ->
    [Min, Max, Value] =
        case Element of
            {Min1, Max1, Value1} ->
                [Min1, Max1, Value1];
            _ ->
                Element
        end,
%%    if I >= Min andalso I =< Max  ->
    if I >= Min andalso (I =< Max orelse Max == 0) ->
        Value;
        true ->
            get_value_from_range_list(I, RangList, Default)
    end.

%% ----------------------------------
%% @doc 	获取列表范围内的value
%% @throws 	none
%% @end
%% ----------------------------------
%% RangList: [[Min, Max, Value]]    Element:固定三个
%% return: value
get_value_from_range_list_1(I, RangList) ->
    get_value_from_range_list_1(I, RangList, undefined).
get_value_from_range_list_1(_I, [], Default) ->
    Default;
get_value_from_range_list_1(I, [Element | RangList], Default) ->
    [Min, Max, Value] =
        case Element of
            {Min1, Max1, Value1} ->
                [Min1, Max1, Value1];
            _ ->
                Element
        end,
%%    if I >= Min andalso I =< Max  ->
    if I >= Min andalso I =< Max ->
        Value;
        true ->
            get_value_from_range_list_1(I, RangList, Default)
    end.


%% ----------------------------------
%% @doc 	获取列表范围内的Element
%% @throws 	none
%% @end
%% ----------------------------------
%% RangList: [[Min, Max|Value]]     Element:元素可大于等于 三个
%% return: value
get_element_from_range_list(_I, []) ->
    undefined;
get_element_from_range_list(I, [Element | RangList]) ->
    [Min, Max | _] = Element,
    if I >= Min andalso (I =< Max orelse Max == 0) ->
        Element;
        true ->
            get_element_from_range_list(I, RangList)
    end.


%%% 列表转换      % JoinTuple key JoinSon Value 例如: "&key=value"
change_list_url(List) ->
    change_list(List, "&", "=").
%%% 列表转换    % key=value
change_list_join_null(List) ->
    change_list(List, "", "=").

%% @fun 列表转换(直接拼接)
change_list_url(List, JoinTuple) ->
    change_list(List, JoinTuple, "").
change_list([], _JoinTuple, _JoinSon) ->
    [];
change_list(List, JoinTuple, JoinSon) ->
    ListSort = lists:reverse(List),
    ListConCat = change_list(ListSort, [], JoinTuple, JoinSon),
    lists:concat(ListConCat).
change_list([], L, _JoinTuple, _JoinSon) ->
    L;
change_list([{Key, Value} | List], L, JoinTuple, JoinSon) ->
    Result =
        if
            List == [] ->
                [Key, JoinSon, Value];
            true ->
                [JoinTuple, Key, JoinSon, Value]
        end,
    change_list(List, Result ++ L, JoinTuple, JoinSon);
change_list([Value | List], L, JoinTuple, JoinSon) ->
    Result =
        if
            List == [] ->
                [Value];
            true ->
                [JoinTuple, Value]
        end,
    change_list(List, Result ++ L, JoinTuple, JoinSon).


%% @doc fun 计算双key处理
calc_two_key_list(Conditions, ValueKey, Value, TempList) ->
    case lists:keytake(Conditions, 1, TempList) of
        {value, {Conditions, ConditionsList}, List1} ->
            case lists:keytake(ValueKey, 1, ConditionsList) of
                {value, {ValueKey, ConditionsValueList}, ValueList1} ->
                    [
                        {
                            Conditions,
                            [{
                                ValueKey,
                                [Value | ConditionsValueList]
                            } | ValueList1]
                        } | List1
                    ];
                _ ->
                    [
                        {
                            Conditions,
                            [{
                                ValueKey,
                                [Value]
                            } | ConditionsList]
                        } | List1
                    ] end;
        _ ->
            [{Conditions, [{ValueKey, [Value]}]} | TempList]
    end.

%% 列表去重
unique(List) -> unique(List, []).
unique([], ResultList) -> lists:reverse(ResultList);
unique([H | L], ResultList) ->
    case lists:member(H, ResultList) of
        true -> unique(L, ResultList);
        false -> unique(L, [H | ResultList])
    end.
