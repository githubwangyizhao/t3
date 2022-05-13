%%% Generated automatically, no need to modify.
-module(logic_get_share_type_task_id).
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


get(101) ->
     [{1,1},{2,3},{3,5},{4,7},{5,10},{6,13},{7,15},{8,17},{9,20},{10,23},{11,25},{12,27},{13,30},{14,33},{15,35},{16,37},{17,40},{18,43},{19,45},{20,47},{21,50}];
get(_Id) ->
    null.
