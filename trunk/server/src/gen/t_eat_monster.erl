%%% Generated automatically, no need to modify.
-module(t_eat_monster).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}].


get({1}) ->
     {t_eat_monster,{1},1,2,4,400,400,1,[[1001,50,100]]};
get({2}) ->
     {t_eat_monster,{2},2,3,20,390,400,2,[[1002,50,100]]};
get({3}) ->
     {t_eat_monster,{3},3,4,26,380,400,4,[[1003,50,100]]};
get({4}) ->
     {t_eat_monster,{4},4,5,50,370,400,6,[[1004,50,100]]};
get({5}) ->
     {t_eat_monster,{5},5,6,100,360,400,10,[[1005,50,100]]};
get({6}) ->
     {t_eat_monster,{6},6,7,200,350,400,15,[[1006,50,100]]};
get({7}) ->
     {t_eat_monster,{7},7,8,300,340,400,20,[[1007,50,100]]};
get({8}) ->
     {t_eat_monster,{8},8,9,400,330,400,25,[[1008,50,100]]};
get({9}) ->
     {t_eat_monster,{9},9,10,500,320,400,30,[[1009,50,100]]};
get({10}) ->
     {t_eat_monster,{10},10,11,600,310,400,35,[[1010,50,100]]};
get({11}) ->
     {t_eat_monster,{11},11,12,700,300,400,40,[[1011,50,100]]};
get({12}) ->
     {t_eat_monster,{12},12,13,800,290,400,45,[[1012,50,100]]};
get({13}) ->
     {t_eat_monster,{13},13,14,900,280,400,50,[[1013,50,100]]};
get({14}) ->
     {t_eat_monster,{14},14,15,1000,270,400,55,[[1014,50,100]]};
get({15}) ->
     {t_eat_monster,{15},15,0,1100,260,400,60,[[1053,50,100]]};
get(_Id) ->
    null.
