%%% Generated automatically, no need to modify.
-module(logic_get_function_have_init_list).
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
     [100,102,103,104,105,110,111,120,122,130,140,170,180,202,203,204,301,400,406,407,408,409,410,411,415,420,502,600,610,630,640,701,800,900,901,902,999,1011,1031,1061,1062,1063,1070,1072,1074,1100,2001,2011,2031,2041,6001,9001];
get(_Id) ->
    null.
