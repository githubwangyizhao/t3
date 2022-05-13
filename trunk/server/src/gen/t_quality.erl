%%% Generated automatically, no need to modify.
-module(t_quality).
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
     [{0},{1},{2},{3},{4},{5},{6}].


get({0}) ->
     {t_quality,{0},0,[230,153,174,233,128,154]};
get({1}) ->
     {t_quality,{1},1,[231,137,185,230,174,138]};
get({2}) ->
     {t_quality,{2},2,[231,168,128,230,156,137]};
get({3}) ->
     {t_quality,{3},3,[231,189,149,232,167,129]};
get({4}) ->
     {t_quality,{4},4,[229,143,178,232,175,151]};
get({5}) ->
     {t_quality,{5},5,[228,188,160,232,175,180]};
get({6}) ->
     {t_quality,{6},6,[231,165,158,232,175,157]};
get(_Id) ->
    null.
