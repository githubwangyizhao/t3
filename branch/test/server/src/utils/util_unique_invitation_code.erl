%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 一月 2021 下午 04:48:30
%%%-------------------------------------------------------------------
-module(util_unique_invitation_code).
-author("Administrator").

%% API
-export([
%%    test/0,
    encode/1,
    decode/1
]).

-define(STRING, "Cd69LAnMltrP5SHUhgjYpaxeDZTyoNWzX8w4qcBbkmRi7uEV23JfsvFQKG").
-define(BXOR, 9584115).
-define(ADD, 12524).
-define(MUL, 2854).

%%-define(BSL_OR_BSR, 2).

%%test() -> lists:foreach(fun(Value) -> encode(Value) end, lists:seq(1, 10000000)).
%%encode(Value)

encode(PlayerId) ->
    Data0 = (PlayerId + ?ADD) * ?MUL,
    Data = Data0 bxor ?BXOR,
    encode1(Data).
encode1(Data) ->
    encode1(Data, length(?STRING) - 1, []).
encode1(0, _Length, Code) ->
    Code;
encode1(Data, Length, Code) ->
    encode1(Data div Length, Length, [lists:nth((Data rem Length) + 1, ?STRING) | Code]).

decode(Code) ->
    Data = decode1(Code),
    Data0 = Data bxor ?BXOR,
    case Data0 rem ?MUL of
        0 ->
            (Data0 div ?MUL) - ?ADD;
        _ ->
            exit(none)
    end.
decode1(Code) ->
    decode1(Code, length(?STRING) - 1, 0).
decode1([], _Length, Data) ->
    Data;
decode1([Value | Code], Length, Data) ->
    {index, Index} = util_list:get_element_index(Value, ?STRING),
    decode1(Code, Length, (Data * Length + Index - 1)).
