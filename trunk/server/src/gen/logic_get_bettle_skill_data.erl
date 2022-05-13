%%% Generated automatically, no need to modify.
-module(logic_get_bettle_skill_data).
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


get({6003,202}) ->
     5;
get({6003,201}) ->
     5;
get({6003,5}) ->
     5;
get({6003,4}) ->
     1;
get({6002,202}) ->
     5;
get({6002,201}) ->
     5;
get({6002,5}) ->
     5;
get({6002,4}) ->
     1;
get({6001,202}) ->
     5;
get({6001,201}) ->
     5;
get({6001,5}) ->
     5;
get({6001,4}) ->
     1;
get(_Id) ->
    null.
