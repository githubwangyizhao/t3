%%% Generated automatically, no need to modify.
-module(t_merge).
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
     [{901},{902}].


get({901}) ->
     {t_merge,{901},901,[1001,50],0};
get({902}) ->
     {t_merge,{902},902,[1002,60],0};
get(_Id) ->
    null.
