-module(build_random_name).

-define(OUT_KEY, "../src/lib/random_name.erl").

%% API
-export([start/0]).

-include("common.hrl").

start() ->
    NamePath = env:get(template_dir, "../priv") ++ "/random_name.csv",
    io:format("create file random_name.erl ~s ", [lists:duplicate(max(0, 45 - length("random_name.erl")), ".")]),
    {ok, File} = file:open(NamePath, [read]),
    {SurnameList, MaleNameList, FemaleNameList} = do(File, [], [], [], 1),
    file:close(File),
    create_str(SurnameList, MaleNameList, FemaleNameList),
    io:format("[ok]~n"),
    qmake:compilep(?OUT_KEY, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH).

do(File, SurnameList, MaleNameList, FemaleNameList, Count) ->
    if
        Count =< 5 ->
            file:read_line(File),
            do(File, SurnameList, MaleNameList, FemaleNameList, Count + 1);
        true ->
            case file:read_line(File) of
                {ok, Data} ->
                    case strip(Data) of
                        [] ->
                            do(File, SurnameList, MaleNameList, FemaleNameList, Count + 1);
                        S ->
                            S1 = build_table:utf8_build(S),
                            [_Id, Surname, MaleName, FemaleName, PlatformId] =
                                case string:tokens(S1, ",") of
                                    [ThisId, ThisSurname, ThisMaleName, ThisFemaleName, ThisPlatformId] ->
                                        [ThisId, ThisSurname, ThisMaleName, ThisFemaleName, ThisPlatformId];
                                    [ThisId, ThisSurname, ThisMaleName, ThisFemaleName] ->
                                        [ThisId, ThisSurname, ThisMaleName, ThisFemaleName, ""]
                                end,
                            F =
                                fun(Str, L) ->
                                    if
                                        Str == "-1" ->
                                            L;
                                        true ->
                                            util_list:key_insert({PlatformId, Str}, L)
%%                                            [Str | L]
                                    end
                                end,
                            do(File, F(Surname, SurnameList), F(MaleName, MaleNameList), F(FemaleName, FemaleNameList), Count + 1)
                    end;
                eof ->
                    {SurnameList, MaleNameList, FemaleNameList};
                {error, Reason} ->
                    exit(list_to_atom(Reason))
            end
    end.

strip(S) ->
    S1 = string:strip(S, both, $\n),
    S2 = string:strip(S1, both, $\r),
    string:strip(S2).

%% ------------------------------------------ 生成文件 ----------------------------------------------------------------------------------------
% 文件头部
head_key() ->
    "-module(random_name).\r\n"
    "-export([\r\n"
    "    get_name/0,\r\n"
    "    get_name/1 \r\n"
    "]).\r\n\r\n"
    "get_name() ->\r\n"
    "    get_name(util_random:random_number(0, 1)).\r\n"
    "get_name(Sex) ->\r\n"
    "    PlatformId = mod_server_config:get_platform_id(),\r\n"
    "    {SurnameNum, SurnameList} = get_surname(util:to_atom(PlatformId)),\r\n"
    "    Surname = lists:nth(util_random:random_number(SurnameNum), SurnameList),\r\n"
    "    Name =\r\n"
    "        case Sex of\r\n"
    "            0 ->\r\n"
    "                {MaleNameNum, MaleNameList} = get_male_name(util:to_atom(PlatformId)),\r\n"
    "                lists:nth(util_random:random_number(MaleNameNum), MaleNameList);\r\n"
    "            _ ->\r\n"
    "                {FemaleNameNum, FemaleNameList} = get_female_name(util:to_atom(PlatformId)),\r\n"
    "                lists:nth(util_random:random_number(FemaleNameNum), FemaleNameList)\r\n"
    "        end,\r\n"
    "    {Sex, Surname ++ Name}.\r\n\r\n".

%%% 创建文件
%%create_str(SurnameList, MaleNameList, FemaleNameList) ->
%%    {ok, File} = file:open(?OUT_KEY, [write]),
%%    {SurnameFunTmp, SurnameTmp} = lists:foldl(
%%        fun({PlatformId, SurnameL}, {FunStr, TmpStr}) ->
%%            PlatformStr = ?IF(PlatformId == "", PlatformId, PlatformId ++ "_"),
%%            NewFunStr =
%%                if
%%                    PlatformId == "" ->
%%                        FunStr ++
%%                        "get_surname(_) ->\r\n"
%%                        "    get_surname().\r\n\r\n";
%%                    true ->
%%                        "get_surname(" ++ PlatformId ++ ") ->\r\n"
%%                        "    " ++ PlatformStr ++ "get_surname();\r\n"
%%                            ++ FunStr
%%                end,
%%            NewTmpStr = io_lib:format(PlatformStr ++ "get_surname() ->\r\n\t{~w,\r\n\t~w}.\r\n", [length(SurnameL), SurnameL]) ++ TmpStr,
%%            {NewFunStr, NewTmpStr}
%%        end,
%%        {"", ""}, SurnameList
%%    ),
%%    Surname = SurnameFunTmp ++ SurnameTmp,
%%    {MaleNameFunTmp, MaleNameTmp} = lists:foldl(
%%        fun({PlatformId, MaleNameL}, {FunStr, TmpStr}) ->
%%            PlatformStr = ?IF(PlatformId == "", PlatformId, PlatformId ++ "_"),
%%            NewFunStr =
%%                if
%%                    PlatformId == "" ->
%%                        FunStr ++
%%                        "get_male_name(_) ->\r\n"
%%                        "    get_male_name().\r\n\r\n";
%%                    true ->
%%                        "get_male_name(" ++ PlatformId ++ ") ->\r\n"
%%                        "    " ++ PlatformStr ++ "get_male_name();\r\n"
%%                            ++ FunStr
%%                end,
%%            NewTmpStr = io_lib:format(PlatformStr ++ "get_male_name() ->\r\n\t{~w,\r\n\t~w}.\r\n", [length(MaleNameL), MaleNameL]) ++ TmpStr,
%%            {NewFunStr, NewTmpStr}
%%        end,
%%        {"", ""}, MaleNameList
%%    ),
%%    MaleName = MaleNameFunTmp ++ MaleNameTmp,
%%    {FemaleFunTmp, FemaleTmp} = lists:foldl(
%%        fun({PlatformId, FemaleNameL}, {FunStr, TmpStr}) ->
%%            PlatformStr = ?IF(PlatformId == "", PlatformId, PlatformId ++ "_"),
%%            NewFunStr =
%%                if
%%                    PlatformId == "" ->
%%                        FunStr ++
%%                        "get_female_name(_) ->\r\n"
%%                        "    get_female_name().\r\n\r\n";
%%                    true ->
%%                        "get_female_name(" ++ PlatformId ++ ") ->\r\n"
%%                        "    " ++ PlatformStr ++ "get_female_name();\r\n"
%%                            ++ FunStr
%%                end,
%%            NewTmpStr = io_lib:format(PlatformStr ++ "get_female_name() ->\r\n\t{~w,\r\n\t~w}.\r\n", [length(FemaleNameL), FemaleNameL]) ++ TmpStr,
%%            {NewFunStr, NewTmpStr}
%%        end,
%%        {"", ""}, FemaleNameList
%%    ),
%%    Female = FemaleFunTmp ++ FemaleTmp,
%%%%    Surname = io_lib:format("get_surname() ->\r\n\t~p.\r\n\r\n", [[[PlatformId, {length(SurnameL), SurnameL}] || {PlatformId, SurnameL} <- SurnameList]]),
%%%%    MaleName = io_lib:format("get_male_name() ->\r\n\t~p.\r\n\r\n", [[PlatformId, {length(MaleNameL), MaleNameL}] || {PlatformId, MaleNameL} <- MaleNameList]),
%%%%    Female = io_lib:format("get_female_name() ->\r\n\t~p.\r\n\r\n", [[PlatformId, {length(FemaleNameL), FemaleNameL}] || {PlatformId, FemaleNameL} <- FemaleNameList]),
%%    file:write(File, head_key() ++ Surname ++ "\r\n\r\n" ++ MaleName ++ "\r\n\r\n" ++ Female),
%%    file:close(File).

% 创建文件
create_str(SurnameList, MaleNameList, FemaleNameList) ->
    {ok, File} = file:open(?OUT_KEY, [write]),
    Surname = lists:foldl(
        fun({PlatformId, SurnameL}, TmpStr) ->
            if
                PlatformId == "" ->
                    TmpStr ++ io_lib:format("get_surname(_) ->\r\n\t{~w,\r\n\t~w}.\r\n\r\n", [length(SurnameL), SurnameL]);
                true ->
                    io_lib:format("get_surname(" ++ PlatformId ++ ") ->\r\n\t{~w,\r\n\t~w};\r\n", [length(SurnameL), SurnameL]) ++ TmpStr
            end
        end,
        "", SurnameList
    ),
    MaleName = lists:foldl(
        fun({PlatformId, MaleNameL}, TmpStr) ->
            if
                PlatformId == "" ->
                    TmpStr ++ io_lib:format("get_male_name(_) ->\r\n\t{~w,\r\n\t~w}.\r\n\r\n", [length(MaleNameL), MaleNameL]);
                true ->
                    io_lib:format("get_male_name(" ++ PlatformId ++ ") ->\r\n\t{~w,\r\n\t~w};\r\n", [length(MaleNameL), MaleNameL]) ++ TmpStr
            end
        end,
        "", MaleNameList
    ),
    Female = lists:foldl(
        fun({PlatformId, FemaleNameL}, TmpStr) ->
            if
                PlatformId == "" ->
                    TmpStr ++ io_lib:format("get_female_name(_) ->\r\n\t{~w,\r\n\t~w}.\r\n\r\n", [length(FemaleNameL), FemaleNameL]);
                true ->
                    io_lib:format("get_female_name(" ++ PlatformId ++ ") ->\r\n\t{~w,\r\n\t~w};\r\n", [length(FemaleNameL), FemaleNameL]) ++ TmpStr
            end
        end,
        "", FemaleNameList
    ),
%%    Surname = io_lib:format("get_surname() ->\r\n\t~p.\r\n\r\n", [[[PlatformId, {length(SurnameL), SurnameL}] || {PlatformId, SurnameL} <- SurnameList]]),
%%    MaleName = io_lib:format("get_male_name() ->\r\n\t~p.\r\n\r\n", [[PlatformId, {length(MaleNameL), MaleNameL}] || {PlatformId, MaleNameL} <- MaleNameList]),
%%    Female = io_lib:format("get_female_name() ->\r\n\t~p.\r\n\r\n", [[PlatformId, {length(FemaleNameL), FemaleNameL}] || {PlatformId, FemaleNameL} <- FemaleNameList]),
    file:write(File, head_key() ++ Surname ++ MaleName ++ Female),
    file:close(File).
