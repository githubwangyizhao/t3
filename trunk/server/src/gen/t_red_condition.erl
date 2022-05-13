%%% Generated automatically, no need to modify.
-module(t_red_condition).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{999}].


get({1}) ->
     {t_red_condition,{1},1,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,7],1,0,[2,4],20};
get({2}) ->
     {t_red_condition,{2},2,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,29],2,0,[3,6],20};
get({3}) ->
     {t_red_condition,{3},3,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,99],3,0,[4,8],20};
get({4}) ->
     {t_red_condition,{4},4,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,299],4,0,[6,12],20};
get({5}) ->
     {t_red_condition,{5},5,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,499],5,0,[8,16],20};
get({6}) ->
     {t_red_condition,{6},6,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,799],6,0,[10,20],20};
get({7}) ->
     {t_red_condition,{7},7,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,1999],7,0,[12,24],20};
get({8}) ->
     {t_red_condition,{8},8,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,2999],8,0,[14,28],20};
get({9}) ->
     {t_red_condition,{9},9,[229,141,149,231,172,148,229,130,168,229,128,188],[230,132,159,232,176,162,229,164,167,228,189,172,124,99,49,48,50,123,37,116,101,120,116,125,36,99,229,143,145,233,128,129,231,154,132,231,166,143,229,136,169],[recharge_money_daliy,4999],9,0,[16,32],20};
get({999}) ->
     {t_red_condition,{999},999,[98,111,115,115,229,135,187,230,157,128],[230,181,139,232,175,149,229,134,133,229,174,185,49,49,52],[],999,0,[10,21],20};
get(_Id) ->
    null.
