%% -*- coding: utf-8 -*-
%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(lib_json).
%% API
-export([
    encode/1,
    decode/1
]).


encode(Term) ->
    mochijson:encode(prepare_for_json(Term)).
%%    rfc4627:encode(prepare_for_json(Term)).

decode(Term) ->
    mochijson2:decode(Term).


prepare_for_json(Int) when is_integer(Int) -> Int;
prepare_for_json(Float) when is_float(Float) -> Float;
prepare_for_json(Atom) when is_atom(Atom) -> Atom;
prepare_for_json(Array) when is_list(Array) ->
    %% case io_lib:printable_list(Array) of
    case io_lib:char_list(Array) of
        true ->
%%             io:format("66:~p~n", [Array] ),
%%            util_string:string_to_binary(Array);
            erlang:list_to_binary(Array);
        false ->
            list_to_json(Array, [])
    end;
prepare_for_json(Tuple) when is_tuple(Tuple) ->
    tuple_to_json(Tuple, erlang:size(Tuple), []);
prepare_for_json(V) -> V.

list_to_json([], Acc) -> lists:reverse(Acc);
list_to_json([{_Key, _Value} | _Rest] = List, Acc) -> {struct, proplist_to_json(List, Acc)};
list_to_json([H | Rest], Acc) -> list_to_json(Rest, [prepare_for_json(H) | Acc]).

proplist_to_json([], Acc) -> lists:reverse(Acc);
proplist_to_json([{Key, Value} | Rest], Acc) ->
    ValidKey = prepare_for_json(Key),
    ValidValue = prepare_for_json(Value),
    proplist_to_json(Rest, [{ValidKey, ValidValue} | Acc]).

tuple_to_json(_Tuple, 0, Acc) -> {struct, [erlang:list_to_tuple(Acc)]};
tuple_to_json(Tuple, CurrPos, Acc) ->
    Ele = prepare_for_json(element(CurrPos, Tuple)),
    tuple_to_json(Tuple, CurrPos - 1, [Ele | Acc]).

%% json_encode(Value) -> mochijson2:encode(Value).


%% json_to_term({struct, L}) ->
%% 	[{K, json_to_term(V)} || {K, V} <- L];
%% json_to_term(L) when is_list(L) ->
%% 	[json_to_term(I) || I <- L];
%% json_to_term(V) when is_binary(V) orelse is_number(V) orelse V =:= null orelse
%% 	V =:= true orelse V =:= false ->
%% 	V.
%%
%% %% This has the flaw that empty lists will never be JSON objects, so use with
%% %% care.
%% term_to_json([{_, _}|_] = L) ->
%% 	{struct, [{K, term_to_json(V)} || {K, V} <- L]};
%% term_to_json(L) when is_list(L) ->
%% 	[term_to_json(I) || I <- L];
%% term_to_json(V) when is_binary(V) orelse is_number(V) orelse V =:= null orelse
%% 	V =:= true orelse V =:= false ->
%% 	V.
