%%% Generated automatically, no need to modify.
-module(t_cost).
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
     [{1},{2},{4},{5},{6},{8},{10},{20},{40},{50},{60},{80},{100},{200},{400},{500},{600},{800},{1000},{2000},{4000},{5000},{6000},{8000},{10000},{20000},{40000},{60000},{80000},{100000},{1000000}].


get({1}) ->
     {t_cost,{1},1,[level,1],[level,1],[level,1],0};
get({2}) ->
     {t_cost,{2},2,[level,1],[level,1],[level,1],0};
get({4}) ->
     {t_cost,{4},4,[level,1],[level,1],[level,1],0};
get({5}) ->
     {t_cost,{5},5,[level,1],[level,1],[level,1],0};
get({6}) ->
     {t_cost,{6},6,[level,1],[level,1],[level,1],0};
get({8}) ->
     {t_cost,{8},8,[level,2],[level,2],[level,1],0};
get({10}) ->
     {t_cost,{10},10,[level,1],[level,1],[level,1],0};
get({20}) ->
     {t_cost,{20},20,[level,1],[level,1],[level,1],0};
get({40}) ->
     {t_cost,{40},40,[level,2],[level,2],[level,1],1};
get({50}) ->
     {t_cost,{50},50,[level,3],[level,3],[level,1],0};
get({60}) ->
     {t_cost,{60},60,[level,4],[level,4],[level,1],0};
get({80}) ->
     {t_cost,{80},80,[level,6],[level,6],[level,1],0};
get({100}) ->
     {t_cost,{100},100,[level,8],[level,8],[level,1],0};
get({200}) ->
     {t_cost,{200},200,[level,10],[level,10],[level,1],0};
get({400}) ->
     {t_cost,{400},400,[level,12],[level,12],[level,1],0};
get({500}) ->
     {t_cost,{500},500,[level,13],[level,13],[level,1],0};
get({600}) ->
     {t_cost,{600},600,[level,14],[level,14],[level,1],0};
get({800}) ->
     {t_cost,{800},800,[level,16],[level,16],[level,1],0};
get({1000}) ->
     {t_cost,{1000},1000,[level,18],[level,18],[level,1],0};
get({2000}) ->
     {t_cost,{2000},2000,[level,20],[level,20],[level,1],0};
get({4000}) ->
     {t_cost,{4000},4000,[level,22],[level,22],[level,1],0};
get({5000}) ->
     {t_cost,{5000},5000,[level,23],[level,23],[level,1],0};
get({6000}) ->
     {t_cost,{6000},6000,[level,24],[level,24],[level,1],0};
get({8000}) ->
     {t_cost,{8000},8000,[level,26],[level,26],[level,1],0};
get({10000}) ->
     {t_cost,{10000},10000,[level,28],[level,28],[level,1],0};
get({20000}) ->
     {t_cost,{20000},20000,[level,30],[level,30],[level,1],0};
get({40000}) ->
     {t_cost,{40000},40000,[level,32],[level,32],[level,1],0};
get({60000}) ->
     {t_cost,{60000},60000,[level,34],[level,34],[level,1],0};
get({80000}) ->
     {t_cost,{80000},80000,[level,36],[level,36],[level,1],0};
get({100000}) ->
     {t_cost,{100000},100000,[level,38],[level,38],[level,1],0};
get({1000000}) ->
     {t_cost,{1000000},1000000,[level,40],[level,40],[level,1],0};
get(_Id) ->
    null.
