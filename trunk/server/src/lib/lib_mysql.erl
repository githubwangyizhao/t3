%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(lib_mysql).

%% API
-export([
    get_rows/1,
    get_fields/1,
    as_record/4,
    fetch/2
]).
-include("mysql.hrl").

get_rows(Result) when is_record(Result, mysql_result) ->
    mysql:get_result_rows(Result).

get_fields(Result) when is_record(Result, mysql_result) ->
    mysql:get_result_field_info(Result).

fetch(PoolId, Sql) ->
    mysql:fetch(PoolId, Sql).


as_record(Result = #mysql_result{}, RecordName, Fields, Fun) when is_atom(RecordName), is_list(Fields), is_function(Fun) ->
    Columns = Result#mysql_result.fieldinfo,
%%    S = lists:seq(1, length(Columns)),
%%    P = lists:zip([ binary_to_atom(erlang:element(2, C1), utf8) || C1 <- Columns ], S),
    {_, P} =
    lists:foldl(
        fun({_, Son,_, FieldType1}, {Sum, L}) ->
            {Sum + 1, [{binary_to_atom(Son, utf8), Sum, FieldType1}|L]}
        end, {1, []}, Columns),
    F = fun(FieldName) ->
        case proplists:lookup(FieldName, P) of
            none ->
                fun(_) -> undefined end;
            {FieldName, Pos, FieldType} ->
                %% omi <<"">> => ""
                fun(Row) ->
                    Str = try_binary_to_list(lists:nth(Pos, Row)),
                    if FieldType == 'FLOAT'  ->
                        util:to_float(Str);
                    true ->
                        Str
                    end
                end
        end
        end,
    Fs = [ F(FieldName) || FieldName <- Fields ],
    F1 = fun(Row) ->
        RecordData = [ Fx(Row) || Fx <- Fs ],
        Fun(list_to_tuple([RecordName|RecordData]))
         end,
    [ F1(Row) || Row <- Result#mysql_result.rows ].

try_binary_to_list(A) when is_binary(A) ->
    binary_to_list(A);
try_binary_to_list(A) ->
    A.
