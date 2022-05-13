%%% Generated automatically, no need to modify.
-module(t_card_book).
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
     [{1},{2}].


get({1}) ->
     {t_card_book,{1},1,[201,202,203,204],0,[231,165,158,45,232,139,177,233,155,132]};
get({2}) ->
     {t_card_book,{2},2,[201,202,203,204],0,[229,166,150,45,229,176,143,230,128,170]};
get(_Id) ->
    null.
