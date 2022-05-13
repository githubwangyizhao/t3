%%% Generated automatically, no need to modify.
-module(logic_get_conditions_function_list).
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


get(task) ->
     [{1001,[7001]},{1002,[8001,10001,10101,99004]},{1004,[99002]},{1005,[99005]},{1006,[99001,99007]}];
get(vip_level) ->
     [{1,[125,171]},{2,[751,4001]},{3,[121]}];
get(level) ->
     [{[1,0],[1071,1081,99003,99006]},{[2,0],[150]},{[5,0],[160]},{[20,0],[751,4001]},{[999,0],[501]},{[99999,0],[401,402,404,405,950,1041,1073,1076,99999]}];
get(_Id) ->
    null.
