%%% Generated automatically, no need to modify.
-module(t_jiangjinchi_init_award).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22}].


get({1}) ->
     {t_jiangjinchi_init_award,{1},1,1,39999,[[{0,0},5600],[{0,0},2800],[{0,0},1200],[{0,0},400]]};
get({2}) ->
     {t_jiangjinchi_init_award,{2},2,40000,79999,[[{1,1},5600],[{2,3},2800],[{4,4},1200],[{5,6},400]]};
get({3}) ->
     {t_jiangjinchi_init_award,{3},3,80000,159999,[[{1,2},5600],[{3,4},2800],[{5,6},1200],[{7,9},400]]};
get({4}) ->
     {t_jiangjinchi_init_award,{4},4,160000,319999,[[{1,4},5600],[{5,8},2800],[{8,11},1200],[{12,15},400]]};
get({5}) ->
     {t_jiangjinchi_init_award,{5},5,320000,639999,[[{2,8},5600],[{9,14},2800],[{15,20},1200],[{21,27},400]]};
get({6}) ->
     {t_jiangjinchi_init_award,{6},6,640000,1279999,[[{2,9},5600],[{9,16},2800],[{16,23},1200],[{23,30},400]]};
get({7}) ->
     {t_jiangjinchi_init_award,{7},7,1280000,2559999,[[{6,27},5600],[{27,48},2800],[{48,69},1200],[{69,90},400]]};
get({8}) ->
     {t_jiangjinchi_init_award,{8},8,2560000,5119999,[[{12,54},5600],[{54,96},2800],[{96,138},1200],[{138,180},400]]};
get({9}) ->
     {t_jiangjinchi_init_award,{9},9,5120000,10239999,[[{20,90},5600],[{90,160},2800],[{160,230},1200],[{230,300},400]]};
get({10}) ->
     {t_jiangjinchi_init_award,{10},10,10240000,20479999,[[{40,180},5600],[{180,320},2800],[{320,460},1200],[{460,600},400]]};
get({11}) ->
     {t_jiangjinchi_init_award,{11},11,20480000,40959999,[[{100,450},5600],[{450,800},2800],[{800,1150},1200],[{1150,1500},400]]};
get({12}) ->
     {t_jiangjinchi_init_award,{12},12,40960000,81919999,[[{200,900},5600],[{900,1600},2800],[{1600,2300},1200],[{2300,3000},400]]};
get({13}) ->
     {t_jiangjinchi_init_award,{13},13,81920000,163839999,[[{400,1800},5600],[{1800,3200},2800],[{3200,4600},1200],[{4600,6000},400]]};
get({14}) ->
     {t_jiangjinchi_init_award,{14},14,163840000,327679999,[[{800,3600},5600],[{3600,6400},2800],[{6400,9200},1200],[{9200,12000},400]]};
get({15}) ->
     {t_jiangjinchi_init_award,{15},15,327680000,655359999,[[{1600,7200},5600],[{7200,12800},2800],[{12800,18400},1200],[{18400,24000},400]]};
get({16}) ->
     {t_jiangjinchi_init_award,{16},16,655360000,1310719999,[[{2000,9000},5600],[{9000,16000},2800],[{16000,23000},1200],[{23000,30000},400]]};
get({17}) ->
     {t_jiangjinchi_init_award,{17},17,1310720000,2621439999,[[{6000,27000},5600],[{27000,48000},2800],[{48000,69000},1200],[{69000,90000},400]]};
get({18}) ->
     {t_jiangjinchi_init_award,{18},18,2621440000,5242879999,[[{12000,54000},5600],[{54000,96000},2800],[{96000,138000},1200],[{138000,180000},400]]};
get({19}) ->
     {t_jiangjinchi_init_award,{19},19,5242880000,10485759999,[[{20000,90000},5600],[{90000,160000},2800],[{160000,230000},1200],[{230000,300000},400]]};
get({20}) ->
     {t_jiangjinchi_init_award,{20},20,10485760000,20971519999,[[{40000,180000},5600],[{180000,320000},2800],[{320000,460000},1200],[{460000,600000},400]]};
get({21}) ->
     {t_jiangjinchi_init_award,{21},21,20971520000,41943039999,[[{100000,450000},5600],[{450000,800000},2800],[{800000,1150000},1200],[{1150000,1500000},400]]};
get({22}) ->
     {t_jiangjinchi_init_award,{22},22,41943040000,0,[[{200000,900000},5600],[{900000,1600000},2800],[{1600000,2300000},1200],[{2300000,3000000},400]]};
get(_Id) ->
    null.
