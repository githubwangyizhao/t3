%%% Generated automatically, no need to modify.
-module(t_effect_type).
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
     [{1},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{19},{20}].


get({1}) ->
     {t_effect_type,{1},1,[97,116,116,114],[229,138,160,229,135,143,229,177,158,230,128,167],[],0,2,[91,97,116,116,114,44,32,229,177,158,230,128,167,105,100,44,32,230,149,176,229,128,188,93]};
get({3}) ->
     {t_effect_type,{3},3,[100,105,122,122,121],[230,153,149,231,156,169],[98,117,102,102,95,121,117,110,95,120,117,97,110],0,2,[91,100,105,122,122,121,93]};
get({4}) ->
     {t_effect_type,{4},4,[97,100,100,95,104,112,95,114,97,116,101],[229,138,160,230,156,128,229,164,167,232,161,128,233,135,143,231,153,190,229,136,134,230,175,148],[],0,1,[91,97,100,100,95,104,112,95,114,97,116,101,44,32,231,153,190,229,136,134,230,175,148,93]};
get({5}) ->
     {t_effect_type,{5},5,[97,100,100,95,98,117,102,102],[230,183,187,229,138,160,98,117,102,102],[],0,1,[91,97,100,100,95,98,117,102,102,44,32,98,117,102,102,73,100,44,32,98,117,102,102,231,173,137,231,186,167,93]};
get({6}) ->
     {t_effect_type,{6},6,[116,114,105,103,103,101,114,95,115,107,105,108,108],[232,167,166,229,143,145,230,138,128,232,131,189],[],0,1,[91,116,114,105,103,103,101,114,95,115,107,105,108,108,44,32,228,184,187,229,138,168,230,138,128,232,131,189,105,100,44,32,228,184,187,229,138,168,230,138,128,232,131,189,231,173,137,231,186,167,93]};
get({7}) ->
     {t_effect_type,{7},7,[120,105,95,120,117,101],[229,144,184,232,161,128],[98,117,102,102,95,115,104,105,95,104,117,110],221,1,[91,120,105,95,120,117,101,44,32,228,184,135,229,136,134,230,175,148,93]};
get({8}) ->
     {t_effect_type,{8},8,[108,105,117,95,120,117,101],[230,181,129,232,161,128],[98,117,102,102,95,108,105,117,95,120,117,101],222,2,[91,108,105,117,95,120,117,101,44,32,228,184,135,229,136,134,230,175,148,93]};
get({9}) ->
     {t_effect_type,{9},9,[101,120,116,114,97,95,104,117,114,116],[233,162,157,229,164,150,228,188,164,229,174,179],[98,117,102,102,95,101,95,119,97,105,95,115,104,97,110,103,95,104,97,105],222,2,[91,101,120,116,114,97,95,104,117,114,116,44,32,228,184,135,229,136,134,230,175,148,93]};
get({10}) ->
     {t_effect_type,{10},10,[114,101,98,111,117,110,100,95,104,117,114,116],[229,143,141,229,188,185,228,188,164,229,174,179],[98,117,102,102,95,102,97,110,95,115,104,97,110],222,2,[91,114,101,98,111,117,110,100,95,104,117,114,116,44,32,228,184,135,229,136,134,230,175,148,93]};
get({11}) ->
     {t_effect_type,{11},11,[99,104,101,110,95,109,111],[230,178,137,233,187,152],[98,117,102,102,95,99,104,101,110,95,109,111],0,2,[91,99,104,101,110,95,109,111,93]};
get({12}) ->
     {t_effect_type,{12},12,[102,101,110,103,95,121,105,110,95,112,101,116],[229,176,129,229,141,176,229,166,150,231,129,181],[98,117,102,102,95,102,101,110,103,95,121,105,110],0,2,[91,102,101,110,103,95,121,105,110,95,112,101,116,93]};
get({13}) ->
     {t_effect_type,{13},13,[102,101,110,103,95,121,105,110,95,102,97,95,98,97,111],[229,176,129,229,141,176,230,179,149,229,174,157],[98,117,102,102,95,102,101,110,103,95,121,105,110],0,2,[91,102,101,110,103,95,121,105,110,95,102,97,95,98,97,111,93]};
get({14}) ->
     {t_effect_type,{14},14,[105,109,109,117,110,101,95,100,105,122,122,121],[229,133,141,231,150,171,230,153,149,231,156,169],[98,117,102,102,95,109,105,97,110,95,121,105,95,121,117,110,95,120,117,97,110],0,2,[91,105,109,109,117,110,101,95,100,105,122,122,121,93]};
get({15}) ->
     {t_effect_type,{15},15,[114,101,100,117,99,101,95,99,100],[229,135,143,229,176,145,230,137,128,230,156,137,230,138,128,232,131,189,99,100],[98,117,102,102,95,100,117,110,95,119,117],223,1,[91,114,101,100,117,99,101,95,99,100,93]};
get({16}) ->
     {t_effect_type,{16},16,[104,117,95,100,117,110],[230,138,164,231,155,190],[98,117,102,102,95,104,117,95,100,117,110],0,2,[91,104,117,95,100,117,110,44,32,230,149,176,229,128,188,93]};
get({17}) ->
     {t_effect_type,{17},17,[97,116,116,114,95,114,97,116,101],[229,138,160,229,135,143,229,177,158,230,128,167,228,184,135,229,136,134,230,175,148],[],0,2,[91,97,116,116,114,95,114,97,116,101,44,229,177,158,230,128,167,105,100,44,228,184,135,229,136,134,230,175,148,93]};
get({19}) ->
     {t_effect_type,{19},19,[99,97,108,108,95,109,111,110,115,116,101,114],[229,143,172,229,148,164,230,128,170,231,137,169],[],0,0,[91,99,97,108,108,95,109,111,110,115,116,101,114,44,32,230,128,170,231,137,169,105,100,93]};
get({20}) ->
     {t_effect_type,{20},20,[107,105,108,108],[229,191,133,230,157,128],[98,117,102,102,95,98,105,95,115,104,97],0,2,[91,107,105,108,108,93]};
get(_Id) ->
    null.
