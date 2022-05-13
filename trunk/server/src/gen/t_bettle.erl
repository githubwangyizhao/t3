%%% Generated automatically, no need to modify.
-module(t_bettle).
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
     [{1},{2},{3}].


get({1}) ->
     {t_bettle,{1},1,[52,100],[[1,90001],[2,0]],210000,6000,1000000,[[1,90004],[2,0]],6001,[[1,1,90004],[2,3,90007],[4,10,90010]],[49,239,188,154,229,175,185,229,177,128,229,133,165,229,156,186,230,182,136,232,128,151,49,48,48,232,181,143,233,135,145,231,159,179,227,128,130,124,110,50,239,188,154,229,175,185,229,177,128,229,165,150,229,138,177,239,188,154,124,110,232,142,183,232,131,156,230,150,185,232,142,183,229,190,151,49,57,54,232,181,143,233,135,145,231,159,179,239,188,140,124,110,229,175,185,229,177,128,229,185,179,230,137,139,229,143,140,230,150,185,232,142,183,229,190,151,57,56,232,181,143,233,135,145,231,159,179,124,110,51,239,188,154,230,175,143,230,151,165,230,160,185,230,141,174,232,131,156,229,156,186,232,191,155,232,161,140,230,142,146,232,161,140,229,143,145,230,148,190,229,165,150,229,138,177,239,188,154,124,110,231,172,172,49,229,144,141,232,142,183,229,190,151,52,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,50,45,51,229,144,141,232,142,183,229,190,151,49,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,52,45,49,48,229,144,141,232,142,183,229,190,151,52,48,232,181,143,233,135,145,231,159,179,124,110,52,239,188,154,230,142,146,232,161,140,230,166,156,230,175,143,230,151,165,50,48,58,48,48,231,187,147,231,174,151,44,233,128,154,232,191,135,233,130,174,228,187,182,229,143,145,230,148,190,229,165,150,229,138,177,44,231,187,147,231,174,151,229,144,142,230,184,133,231,169,186,230,142,146,232,161,140,230,166,156,227,128,130,124,110,53,239,188,154,230,156,128,229,176,145,233,156,128,232,166,129,231,180,175,232,174,161,49,48,229,156,186,232,131,156,229,156,186,230,137,141,232,131,189,228,184,138,230,166,156,227,128,130,124,110,54,239,188,154,229,175,185,229,177,128,229,134,133,229,141,149,228,189,147,230,148,187,229,135,187,229,146,140,231,190,164,228,189,147,230,148,187,229,135,187,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,227,128,130,124,110,55,239,188,154,229,175,185,229,177,128,229,134,133,229,134,176,229,134,187,229,141,183,232,189,180,229,146,140,231,139,130,230,154,180,229,141,183,232,189,180,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,228,184,148,228,184,141,230,182,136,232,128,151,230,139,165,230,156,137,231,154,132,229,141,183,232,189,180],16,[[201,5],[202,5],[4,1],[5,5]],10,35004,35001,35007,10};
get({2}) ->
     {t_bettle,{2},2,[52,500],[[1,90002],[2,0]],210000,6000,10000000,[[1,90005],[2,0]],6002,[[1,1,90005],[2,3,90008],[4,10,90011]],[49,239,188,154,229,175,185,229,177,128,229,133,165,229,156,186,230,182,136,232,128,151,53,48,48,232,181,143,233,135,145,231,159,179,227,128,130,124,110,50,239,188,154,229,175,185,229,177,128,229,165,150,229,138,177,239,188,154,124,110,232,142,183,232,131,156,230,150,185,232,142,183,229,190,151,57,56,48,232,181,143,233,135,145,231,159,179,239,188,140,124,110,229,185,179,230,137,139,229,143,140,230,150,185,232,142,183,229,190,151,52,57,48,232,181,143,233,135,145,231,159,179,124,110,51,239,188,154,230,175,143,230,151,165,230,160,185,230,141,174,232,131,156,229,156,186,232,191,155,232,161,140,230,142,146,232,161,140,229,143,145,230,148,190,229,165,150,229,138,177,239,188,154,124,110,231,172,172,49,229,144,141,232,142,183,229,190,151,50,48,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,50,45,51,229,144,141,232,142,183,229,190,151,53,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,52,45,49,48,229,144,141,232,142,183,229,190,151,50,48,48,232,181,143,233,135,145,231,159,179,124,110,52,239,188,154,230,142,146,232,161,140,230,166,156,230,175,143,230,151,165,50,48,58,48,48,231,187,147,231,174,151,44,233,128,154,232,191,135,233,130,174,228,187,182,229,143,145,230,148,190,229,165,150,229,138,177,44,231,187,147,231,174,151,229,144,142,230,184,133,231,169,186,230,142,146,232,161,140,230,166,156,227,128,130,124,110,53,239,188,154,230,156,128,229,176,145,233,156,128,232,166,129,231,180,175,232,174,161,49,48,229,156,186,232,131,156,229,156,186,230,137,141,232,131,189,228,184,138,230,166,156,227,128,130,124,110,54,239,188,154,229,175,185,229,177,128,229,134,133,229,141,149,228,189,147,230,148,187,229,135,187,229,146,140,231,190,164,228,189,147,230,148,187,229,135,187,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,227,128,130,124,110,55,239,188,154,229,175,185,229,177,128,229,134,133,229,134,176,229,134,187,229,141,183,232,189,180,229,146,140,231,139,130,230,154,180,229,141,183,232,189,180,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,228,184,148,228,184,141,230,182,136,232,128,151,230,139,165,230,156,137,231,154,132,229,141,183,232,189,180],16,[[201,5],[202,5],[4,1],[5,5]],10,35005,35002,35008,10};
get({3}) ->
     {t_bettle,{3},3,[52,2000],[[1,90003],[2,0]],210000,6000,100000000,[[1,90006],[2,0]],6003,[[1,1,90006],[2,3,90009],[4,10,90012]],[49,239,188,154,229,175,185,229,177,128,229,133,165,229,156,186,230,182,136,232,128,151,50,48,48,48,232,181,143,233,135,145,231,159,179,227,128,130,124,110,50,239,188,154,229,175,185,229,177,128,229,165,150,229,138,177,239,188,154,124,110,232,142,183,232,131,156,230,150,185,232,142,183,229,190,151,51,57,50,48,232,181,143,233,135,145,231,159,179,239,188,140,124,110,229,185,179,230,137,139,229,143,140,230,150,185,232,142,183,229,190,151,49,57,54,48,232,181,143,233,135,145,231,159,179,124,110,51,239,188,154,230,175,143,230,151,165,230,160,185,230,141,174,232,131,156,229,156,186,232,191,155,232,161,140,230,142,146,232,161,140,229,143,145,230,148,190,229,165,150,229,138,177,239,188,154,124,110,231,172,172,49,229,144,141,232,142,183,229,190,151,56,48,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,50,45,51,229,144,141,232,142,183,229,190,151,50,48,48,48,232,181,143,233,135,145,231,159,179,124,110,231,172,172,52,45,49,48,229,144,141,232,142,183,229,190,151,56,48,48,232,181,143,233,135,145,231,159,179,124,110,52,239,188,154,230,142,146,232,161,140,230,166,156,230,175,143,230,151,165,50,48,58,48,48,231,187,147,231,174,151,44,233,128,154,232,191,135,233,130,174,228,187,182,229,143,145,230,148,190,229,165,150,229,138,177,44,231,187,147,231,174,151,229,144,142,230,184,133,231,169,186,230,142,146,232,161,140,230,166,156,227,128,130,124,110,53,239,188,154,230,156,128,229,176,145,233,156,128,232,166,129,231,180,175,232,174,161,49,48,229,156,186,232,131,156,229,156,186,230,137,141,232,131,189,228,184,138,230,166,156,227,128,130,124,110,54,239,188,154,229,175,185,229,177,128,229,134,133,229,141,149,228,189,147,230,148,187,229,135,187,229,146,140,231,190,164,228,189,147,230,148,187,229,135,187,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,227,128,130,124,110,55,239,188,154,229,175,185,229,177,128,229,134,133,229,134,176,229,134,187,229,141,183,232,189,180,229,146,140,231,139,130,230,154,180,229,141,183,232,189,180,230,156,137,230,172,161,230,149,176,233,153,144,229,136,182,228,184,148,228,184,141,230,182,136,232,128,151,230,139,165,230,156,137,231,154,132,229,141,183,232,189,180],16,[[201,5],[202,5],[4,1],[5,5]],10,35006,35003,35009,10};
get(_Id) ->
    null.
