%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%       自定义生成逻辑数据代码
%%% @end
%%% Created : 27. 5月 2021 12:00
%%%-------------------------------------------------------------------

-module(logic_code2).

-export([start/0]).
-include("common.hrl").
-include("gen/table_db.hrl").

%% {EtsTable, Tag, Params}
%% Tag:
%%      compare 快速对比
%%      group 快速分组
%%      group_compare 分组后快速对比
%%      key_index 主键索引
-define(TRAN_CONFIG, [
    {t_jiangjinchi_award, group_compare, [#t_jiangjinchi_award.sceneid, #t_jiangjinchi_award.award_min, #t_jiangjinchi_award.award_max]},
    {t_tongxingzheng_level, group, [#t_tongxingzheng_level.id]},
    {t_activity_lei_chong, group, [#t_activity_lei_chong.activity_id]},
    {t_bubble, group, [#t_bubble.type]},
    {t_monster_function_task, group, [{#t_monster_function_task.scene_id, #t_monster_function_task.task_type}]},
    {t_monster_effect, key_index, [#t_monster_effect.effect_id]},
    {t_daily_task, group, [#t_daily_task.type]},
    {t_laba_icon, group, [#t_laba_icon.type]},
    {t_laba_icon, key_index, [{#t_laba_icon.type, #t_laba_icon.id}]},
    {t_labapreset, group, [{#t_labapreset.type, #t_labapreset.presetlevel}]},
    {t_labaline, group, [#t_labaline.type]}
]).

start() ->
    io:format("~n ### build table2code start! ~n~n"),

    [
        begin
            FileName = io_lib:format("~s@~s", [atom_to_list(TableName), FuncTag]),
            FullFileName = filename:join([?CODE_PATH, FileName ++ ".erl"]),
            io:format("Create file ~s ~s", [FullFileName, lists:duplicate(max(0, 45 - length(FullFileName)), ".")]),

            TermList = lists:keysort(3, ets:tab2list(TableName)),
            Head = file_head(FileName),
            {Body, Export} = term_to_code(TermList, FuncTag, Params),
            io:format(" [ok]~n"),
            util_file:save_code(FullFileName, lists:flatten([Head, Export, Body]), true)
        end || {TableName, FuncTag, Params} <- ?TRAN_CONFIG
    ],

    io:format("~n ### build table2code end! ~n~n"),
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
file_head(FileName) ->
    Desc = "%%% Generated automatically, no need to modify.\n",
    Mod = io_lib:format("-module(~s).\n", [FileName]),
    lists:flatten([Desc, Mod]).

term_to_code(TermList, compare, Params) ->
    [MinNth, MaxNth] = Params,
    term_to_code_by_compare(TermList, MinNth, MaxNth);
term_to_code(TermList, group, Params) ->
    [Nth] = Params,
    term_to_code_by_group(TermList, Nth);
term_to_code(TermList, group_compare, Params) ->
    [Nth, MinNth, MaxNth] = Params,
    term_to_code_by_groupcompare(TermList, Nth, MinNth, MaxNth);
term_to_code(TermList, key_index, Params) ->
    [Nth] = Params,
    term_to_code_by_keyindex(TermList, Nth);
term_to_code(_, _Tag, _) ->
    exit({unknow_tag, _Tag}).

term_to_code_by_compare(TermList, MinNth, MaxNth) ->
    Fun =
        fun(X, StrBody) ->
            MinNum = element(MinNth, X),
            MaxNum = element(MaxNth, X),
            Str = io_lib:format("get(Num) when is_integer(Num), Num >= ~p, (Num =< ~p orelse ~p =:= 0) -> \n\t ~w;\r\n", [MinNum, MaxNum, MaxNum, X]),
            StrBody ++ Str
        end,
    Body1 = lists:foldl(Fun, "", TermList),
    Body2 = io_lib:format("get(_) -> \n\t undefined.\r\n", []),
    ExtraExport = "-export([get/1]).\n\r",
    {lists:flatten([Body1, Body2]), ExtraExport}.

term_to_code_by_group(TermList, Nth) ->
    Types =
        lists:foldl(fun(X, Acc)->
            Type = get_group_type(Nth, X),
            case lists:member(Type, Acc) of
                false -> [Type | Acc];
                _ -> Acc
            end
        end, [], TermList),
    Body = io_lib:format("get_group_keys() ->\n\t ~w.\n\r", [Types]),
    Fun =
        fun(Type, StrBody) ->
            List = [ X || X <- TermList, get_group_type(Nth, X) =:= Type ],
            Str = io_lib:format("get(~p) -> \n\t ~w;\r\n", [Type, List]),
            StrBody ++ Str
        end,
    Body1 = lists:foldl(Fun, "", lists:sort(Types)),
    Body2 = io_lib:format("get(_) -> \n\t undefined.\n\r", []),
    Fun2 =
        fun(Type, StrBody) ->
            List = [ X || X <- TermList, get_group_type(Nth, X) =:= Type ],
            Str = io_lib:format("get_group_size(~p) -> ~p;\r\n", [Type, length(List)]),
            StrBody ++ Str
        end,
    Body3 = lists:foldl(Fun2, "", lists:sort(Types)),
    Body4 = io_lib:format("get_group_size(_) -> 0.\r\n", []),
    ExtraExport = "-export([get_group_keys/0, get/1, get_group_size/1]).\n\r",
    {lists:flatten([Body, Body1, Body2, Body3, Body4]), ExtraExport}.

term_to_code_by_groupcompare(TermList, Nth, MinNth, MaxNth) ->
    Types =
        lists:foldl(fun(X, Acc)->
            Type = get_group_type(Nth, X),
            case lists:member(Type, Acc) of
                false -> [Type | Acc];
                _ -> Acc
            end
        end, [], TermList),
    Fun =
        fun(Type, Acc) ->
            GroupList = [ X || X <- TermList, get_group_type(Nth, X) =:= Type ],
            Fun2 =
                fun(X, StrBody) ->
                    MinNum = element(MinNth, X),
                    MaxNum = element(MaxNth, X),
                    Str = io_lib:format("get(Group, Num) when is_integer(Num), is_integer(Num), Group =:= ~p,  Num >= ~p, (Num =< ~p orelse ~p =:= 0) -> \n\t ~w;\r\n", [Type, MinNum, MaxNum, MaxNum, X]),
                    StrBody ++ Str
                end,
            Acc ++ lists:foldl(Fun2, "", GroupList)
        end,
    Body = io_lib:format("get_group_keys() ->\n\t ~w.\n\r", [Types]),
    Body1 = lists:foldl(Fun, "", lists:sort(Types)),
    Body2 = io_lib:format("get(_, _) -> \n\t undefined.\r\n", []),
    ExtraExport = "-export([get_group_keys/0, get/2]).\n\r",
    {lists:flatten([Body, Body1, Body2]), ExtraExport}.

term_to_code_by_keyindex(TermList, Nth) ->
    Keys = lists:foldl(
        fun(X, TmpKeys) ->
            Key = get_group_type(Nth, X),
            ordsets:add_element(Key, TmpKeys)
        end, [], TermList),
    ?ASSERT(length(Keys) == length(TermList), key_repeated),
    Body = io_lib:format("get_keys() ->\n\t ~w.\n\r", [Keys]),
    Fun =
        fun(X, StrBody) ->
            Type = get_group_type(Nth, X),
            Str = io_lib:format("get(~p) -> \n\t ~w;\r\n", [Type, X]),
            StrBody ++ Str
        end,
    Body1 = lists:foldl(Fun, "", TermList),
    Body2 = io_lib:format("get(_) -> \n\t undefined.\r\n", []),
    ExtraExport = "-export([get_keys/0, get/1]).\n\r",
    {lists:flatten([Body, Body1, Body2]), ExtraExport}.

% #####################
get_group_type(Nth, Tuple) when is_integer(Nth) ->
    element(Nth, Tuple);
get_group_type(Nth, Tuple) when is_tuple(Nth) ->
    NthList = tuple_to_list(Nth),
    list_to_tuple([element(Nth0, Tuple) || Nth0 <- NthList]).