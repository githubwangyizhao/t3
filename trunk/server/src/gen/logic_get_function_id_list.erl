%%% Generated automatically, no need to modify.
-module(logic_get_function_id_list).
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


get(0) ->
     [121,125,150,160,170,171,401,402,404,405,406,407,408,409,410,411,415,420,501,502,610,751,900,901,902,950,999,1041,1071,1072,1073,1074,1076,1081,1100,2001,2011,2031,2041,4001,6001,7001,8001,9001,10001,10101,99001,99002,99003,99004,99005,99006,99007,99999];
get(_Id) ->
    null.
