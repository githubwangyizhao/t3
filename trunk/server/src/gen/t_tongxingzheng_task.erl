%%% Generated automatically, no need to modify.
-module(t_tongxingzheng_task).
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
     [{1001},{1002},{1003},{1004},{1005},{1006},{1007},{1008},{1009},{1010},{1011},{1012},{1013},{1014},{1015},{1016},{1017},{1018},{1019},{1020},{1021},{1022},{1023},{1024},{1025},{1026},{1027},{1028},{1029},{1030},{1031},{1032},{1033},{1034},{1035},{1036},{1037},{1038},{1039},{1040},{1041},{1042},{1043},{1044},{1045},{1046},{1047},{1048},{1049},{1050},{1051},{1052},{1053},{1054},{1055},{1056},{1057},{1058},{1059},{1060},{1061},{1062},{1063},{1064},{1101},{1102},{1103},{1104},{1105},{1106},{1107},{1108},{1109},{1110},{1111},{1112},{1113},{1114},{1115},{1116},{1117},{1118},{1119},{1120},{1121},{1122},{1123},{1124},{1125},{1126},{1127},{1128},{1129},{1130},{1131},{1132},{2001},{2002},{2003},{2004},{2005},{2006},{2007},{2008},{2009},{2010},{2011},{2012},{2013},{2014},{2015},{2016},{2017},{2018},{2019},{2020},{2021},{2022},{2023},{2024},{2025},{2026},{2027},{2028},{2029},{2030},{2031},{2032},{2033},{2034},{2035},{2036},{2037},{2038},{2039},{2040},{2041},{2042},{2043},{2044},{2045},{2046},{2047},{2048},{2049},{2050},{2051},{2052},{2053},{2054},{2055},{2056},{2057},{2058},{2059},{2060},{2061},{2062},{2063},{2064},{2101},{2102},{2103},{2104},{2105},{2106},{2107},{2108},{2109},{2110},{2111},{2112},{2113},{2114},{2115},{2116},{2117},{2118},{2119},{2120},{2121},{2122},{2123},{2124},{2125},{2126},{2127},{2128},{2129},{2130},{2131},{2132}].


get({1001}) ->
     {t_tongxingzheng_task,{1001},1001,1,1,0,[kill,50101,100],[]};
get({1002}) ->
     {t_tongxingzheng_task,{1002},1002,1,1,0,[kill,50107,40],[]};
get({1003}) ->
     {t_tongxingzheng_task,{1003},1003,2,1,0,[kill,50105,50],[]};
get({1004}) ->
     {t_tongxingzheng_task,{1004},1004,2,1,0,[kill_effect_count,12,5],[]};
get({1005}) ->
     {t_tongxingzheng_task,{1005},1005,3,1,0,[kill,50102,90],[]};
get({1006}) ->
     {t_tongxingzheng_task,{1006},1006,3,1,0,[kill,50110,9],[]};
get({1007}) ->
     {t_tongxingzheng_task,{1007},1007,4,1,0,[kill,50201,100],[]};
get({1008}) ->
     {t_tongxingzheng_task,{1008},1008,4,1,0,[kill,50115,3],[]};
get({1009}) ->
     {t_tongxingzheng_task,{1009},1009,5,1,0,[kill_effect_count,13,5],[]};
get({1010}) ->
     {t_tongxingzheng_task,{1010},1010,5,1,0,[kill,50109,10],[]};
get({1011}) ->
     {t_tongxingzheng_task,{1011},1011,6,1,0,[kill,50205,50],[]};
get({1012}) ->
     {t_tongxingzheng_task,{1012},1012,6,1,0,[kill,50111,8],[]};
get({1013}) ->
     {t_tongxingzheng_task,{1013},1013,7,1,0,[kill,50106,45],[]};
get({1014}) ->
     {t_tongxingzheng_task,{1014},1014,7,1,0,[kill,50216,3],[]};
get({1015}) ->
     {t_tongxingzheng_task,{1015},1015,8,1,0,[kill,50103,80],[]};
get({1016}) ->
     {t_tongxingzheng_task,{1016},1016,8,1,0,[kill_effect_count,15,1],[]};
get({1017}) ->
     {t_tongxingzheng_task,{1017},1017,9,1,0,[kill,50202,90],[]};
get({1018}) ->
     {t_tongxingzheng_task,{1018},1018,9,1,0,[kill,50210,9],[]};
get({1019}) ->
     {t_tongxingzheng_task,{1019},1019,10,1,0,[kill,50206,45],[]};
get({1020}) ->
     {t_tongxingzheng_task,{1020},1020,10,1,0,[kill,50215,3],[]};
get({1021}) ->
     {t_tongxingzheng_task,{1021},1021,11,1,0,[kill_effect_count,5,5],[]};
get({1022}) ->
     {t_tongxingzheng_task,{1022},1022,11,1,0,[kill,50209,10],[]};
get({1023}) ->
     {t_tongxingzheng_task,{1023},1023,12,1,0,[kill,50203,80],[]};
get({1024}) ->
     {t_tongxingzheng_task,{1024},1024,12,1,0,[kill,50212,7],[]};
get({1025}) ->
     {t_tongxingzheng_task,{1025},1025,13,1,0,[kill,50207,40],[]};
get({1026}) ->
     {t_tongxingzheng_task,{1026},1026,13,1,0,[kill,50313,35],[]};
get({1027}) ->
     {t_tongxingzheng_task,{1027},1027,14,1,0,[kill,50301,100],[]};
get({1028}) ->
     {t_tongxingzheng_task,{1028},1028,14,1,0,[kill_effect_count,14,5],[]};
get({1029}) ->
     {t_tongxingzheng_task,{1029},1029,15,1,0,[kill,50305,50],[]};
get({1030}) ->
     {t_tongxingzheng_task,{1030},1030,15,1,0,[kill,50211,8],[]};
get({1031}) ->
     {t_tongxingzheng_task,{1031},1031,16,1,0,[kill,50318,3],[]};
get({1032}) ->
     {t_tongxingzheng_task,{1032},1032,16,1,0,[kill,50204,70],[]};
get({1033}) ->
     {t_tongxingzheng_task,{1033},1033,17,1,0,[kill_effect_count,7,1],[]};
get({1034}) ->
     {t_tongxingzheng_task,{1034},1034,17,1,0,[kill,50311,8],[]};
get({1035}) ->
     {t_tongxingzheng_task,{1035},1035,18,1,0,[kill,50302,90],[]};
get({1036}) ->
     {t_tongxingzheng_task,{1036},1036,18,1,0,[kill,50317,3],[]};
get({1037}) ->
     {t_tongxingzheng_task,{1037},1037,19,1,0,[kill,50306,45],[]};
get({1038}) ->
     {t_tongxingzheng_task,{1038},1038,19,1,0,[kill,50310,9],[]};
get({1039}) ->
     {t_tongxingzheng_task,{1039},1039,20,1,0,[kill,50303,80],[]};
get({1040}) ->
     {t_tongxingzheng_task,{1040},1040,20,1,0,[kill_effect_count,21,5],[]};
get({1041}) ->
     {t_tongxingzheng_task,{1041},1041,21,1,0,[kill,50307,40],[]};
get({1042}) ->
     {t_tongxingzheng_task,{1042},1042,21,1,0,[kill,50316,3],[]};
get({1043}) ->
     {t_tongxingzheng_task,{1043},1043,22,1,0,[kill,50401,100],[]};
get({1044}) ->
     {t_tongxingzheng_task,{1044},1044,22,1,0,[kill,50309,10],[]};
get({1045}) ->
     {t_tongxingzheng_task,{1045},1045,23,1,0,[kill_effect_count,8,1],[]};
get({1046}) ->
     {t_tongxingzheng_task,{1046},1046,23,1,0,[kill,50312,7],[]};
get({1047}) ->
     {t_tongxingzheng_task,{1047},1047,24,1,0,[kill,50405,50],[]};
get({1048}) ->
     {t_tongxingzheng_task,{1048},1048,24,1,0,[kill,50420,3],[]};
get({1049}) ->
     {t_tongxingzheng_task,{1049},1049,25,1,0,[kill,50304,70],[]};
get({1050}) ->
     {t_tongxingzheng_task,{1050},1050,25,1,0,[kill,50412,7],[]};
get({1051}) ->
     {t_tongxingzheng_task,{1051},1051,26,1,0,[kill,50308,35],[]};
get({1052}) ->
     {t_tongxingzheng_task,{1052},1052,26,1,0,[kill_effect_count,22,5],[]};
get({1053}) ->
     {t_tongxingzheng_task,{1053},1053,27,1,0,[kill,50402,90],[]};
get({1054}) ->
     {t_tongxingzheng_task,{1054},1054,27,1,0,[kill,50419,3],[]};
get({1055}) ->
     {t_tongxingzheng_task,{1055},1055,28,1,0,[kill_effect_count,23,5],[]};
get({1056}) ->
     {t_tongxingzheng_task,{1056},1056,28,1,0,[kill,50411,8],[]};
get({1057}) ->
     {t_tongxingzheng_task,{1057},1057,29,1,0,[kill,50406,45],[]};
get({1058}) ->
     {t_tongxingzheng_task,{1058},1058,29,1,0,[kill,50418,3],[]};
get({1059}) ->
     {t_tongxingzheng_task,{1059},1059,30,1,0,[kill,50403,80],[]};
get({1060}) ->
     {t_tongxingzheng_task,{1060},1060,30,1,0,[kill_effect_count,6,5],[]};
get({1061}) ->
     {t_tongxingzheng_task,{1061},1061,31,1,0,[kill,50407,40],[]};
get({1062}) ->
     {t_tongxingzheng_task,{1062},1062,31,1,0,[kill,50410,9],[]};
get({1063}) ->
     {t_tongxingzheng_task,{1063},1063,32,1,0,[kill,50404,70],[]};
get({1064}) ->
     {t_tongxingzheng_task,{1064},1064,32,1,0,[kill,50417,3],[]};
get({1101}) ->
     {t_tongxingzheng_task,{1101},1101,1,1,1,[kill_effect_count,14,5],[]};
get({1102}) ->
     {t_tongxingzheng_task,{1102},1102,2,1,1,[kill,50103,80],[]};
get({1103}) ->
     {t_tongxingzheng_task,{1103},1103,3,1,1,[kill,50106,45],[]};
get({1104}) ->
     {t_tongxingzheng_task,{1104},1104,4,1,1,[kill_effect_count,21,5],[]};
get({1105}) ->
     {t_tongxingzheng_task,{1105},1105,5,1,1,[kill,50101,100],[]};
get({1106}) ->
     {t_tongxingzheng_task,{1106},1106,6,1,1,[kill,50105,50],[]};
get({1107}) ->
     {t_tongxingzheng_task,{1107},1107,7,1,1,[kill_effect_count,22,5],[]};
get({1108}) ->
     {t_tongxingzheng_task,{1108},1108,8,1,1,[kill,50204,70],[]};
get({1109}) ->
     {t_tongxingzheng_task,{1109},1109,9,1,1,[kill,50211,8],[]};
get({1110}) ->
     {t_tongxingzheng_task,{1110},1110,10,1,1,[kill_effect_count,6,5],[]};
get({1111}) ->
     {t_tongxingzheng_task,{1111},1111,11,1,1,[kill,50201,100],[]};
get({1112}) ->
     {t_tongxingzheng_task,{1112},1112,12,1,1,[kill,50205,50],[]};
get({1113}) ->
     {t_tongxingzheng_task,{1113},1113,13,1,1,[kill_effect_count,23,5],[]};
get({1114}) ->
     {t_tongxingzheng_task,{1114},1114,14,1,1,[kill,50304,70],[]};
get({1115}) ->
     {t_tongxingzheng_task,{1115},1115,15,1,1,[kill,50308,35],[]};
get({1116}) ->
     {t_tongxingzheng_task,{1116},1116,16,1,1,[kill_effect_count,7,1],[]};
get({1117}) ->
     {t_tongxingzheng_task,{1117},1117,17,1,1,[kill,50301,100],[]};
get({1118}) ->
     {t_tongxingzheng_task,{1118},1118,18,1,1,[kill,50305,50],[]};
get({1119}) ->
     {t_tongxingzheng_task,{1119},1119,19,1,1,[kill_effect_count,8,1],[]};
get({1120}) ->
     {t_tongxingzheng_task,{1120},1120,20,1,1,[kill,50402,90],[]};
get({1121}) ->
     {t_tongxingzheng_task,{1121},1121,21,1,1,[kill,50406,45],[]};
get({1122}) ->
     {t_tongxingzheng_task,{1122},1122,22,1,1,[kill_effect_count,15,1],[]};
get({1123}) ->
     {t_tongxingzheng_task,{1123},1123,23,1,1,[kill,50403,80],[]};
get({1124}) ->
     {t_tongxingzheng_task,{1124},1124,24,1,1,[kill,50407,40],[]};
get({1125}) ->
     {t_tongxingzheng_task,{1125},1125,25,1,1,[kill_effect_count,12,5],[]};
get({1126}) ->
     {t_tongxingzheng_task,{1126},1126,26,1,1,[kill,50408,35],[]};
get({1127}) ->
     {t_tongxingzheng_task,{1127},1127,27,1,1,[kill_effect_count,13,5],[]};
get({1128}) ->
     {t_tongxingzheng_task,{1128},1128,28,1,1,[kill,50409,10],[]};
get({1129}) ->
     {t_tongxingzheng_task,{1129},1129,29,1,1,[kill_effect_count,5,5],[]};
get({1130}) ->
     {t_tongxingzheng_task,{1130},1130,30,1,1,[kill,50420,3],[]};
get({1131}) ->
     {t_tongxingzheng_task,{1131},1131,31,1,1,[kill,50412,7],[]};
get({1132}) ->
     {t_tongxingzheng_task,{1132},1132,32,1,1,[kill,50401,100],[]};
get({2001}) ->
     {t_tongxingzheng_task,{2001},2001,1,2,0,[kill,50101,100],[]};
get({2002}) ->
     {t_tongxingzheng_task,{2002},2002,1,2,0,[kill,50107,40],[]};
get({2003}) ->
     {t_tongxingzheng_task,{2003},2003,2,2,0,[kill,50105,50],[]};
get({2004}) ->
     {t_tongxingzheng_task,{2004},2004,2,2,0,[kill_effect_count,12,5],[]};
get({2005}) ->
     {t_tongxingzheng_task,{2005},2005,3,2,0,[kill,50102,90],[]};
get({2006}) ->
     {t_tongxingzheng_task,{2006},2006,3,2,0,[kill,50110,9],[]};
get({2007}) ->
     {t_tongxingzheng_task,{2007},2007,4,2,0,[kill,50201,100],[]};
get({2008}) ->
     {t_tongxingzheng_task,{2008},2008,4,2,0,[kill,50115,3],[]};
get({2009}) ->
     {t_tongxingzheng_task,{2009},2009,5,2,0,[kill_effect_count,13,5],[]};
get({2010}) ->
     {t_tongxingzheng_task,{2010},2010,5,2,0,[kill,50109,10],[]};
get({2011}) ->
     {t_tongxingzheng_task,{2011},2011,6,2,0,[kill,50205,50],[]};
get({2012}) ->
     {t_tongxingzheng_task,{2012},2012,6,2,0,[kill,50111,8],[]};
get({2013}) ->
     {t_tongxingzheng_task,{2013},2013,7,2,0,[kill,50106,45],[]};
get({2014}) ->
     {t_tongxingzheng_task,{2014},2014,7,2,0,[kill,50216,3],[]};
get({2015}) ->
     {t_tongxingzheng_task,{2015},2015,8,2,0,[kill,50103,80],[]};
get({2016}) ->
     {t_tongxingzheng_task,{2016},2016,8,2,0,[kill_effect_count,15,1],[]};
get({2017}) ->
     {t_tongxingzheng_task,{2017},2017,9,2,0,[kill,50202,90],[]};
get({2018}) ->
     {t_tongxingzheng_task,{2018},2018,9,2,0,[kill,50210,9],[]};
get({2019}) ->
     {t_tongxingzheng_task,{2019},2019,10,2,0,[kill,50206,45],[]};
get({2020}) ->
     {t_tongxingzheng_task,{2020},2020,10,2,0,[kill,50215,3],[]};
get({2021}) ->
     {t_tongxingzheng_task,{2021},2021,11,2,0,[kill_effect_count,5,5],[]};
get({2022}) ->
     {t_tongxingzheng_task,{2022},2022,11,2,0,[kill,50209,10],[]};
get({2023}) ->
     {t_tongxingzheng_task,{2023},2023,12,2,0,[kill,50203,80],[]};
get({2024}) ->
     {t_tongxingzheng_task,{2024},2024,12,2,0,[kill,50212,7],[]};
get({2025}) ->
     {t_tongxingzheng_task,{2025},2025,13,2,0,[kill,50207,40],[]};
get({2026}) ->
     {t_tongxingzheng_task,{2026},2026,13,2,0,[kill,50313,35],[]};
get({2027}) ->
     {t_tongxingzheng_task,{2027},2027,14,2,0,[kill,50301,100],[]};
get({2028}) ->
     {t_tongxingzheng_task,{2028},2028,14,2,0,[kill_effect_count,14,5],[]};
get({2029}) ->
     {t_tongxingzheng_task,{2029},2029,15,2,0,[kill,50305,50],[]};
get({2030}) ->
     {t_tongxingzheng_task,{2030},2030,15,2,0,[kill,50211,8],[]};
get({2031}) ->
     {t_tongxingzheng_task,{2031},2031,16,2,0,[kill,50318,3],[]};
get({2032}) ->
     {t_tongxingzheng_task,{2032},2032,16,2,0,[kill,50204,70],[]};
get({2033}) ->
     {t_tongxingzheng_task,{2033},2033,17,2,0,[kill_effect_count,7,1],[]};
get({2034}) ->
     {t_tongxingzheng_task,{2034},2034,17,2,0,[kill,50311,8],[]};
get({2035}) ->
     {t_tongxingzheng_task,{2035},2035,18,2,0,[kill,50302,90],[]};
get({2036}) ->
     {t_tongxingzheng_task,{2036},2036,18,2,0,[kill,50317,3],[]};
get({2037}) ->
     {t_tongxingzheng_task,{2037},2037,19,2,0,[kill,50306,45],[]};
get({2038}) ->
     {t_tongxingzheng_task,{2038},2038,19,2,0,[kill,50310,9],[]};
get({2039}) ->
     {t_tongxingzheng_task,{2039},2039,20,2,0,[kill,50303,80],[]};
get({2040}) ->
     {t_tongxingzheng_task,{2040},2040,20,2,0,[kill_effect_count,21,5],[]};
get({2041}) ->
     {t_tongxingzheng_task,{2041},2041,21,2,0,[kill,50307,40],[]};
get({2042}) ->
     {t_tongxingzheng_task,{2042},2042,21,2,0,[kill,50316,3],[]};
get({2043}) ->
     {t_tongxingzheng_task,{2043},2043,22,2,0,[kill,50401,100],[]};
get({2044}) ->
     {t_tongxingzheng_task,{2044},2044,22,2,0,[kill,50309,10],[]};
get({2045}) ->
     {t_tongxingzheng_task,{2045},2045,23,2,0,[kill_effect_count,8,1],[]};
get({2046}) ->
     {t_tongxingzheng_task,{2046},2046,23,2,0,[kill,50312,7],[]};
get({2047}) ->
     {t_tongxingzheng_task,{2047},2047,24,2,0,[kill,50405,50],[]};
get({2048}) ->
     {t_tongxingzheng_task,{2048},2048,24,2,0,[kill,50420,3],[]};
get({2049}) ->
     {t_tongxingzheng_task,{2049},2049,25,2,0,[kill,50304,70],[]};
get({2050}) ->
     {t_tongxingzheng_task,{2050},2050,25,2,0,[kill,50412,7],[]};
get({2051}) ->
     {t_tongxingzheng_task,{2051},2051,26,2,0,[kill,50308,35],[]};
get({2052}) ->
     {t_tongxingzheng_task,{2052},2052,26,2,0,[kill_effect_count,22,5],[]};
get({2053}) ->
     {t_tongxingzheng_task,{2053},2053,27,2,0,[kill,50402,90],[]};
get({2054}) ->
     {t_tongxingzheng_task,{2054},2054,27,2,0,[kill,50419,3],[]};
get({2055}) ->
     {t_tongxingzheng_task,{2055},2055,28,2,0,[kill_effect_count,23,5],[]};
get({2056}) ->
     {t_tongxingzheng_task,{2056},2056,28,2,0,[kill,50411,8],[]};
get({2057}) ->
     {t_tongxingzheng_task,{2057},2057,29,2,0,[kill,50406,45],[]};
get({2058}) ->
     {t_tongxingzheng_task,{2058},2058,29,2,0,[kill,50418,3],[]};
get({2059}) ->
     {t_tongxingzheng_task,{2059},2059,30,2,0,[kill,50403,80],[]};
get({2060}) ->
     {t_tongxingzheng_task,{2060},2060,30,2,0,[kill_effect_count,6,5],[]};
get({2061}) ->
     {t_tongxingzheng_task,{2061},2061,31,2,0,[kill,50407,40],[]};
get({2062}) ->
     {t_tongxingzheng_task,{2062},2062,31,2,0,[kill,50410,9],[]};
get({2063}) ->
     {t_tongxingzheng_task,{2063},2063,32,2,0,[kill,50404,70],[]};
get({2064}) ->
     {t_tongxingzheng_task,{2064},2064,32,2,0,[kill,50417,3],[]};
get({2101}) ->
     {t_tongxingzheng_task,{2101},2101,1,2,1,[kill_effect_count,14,5],[]};
get({2102}) ->
     {t_tongxingzheng_task,{2102},2102,2,2,1,[kill,50103,80],[]};
get({2103}) ->
     {t_tongxingzheng_task,{2103},2103,3,2,1,[kill,50106,45],[]};
get({2104}) ->
     {t_tongxingzheng_task,{2104},2104,4,2,1,[kill_effect_count,21,5],[]};
get({2105}) ->
     {t_tongxingzheng_task,{2105},2105,5,2,1,[kill,50101,100],[]};
get({2106}) ->
     {t_tongxingzheng_task,{2106},2106,6,2,1,[kill,50105,50],[]};
get({2107}) ->
     {t_tongxingzheng_task,{2107},2107,7,2,1,[kill_effect_count,22,5],[]};
get({2108}) ->
     {t_tongxingzheng_task,{2108},2108,8,2,1,[kill,50204,70],[]};
get({2109}) ->
     {t_tongxingzheng_task,{2109},2109,9,2,1,[kill,50211,8],[]};
get({2110}) ->
     {t_tongxingzheng_task,{2110},2110,10,2,1,[kill_effect_count,6,5],[]};
get({2111}) ->
     {t_tongxingzheng_task,{2111},2111,11,2,1,[kill,50201,100],[]};
get({2112}) ->
     {t_tongxingzheng_task,{2112},2112,12,2,1,[kill,50205,50],[]};
get({2113}) ->
     {t_tongxingzheng_task,{2113},2113,13,2,1,[kill_effect_count,23,5],[]};
get({2114}) ->
     {t_tongxingzheng_task,{2114},2114,14,2,1,[kill,50304,70],[]};
get({2115}) ->
     {t_tongxingzheng_task,{2115},2115,15,2,1,[kill,50308,35],[]};
get({2116}) ->
     {t_tongxingzheng_task,{2116},2116,16,2,1,[kill_effect_count,7,1],[]};
get({2117}) ->
     {t_tongxingzheng_task,{2117},2117,17,2,1,[kill,50301,100],[]};
get({2118}) ->
     {t_tongxingzheng_task,{2118},2118,18,2,1,[kill,50305,50],[]};
get({2119}) ->
     {t_tongxingzheng_task,{2119},2119,19,2,1,[kill_effect_count,8,1],[]};
get({2120}) ->
     {t_tongxingzheng_task,{2120},2120,20,2,1,[kill,50402,90],[]};
get({2121}) ->
     {t_tongxingzheng_task,{2121},2121,21,2,1,[kill,50406,45],[]};
get({2122}) ->
     {t_tongxingzheng_task,{2122},2122,22,2,1,[kill_effect_count,15,1],[]};
get({2123}) ->
     {t_tongxingzheng_task,{2123},2123,23,2,1,[kill,50403,80],[]};
get({2124}) ->
     {t_tongxingzheng_task,{2124},2124,24,2,1,[kill,50407,40],[]};
get({2125}) ->
     {t_tongxingzheng_task,{2125},2125,25,2,1,[kill_effect_count,12,5],[]};
get({2126}) ->
     {t_tongxingzheng_task,{2126},2126,26,2,1,[kill,50408,35],[]};
get({2127}) ->
     {t_tongxingzheng_task,{2127},2127,27,2,1,[kill_effect_count,13,5],[]};
get({2128}) ->
     {t_tongxingzheng_task,{2128},2128,28,2,1,[kill,50409,10],[]};
get({2129}) ->
     {t_tongxingzheng_task,{2129},2129,29,2,1,[kill_effect_count,5,5],[]};
get({2130}) ->
     {t_tongxingzheng_task,{2130},2130,30,2,1,[kill,50420,3],[]};
get({2131}) ->
     {t_tongxingzheng_task,{2131},2131,31,2,1,[kill,50412,7],[]};
get({2132}) ->
     {t_tongxingzheng_task,{2132},2132,32,2,1,[kill,50401,100],[]};
get(_Id) ->
    null.
