%%% Generated automatically, no need to modify.
-module(logic_get_seize_treasure_cost_list_by_pos).
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


get({2,0}) ->
     {1,4,100};
get({2,1}) ->
     {5,4,500};
get({1,0}) ->
     {1,4,100};
get({1,1}) ->
     {5,4,500};
get(_Id) ->
    null.
