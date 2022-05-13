%%% Generated automatically, no need to modify.
-module(t_hit_effect).
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
     [{1},{10},{101},{102},{103},{104},{105},{106},{107},{108},{109},{110},{111},{112},{113},{114},{201},{202},{203},{204},{205},{206},{207},{208},{221},{222},{223},{301},{302},{303},{304},{305},{306},{307},{308},{501},{502},{999},{1558},{10001},{10002},{10003}].


get({1}) ->
     {t_hit_effect,{1},1,[229,137,145,230,148,187,229,135,187,231,137,185,230,149,136,49],101,-1,1,106};
get({10}) ->
     {t_hit_effect,{10},10,[231,187,132,228,187,182,229,143,151,229,135,187,231,137,185,230,149,136],-1,2802,0,-1};
get({101}) ->
     {t_hit_effect,{101},101,[229,166,150,231,129,181,230,148,187,229,135,187,231,137,185,230,149,136,49],1001,-1,0,-1};
get({102}) ->
     {t_hit_effect,{102},102,[229,166,150,231,129,181,230,148,187,229,135,187,231,137,185,230,149,136,50],1002,-1,0,-1};
get({103}) ->
     {t_hit_effect,{103},103,[229,166,150,231,129,181,49,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({104}) ->
     {t_hit_effect,{104},104,[229,166,150,231,129,181,50,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({105}) ->
     {t_hit_effect,{105},105,[229,166,150,231,129,181,51,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({106}) ->
     {t_hit_effect,{106},106,[229,166,150,231,129,181,52,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({107}) ->
     {t_hit_effect,{107},107,[229,166,150,231,129,181,53,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({108}) ->
     {t_hit_effect,{108},108,[229,166,150,231,129,181,54,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({109}) ->
     {t_hit_effect,{109},109,[229,166,150,231,129,181,55,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({110}) ->
     {t_hit_effect,{110},110,[229,166,150,231,129,181,56,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({111}) ->
     {t_hit_effect,{111},111,[229,166,150,231,129,181,57,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({112}) ->
     {t_hit_effect,{112},112,[229,166,150,231,129,181,49,48,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({113}) ->
     {t_hit_effect,{113},113,[229,166,150,231,129,181,49,49,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({114}) ->
     {t_hit_effect,{114},114,[229,166,150,231,129,181,49,50,233,152,182,229,143,151,229,135,187],101,-1,0,-1};
get({201}) ->
     {t_hit_effect,{201},201,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,49],201,-1,0,107};
get({202}) ->
     {t_hit_effect,{202},202,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,50],202,-1,0,108};
get({203}) ->
     {t_hit_effect,{203},203,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,51],203,-1,0,109};
get({204}) ->
     {t_hit_effect,{204},204,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,52],204,-1,1,110};
get({205}) ->
     {t_hit_effect,{205},205,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,53],205,-1,0,111};
get({206}) ->
     {t_hit_effect,{206},206,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,54],206,-1,0,112};
get({207}) ->
     {t_hit_effect,{207},207,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,55],207,-1,0,113};
get({208}) ->
     {t_hit_effect,{208},208,[231,165,158,229,133,181,230,148,187,229,135,187,231,137,185,230,149,136,56],208,-1,0,113};
get({221}) ->
     {t_hit_effect,{221},221,[98,117,102,102,229,145,189,228,184,173,231,137,185,230,149,136,229,144,184,232,161,128],221,-1,0,-1};
get({222}) ->
     {t_hit_effect,{222},222,[98,117,102,102,229,145,189,228,184,173,231,137,185,230,149,136,233,162,157,229,164,150,228,188,164,229,174,179],222,-1,0,-1};
get({223}) ->
     {t_hit_effect,{223},223,[98,117,102,102,229,145,189,228,184,173,231,137,185,230,149,136,230,138,128,232,131,189,67,68,230,184,133,233,153,164],223,-1,0,-1};
get({301}) ->
     {t_hit_effect,{301},301,[229,164,169,228,188,151,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({302}) ->
     {t_hit_effect,{302},302,[229,164,156,229,143,137,229,143,151,229,135,187,231,137,185,230,149,136,239,188,136,97,100,100,41],101,-1,0,-1};
get({303}) ->
     {t_hit_effect,{303},303,[233,190,153,228,188,151,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({304}) ->
     {t_hit_effect,{304},304,[233,152,191,228,191,174,231,189,151,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({305}) ->
     {t_hit_effect,{305},305,[228,185,190,232,190,190,229,169,134,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({306}) ->
     {t_hit_effect,{306},306,[231,180,167,233,130,163,231,189,151,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({307}) ->
     {t_hit_effect,{307},307,[232,191,166,230,165,188,231,189,151,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({308}) ->
     {t_hit_effect,{308},308,[230,145,169,228,185,142,231,189,151,232,191,166,229,143,151,229,135,187,231,137,185,230,149,136,239,188,136,97,100,100,41],101,-1,0,-1};
get({501}) ->
     {t_hit_effect,{501},501,[231,129,171,231,132,176,231,174,173,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({502}) ->
     {t_hit_effect,{502},502,[229,134,176,233,156,156,231,174,173,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({999}) ->
     {t_hit_effect,{999},999,[231,169,186,231,153,189,231,187,132,228,187,182],101,-1,0,-1};
get({1558}) ->
     {t_hit_effect,{1558},1558,[231,153,189,230,157,191,229,143,151,229,135,187,231,137,185,230,149,136],101,-1,0,-1};
get({10001}) ->
     {t_hit_effect,{10001},10001,[233,169,177,230,149,163,231,137,185,230,149,136,231,148,168],101,-1,0,-1};
get({10002}) ->
     {t_hit_effect,{10002},10002,[229,144,184,232,161,128,231,137,185,230,149,136,231,148,168],101,-1,0,-1};
get({10003}) ->
     {t_hit_effect,{10003},10003,[229,137,178,232,163,130,230,142,168,230,139,137,231,137,185,230,149,136],101,-1,0,-1};
get(_Id) ->
    null.
