%%% Generated automatically, no need to modify.
-module(t_buff_new).
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
     [{10},{20},{30},{40},{50},{60},{70},{100},{200},{300},{400}].


get({10}) ->
     {t_buff_new,{10},10,[[dizzy]],0,10000,50,0,[],1};
get({20}) ->
     {t_buff_new,{20},20,[[knock1,500]],0,10000,50,0,[],2};
get({30}) ->
     {t_buff_new,{30},30,[[knock2,200,500]],0,10000,50,0,[],3};
get({40}) ->
     {t_buff_new,{40},40,[[knock3,250,90,500]],0,10000,50,0,[],4};
get({50}) ->
     {t_buff_new,{50},50,[[knock4]],0,10000,1000,0,[],2};
get({60}) ->
     {t_buff_new,{60},60,[[knock5,40]],0,10000,500,0,[],3};
get({70}) ->
     {t_buff_new,{70},70,[[knock6,300,90]],0,10000,500,0,[],4};
get({100}) ->
     {t_buff_new,{100},100,[[dizzy]],0,10000,3000,0,[],1};
get({200}) ->
     {t_buff_new,{200},200,[[knock1,500]],0,10000,3000,0,[],2};
get({300}) ->
     {t_buff_new,{300},300,[[knock2,200,500]],0,10000,3000,0,[],3};
get({400}) ->
     {t_buff_new,{400},400,[[knock3,250,90,500]],0,10000,3000,0,[],4};
get(_Id) ->
    null.
