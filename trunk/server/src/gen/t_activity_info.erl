%%% Generated automatically, no need to modify.
-module(t_activity_info).
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
     [{1001}].


get({1001}) ->
     {t_activity_info,{1001},1001,[108,101,105,95,106,105,95,99,104,111,110,103,95,122,104,105],[231,180,175,232,174,161,229,133,133,229,128,188],0,1,1,[],1,[109,111,100,95,108,101,105,99,104,111,110,103],[],[],0,[],[],[],[[[2021,9,1],[0,0,0]],[[2021,9,30],[23,59,59]]],1,[],1074,0,[],[]};
get(_Id) ->
    null.
