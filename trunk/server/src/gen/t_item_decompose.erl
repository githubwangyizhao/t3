%%% Generated automatically, no need to modify.
-module(t_item_decompose).
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
     [{12001},{12002},{12003},{12004},{12101},{12102},{12103},{12104},{12201},{12202},{12203},{12204},{14501},{14502},{14503},{14504},{14601},{14602},{14603},{14604},{14701},{14702},{14703},{14704},{14705},{14706},{14707},{14708},{19007}].


get({12001}) ->
     {t_item_decompose,{12001},12001,[[11001,100]]};
get({12002}) ->
     {t_item_decompose,{12002},12002,[[11002,100]]};
get({12003}) ->
     {t_item_decompose,{12003},12003,[[11003,100]]};
get({12004}) ->
     {t_item_decompose,{12004},12004,[[11004,100]]};
get({12101}) ->
     {t_item_decompose,{12101},12101,[[11101,100]]};
get({12102}) ->
     {t_item_decompose,{12102},12102,[[11102,100]]};
get({12103}) ->
     {t_item_decompose,{12103},12103,[[11103,100]]};
get({12104}) ->
     {t_item_decompose,{12104},12104,[[11104,100]]};
get({12201}) ->
     {t_item_decompose,{12201},12201,[[11201,100]]};
get({12202}) ->
     {t_item_decompose,{12202},12202,[[11202,100]]};
get({12203}) ->
     {t_item_decompose,{12203},12203,[[11203,100]]};
get({12204}) ->
     {t_item_decompose,{12204},12204,[[11204,100]]};
get({14501}) ->
     {t_item_decompose,{14501},14501,[[14001,100]]};
get({14502}) ->
     {t_item_decompose,{14502},14502,[[14002,100]]};
get({14503}) ->
     {t_item_decompose,{14503},14503,[[14003,100]]};
get({14504}) ->
     {t_item_decompose,{14504},14504,[[14004,100]]};
get({14601}) ->
     {t_item_decompose,{14601},14601,[[14101,100]]};
get({14602}) ->
     {t_item_decompose,{14602},14602,[[14102,100]]};
get({14603}) ->
     {t_item_decompose,{14603},14603,[[14103,100]]};
get({14604}) ->
     {t_item_decompose,{14604},14604,[[14104,100]]};
get({14701}) ->
     {t_item_decompose,{14701},14701,[[14201,100]]};
get({14702}) ->
     {t_item_decompose,{14702},14702,[[14202,100]]};
get({14703}) ->
     {t_item_decompose,{14703},14703,[[14203,100]]};
get({14704}) ->
     {t_item_decompose,{14704},14704,[[14204,100]]};
get({14705}) ->
     {t_item_decompose,{14705},14705,[[14205,100]]};
get({14706}) ->
     {t_item_decompose,{14706},14706,[[14206,100]]};
get({14707}) ->
     {t_item_decompose,{14707},14707,[[14207,100]]};
get({14708}) ->
     {t_item_decompose,{14708},14708,[[14208,100]]};
get({19007}) ->
     {t_item_decompose,{19007},19007,[[19107,100]]};
get(_Id) ->
    null.
