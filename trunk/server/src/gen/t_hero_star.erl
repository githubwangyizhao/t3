%%% Generated automatically, no need to modify.
-module(t_hero_star).
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
     [{1,0},{1,1},{1,2},{1,3},{1,4},{1,5},{2,0},{2,1},{2,2},{2,3},{2,4},{2,5},{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{4,0},{4,1},{4,2},{4,3},{4,4},{4,5},{5,0},{5,1},{5,2},{5,3},{5,4},{5,5},{6,0},{6,1},{6,2},{6,3},{6,4},{6,5},{7,0},{7,1},{7,2},{7,3},{7,4},{7,5},{8,0},{8,1},{8,2},{8,3},{8,4},{8,5},{9,0},{9,1},{9,2},{9,3},{9,4},{9,5},{10,0},{10,1},{10,2},{10,3},{10,4},{10,5},{11,0},{11,1},{11,2},{11,3},{11,4},{11,5},{12,0},{12,1},{12,2},{12,3},{12,4},{12,5}].


get({1,0}) ->
     {t_hero_star,{1,0},1,0,1,[901,1],8010};
get({1,1}) ->
     {t_hero_star,{1,1},1,1,2,[901,1],8013};
get({1,2}) ->
     {t_hero_star,{1,2},1,2,3,[901,1],8012};
get({1,3}) ->
     {t_hero_star,{1,3},1,3,4,[901,1],8011};
get({1,4}) ->
     {t_hero_star,{1,4},1,4,5,[901,1],8014};
get({1,5}) ->
     {t_hero_star,{1,5},1,5,0,[],8015};
get({2,0}) ->
     {t_hero_star,{2,0},2,0,1,[902,1],8020};
get({2,1}) ->
     {t_hero_star,{2,1},2,1,2,[902,1],8023};
get({2,2}) ->
     {t_hero_star,{2,2},2,2,3,[902,1],8022};
get({2,3}) ->
     {t_hero_star,{2,3},2,3,4,[902,1],8021};
get({2,4}) ->
     {t_hero_star,{2,4},2,4,5,[902,1],8024};
get({2,5}) ->
     {t_hero_star,{2,5},2,5,0,[],8025};
get({3,0}) ->
     {t_hero_star,{3,0},3,0,1,[903,1],8030};
get({3,1}) ->
     {t_hero_star,{3,1},3,1,2,[903,1],8033};
get({3,2}) ->
     {t_hero_star,{3,2},3,2,3,[903,1],8032};
get({3,3}) ->
     {t_hero_star,{3,3},3,3,4,[903,1],8031};
get({3,4}) ->
     {t_hero_star,{3,4},3,4,5,[903,1],8034};
get({3,5}) ->
     {t_hero_star,{3,5},3,5,0,[],8035};
get({4,0}) ->
     {t_hero_star,{4,0},4,0,1,[904,1],8040};
get({4,1}) ->
     {t_hero_star,{4,1},4,1,2,[904,1],8043};
get({4,2}) ->
     {t_hero_star,{4,2},4,2,3,[904,1],8042};
get({4,3}) ->
     {t_hero_star,{4,3},4,3,4,[904,1],8041};
get({4,4}) ->
     {t_hero_star,{4,4},4,4,5,[904,1],8044};
get({4,5}) ->
     {t_hero_star,{4,5},4,5,0,[],8045};
get({5,0}) ->
     {t_hero_star,{5,0},5,0,1,[905,1],8050};
get({5,1}) ->
     {t_hero_star,{5,1},5,1,2,[905,1],8053};
get({5,2}) ->
     {t_hero_star,{5,2},5,2,3,[905,1],8052};
get({5,3}) ->
     {t_hero_star,{5,3},5,3,4,[905,1],8051};
get({5,4}) ->
     {t_hero_star,{5,4},5,4,5,[905,1],8054};
get({5,5}) ->
     {t_hero_star,{5,5},5,5,0,[],8055};
get({6,0}) ->
     {t_hero_star,{6,0},6,0,1,[906,1],8060};
get({6,1}) ->
     {t_hero_star,{6,1},6,1,2,[906,1],8063};
get({6,2}) ->
     {t_hero_star,{6,2},6,2,3,[906,1],8062};
get({6,3}) ->
     {t_hero_star,{6,3},6,3,4,[906,1],8061};
get({6,4}) ->
     {t_hero_star,{6,4},6,4,5,[906,1],8064};
get({6,5}) ->
     {t_hero_star,{6,5},6,5,0,[],8065};
get({7,0}) ->
     {t_hero_star,{7,0},7,0,1,[907,1],8070};
get({7,1}) ->
     {t_hero_star,{7,1},7,1,2,[907,1],8073};
get({7,2}) ->
     {t_hero_star,{7,2},7,2,3,[907,1],8072};
get({7,3}) ->
     {t_hero_star,{7,3},7,3,4,[907,1],8071};
get({7,4}) ->
     {t_hero_star,{7,4},7,4,5,[907,1],8074};
get({7,5}) ->
     {t_hero_star,{7,5},7,5,0,[],8075};
get({8,0}) ->
     {t_hero_star,{8,0},8,0,1,[908,1],8080};
get({8,1}) ->
     {t_hero_star,{8,1},8,1,2,[908,1],8083};
get({8,2}) ->
     {t_hero_star,{8,2},8,2,3,[908,1],8082};
get({8,3}) ->
     {t_hero_star,{8,3},8,3,4,[908,1],8081};
get({8,4}) ->
     {t_hero_star,{8,4},8,4,5,[908,1],8084};
get({8,5}) ->
     {t_hero_star,{8,5},8,5,0,[],8085};
get({9,0}) ->
     {t_hero_star,{9,0},9,0,1,[909,1],8090};
get({9,1}) ->
     {t_hero_star,{9,1},9,1,2,[909,1],8093};
get({9,2}) ->
     {t_hero_star,{9,2},9,2,3,[909,1],8092};
get({9,3}) ->
     {t_hero_star,{9,3},9,3,4,[909,1],8091};
get({9,4}) ->
     {t_hero_star,{9,4},9,4,5,[909,1],8094};
get({9,5}) ->
     {t_hero_star,{9,5},9,5,0,[],8095};
get({10,0}) ->
     {t_hero_star,{10,0},10,0,1,[910,1],8100};
get({10,1}) ->
     {t_hero_star,{10,1},10,1,2,[910,1],8103};
get({10,2}) ->
     {t_hero_star,{10,2},10,2,3,[910,1],8102};
get({10,3}) ->
     {t_hero_star,{10,3},10,3,4,[910,1],8101};
get({10,4}) ->
     {t_hero_star,{10,4},10,4,5,[910,1],8104};
get({10,5}) ->
     {t_hero_star,{10,5},10,5,0,[],8105};
get({11,0}) ->
     {t_hero_star,{11,0},11,0,1,[911,1],0};
get({11,1}) ->
     {t_hero_star,{11,1},11,1,2,[911,1],8113};
get({11,2}) ->
     {t_hero_star,{11,2},11,2,3,[911,1],8112};
get({11,3}) ->
     {t_hero_star,{11,3},11,3,4,[911,1],8111};
get({11,4}) ->
     {t_hero_star,{11,4},11,4,5,[911,1],8114};
get({11,5}) ->
     {t_hero_star,{11,5},11,5,0,[],8115};
get({12,0}) ->
     {t_hero_star,{12,0},12,0,1,[912,1],8120};
get({12,1}) ->
     {t_hero_star,{12,1},12,1,2,[912,1],8123};
get({12,2}) ->
     {t_hero_star,{12,2},12,2,3,[912,1],8122};
get({12,3}) ->
     {t_hero_star,{12,3},12,3,4,[912,1],8121};
get({12,4}) ->
     {t_hero_star,{12,4},12,4,5,[912,1],8124};
get({12,5}) ->
     {t_hero_star,{12,5},12,5,0,[],8125};
get(_Id) ->
    null.
