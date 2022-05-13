%%% Generated automatically, no need to modify.
-module(logic_get_function_id_module).
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


get(1041) ->
     {ok,mod_rank};
get(950) ->
     {ok,mod_jiangjinchi};
get(_Id) ->
    null.
