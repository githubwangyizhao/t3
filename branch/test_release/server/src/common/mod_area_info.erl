%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 11月 2021 下午 03:26:21
%%%-------------------------------------------------------------------
-module(mod_area_info).
-author("Administrator").

-include("common.hrl").

-define(AREA_CODE_URL, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_area_code_list", "http://127.0.0.1:7199/api/get_area_code_list")).
-define(DEFAULT_APP_NAME(Env),
    case Env of
        "develop" -> "com.tb.custom.test";
        "testing" -> "com.arsham.t3";
        "testing_oversea" -> "com.arsham.t3";
        _ -> "com.arsham.t3"
    end
).

%% API
-export([
    delete_area_info/1,
    update_area_info/3,
    get_area_code/0
]).

get_area_code() ->
    ?INFO("get app notice from admin: ~p", [?AREA_CODE_URL]),
    ReqData = [{"offset", 0}, {"limit", 999999999}],
    case util_http:post(?AREA_CODE_URL, json, ReqData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p", [{Code, Msg}]),
            ?DEBUG("Data: ~p", [{is_list(Data), Data}]),
            Data2Ets =
                lists:filtermap(
                    fun(KeyValueMap) ->
                        Currency = util:to_list(maps:get(<<"currency">>, KeyValueMap)),
                        Region = util:to_list(maps:get(<<"region">>, KeyValueMap)),
                        AreaCode = util:to_int(maps:get(<<"area_code">>, KeyValueMap)),
                        {
                            true,
                            #ets_area_info{currency = Currency, region = Region, area_code = AreaCode}
                        }
                    end,
                    Data
                ),
            ?IF(Data2Ets =/= [], ets:insert_new(?ETS_AREA_INFO, Data2Ets), ok);
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?AREA_CODE_URL, Reason]),
            false
    end.

delete_area_info(Currency) ->
    ets:delete(?ETS_AREA_INFO, Currency).

update_area_info(Currency, Region, AreaCode) ->
    AreaInfo =
        case ets:lookup(?ETS_AREA_INFO, Currency) of
            [AreaInfoInEts] when is_record(AreaInfoInEts, ets_area_info) ->
                #ets_area_info{currency = OldCurrency, region = OldRegion, area_code = OldAreaCode} = AreaInfoInEts,
                NewAreaInfo = ?IF(OldCurrency =:= Currency, AreaInfoInEts, AreaInfoInEts#ets_area_info{currency = Currency}),
                NewAreaInfo1 = ?IF(OldRegion =:= Region, NewAreaInfo, NewAreaInfo#ets_area_info{region = Region}),
                NewAreaInfo2 = ?IF(OldAreaCode =:= AreaCode, NewAreaInfo1, NewAreaInfo1#ets_area_info{area_code = AreaCode}),
                ets:delete(?ETS_AREA_INFO, Currency),
                NewAreaInfo2;
            [] ->
                #ets_area_info{currency = Currency, region = Region, area_code = AreaCode}
        end,
    ?DEBUG("AreaInfo: ~p", [AreaInfo]),
    ets:insert_new(?ETS_AREA_INFO, AreaInfo).
