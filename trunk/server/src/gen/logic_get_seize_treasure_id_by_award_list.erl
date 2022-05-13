%%% Generated automatically, no need to modify.
-module(logic_get_seize_treasure_id_by_award_list).
-export([get/1, get/2, assert_get/1, get_keys/0]).

get(Key, Default) ->
    case ?MODULE:get(Key) of
        null -> Default;
        Result -> Result
    end.

assert_get(Key) ->
    case ?MODULE:get(Key) of
        null -> exit({got_null, ?MODULE, Key});
        Result -> Result
    end.

get_keys() ->
     [].


get({4,50,1}) ->
     8;
get({90,1,2}) ->
     12;
get({101,1,1}) ->
     0;
get({1008,5,1}) ->
     11;
get({2,200000,1}) ->
     5;
get({2,50000,2}) ->
     9;
get({2,100000,1}) ->
     13;
get({91,1,1}) ->
     7;
get({1008,5,2}) ->
     1;
get({4,200,2}) ->
     4;
get({2,200000,2}) ->
     5;
get({1008,5,1}) ->
     1;
get({201,5,1}) ->
     3;
get({201,5,2}) ->
     3;
get({4,200,1}) ->
     4;
get({1008,5,2}) ->
     11;
get({101,1,2}) ->
     0;
get({90,1,1}) ->
     12;
get({1008,10,1}) ->
     6;
get({2,50000,2}) ->
     2;
get({2,50000,1}) ->
     9;
get({91,1,2}) ->
     7;
get({1008,10,2}) ->
     6;
get({202,5,2}) ->
     10;
get({202,5,1}) ->
     10;
get({2,50000,1}) ->
     2;
get({2,100000,2}) ->
     13;
get({4,50,2}) ->
     8;
get(_Id) ->
    null.
