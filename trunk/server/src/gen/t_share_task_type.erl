%%% Generated automatically, no need to modify.
-module(t_share_task_type).
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
     [{101}].


get({101}) ->
     {t_share_task_type,{101},101,1,[115,104,97,114,101,95,116,97,115,107],[233,130,128,232,175,183,229,165,189,229,143,139],[],1,1,[229,136,155,229,187,186,232,167,146,232,137,178,229,185,182,232,191,155,229,133,165,230,184,184,230,136,143],0};
get(_Id) ->
    null.
