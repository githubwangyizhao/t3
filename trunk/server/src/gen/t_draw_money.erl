%%% Generated automatically, no need to modify.
-module(t_draw_money).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}].


get({1}) ->
     {t_draw_money,{1},1,3,101,0};
get({2}) ->
     {t_draw_money,{2},2,10,101,1};
get({3}) ->
     {t_draw_money,{3},3,50,101,1};
get({4}) ->
     {t_draw_money,{4},4,100,101,1};
get({5}) ->
     {t_draw_money,{5},5,300,101,1};
get({6}) ->
     {t_draw_money,{6},6,500,101,1};
get({7}) ->
     {t_draw_money,{7},7,800,101,1};
get({8}) ->
     {t_draw_money,{8},8,1000,101,1};
get({9}) ->
     {t_draw_money,{9},9,1500,101,1};
get({10}) ->
     {t_draw_money,{10},10,2000,101,1};
get({11}) ->
     {t_draw_money,{11},11,3000,101,1};
get(_Id) ->
    null.
