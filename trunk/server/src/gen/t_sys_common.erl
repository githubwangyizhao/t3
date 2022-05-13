%%% Generated automatically, no need to modify.
-module(t_sys_common).
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
     [{601},{602},{603},{604},{605},{606}].


get({601}) ->
     {t_sys_common,{601},601,105,[6,10],[]};
get({602}) ->
     {t_sys_common,{602},602,105,[6,20],[]};
get({603}) ->
     {t_sys_common,{603},603,105,[6,30],[]};
get({604}) ->
     {t_sys_common,{604},604,105,[6,40],[]};
get({605}) ->
     {t_sys_common,{605},605,105,[6,60],[]};
get({606}) ->
     {t_sys_common,{606},606,105,[6,100],[]};
get(_Id) ->
    null.
