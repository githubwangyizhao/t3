%%% Generated automatically, no need to modify.
-module(t_platform).
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
     [{[99,97,109,98,111,100,105,97]},{[105,110,100,111,110,101,115,105,97]},{[108,97,111,115]},{[108,111,99,97,108]},{[109,97,108,97,121,115,105,97]},{[109,111,121]},{[109,121,97,110,109,97,114]},{[115,105,110,103,97,112,111,114,101]},{[116,97,105,119,97,110]},{[116,101,115,116]},{[116,101,115,116,50]},{[116,104,97,105,108,97,110,100]},{[118,105,101,116,110,97,109]}].


get({"cambodia"}) ->
     {t_platform,{[99,97,109,98,111,100,105,97]},[99,97,109,98,111,100,105,97],[230,159,172,229,159,148,229,175,168],[75,72,82],[],[]};
get({"indonesia"}) ->
     {t_platform,{[105,110,100,111,110,101,115,105,97]},[105,110,100,111,110,101,115,105,97],[229,141,176,229,176,188],[73,68,82],[],[]};
get({"laos"}) ->
     {t_platform,{[108,97,111,115]},[108,97,111,115],[232,128,129,230,140,157],[76,65,75],[],[]};
get({"local"}) ->
     {t_platform,{[108,111,99,97,108]},[108,111,99,97,108],[229,134,133,231,189,145],[],[],[]};
get({"malaysia"}) ->
     {t_platform,{[109,97,108,97,121,115,105,97]},[109,97,108,97,121,115,105,97],[233,169,172,230,157,165,232,165,191,228,186,154],[77,89,82],[],[]};
get({"moy"}) ->
     {t_platform,{[109,111,121]},[109,111,121],[233,187,152,229,190,128],[],[],[]};
get({"myanmar"}) ->
     {t_platform,{[109,121,97,110,109,97,114]},[109,121,97,110,109,97,114],[231,188,133,231,148,184],[77,77,75],[],[]};
get({"singapore"}) ->
     {t_platform,{[115,105,110,103,97,112,111,114,101]},[115,105,110,103,97,112,111,114,101],[230,150,176,229,138,160,229,157,161],[83,71,68],[],[]};
get({"taiwan"}) ->
     {t_platform,{[116,97,105,119,97,110]},[116,97,105,119,97,110],[230,150,176,229,143,176,229,184,129],[84,87,68],[1,2],[229,143,176,231,129,163]};
get({"test"}) ->
     {t_platform,{[116,101,115,116]},[116,101,115,116],[229,164,150,231,189,145,230,181,139,232,175,149],[],[],[]};
get({"test2"}) ->
     {t_platform,{[116,101,115,116,50]},[116,101,115,116,50],[230,181,139,232,175,149,230,156,141,228,187,163,231,144,134],[84,87,68],[1,2],[229,143,176,231,129,163]};
get({"thailand"}) ->
     {t_platform,{[116,104,97,105,108,97,110,100]},[116,104,97,105,108,97,110,100],[230,179,176,229,155,189],[84,72,66],[],[]};
get({"vietnam"}) ->
     {t_platform,{[118,105,101,116,110,97,109]},[118,105,101,116,110,97,109],[232,182,138,229,141,151],[86,78,68],[],[]};
get(_Id) ->
    null.
