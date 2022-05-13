-module(string_file_vague).


-define(KEYWORDS_FILE, "../priv/sensitive.txt").
-define(OUT, "../src/gen/sensitive_vague.txt").

-define(OUT_KEY, "../src/gen/keycheck_vague.erl").

%% API
-export([
    start/0]).

%%head() ->
%%    "-module(sensitive).\n"
%%    "-export([get/0]).\n\n"
%%    "get() ->\n".

head_key() ->
    "-module(keycheck_vague).\n"
    "-export([mc/2]).\n\n".

start() ->
    {ok, File} = file:open(?KEYWORDS_FILE, [read]),

    Out = do(File, []),
    OutList = lists:usort(Out),    % 对得到结果进行反排序
%%    Out1 = lists:sort(Out),    % 对得到结果进行反排序
%%    OutList = [O || O <- Out1, hd(O)=={230,147,141}],
    file:close(File),

    Map = maps:new(),
    FinalMap = merge_map(OutList, Map, Map),
    key_start_vague(FinalMap).
%%    L = io_lib:format("~p", [OutList]),
%%%%
%%    {ok, File1} = file:open(?OUT, [write]),
%%    lib_file:write(File1, L),
%%    file:close(File1).

do(File, Out) ->
    case file:read_line(File) of
        {ok, Data} ->
            case strip(Data) of
                [] ->
                    do(File, Out);
                S ->
                    List = string_1(S),
%%                     {ok, MP} = re:compile(S),
                    do(File, [List | Out])
%%                    do(File, [format(List) | Out])
            end;
        eof ->
            Out;
        {error, Reason} ->
            exit(list_to_atom(Reason))
    end.

strip(S) ->
    S1 = string:strip(S, both, $\n),
    S2 = string:strip(S1, both, $\r),
    string:strip(S2).

string_1(String) ->
    lists:reverse(string_1(String, [])).

string_1([], List) ->
    List;
string_1(String, List) ->
    {Char, String2} = util_string:u8(String),
    string_1(String2, [Char | List]).

%% 初始列表解析
merge_map([], FinalMap, _Map) ->        % 找到最后一次了
    FinalMap;
merge_map([S | List], FinalMap, Map) ->
    merge_map(List, merge_map1(S, FinalMap, Map), Map).

%% 结果列表解析
merge_map1([], FinalMap, _Map) ->
    FinalMap;
merge_map1([S1 | List], FinalMap, Map) ->   % 解析 FinalList 第一层
    case maps:find(S1, FinalMap) of
        {ok, Value} ->   % 有相同的key
            L = merge_map2(List, Value, Map, [], []),
            maps:update(S1, L, FinalMap);
        _ ->            % 加入新的列表
            L = list_to_map(List, Map),
            maps:put(S1, L, FinalMap)
    end.

merge_map2(List, [], Map, NewList, Fs) ->
    L = list_to_map(List, Map),
    if
        L==fs ->
            NewList ++ [fs];
        true ->
            [L | NewList] ++ Fs
    end;
merge_map2([], MapList, Map, NewList, _Fs) ->
%%    io:format("~p: _____~p_____~p~n", [?LINE, NewList, MapList]),
    if
        MapList==fs orelse MapList==[fs] ->
%%            io:format("~p: _____~p_____1111111111111111111~n", [?LINE, MapList]),
            merge_map2([], [], Map, NewList, [fs]);
        true ->
            NewList ++ MapList ++ [fs]
    end;
merge_map2([S2 | L2] = List, [M | MapList] = MapLists, Map, NewList, Fs) when is_list(MapLists) ->
    if
        M==fs ->
            merge_map2(List, MapList, Map, NewList, [fs]);
        true ->
            case maps:find(S2, M) of
                {ok, Value} ->
                    L1 = maps:update(S2, merge_map2(L2, Value, Map, [], []), M),
                    if
                        MapList==[fs] orelse MapList==fs ->      % 列表最后一个值为fs
                            merge_map2([], [], Map, [L1], [fs]) ++ NewList;
                        true ->
                            L = if
                                    is_list(L1) ->
                                        L1 ++ MapList ++ NewList;
                                    true ->
                                        [L1 | MapList] ++ NewList
                                end,
                            list_fs_last(L, [], [])
                    end;
                _ ->
                    merge_map2(List, MapList, Map, [M | NewList], Fs)

            end
    end;
merge_map2([S2 | L2] = List, M, Map, NewList, Fs) ->
    if
        M==fs ->
            merge_map2(List, [], Map, NewList, [fs]);
        true ->
            case maps:find(S2, M) of
                {ok, Value} ->
                    L1 = maps:update(S2, merge_map2(L2, Value, Map, [], []), M),
                    L = if
                            is_list(L1) ->
                                NewList ++ L1;
                            true ->
                                NewList ++ [L1]
                        end,
                    list_fs_last(L, [], []);
                _ ->
                    merge_map2(List, [], Map, [M | NewList], Fs)
            end
    end.

% 剩余list转成map
list_to_map([], _Map) ->
    fs;
list_to_map([E | List], Map) ->
    maps:put(E, list_to_map(List, Map), Map).

% 列表中移动到最后
list_fs_last([], NewList, Fs) ->
    FS =
        if
            is_list(Fs) ->
                Fs;
            true ->
                [Fs]
        end,
    lists:reverse(NewList) ++ FS;
list_fs_last([M | List], NewList, Fs) ->
    if
        M==fs ->
            list_fs_last(List, NewList, [fs]);
        true ->
            list_fs_last(List, [M | NewList], Fs)
    end.

% 生成key文件
key_start_vague(Map) ->
%%    Map = sensitive:get(),
    Keys = maps:keys(Map),
    List = key_start_vague(Keys, Map, [], 0),
    erase(key_value),
    file:write_file(?OUT_KEY, head_key() ++ List).

key_start_vague([], _Map, List, _Count) ->        % 最尾部
    I = io_lib:format("mc (_, _) ->\n~sfs.\n ", [get_list_null(1)]),
    dict_format(List, 0) ++ [I];
key_start_vague([Key | Keys], Map, List, Count) ->
    case maps:find(Key, Map) of
        {ok, Value} ->
            NewList = dict_format(List, 0),
            key_start_vague(Keys, Map, key_map_vague1(Value, Key, Count, 1, NewList), Count);
        true ->
            key_start_vague(Keys, Map, List, Count)
    end.

key_map_vague([], _Map, List, Count) ->       % 每次的结束
    case get(key_value) of
        undefined ->
            put(key_value, [Count]);
        Val ->
            put(key_value, Val ++ [Count])
    end,
    List;
key_map_vague([Key | Keys] = KeyList, Map, List, Count) when is_list(KeyList) ->
    case maps:find(Key, Map) of
        {ok, Value} ->
            key_map_vague(Keys, Map, key_map_vague1(Value, Key, Count, 1, List), Count);
        true ->
            key_map_vague(Keys, Map, List, Count)
    end;
key_map_vague(Key, Map, List, Count) ->
    case maps:find(Key, Map) of
        {ok, Value} ->
            key_map_vague([], Map, key_map_vague1(Value, Key, Count, 1, List), Count);
        true ->
            key_map_vague([], Map, List, Count)
    end.

key_map_vague1([], _, _, _, NewList) ->
    NewList;
key_map_vague1([Map | Maps] = MapList, Key, Count, SingleCount, NewList) when is_list(MapList) ->
    case check_fs(MapList) of
        true ->
            key_map_vague1([], fs1, Count, SingleCount + 1, NewList ++  key_map_vague1(fs, Key, Count, SingleCount, []));
        _ ->
            F =
                fun(M) ->
                    key_map_vague1(M, Key, Count, SingleCount, [])
                end,

            if
                length(MapList)==2 andalso not is_list(Maps) ->
                    key_map_vague1([Maps], fs1, Count, SingleCount + 1, NewList ++ F(Map));
                true ->
                    key_map_vague1(Maps, fs1, Count, SingleCount + 1, NewList ++ F(Map))
            end
    end;

key_map_vague1(Map, Key, Count, SingleCount, List) ->
    NewList = dict_format(List, 1),
    if
        Count==0 ->
            if
                Map==fs ->
                    I = if
                            SingleCount > 1 ->
                                if
                                    Key==fs1 ->
                                        io_lib:format("~s_ ->\n~s{ok, S0, 1} end;\n ", [get_list_null(Count + 1), get_list_null(Count + 2)]);
                                    true ->
                                        io_lib:format("~s_ -> \n~sfs end;\n", [get_list_null(Count + 1), get_list_null(Count + 2)])
                                end;
%%                                io:format("~p: _____~p_____~p~n", [?LINE, SingleCount, Key]),
%%                                io_lib:format("~s_ -> \n~sfs end;\n", [get_list_null(Count + 1), get_list_null(Count + 2)]);
                            Key==fs1 ->
%%                            io_lib:format("~s_ -> \n~sfs end;\n", [get_list_null(Count + 1), get_list_null(Count + 2)]);
%%                            io:format("~p: _____~p_____~p~n", [?LINE, Map, Key]),
                                io_lib:format("", []);
                            true ->
                                io_lib:format("mc (~p , S0) ->\n~s{ok, S0, 1};\n ", [Key, get_list_null(Count + 1)])
                        end,
                    NewList ++ [I];
                true ->
                    I = if
                            Key==fs1 ->              % 多个Map时。会多生成一个key
                                io_lib:format("", []);
                            SingleCount==1 ->
                                io_lib:format("mc (~p , S0) ->\n~s{C~p, S~p} = string_u8:u8(S~p),\n~scase C~p of \n", [Key, get_list_null(Count + 1), Count + 1, Count + 1, Count, get_list_null(Count + 1), Count + 1]);
                            true ->
                                io_lib:format("~s~p -> \n", [get_list_null(Count), Key])
                        end,
                    Keys = maps:keys(Map),
                    S =
                        if
                            length(Keys) =< 1 ->
                                hd(Keys);
                            true ->
                                Keys
                        end,
                    key_map_vague(S, Map, NewList ++ [I], Count + 1)
            end;
        true ->
            if
                Map==fs ->
                    I =
                        if
                            Key==fs ->
                                io_lib:format("~s_ -> fs end; \n", [get_list_null(Count)]);
                            Key==fs1 ->              % 多个Map时。会多生成一个key
                                io_lib:format("~s_ ->\n~s{ok, S~p, ~p} end; \n", [get_list_null(Count), get_list_null(Count + 1), Count, Count]);
                            true ->
                                io_lib:format("~s~p ->\n~s{ok, S~p, ~p}; \n", [get_list_null(Count), Key, get_list_null(Count + 1), Count, Count])
                        end,
                    NewList ++ [I];
                true ->
                    I = if
                            Key==fs1 ->              % 多个Map时。会多生成一个key
                                io_lib:format("", []);
                            SingleCount==1 ->
                                io_lib:format("~s~p ->\n~s{C~p, S~p} = string_u8:u8(S~p),\n~scase C~p of \n", [get_list_null(Count), Key, get_list_null(Count + 1), Count + 1, Count + 1, Count, get_list_null(Count + 1), Count + 1]);
                            true ->
                                io_lib:format("~s~p -> \n", [get_list_null(Count), Key])
                        end,
                    Keys = maps:keys(Map),
                    S =
                        if
                            length(Keys) =< 1 ->
                                hd(Keys);
                            true ->
                                Keys
                        end,
                    key_map_vague(S, Map, NewList ++ [I], Count + 1)
            end
    end.

% 检查列表中是否有fs
check_fs([]) ->
    false;
check_fs([Map | List]) ->
    if
        Map==fs ->
            true;
        Map==[fs] ->
            true;
        true ->
            check_fs(List)
    end.

% 字典内容 State: 1 减一
dict_format(List, State) ->
    case erase(key_value) of
        undefined ->
            List;
        Val ->
            L = if
                    State==1 ->
                        lists:sublist(Val, length(Val) - 1);
                    true ->
                        Val
                end,
            L1 = lists:foldl(
                fun(P, NewList) ->
                    [io_lib:format("~s_ -> \n ~sfs end; \n", [get_list_null(P), get_list_null(P + 1)]) | NewList]
                end, [], L),
            List ++ lists:reverse(L1)
    end.

% 前面空格数
get_list_null(Number) ->
    string:copies("      ", Number).

%%format(S) ->
%%    io_lib:format("    ~p", [S]).











