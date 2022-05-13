%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 6月 2021 上午 09:55:52
%%%-------------------------------------------------------------------
-module(flash).
-author("Administrator").

-include("common.hrl").

%% API
-export([
    rc4_decode/1
]).

-define(KEY_LENGTH, 4).
-define(FLASH_KEY, "abc").
-define(UNICODE_COUNT, 255).

rc4_decode(Msg) ->
%%    ?DEBUG("Msg: ~p", [Msg]),
    [Msg1] = string:replace(Msg, "\\", ""),
    [Msg2] = string:replace(Msg1, " ", "+"),
    Msg3 = Msg2 ++ "==",
%%    ?DEBUG("Msg1: ~p", [Msg1]),
%%    ?DEBUG("Msg2: ~p", [Msg2]),
%%    ?DEBUG("Msg3: ~p", [Msg3]),
    Now = util_time:milli_timestamp(),
    KeyAfterMd5 = encrypt:md5(?FLASH_KEY),
    {KeyC, RealMsg} = lists:split(?KEY_LENGTH, Msg3),
    {KeyA, KeyB} = lists:split(16, KeyAfterMd5),
    KeyAAfterEncrypt = encrypt:md5(KeyA),
    KeyBAfterEncrypt = encrypt:md5(KeyB),
    ?DEBUG("KeyBAfterEncrypt: ~p", [KeyBAfterEncrypt]),
    Str = base64:mime_decode(list_to_binary(RealMsg)),
    CryptKey = KeyAAfterEncrypt ++ KeyC,
    CryptKeyAfterMd5 = KeyAAfterEncrypt ++ encrypt:md5(CryptKey),
%%    ?DEBUG("CryptKey: ~p", [{CryptKey, CryptKeyAfterMd5}]),

    CryptKeyLength = length(CryptKeyAfterMd5),
    RndKey = lists:seq(0, ?UNICODE_COUNT),
    RealUnicodeCount = ?UNICODE_COUNT + 1,
    RealRndKey =
        lists:foldr(
            fun(Ele, Tmp) ->
                Pos = Ele rem CryptKeyLength,
                [lists:nth(Pos + 1, CryptKeyAfterMd5) | Tmp]
            end,
            [],
            RndKey
        ),
    Box = lists:seq(0, util:to_int(RealUnicodeCount / 2) - 1, 1) ++ lists:seq(util:to_int((0 - RealUnicodeCount) / 2), -1, 1),
    NewBox = [{?IF(I >= 0, I, RealUnicodeCount + I), I} || I <- Box],

    F = lists:foldl(
        fun(Ele, Tmp) ->
            Pos = Ele + 1,
            {new_box, BoxIInTmp} = lists:keyfind(new_box, 1, Tmp),
            {BoxPos, BoxValue} = lists:nth(Pos, BoxIInTmp),
            RndKeyI = lists:nth(Pos, RealRndKey),
            {TmpValue, _} =
                case lists:keyfind(tmp_value, 1, Tmp) of
                    false -> {(BoxValue + RndKeyI) rem RealUnicodeCount, 0};
                    {tmp_value, TmpValueInTmp} ->
                        T = (TmpValueInTmp + BoxValue + RndKeyI) rem RealUnicodeCount,
                        {?IF(T < 0, RealUnicodeCount + T, T), TmpValueInTmp}
                end,
            Tmp1 = lists:keystore(tmp_value, 1, Tmp, {tmp_value, TmpValue}),

            {_, MatchTmpValue} = lists:keyfind(TmpValue, 1, BoxIInTmp),
            Tmp2 = lists:keyreplace(new_box, 1, Tmp1, {new_box, lists:keyreplace(BoxPos, 1, BoxIInTmp, {BoxPos, MatchTmpValue})}),
            {new_box, BoxIInTmp2} = lists:keyfind(new_box, 1, Tmp2),
            Tmp3 = lists:keyreplace(new_box, 1, Tmp2, {new_box, lists:keyreplace(TmpValue, 1, BoxIInTmp2, {TmpValue, BoxValue})}),
            Tmp3
        end,
        [{new_box, NewBox}],
        lists:seq(0, 255)
    ),

    {new_box, R} = lists:keyfind(new_box, 1, F),
    RealBox = [V || {_P, V} <- R],
    MatchBox1 =
        lists:foldl(
            fun(B, Tmp) ->
                BoxEle = lists:nth(B, RealBox),
                [{B - 1, BoxEle} | Tmp]
            end,
            [],
            lists:seq(1, length(RealBox))
        ),
    MatchBox = lists:sort(MatchBox1),

    TmpResultList = lists:seq(0, length(util:to_list(Str)) - 1),
%%    ?DEBUG("TmpResultList: ~p", [length(util:to_list(Str)) - 1]),

    Res = [{tmpj, 0}, {box, MatchBox}, {result, []}],
    R1 =
        lists:foldl(
            fun(E, Tmp) ->
                TmpI = (E + 1) rem RealUnicodeCount,
                {box, BoxInTmp} = lists:keyfind(box, 1, Tmp),
                {result, Result} = lists:keyfind(result, 1, Tmp),
                TmpJ =
                    case lists:keyfind(tmpj, 1, Tmp) of
                        false -> 0;
                        {tmpj, TmpJ1} ->
                            {_, MatchBoxValue} = lists:keyfind(TmpI, 1, BoxInTmp),
                            RealTmpJ1 = (TmpJ1 + MatchBoxValue) rem RealUnicodeCount,
                            RealTmpJ = ?IF(RealTmpJ1 < 0, RealUnicodeCount + RealTmpJ1, RealTmpJ1),
                            RealTmpJ
                    end,
                ByteA = lists:nth(TmpI, util:to_list(Str)),
                Tmp1 = lists:keystore(tmpj, 1, Tmp, {tmpj, TmpJ}),
                Tmp2 =
                    case lists:keyfind(TmpI, 1, BoxInTmp) of
                        false -> Tmp1;
                        {TmpI, V} ->
                            case lists:keyfind(TmpJ, 1, BoxInTmp) of
                                false -> Tmp1;
                                {TmpJ, TmpBoxJ} ->
                                    TmpBoxJTupleList = lists:keyreplace(TmpI, 1, BoxInTmp, {TmpI, TmpBoxJ}),
                                    TmpBoxITupleList = lists:keyreplace(TmpJ, 1, TmpBoxJTupleList, {TmpJ, V}),
                                    NewTmp = lists:keyreplace(box, 1, Tmp1, {box, TmpBoxITupleList}),
%%                                    NewTmp
                                    ByteB1 = (TmpBoxJ + V) rem RealUnicodeCount,
                                    Pos1 = ?IF(ByteB1 < 0, ByteB1 + RealUnicodeCount, ByteB1),
                                    {Pos1, ByteB} = lists:nth(Pos1 + 1, TmpBoxITupleList),
                                    Pos2 = ?IF(ByteA bxor ByteB < 0, ByteA bxor ByteB + RealUnicodeCount, ByteA bxor ByteB),
                                    NewResult = Result ++ [Pos2],
                                    lists:keyreplace(result, 1, NewTmp, {result, NewResult})
                            end
                    end,
                Tmp2
            end,
            Res,
            TmpResultList
        ),
    {result, DecodeRes} = lists:keyfind(result, 1, R1),
    ?DEBUG("DecodeRes: ~p", [DecodeRes]),
    A = string:sub_string(DecodeRes, 1, 10),
    ?DEBUG("A: ~p", [A]),
    B = string:sub_string(DecodeRes, 11, 26),
    ?DEBUG("B: ~p", [B]),
    C = string:sub_string(DecodeRes, 27) ++ KeyBAfterEncrypt,
    ?DEBUG("C: ~p", [{string:sub_string(DecodeRes, 27), C}]),
    D = encrypt:md5(C),
    ?DEBUG("D: ~p", [D]),
    TimeVal = util:to_int(A),
    DAfterCut = string:sub_string(D, 1, 16),
    ?DEBUG("DAfterCut: ~p", [DAfterCut]),
    ?DEBUG("Time: ~p", [{DAfterCut, B}]),
    ResultAfterDecode =
        if
            (TimeVal =:= 0 orelse TimeVal > Now) andalso B =:= DAfterCut ->
                DecodeResAfterCut = string:sub_string(DecodeRes, 27),
                case json:decode(DecodeResAfterCut) of
                    {ok, {obj, JsonDecode}, _} ->
                        ?DEBUG("JsonDecode: ~p", [JsonDecode]),
                        lists:foldl(
                            fun({Key, Value}, Tmp) ->
                                Tmp ++ [{util:to_list(Key), ?IF(is_integer(Value), Value, util:to_list(Value))}]
                            end,
                            [],
                            JsonDecode
                        );
                    Other -> ?DEBUG("Other: ~p", [Other]), []
                end;
            true -> ?DEBUG("false"), []
        end,
    ?DEBUG("ResultAfterDecode: ~p", [ResultAfterDecode]),
    ResultAfterDecode.
