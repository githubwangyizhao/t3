%%% Generated automatically, no need to modify.
-module(logic_get_skill_shift_info).
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


get(405) ->
     [];
get(3005) ->
     [];
get(109) ->
     [];
get(21002) ->
     [];
get(101) ->
     [];
get(106) ->
     [];
get(357) ->
     [];
get(330) ->
     [];
get(350) ->
     [];
get(1512) ->
     [];
get(1017) ->
     [];
get(359) ->
     [];
get(119) ->
     [];
get(1001) ->
     [];
get(1003) ->
     [];
get(1016) ->
     [];
get(111) ->
     [];
get(1005) ->
     [{1500,500,50,0}];
get(3006) ->
     [];
get(2005) ->
     [];
get(3002) ->
     [];
get(1013) ->
     [];
get(2008) ->
     [];
get(360) ->
     [];
get(3005) ->
     [];
get(110) ->
     [];
get(0) ->
     [];
get(6019) ->
     [];
get(354) ->
     [];
get(352) ->
     [];
get(2007) ->
     [];
get(6014) ->
     [];
get(46) ->
     [];
get(6016) ->
     [];
get(115) ->
     [];
get(2009) ->
     [];
get(1011) ->
     [];
get(118) ->
     [];
get(303) ->
     [];
get(2011) ->
     [];
get(1012) ->
     [];
get(3006) ->
     [];
get(41) ->
     [{650,300,200,0}];
get(108) ->
     [];
get(300) ->
     [{0,300,150,0}];
get(6024) ->
     [];
get(114) ->
     [];
get(6005) ->
     [];
get(5006) ->
     [];
get(116) ->
     [];
get(22002) ->
     [];
get(1017) ->
     [];
get(34) ->
     [];
get(346) ->
     [];
get(344) ->
     [];
get(2010) ->
     [];
get(6004) ->
     [];
get(5123) ->
     [];
get(2012) ->
     [];
get(4008) ->
     [];
get(412) ->
     [];
get(102) ->
     [];
get(3001) ->
     [];
get(831) ->
     [];
get(3003) ->
     [];
get(47) ->
     [];
get(6018) ->
     [];
get(122) ->
     [];
get(2000) ->
     [];
get(6015) ->
     [];
get(21004) ->
     [];
get(4066) ->
     [];
get(6012) ->
     [];
get(103) ->
     [];
get(1012) ->
     [];
get(48) ->
     [];
get(353) ->
     [];
get(112) ->
     [];
get(113) ->
     [];
get(2006) ->
     [];
get(5161) ->
     [];
get(5162) ->
     [];
get(3001) ->
     [];
get(829) ->
     [];
get(105) ->
     [];
get(358) ->
     [];
get(351) ->
     [];
get(301) ->
     [];
get(120) ->
     [];
get(1014) ->
     [];
get(1605) ->
     [];
get(22002) ->
     [];
get(117) ->
     [];
get(356) ->
     [];
get(107) ->
     [];
get(1603) ->
     [];
get(42) ->
     [];
get(832) ->
     [];
get(3005) ->
     [];
get(2001) ->
     [];
get(6023) ->
     [];
get(104) ->
     [];
get(21001) ->
     [];
get(5153) ->
     [];
get(1541) ->
     [];
get(3004) ->
     [];
get(1011) ->
     [];
get(2003) ->
     [];
get(2002) ->
     [];
get(432) ->
     [];
get(121) ->
     [];
get(2004) ->
     [];
get(6013) ->
     [];
get(_Id) ->
    null.
