%%% Generated automatically, no need to modify.
-module(logic_get_conditions_task_list).
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


get({kill_kind_count,2}) ->
     [1002];
get(attack_shishicai_count) ->
     [1005];
get({kill_kind_count,102}) ->
     [1007];
get(level) ->
     [1010];
get({kill_kind_count,3}) ->
     [1009];
get(wujinduijue_count) ->
     [1008];
get(kill_monster_count) ->
     [1001,1004];
get(laba_count) ->
     [1003,1006];
get(_Id) ->
    null.
