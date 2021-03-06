%%% Generated automatically, no need to modify.
-module(t_tongxingzheng_level).
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
     [{1,0},{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{1,9},{1,10},{1,11},{1,12},{1,13},{1,14},{1,15},{1,16},{1,17},{1,18},{1,19},{1,20},{1,21},{1,22},{1,23},{1,24},{1,25},{1,26},{1,27},{1,28},{1,29},{1,30},{1,31},{1,32},{1,33},{1,34},{1,35},{1,36},{1,37},{1,38},{1,39},{1,40},{1,41},{1,42},{1,43},{1,44},{1,45},{1,46},{1,47},{1,48},{1,49},{1,50},{2,0},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{2,9},{2,10},{2,11},{2,12},{2,13},{2,14},{2,15},{2,16},{2,17},{2,18},{2,19},{2,20},{2,21},{2,22},{2,23},{2,24},{2,25},{2,26},{2,27},{2,28},{2,29},{2,30},{2,31},{2,32},{2,33},{2,34},{2,35},{2,36},{2,37},{2,38},{2,39},{2,40},{2,41},{2,42},{2,43},{2,44},{2,45},{2,46},{2,47},{2,48},{2,49},{2,50}].


get({1,0}) ->
     {t_tongxingzheng_level,{1,0},1,0,50,[52,100],[52,4000],1,1};
get({1,1}) ->
     {t_tongxingzheng_level,{1,1},1,1,100,[201,2],[202,10],0,0};
get({1,2}) ->
     {t_tongxingzheng_level,{1,2},1,2,150,[2,10000],[2,100000],0,0};
get({1,3}) ->
     {t_tongxingzheng_level,{1,3},1,3,200,[202,2],[201,10],0,0};
get({1,4}) ->
     {t_tongxingzheng_level,{1,4},1,4,250,[2,10000],[202,10],0,0};
get({1,5}) ->
     {t_tongxingzheng_level,{1,5},1,5,300,[201,2],[2,50000],0,0};
get({1,6}) ->
     {t_tongxingzheng_level,{1,6},1,6,350,[2,10000],[201,10],0,0};
get({1,7}) ->
     {t_tongxingzheng_level,{1,7},1,7,400,[202,2],[202,10],0,0};
get({1,8}) ->
     {t_tongxingzheng_level,{1,8},1,8,450,[2,10000],[52,500],0,1};
get({1,9}) ->
     {t_tongxingzheng_level,{1,9},1,9,500,[201,2],[2,50000],0,0};
get({1,10}) ->
     {t_tongxingzheng_level,{1,10},1,10,500,[52,100],[201,10],1,0};
get({1,11}) ->
     {t_tongxingzheng_level,{1,11},1,11,500,[201,2],[202,10],0,0};
get({1,12}) ->
     {t_tongxingzheng_level,{1,12},1,12,500,[2,10000],[2,50000],0,0};
get({1,13}) ->
     {t_tongxingzheng_level,{1,13},1,13,500,[202,2],[201,10],0,0};
get({1,14}) ->
     {t_tongxingzheng_level,{1,14},1,14,500,[2,10000],[2,50000],0,0};
get({1,15}) ->
     {t_tongxingzheng_level,{1,15},1,15,500,[201,2],[52,500],0,1};
get({1,16}) ->
     {t_tongxingzheng_level,{1,16},1,16,500,[2,10000],[202,10],0,0};
get({1,17}) ->
     {t_tongxingzheng_level,{1,17},1,17,500,[202,2],[2,50000],0,0};
get({1,18}) ->
     {t_tongxingzheng_level,{1,18},1,18,500,[2,10000],[201,10],0,0};
get({1,19}) ->
     {t_tongxingzheng_level,{1,19},1,19,500,[201,2],[2,50000],0,0};
get({1,20}) ->
     {t_tongxingzheng_level,{1,20},1,20,500,[6206,1],[6010,1],1,1};
get({1,21}) ->
     {t_tongxingzheng_level,{1,21},1,21,500,[201,2],[202,10],0,0};
get({1,22}) ->
     {t_tongxingzheng_level,{1,22},1,22,500,[2,10000],[2,50000],0,0};
get({1,23}) ->
     {t_tongxingzheng_level,{1,23},1,23,500,[202,2],[201,10],0,0};
get({1,24}) ->
     {t_tongxingzheng_level,{1,24},1,24,500,[2,10000],[2,50000],0,0};
get({1,25}) ->
     {t_tongxingzheng_level,{1,25},1,25,500,[201,2],[52,500],0,1};
get({1,26}) ->
     {t_tongxingzheng_level,{1,26},1,26,500,[2,10000],[202,10],0,0};
get({1,27}) ->
     {t_tongxingzheng_level,{1,27},1,27,500,[202,2],[2,50000],0,0};
get({1,28}) ->
     {t_tongxingzheng_level,{1,28},1,28,500,[2,10000],[201,10],0,0};
get({1,29}) ->
     {t_tongxingzheng_level,{1,29},1,29,500,[201,2],[2,50000],0,0};
get({1,30}) ->
     {t_tongxingzheng_level,{1,30},1,30,500,[52,100],[52,500],1,1};
get({1,31}) ->
     {t_tongxingzheng_level,{1,31},1,31,500,[201,2],[202,10],0,0};
get({1,32}) ->
     {t_tongxingzheng_level,{1,32},1,32,500,[2,10000],[2,50000],0,0};
get({1,33}) ->
     {t_tongxingzheng_level,{1,33},1,33,500,[202,2],[201,10],0,0};
get({1,34}) ->
     {t_tongxingzheng_level,{1,34},1,34,500,[2,10000],[2,50000],0,0};
get({1,35}) ->
     {t_tongxingzheng_level,{1,35},1,35,500,[201,2],[52,500],0,1};
get({1,36}) ->
     {t_tongxingzheng_level,{1,36},1,36,500,[2,10000],[202,10],0,0};
get({1,37}) ->
     {t_tongxingzheng_level,{1,37},1,37,500,[202,2],[2,50000],0,0};
get({1,38}) ->
     {t_tongxingzheng_level,{1,38},1,38,500,[2,10000],[201,10],0,0};
get({1,39}) ->
     {t_tongxingzheng_level,{1,39},1,39,500,[201,2],[2,50000],0,0};
get({1,40}) ->
     {t_tongxingzheng_level,{1,40},1,40,500,[52,100],[52,500],1,1};
get({1,41}) ->
     {t_tongxingzheng_level,{1,41},1,41,500,[201,2],[202,10],0,0};
get({1,42}) ->
     {t_tongxingzheng_level,{1,42},1,42,500,[2,10000],[2,50000],0,0};
get({1,43}) ->
     {t_tongxingzheng_level,{1,43},1,43,500,[202,2],[201,10],0,0};
get({1,44}) ->
     {t_tongxingzheng_level,{1,44},1,44,500,[2,10000],[2,50000],0,0};
get({1,45}) ->
     {t_tongxingzheng_level,{1,45},1,45,500,[201,2],[52,500],0,1};
get({1,46}) ->
     {t_tongxingzheng_level,{1,46},1,46,500,[2,10000],[202,10],0,0};
get({1,47}) ->
     {t_tongxingzheng_level,{1,47},1,47,500,[202,2],[2,50000],0,0};
get({1,48}) ->
     {t_tongxingzheng_level,{1,48},1,48,500,[2,10000],[201,10],0,0};
get({1,49}) ->
     {t_tongxingzheng_level,{1,49},1,49,500,[201,2],[2,50000],0,0};
get({1,50}) ->
     {t_tongxingzheng_level,{1,50},1,50,0,[52,100],[52,500],1,1};
get({2,0}) ->
     {t_tongxingzheng_level,{2,0},2,0,50,[52,100],[52,4000],1,1};
get({2,1}) ->
     {t_tongxingzheng_level,{2,1},2,1,100,[201,2],[202,10],0,0};
get({2,2}) ->
     {t_tongxingzheng_level,{2,2},2,2,150,[2,10000],[2,100000],0,0};
get({2,3}) ->
     {t_tongxingzheng_level,{2,3},2,3,200,[202,2],[201,10],0,0};
get({2,4}) ->
     {t_tongxingzheng_level,{2,4},2,4,250,[2,10000],[202,10],0,0};
get({2,5}) ->
     {t_tongxingzheng_level,{2,5},2,5,300,[201,2],[2,50000],0,0};
get({2,6}) ->
     {t_tongxingzheng_level,{2,6},2,6,350,[2,10000],[201,10],0,0};
get({2,7}) ->
     {t_tongxingzheng_level,{2,7},2,7,400,[202,2],[202,10],0,0};
get({2,8}) ->
     {t_tongxingzheng_level,{2,8},2,8,450,[2,10000],[52,500],0,1};
get({2,9}) ->
     {t_tongxingzheng_level,{2,9},2,9,500,[201,2],[2,50000],0,0};
get({2,10}) ->
     {t_tongxingzheng_level,{2,10},2,10,500,[52,100],[201,10],1,0};
get({2,11}) ->
     {t_tongxingzheng_level,{2,11},2,11,500,[201,2],[202,10],0,0};
get({2,12}) ->
     {t_tongxingzheng_level,{2,12},2,12,500,[2,10000],[2,50000],0,0};
get({2,13}) ->
     {t_tongxingzheng_level,{2,13},2,13,500,[202,2],[201,10],0,0};
get({2,14}) ->
     {t_tongxingzheng_level,{2,14},2,14,500,[2,10000],[2,50000],0,0};
get({2,15}) ->
     {t_tongxingzheng_level,{2,15},2,15,500,[201,2],[52,500],0,1};
get({2,16}) ->
     {t_tongxingzheng_level,{2,16},2,16,500,[2,10000],[202,10],0,0};
get({2,17}) ->
     {t_tongxingzheng_level,{2,17},2,17,500,[202,2],[2,50000],0,0};
get({2,18}) ->
     {t_tongxingzheng_level,{2,18},2,18,500,[2,10000],[201,10],0,0};
get({2,19}) ->
     {t_tongxingzheng_level,{2,19},2,19,500,[201,2],[2,50000],0,0};
get({2,20}) ->
     {t_tongxingzheng_level,{2,20},2,20,500,[6206,1],[6010,1],1,1};
get({2,21}) ->
     {t_tongxingzheng_level,{2,21},2,21,500,[201,2],[202,10],0,0};
get({2,22}) ->
     {t_tongxingzheng_level,{2,22},2,22,500,[2,10000],[2,50000],0,0};
get({2,23}) ->
     {t_tongxingzheng_level,{2,23},2,23,500,[202,2],[201,10],0,0};
get({2,24}) ->
     {t_tongxingzheng_level,{2,24},2,24,500,[2,10000],[2,50000],0,0};
get({2,25}) ->
     {t_tongxingzheng_level,{2,25},2,25,500,[201,2],[52,500],0,1};
get({2,26}) ->
     {t_tongxingzheng_level,{2,26},2,26,500,[2,10000],[202,10],0,0};
get({2,27}) ->
     {t_tongxingzheng_level,{2,27},2,27,500,[202,2],[2,50000],0,0};
get({2,28}) ->
     {t_tongxingzheng_level,{2,28},2,28,500,[2,10000],[201,10],0,0};
get({2,29}) ->
     {t_tongxingzheng_level,{2,29},2,29,500,[201,2],[2,50000],0,0};
get({2,30}) ->
     {t_tongxingzheng_level,{2,30},2,30,500,[52,100],[52,500],1,1};
get({2,31}) ->
     {t_tongxingzheng_level,{2,31},2,31,500,[201,2],[202,10],0,0};
get({2,32}) ->
     {t_tongxingzheng_level,{2,32},2,32,500,[2,10000],[2,50000],0,0};
get({2,33}) ->
     {t_tongxingzheng_level,{2,33},2,33,500,[202,2],[201,10],0,0};
get({2,34}) ->
     {t_tongxingzheng_level,{2,34},2,34,500,[2,10000],[2,50000],0,0};
get({2,35}) ->
     {t_tongxingzheng_level,{2,35},2,35,500,[201,2],[52,500],0,1};
get({2,36}) ->
     {t_tongxingzheng_level,{2,36},2,36,500,[2,10000],[202,10],0,0};
get({2,37}) ->
     {t_tongxingzheng_level,{2,37},2,37,500,[202,2],[2,50000],0,0};
get({2,38}) ->
     {t_tongxingzheng_level,{2,38},2,38,500,[2,10000],[201,10],0,0};
get({2,39}) ->
     {t_tongxingzheng_level,{2,39},2,39,500,[201,2],[2,50000],0,0};
get({2,40}) ->
     {t_tongxingzheng_level,{2,40},2,40,500,[52,100],[52,500],1,1};
get({2,41}) ->
     {t_tongxingzheng_level,{2,41},2,41,500,[201,2],[202,10],0,0};
get({2,42}) ->
     {t_tongxingzheng_level,{2,42},2,42,500,[2,10000],[2,50000],0,0};
get({2,43}) ->
     {t_tongxingzheng_level,{2,43},2,43,500,[202,2],[201,10],0,0};
get({2,44}) ->
     {t_tongxingzheng_level,{2,44},2,44,500,[2,10000],[2,50000],0,0};
get({2,45}) ->
     {t_tongxingzheng_level,{2,45},2,45,500,[201,2],[52,500],0,1};
get({2,46}) ->
     {t_tongxingzheng_level,{2,46},2,46,500,[2,10000],[202,10],0,0};
get({2,47}) ->
     {t_tongxingzheng_level,{2,47},2,47,500,[202,2],[2,50000],0,0};
get({2,48}) ->
     {t_tongxingzheng_level,{2,48},2,48,500,[2,10000],[201,10],0,0};
get({2,49}) ->
     {t_tongxingzheng_level,{2,49},2,49,500,[201,2],[2,50000],0,0};
get({2,50}) ->
     {t_tongxingzheng_level,{2,50},2,50,0,[52,100],[52,500],1,1};
get(_Id) ->
    null.
