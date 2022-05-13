%%% Generated automatically, no need to modify.
-module(t_monster_kind).
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
     [{0},{1},{2},{3},{101},{102},{103},{104},{105},{106}].


get({0}) ->
     {t_monster_kind,{0},0,[229,133,182,228,187,150],1,1};
get({1}) ->
     {t_monster_kind,{1},1,[229,176,143,229,158,139,230,128,170],1,1};
get({2}) ->
     {t_monster_kind,{2},2,[228,184,173,229,158,139,230,128,170],1,1};
get({3}) ->
     {t_monster_kind,{3},3,[229,164,167,229,158,139,230,128,170],1,1};
get({101}) ->
     {t_monster_kind,{101},101,[232,181,143,233,135,145,230,128,170],1,0};
get({102}) ->
     {t_monster_kind,{102},102,[229,138,159,232,131,189,230,128,170],1,0};
get({103}) ->
     {t_monster_kind,{103},103,[232,151,143,229,174,157,229,156,176,231,178,190],0,0};
get({104}) ->
     {t_monster_kind,{104},104,[66,79,83,83],0,0};
get({105}) ->
     {t_monster_kind,{105},105,[229,174,157,231,174,177,230,128,170],1,0};
get({106}) ->
     {t_monster_kind,{106},106,[229,189,169,231,144,131,230,128,170],1,0};
get(_Id) ->
    null.
