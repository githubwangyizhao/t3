%%% Generated automatically, no need to modify.
-module(logic_get_effect_id_by_effect_sign).
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


get(trigger_skill) ->
     6;
get(reduce_cd) ->
     15;
get(immune_dizzy) ->
     14;
get(extra_hurt) ->
     9;
get(rebound_hurt) ->
     10;
get(hu_dun) ->
     16;
get(feng_yin_fa_bao) ->
     13;
get(chen_mo) ->
     11;
get(attr) ->
     1;
get(attr_rate) ->
     17;
get(feng_yin_pet) ->
     12;
get(xi_xue) ->
     7;
get(add_hp_rate) ->
     4;
get(dizzy) ->
     3;
get(liu_xue) ->
     8;
get(kill) ->
     20;
get(add_buff) ->
     5;
get(call_monster) ->
     19;
get(_Id) ->
    null.
