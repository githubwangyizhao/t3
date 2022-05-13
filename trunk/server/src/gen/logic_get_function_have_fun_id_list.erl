%%% Generated automatically, no need to modify.
-module(logic_get_function_have_fun_id_list).
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


get(9001) ->
     1;
get(6001) ->
     1;
get(2041) ->
     1;
get(2031) ->
     1;
get(2011) ->
     1;
get(2001) ->
     1;
get(1100) ->
     1;
get(1074) ->
     1;
get(1072) ->
     1;
get(1070) ->
     1;
get(1063) ->
     1;
get(1062) ->
     1;
get(1061) ->
     1;
get(1031) ->
     1;
get(1011) ->
     1;
get(999) ->
     1;
get(902) ->
     1;
get(901) ->
     1;
get(900) ->
     1;
get(800) ->
     1;
get(701) ->
     1;
get(640) ->
     1;
get(630) ->
     1;
get(610) ->
     1;
get(600) ->
     1;
get(502) ->
     1;
get(420) ->
     1;
get(415) ->
     1;
get(411) ->
     1;
get(410) ->
     1;
get(409) ->
     1;
get(408) ->
     1;
get(407) ->
     1;
get(406) ->
     1;
get(400) ->
     1;
get(301) ->
     1;
get(204) ->
     1;
get(203) ->
     1;
get(202) ->
     1;
get(180) ->
     1;
get(170) ->
     1;
get(140) ->
     1;
get(130) ->
     1;
get(122) ->
     1;
get(120) ->
     1;
get(111) ->
     1;
get(110) ->
     1;
get(105) ->
     1;
get(104) ->
     1;
get(103) ->
     1;
get(102) ->
     1;
get(100) ->
     1;
get(_Id) ->
    null.
