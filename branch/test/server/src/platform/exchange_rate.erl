%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 2月 2021 下午 12:09:58
%%%-------------------------------------------------------------------
-module(exchange_rate).
-author("Administrator").

%% API
-export([
    get_currency_by_platform/1,
    convert/2
]).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

-define(JISU_API_QUERY_URI, "https://jisuhuilv.market.alicloudapi.com/exchange/currency").
-define(JISU_API_RATE_URI, "https://jisuhuilv.market.alicloudapi.com/exchange/single?currency=").
-define(JISU_API_EXCHANGE_RATE_URI, "https://jisuhuilv.market.alicloudapi.com/exchange/convert").
-define(APPCODE(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "APPCODE 5ab395ce061c41f2b5449e7955409e36", "APPCODE 59815c4fcc8a4366b2645c3ae17d5e64")).
-define(APPCODE, ?IF(?IS_DEBUG =:= true, "APPCODE 5ab395ce061c41f2b5449e7955409e36", "APPCODE 59815c4fcc8a4366b2645c3ae17d5e64")).
-define(CURRENCY, "USD").

get_currency_by_platform(Platform) ->
    if
        Platform =/= "local" andalso Platform =/= "moy" andalso Platform =/= "test" ->
            case query("jisu", Platform) of
                Rate when is_integer(Rate) orelse is_float(Rate) -> ?DEBUG("Rate: ~p", [Rate]), Rate;
                ok -> ok;
                Other ->
                    ?ERROR("返回有问题 ： ~p", [{Platform, Other}])
            end;
        true -> ok
    end.

%% ---------------------- 阿里云市场 极速数据 ---------------------- %%
query(Exchange, Platform) ->
    {AppCode, Uri} = case Exchange of
                         "jisu" ->
%%            {?JISU_APP_CODE, ?API_QUERY_URI}
                             {?APPCODE(Platform), ?JISU_API_RATE_URI}
                     end,
    #t_platform{currency = Currency} = t_platform:get({Platform}),
    ?INFO("Currency: ~p ~p ~p", [is_list(Currency), Currency, AppCode]),
    case httpc:request(get, {Uri ++ ?CURRENCY, [{"Authorization", AppCode}]}, [], []) of
        {ok, {{_, _, _}, _, HtmlResultJson}} ->
            Response = jsone:decode(util:to_binary(HtmlResultJson)),
            case maps:find(<<"result">>, Response) of
                {ok, Results} ->
                    case maps:find(<<"list">>, Results) of
                        {ok, Lists} ->
                            case maps:find(list_to_binary(?CURRENCY), Lists) of
                                {ok, Info} ->
                                    case maps:find(<<"rate">>, Info) of
                                        {ok, Rate} ->
                                            binary_to_float(Rate);
                                        {error, Reason} ->
                                            ?ERROR("Error no rate: ~p", [Reason]),
                                            noop
                                    end;
                                {error, Reason} ->
                                    ?ERROR("Error on ~p: ~p", [Currency, Reason]),
                                    noop
                            end;
                        {error, Reason} ->
                            ?ERROR("Error no list: ~p", [Reason]),
                            noop
                    end;
                error ->
                    ?ERROR("Error no esult"),
                    noop
            end;
        {error, Reason} ->
            ?ERROR("Error: ~p", [Reason]),
            noop
    end.
convert(Currency, Money) ->
    Uri = ?JISU_API_EXCHANGE_RATE_URI ++ "?amount=" ++ util:to_list(Money) ++ "&from=" ++ ?CURRENCY ++ "&to=" ++ ?IF(Currency =:= "", "IDR", Currency),
    ?INFO("Uri: ~p, AppCode: ~p", [Uri, ?APPCODE]),
    case httpc:request(get, {Uri, [{"Authorization", ?APPCODE}]}, [], []) of
        {ok, {{_, _, _}, _, HtmlResultJson}} ->
            Response = jsone:decode(util:to_binary(HtmlResultJson)),
            ?DEBUG("resp: ~p", [Response]),
%%                    Msg = maps:find(<<"msg">>, Response),
%%                    Status = maps:find(<<"status">>, Response),
            case maps:find(<<"result">>, Response) of
                {ok, Info} ->
                    case maps:find(<<"camount">>, Info) of
                        {ok, RealMoney} ->
                            ExchangeMoney = ?IF(is_float(RealMoney), RealMoney, util:to_float(RealMoney)),
                            ?DEBUG("RealMoney: ~p ~p ~p", [RealMoney, ExchangeMoney, util:to_float(ExchangeMoney / Money)]),
                            {ExchangeMoney, Money, util:to_float(ExchangeMoney / Money)};
                        {error, Reason} ->
                            ?ERROR("Error no camount: ~p", [Reason]),
                            {Money, Money, 1}
                    end;
                {error, Reason} ->
                    ?ERROR("Error no result: ~p", [Reason]),
                    {Money, Money, 1}
            end;
        {error, Reason} ->
            ?ERROR("Error: ~p", [Reason]),
            {Money, Money, 1}
    end.
%%convert(Platform, Money) ->
%%    case t_platform:get({Platform}) of
%%        null ->
%%            {Money, Money, 1};
%%        R ->
%%            #t_platform{currency = Currency} = R,
%%            Uri = ?JISU_API_EXCHANGE_RATE_URI ++ "?amount=" ++ util:to_list(Money) ++ "&from=" ++ ?CURRENCY ++ "&to=" ++ ?IF(Currency =:= "", "IDR", Currency),
%%            ?INFO("Uri: ~p, AppCode: ~p", [Uri, ?APPCODE(Platform)]),
%%            case httpc:request(get, {Uri, [{"Authorization", ?APPCODE(Platform)}]}, [], []) of
%%                {ok, {{_, _, _}, _, HtmlResultJson}} ->
%%                    Response = jsone:decode(util:to_binary(HtmlResultJson)),
%%                    ?DEBUG("resp: ~p", [Response]),
%%                    case maps:find(<<"result">>, Response) of
%%                        {ok, Info} ->
%%                            case maps:find(<<"camount">>, Info) of
%%                                {ok, RealMoney} ->
%%                                    ExchangeMoney = ?IF(is_float(RealMoney), RealMoney, util:to_float(RealMoney)),
%%                                    ?DEBUG("RealMoney: ~p ~p ~p", [RealMoney, ExchangeMoney, util:to_float(ExchangeMoney / Money)]),
%%                                    {ExchangeMoney, Money, util:to_float(ExchangeMoney / Money)};
%%                                {error, Reason} ->
%%                                    ?ERROR("Error no camount: ~p", [Reason]),
%%                                    {Money, Money, 1}
%%                            end;
%%                        {error, Reason} ->
%%                            ?ERROR("Error no result: ~p", [Reason]),
%%                            {Money, Money, 1}
%%                    end;
%%                {error, Reason} ->
%%                    ?ERROR("Error: ~p", [Reason]),
%%                    {Money, Money, 1}
%%            end
%%    end.


