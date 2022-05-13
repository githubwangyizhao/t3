%%% Generated automatically, no need to modify.
-module(t_pk_mode).
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
     [{0},{1},{2},{3}].


get({0}) ->
     {t_pk_mode,{0},0,[229,146,140,229,185,179],[112,107,95,112,101,97,99,101],[228,184,141,229,143,175,229,175,185,231,142,169,229,174,182,233,128,160,230,136,144,228,188,164,229,174,179],[48,120,48,49,102,102,49,57]};
get({1}) ->
     {t_pk_mode,{1},1,[228,187,153,231,155,159],[112,107,95,102,97,99,116,105,111,110],[229,143,175,229,175,185,233,157,158,230,156,172,228,187,153,231,155,159,231,142,169,229,174,182,233,128,160,230,136,144,228,188,164,229,174,179],[48,120,48,48,97,48,101,57]};
get({2}) ->
     {t_pk_mode,{2},2,[229,175,185,229,134,179],[112,107,95,98,97,116,116,108,101],[229,143,175,229,175,185,230,140,135,229,174,154,231,142,169,229,174,182,228,188,164,229,174,179],[48,120,102,102,101,98,52,53]};
get({3}) ->
     {t_pk_mode,{3},3,[229,133,168,228,189,147],[112,107,95,119,111,114,108,100],[229,143,175,229,175,185,230,137,128,230,156,137,231,142,169,229,174,182,233,128,160,230,136,144,228,188,164,229,174,179],[48,120,102,102,48,48,48,48]};
get(_Id) ->
    null.
