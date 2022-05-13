%%% Generated automatically, no need to modify.
-module(map_data).
-export([get/1, get_map_mark_table_name/1]).

get(999) ->
    {r_map_data,999,4400,3760,
                [{72,53,72,41},{70,40,69,53},{48,57,42,44},{39,44,44,58}]};
get(1000) ->
    {r_map_data,1000,2668,1500,[]};
get(1001) ->
    {r_map_data,1001,2668,1500,[]};
get(1002) ->
    {r_map_data,1002,2668,1500,[]};
get(1003) ->
    {r_map_data,1003,2668,1500,[]};
get(1004) ->
    {r_map_data,1004,2668,1500,[]};
get(1005) ->
    {r_map_data,1005,2668,1500,[]};
get(1006) ->
    {r_map_data,1006,2668,1500,[]};
get(2001) ->
    {r_map_data,2001,1334,804,[]};
get(3001) ->
    {r_map_data,3001,1334,750,[]};
get(4101) ->
    {r_map_data,4101,2668,1500,[]};
get(4201) ->
    {r_map_data,4201,2668,1500,[]};
get(9901) ->
    {r_map_data,9901,2668,1500,[]};
get(9903) ->
    {r_map_data,9903,2395,1642,[]};
get(10000) ->
    {r_map_data,10000,5186,3743,[]};
get(Id) ->
     logger:debug("map_data =>data not find:~p~n", [Id]),
     null.

get_map_mark_table_name(999) ->
     map_mark_999;
get_map_mark_table_name(1000) ->
     map_mark_1000;
get_map_mark_table_name(1001) ->
     map_mark_1001;
get_map_mark_table_name(1002) ->
     map_mark_1002;
get_map_mark_table_name(1003) ->
     map_mark_1003;
get_map_mark_table_name(1004) ->
     map_mark_1004;
get_map_mark_table_name(1005) ->
     map_mark_1005;
get_map_mark_table_name(1006) ->
     map_mark_1006;
get_map_mark_table_name(2001) ->
     map_mark_2001;
get_map_mark_table_name(3001) ->
     map_mark_3001;
get_map_mark_table_name(4101) ->
     map_mark_4101;
get_map_mark_table_name(4201) ->
     map_mark_4201;
get_map_mark_table_name(9901) ->
     map_mark_9901;
get_map_mark_table_name(9903) ->
     map_mark_9903;
get_map_mark_table_name(10000) ->
     map_mark_10000;
get_map_mark_table_name(MapId) ->
     logger:debug("map_data =>get_map_mark_table_name not find:~p~n", [MapId]),
     null.