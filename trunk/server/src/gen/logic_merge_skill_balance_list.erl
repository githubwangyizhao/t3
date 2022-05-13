%%% Generated automatically, no need to modify.
-module(logic_merge_skill_balance_list).
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
     [].


get(22004) ->
     [{1,1,0,[{1,6,0,1}]}];
get(22003) ->
     [{1,1,0,[{1,9,0,1}]}];
get(22002) ->
     [{1,1,0,[{1,9,0,1}]}];
get(22001) ->
     [{1,1,0,[{1,2,0,1}]}];
get(21004) ->
     [{1,1,0,[{1,6,0,1}]}];
get(21002) ->
     [{1,1,0,[{1,3,0,1}]}];
get(21001) ->
     [{1,1,0,[{1,4,0,1}]}];
get(4002) ->
     [{1,1,0,[{1,5,0,1}]}];
get(4001) ->
     [{1,1,0,[{1,5,0,1}]}];
get(3007) ->
     [{1,1,0,[{1,4,0,1}]}];
get(3006) ->
     [{1,1,0,[{1,11,0,1}]}];
get(3005) ->
     [{1,1,0,[{1,8,0,1}]}];
get(3004) ->
     [{1,1,0,[{1,4,0,1}]}];
get(3003) ->
     [{1,1,0,[{1,7,0,1}]}];
get(3002) ->
     [{1,1,0,[{1,4,0,1}]}];
get(3001) ->
     [{1,1,0,[{1,6,0,1}]}];
get(3000) ->
     [{1,1,0,[{1,6,0,1}]}];
get(2012) ->
     [{1,0,0,[{1,0,0,0}]},{2,1,1200,[{2,2101,1200,1}]}];
get(2011) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.34,1200,[{2,2101,1200,0.34}]},{3,0.66,400,[{2,2101,200,0.33},{2,2101,400,0.33}]}];
get(2010) ->
     [{1,0.34,880,[{1,0,0,0},{2,2102,880,0.34}]},{2,0.66,400,[{2,2102,200,0.33},{2,2102,400,0.33}]}];
get(2009) ->
     [{1,0.4,970,[{1,0,0,0},{2,2101,880,0.2},{3,2101,970,0.2}]},{2,0.6000000000000001,270,[{4,2101,90,0.2},{5,2101,180,0.2},{6,2101,270,0.2}]}];
get(2008) ->
     [{1,0.4,970,[{1,0,0,0},{2,2101,880,0.2},{3,2101,970,0.2}]},{2,0.6000000000000001,270,[{4,2101,90,0.2},{5,2101,180,0.2},{6,2101,270,0.2}]}];
get(2007) ->
     [{1,0,0,[{1,0,0,0}]},{2,1,1500,[{2,208,1500,1}]}];
get(2006) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.1,1840,[{2,2107,1840,0.1}]},{3,0.8999999999999999,540,[{3,2107,60,0.1},{4,2107,120,0.1},{5,2107,180,0.1},{6,2107,240,0.1},{7,2107,300,0.1},{8,2107,360,0.1},{9,2107,420,0.1},{10,2107,480,0.1},{11,2107,540,0.1}]}];
get(2005) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.1,1240,[{2,2109,1240,0.1}]},{3,0.8999999999999999,720,[{3,2109,80,0.1},{4,2109,160,0.1},{5,2109,240,0.1},{6,2109,320,0.1},{7,2109,400,0.1},{8,2109,480,0.1},{9,2109,560,0.1},{10,2109,640,0.1},{11,2109,720,0.1}]}];
get(2004) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.2,1240,[{2,2101,1240,0.2}]},{3,0.8,920,[{3,2103,230,0.2},{4,2104,460,0.2},{5,2105,690,0.2},{6,2106,920,0.2}]}];
get(2003) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.34,1360,[{2,2108,1360,0.34}]},{3,0.66,400,[{3,2108,200,0.33},{4,2108,400,0.33}]}];
get(2002) ->
     [{1,0,0,[{1,0,0,0}]},{2,0.1,1640,[{2,2107,1640,0.1}]},{3,0.8999999999999999,900,[{3,2107,100,0.1},{4,2107,200,0.1},{5,2107,300,0.1},{6,2107,400,0.1},{7,2107,500,0.1},{8,2107,600,0.1},{9,2107,700,0.1},{10,2107,800,0.1},{11,2107,900,0.1}]}];
get(2001) ->
     [{1,1.0,640,[{1,0,0,0},{2,9999,80,0.125},{3,9999,160,0.125},{4,9999,240,0.125},{5,9999,320,0.125},{6,9999,400,0.125},{7,9999,480,0.125},{8,9999,560,0.125},{9,9999,640,0.125}]}];
get(1017) ->
     [{1,1,0,[{1,3,0,1}]}];
get(1016) ->
     [{1,1,0,[{1,4,0,1}]}];
get(1015) ->
     [{1,1,0,[{1,11,0,1}]}];
get(1014) ->
     [{1,1,0,[{1,6,0,1}]}];
get(1013) ->
     [{1,1,0,[{1,11,0,1}]}];
get(1012) ->
     [{1,1,0,[{1,4,0,1}]}];
get(1011) ->
     [{1,1,0,[{1,2,0,1}]}];
get(1002) ->
     [{1,1,0,[{1,1,0,1}]}];
get(1001) ->
     [{1,1,0,[{1,1,0,1}]}];
get(999) ->
     [{1,1,0,[{1,1,0,1}]}];
get(903) ->
     [{1,1,0,[{1,1,0,1}]}];
get(902) ->
     [{1,1,0,[{1,1,0,1}]}];
get(901) ->
     [{1,1,0,[{1,1,0,1}]}];
get(203) ->
     [{1,1,0,[{1,1203,0,1}]}];
get(202) ->
     [{1,1,0,[{1,1202,0,1}]}];
get(201) ->
     [{1,1,0,[{1,1201,0,1}]}];
get(112) ->
     [{1,1,0,[{1,106,0,1}]}];
get(111) ->
     [{1,1,0,[{1,105,0,1}]}];
get(110) ->
     [{1,1,0,[{1,108,0,1}]}];
get(109) ->
     [{1,1,0,[{1,105,0,1}]}];
get(108) ->
     [{1,1,0,[{1,0,0,1}]}];
get(107) ->
     [{1,1,0,[{1,108,0,1}]}];
get(106) ->
     [{1,1,0,[{1,106,0,1}]}];
get(105) ->
     [{1,1,0,[{1,105,0,1}]}];
get(103) ->
     [{1,1,0,[{1,1102,0,1}]}];
get(102) ->
     [{1,1,0,[{1,1102,0,1}]}];
get(101) ->
     [{1,1,0,[{1,1101,0,1}]}];
get(5) ->
     [{1,1,0,[{1,1,0,1}]}];
get(4) ->
     [{1,1,0,[{1,9999,0,1}]}];
get(_Id) ->
    null.
