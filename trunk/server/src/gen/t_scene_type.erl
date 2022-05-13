%%% Generated automatically, no need to modify.
-module(t_scene_type).
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
     [{1},{2},{3}].


get({1}) ->
     {t_scene_type,{1},1,[228,184,150,231,149,140,229,156,176,229,155,190],[119,111,114,108,100,95,115,99,101,110,101]};
get({2}) ->
     {t_scene_type,{2},2,[229,137,175,230,156,172],[109,105,115,115,105,111,110]};
get({3}) ->
     {t_scene_type,{3},3,[229,140,185,233,133,141,229,156,186],[109,97,116,99,104,95,115,99,101,110,101]};
get(_Id) ->
    null.
