%%% Generated automatically, no need to modify.
-module(logic_get_conditions_individual_red_packet_id_list).
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


get(recharge_money_daliy) ->
     [{1,7},{2,29},{3,99},{4,299},{5,499},{6,799},{7,1999},{8,2999},{9,4999}];
get(_Id) ->
    null.
