%%% Generated automatically, no need to modify.
-module(t_debug).
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
     [{1},{2},{3},{4}].


get({1}) ->
     {t_debug,{1},1,[231,187,153,233,129,147,229,133,183],[105,116,101,109],[91,80,114,111,112,84,121,112,101,44,32,80,114,111,112,73,100,44,32,78,117,109,93]};
get({2}) ->
     {t_debug,{2},2,[232,176,131,228,187,187,229,138,161],[116,97,115,107],[91,84,97,115,107,73,100,93]};
get({3}) ->
     {t_debug,{3},3,[229,138,160,231,173,137,231,186,167],[],[91,108,101,118,101,108,93]};
get({4}) ->
     {t_debug,{4},4,[232,174,190,231,189,174,118,105,112,231,173,137,231,186,167],[],[91,118,105,112,95,108,101,118,101,108,93]};
get(_Id) ->
    null.
