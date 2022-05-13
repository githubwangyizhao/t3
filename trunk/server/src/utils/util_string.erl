%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc
%%% @end
%%% Created : 02. 一月 2018 下午 2:02
%%%-------------------------------------------------------------------
-module(util_string).

%% API
-export([
    is_valid_name/1,
    is_valid_string/1,
    replace/3,
    trim/1,
    head_to_upper/1,
    to_var_name/1,
    to_upper_char/1,
    to_lower_char/1,
    str_to_lower/1,
    str_to_upper/1,
    string_to_term/1,
    string_to_list_term/1,
    string_to_tuple_term/1,
    term_to_string/1,
    string_length/1,
    string_to_binary/1,
    string_to_list/1,
    is_latin1/1,
    to_utf8/1,
    random_string/1,
    u8/1,           %% 转成u8
    append_char/2,  %% 反转成字符串
    is_match/1,     %% 是否有关键字
    filter/1        %% 敏感词过滤
]).

-export([
    unicode_to_string/1
]).

%% ----------------------------------
%% @doc 	是否有效名字 [中日韩 | 字母 | 数字 | _]
%% @throws 	none
%% @end
%% ----------------------------------
is_valid_name(String) ->
    String1 = list_to_binary(String),
    case re:run(String1, "^[\\x{4e00}-\\x{9fa5}a-zA-Z0-9_]+$", [unicode]) of %%中日韩, 字母，数字, _
        nomatch ->
            false;
        _ ->
            true
    end.

%% ----------------------------------
%% @doc 	随机字符串
%% @throws 	none
%% @end
%% ----------------------------------
random_string(N) ->
    random_string_1(N, []).
random_string_1(0, S) ->
    S;
random_string_1(N, S) ->
    random_string_1(N - 1, [util_random:random_number($a, $z) | S]).

%% ----------------------------------
%% @doc 	是否有效字符串 [中日韩 | 字母 | 数字 | 常用符号]
%% @throws 	none
%% 中文符号。 ；  ， ： “ ”（ ） 、 ？ 《 》
%% \\x{3002}\\x{ff1b}\\x{ff0c}\\x{ff1a}\\x{201c}\\x{201d}\\x{ff08}\\x{ff09}\\x{3001}\\x{ff1f}\\x{300a}\\x{300b}
%% @end
%% ----------------------------------
is_valid_string(String) ->
    String1 = list_to_binary(String),
    case re:run(String1, "^[\\x{4e00}-\\x{9fa5}\\x{00}-\\x{007f}\\x{3002}\\x{ff1b}\\x{ff0c}\\x{ff1a}\\x{201c}\\x{201d}\\x{ff08}\\x{ff09}\\x{3001}\\x{ff1f}\\x{300a}\\x{300b}]+$", [unicode]) of %%中日韩, 字母，数字, 常用符号
        nomatch ->
            false;
        _ ->
            true
    end.

%% ----------------------------------
%% @doc 	字符串替换
%% @throws 	none
%% @end
%% ----------------------------------
replace([], _Search, _Replace) -> "";
replace(Str, Search, Replace) ->
    replace(Str, Search, Replace, length(Search), []).
replace(Str, Search, Replace, Len, Rtn) ->
    case string:str(Str, Search) of
        0 -> Rtn ++ Str;
        P ->
            S = string:substr(Str, 1, P - 1) ++ Replace,
            replace(string:substr(Str, P + Len), Search, Replace, Len, Rtn ++ S)
    end.

%% ----------------------------------
%% @doc 	去除字符串两边的 空格 换行符
%% @throws 	none
%% @end
%% ----------------------------------
trim(S) ->
    S1 = string:strip(S, both, $\n),
    S2 = string:strip(S1, both, $\r),
    string:strip(S2).

%%首字母大写
head_to_upper([H | T]) ->
    lists:reverse(head_to_upper1(T, [to_upper_char(H)])).
head_to_upper1([H | T], R) ->
    head_to_upper1(T, [H | R]);
head_to_upper1([], R) ->
    R.


%%生成变量名
to_var_name(Atom) when is_atom(Atom) ->
    to_var_name(atom_to_list(Atom));
to_var_name([H | T]) ->
    lists:reverse(to_var_name1(T, [to_upper_char(H)])).
to_var_name1([$_], R) ->
    [$_ | R];
to_var_name1([$_ | T], R) ->
    [H | T1] = T,
    to_var_name1(T1, [to_upper_char(H) | R]);
to_var_name1([H | T], R) ->
    to_var_name1(T, [H | R]);
to_var_name1([], R) ->
    R.

to_lower_char(C) when is_integer(C), $A =< C, C =< $Z ->
    C + 32;
to_lower_char(C) when is_integer(C), 16#C0 =< C, C =< 16#D6 ->
    C + 32;
to_lower_char(C) when is_integer(C), 16#D8 =< C, C =< 16#DE ->
    C + 32;
to_lower_char(C) ->
    C.

to_upper_char(C) when is_integer(C), $a =< C, C =< $z ->
    C - 32;
to_upper_char(C) when is_integer(C), 16#E0 =< C, C =< 16#F6 ->
    C - 32;
to_upper_char(C) when is_integer(C), 16#F8 =< C, C =< 16#FE ->
    C - 32;
to_upper_char(C) ->
    C.

str_to_lower(String) when is_list(String) ->
    [
        to_lower_char(C)
        || C <- String];
str_to_lower(Input) -> Input.

str_to_upper(String) when is_list(String) ->
    [
        to_upper_char(C)
        || C <- String];
str_to_upper(Input) -> Input.


%%string转换为term,  "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String ++ ".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err ->
                    io:format("string_to_term_error:~s, ~p~n", [String, _Err]),
                    exit(string_to_term_error)
            end;
        _Error ->
            io:format("string_to_term:~s, ~p~n", [String, _Error]),
            exit(string_to_term_error)
    end.
string_to_list_term("") ->
    [];
string_to_list_term("[]") ->
    [];
string_to_list_term(String) ->
    case erl_scan:string(String ++ ".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err ->
                    io:format("string_to_list_term_error:~s, ~p~n", [String, _Err]),
                    exit(string_to_list_term_error)
            end;
        _Error ->
            io:format("string_to_list_term:~s, ~p~n", [String, _Error]),
            exit(string_to_list_term_error)
    end.
string_to_tuple_term("") ->
    {};
string_to_tuple_term(String) ->
    case erl_scan:string(String ++ ".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err ->
                    io:format("string_to_tuple_term:~s, ~p~n", [String, _Err]),
                    exit(string_to_tuple_term)
            end;
        _Error ->
            io:format("string_to_tuple_term:~s, ~p~n", [String, _Error]),
            exit(string_to_tuple_term)
    end.

%% term转换为string,
term_to_string(Term) ->
%%    erlang:binary_to_list(erlang:term_to_binary(Term)).
    lists:flatten(io_lib:format("~w", [Term])).


%%获取长度 中文算两个字符
string_length([]) ->
    0;
string_length([Char1 | String]) ->
    string_length(Char1, String).
string_length(Char1, String) when Char1 < 16#80 ->
    string_length(String) + 1;
string_length(Char1, String) when Char1 < 16#E0 ->
    [_Char2 | String2] = String,
    string_length(String2) + 2;
string_length(Char1, String) when Char1 < 16#F0 ->
    [_Char2, _Char3 | String2] = String,
    string_length(String2) + 2;
string_length(Char1, String) when Char1 < 16#F8 ->
    [_Char2, _Char3, _Char4 | String2] = String,
    string_length(String2) + 2;
string_length(Char1, String) when Char1 < 16#FC ->
    [_Char2, _Char3, _Char4, _Char5 | String2] = String,
    string_length(String2) + 2;
string_length(Char1, String) when Char1 < 16#FE ->
    [_Char2, _Char3, _Char4, _Char5, _Char6 | String2] = String,
    string_length(String2) + 2.

string_to_binary(String) ->
    unicode:characters_to_binary(String).

string_to_list(String) ->
    Binary = unicode:characters_to_binary(String),
    binary_to_list(Binary).


is_latin1([]) ->
    true;
is_latin1([H | L]) ->
    if H > 255 ->
        false;
        true ->
            is_latin1(L)
    end.

to_utf8(String) ->
    case is_latin1(String) of
        true ->
            String;
        false ->
            xmerl_ucs:to_utf8(String)
    end.

%% ------------------------------------------------ 敏感字 匹配方式过滤  -------------------------------------------------------------------
%%  全半码方式替换关键字为*, 返回：处理过的字符串
filter(String) ->
    NewString = replace_full(clean_string(String)),
    String1 = change_twice(NewString, []),
    replace_vague(String1).

clean_string(String) ->
%%    String0 = util_string:replace(String, " ", ""),
    String0 = String,
    String1 = util_string:replace(String0, "*", ""),
    String2 = util_string:replace(String1, "&", ""),
    String2.

%   半码方式替换关键字为*, 返回：处理过的字符串
replace_vague(String1) ->
    replace_vague(String1, []).
replace_vague([], Result) -> lists:reverse(Result);
replace_vague(String, Result) ->
    [OChar | _] = String,
    {Char, String2} = u8(String),
    case keycheck_vague:mc(Char, String2) of
        ok -> ok;
        fs ->
            if
                (OChar > 64) andalso (OChar < 91) ->
                    replace_vague(String2, append_char(OChar, Result));
                true ->
                    replace_vague(String2, append_char(Char, Result))
            end;
        {ok, String3, N} ->
            NL = lists:seq(0, N),
            CL = lists:map(fun(_NLItem) -> $* end, NL),
            replace_vague(String3, [CL | Result])
    end.

%   全码方式替换关键字为*, 返回：处理过的字符串
replace_full(String) -> replace_full(String, []).
replace_full([], Result) -> lists:reverse(Result);
replace_full(String, Result) ->
    [OChar | _] = String,
    {Char, String2} = u8(String),
    case keycheck:mc(Char, String2) of
        ok -> ok;
        fs ->
            if
                (OChar > 64) andalso (OChar < 91) ->
                    replace_full(String2, append_char(OChar, Result));
                true ->
                    replace_full(String2, append_char(Char, Result))
            end;
        {ok, String3, N} ->
            NL = lists:seq(0, N),
            CL = lists:map(fun(_NLItem) -> $* end, NL),
            replace_full(String3, [CL | Result])
    end.

% 对全码处理的字符串进行处理
change_twice([], List) ->
    lists:reverse(List);
change_twice([A | String], List) ->
    NewList =
        if
            is_list(A) ->
                NL = lists:seq(0, length(A)),
                CL = lists:map(fun(_NLItem) -> $* end, NL),
                if
                    CL == A ->
                        lists:foldl(fun(_A1, AList) -> [42 | AList] end, [], NL) ++ List;
                    true ->
                        A ++ List
                end;
            true ->
                [A | List]
        end,
    change_twice(String, NewList).

%% 检查字符串是否存在关键字, 返回：true | false
is_match(String) ->
    ResultString = replace_vague(String),
    ResultString =/= String.

u8([]) ->
    {null, []};
u8([Char1 | String]) ->
    u8(Char1, String).
u8(Char1, String) when Char1 < 16#80 ->
    {ttl(Char1), String};
u8(Char1, String) when Char1 < 16#E0 ->
    [Char2 | String2] = String,
    {{Char1, Char2}, String2};
u8(Char1, String) when Char1 < 16#F0 ->
    [Char2, Char3 | String2] = String,
    {{Char1, Char2, Char3}, String2};
u8(Char1, String) when Char1 < 16#F8 ->
    [Char2, Char3, Char4 | String2] = String,
    {{Char1, Char2, Char3, Char4}, String2};
u8(Char1, String) when Char1 < 16#FC ->
    [Char2, Char3, Char4, Char5 | String2] = String,
    {{Char1, Char2, Char3, Char4, Char5}, String2};
u8(Char1, String) when Char1 < 16#FE ->
    [Char2, Char3, Char4, Char5, Char6 | String2] = String,
    {{Char1, Char2, Char3, Char4, Char5, Char6}, String2}.

append_char(Char1, String) when is_tuple(Char1) == false ->
    [Char1 | String];
append_char({Char3, Char2, Char1}, String) ->
    [Char1, Char2, Char3 | String];
append_char({Char2, Char1}, String) ->
    [Char1, Char2 | String];
append_char({Char4, Char3, Char2, Char1}, String) ->
    [Char1, Char2, Char3, Char4 | String];
append_char({Char5, Char4, Char3, Char2, Char1}, String) ->
    [Char1, Char2, Char3, Char4, Char5 | String];
append_char({Char6, Char5, Char4, Char3, Char2, Char1}, String) ->
    [Char1, Char2, Char3, Char4, Char5, Char6 | String].

ttl(UChar) when (UChar > 64) andalso (UChar < 91) -> UChar + 32;
ttl(LChar) -> LChar.

unicode_to_string(Unicode) ->
    List = string:tokens(Unicode, "\u"),
    unicode_to_string_1(List, []).
unicode_to_string_1([Str | List], NewList) ->
    unicode_to_string_1(List, [list_to_integer(Str, 16) | NewList]);
unicode_to_string_1([], NewList) ->
    util:to_binary(util_string:to_utf8(NewList)).