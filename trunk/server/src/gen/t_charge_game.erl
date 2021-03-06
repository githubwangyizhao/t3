%%% Generated automatically, no need to modify.
-module(t_charge_game).
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
     [{0},{1},{2},{3},{4},{5}].


get({0}) ->
     {t_charge_game,{0},0,[99,111,109,109,111,110,95,99,104,97,114,103,101,95,100,105,97,109,111,110,100],[230,153,174,233,128,154,40,233,146,187,231,159,179,41],1,0,403};
get({1}) ->
     {t_charge_game,{1},1,[102,105,114,115,116,95,99,104,97,114,103,101],[233,166,150,229,133,133],0,0,2};
get({2}) ->
     {t_charge_game,{2},2,[122,104,105,95,103,111,117],[231,155,180,230,142,165,232,180,173,231,164,188,229,140,133,230,180,187,229,138,168],0,0,0};
get({3}) ->
     {t_charge_game,{3},3,[116,111,117,95,122,105,95,106,105,95,104,117,97],[230,138,149,232,181,132,232,174,161,229,136,146],0,0,0};
get({4}) ->
     {t_charge_game,{4},4,[99,111,109,109,111,110,95,99,104,97,114,103,101,95,99,111,105,110],[230,153,174,233,128,154,40,233,135,145,229,184,129,41],2,0,402};
get({5}) ->
     {t_charge_game,{5},5,[122,104,105,95,103,111,117,95,108,101,118,101,108],[231,155,180,232,180,173,231,173,137,231,186,167],2,0,0};
get(_Id) ->
    null.
