%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 2月 2021 上午 10:27:42
%%%-------------------------------------------------------------------
-module(mod_customer).
-author("Administrator").

-author("Administrator").

%% API
-export([
    get_player_customer_url/1,
    getCustomerServiceUrl/1,
    getCustomerServiceUrlData/1,
    updateCusSerData/0
]).

-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").

-define(API_HOST(PlatformId), "https://g0jxpl5d.api.lncldglobal.com/1.1/classes/Customer").
-define(HEADER_PARAM(PlatformId), [{"X-LC-Id", "G0JXpl5dUG0EF9ab1kN3qgjQ-MdYXbMMI"}, {"X-LC-Key", "5e5ucK3PzGyJVTiLWDaLoIcy"}]).
%%-define(API_HOST(PlatformId),
%%    ?IF(PlatformId =:= ?PLATFORM_LOCAL,
%%        "https://n88sag76.lc-cn-n1-shared.com/1.1/classes/Customer",
%%        "https://yy9u265w.api.lncldglobal.com/1.1/classes/Customer")).
%%-define(HEADER_PARAM(PlatformId),
%%    ?IF(PlatformId =:= ?PLATFORM_LOCAL,
%%        [{"X-LC-Id", "N88sag76PVxboQAcEROScp2l-gzGzoHsz"}, {"X-LC-Key", "HAQTDQy7zu3j7s0GG1rmLU8j"}],
%%        [{"X-LC-Id", "Yy9u265wSaPnpfxBsYaELfyA-MdYXbMMI"}, {"X-LC-Key", "vUuTBiL2gnTgGd6yAMDeUk4D"}])).
-define(GET_INTERVAL_TIME(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, 5, 3600 * 1)). % 上一次和这一次获取的间隔时间内s

get_player_customer_url(PlayerId) ->
    case getCustomerServiceUrl(PlayerId) of
        noop ->
            ?UNDEFINED;
        not_results ->
            ?UNDEFINED;
        {ok, Length, UrlList} ->
            if
                Length =:= 0 ->
                    ?UNDEFINED;
                true ->
                    Nth =
                        case PlayerId rem Length of
                            0 ->
                                Length;
                            Value ->
                                Value
                        end,
%%                    ?INFO("UrlList: ~p Nth: ~p", [UrlList, Nth]),
                    lists:nth(Nth, UrlList)
            end;
        Other ->
            ?ERROR("Other : ~p", [Other]),
            ?UNDEFINED
    end.

updateCusSerData() ->
%%    ?IF(Key =:= addr, {true, tuple_to_list(Value)}, false)
%%    R =
%%        case inet:getifaddrs() of
%%            {ok, L} ->
%%                lists:foldl(
%%                    fun({_, InetInfoList}, Tmp) ->
%%                        MatchList =
%%                            lists:filtermap(
%%                                fun({Key, Value}) ->
%%                                    if
%%                                        Key =:= addr -> {true, tuple_to_list(Value)};
%%                                        true -> false
%%                                    end
%%                                end,
%%                                InetInfoList
%%                            ),
%%                        lists:append(MatchList, Tmp)
%%                    end,
%%                    [],
%%                    L
%%                );
%%            E ->
%%                ?ERROR("getifaddrs failure: ~p", [E]),
%%                []
%%        end,
%%    PlatformId = ?IF(lists:member([127,0,0,1], R) orelse lists:member([192,168,31,100], R), "local", ""),
    PlatformId = "",
%%    ?INFO("ipAddress: ~p isExists: ~p PlatformId: ~p", [R, lists:member([127, 0, 0, 1], R), PlatformId]),
    spawn(fun() ->
        case mod_customer:getCustomerServiceUrlData(PlatformId) of
            CustomerServiceTupleList when is_list(CustomerServiceTupleList) ->
                ?DEBUG("CustomerServiceTupleList: ~p", [CustomerServiceTupleList]),
                mod_cache:update({mod_customer, customer}, CustomerServiceTupleList, 8640000000);
            R when is_atom(R) ->
                ?ERROR("update customer service url failure: ~p", [R])
        end end).

getCustomerServiceUrlData(PlatformId) ->
    Result = httpc:request(get, {?API_HOST(PlatformId), ?HEADER_PARAM(PlatformId)}, [], []),
    case Result of
        {ok, {{_, RespCode, _}, _, HtmlResultJson}} ->
            if
                RespCode =/= 200 ->
                    ?ERROR("customer url api failure: ~p", [RespCode]),
                    not_results;
                true ->
                    Response = jsone:decode(util:to_binary(HtmlResultJson)),
                    case maps:find(<<"results">>, Response) of
                        {ok, Results} ->
%%                            ?DEBUG("Results: ~p", [Results]),
                            List = lists:filtermap(
                                fun(Ele) ->
                                    {true, {util_string:trim(binary_to_list(maps:get(<<"region">>, Ele))), util_string:trim(binary_to_list(maps:get(<<"url">>, Ele)))}}
%%                                    {true, {util_string:trim(binary_to_list(maps:get(<<"platform">>, Ele))), util_string:trim(binary_to_list(maps:get(<<"url">>, Ele)))}}
                                end,
                                Results
                            ),
                            List;
                        error ->
                            not_results
                    end
            end;
        {error, Reason} ->
            ?ERROR("Error: ~p~n", [Reason]),
            noop
    end.

%%getDefaultCusSerUrl(PlatformId) ->
%%    ok.

getCustomerServiceUrl(PlayerId) ->
%%    Header = [{Key, env:get(list_to_atom(Value))} || {Key, Value} <- ?HEADER_PARAM],
    Region = mod_player:get_region_by_player_id(PlayerId),
    {PlatformId, _} = mod_player:get_platform_id_and_server_id(PlayerId),
    Fun =
        fun() ->
            case mod_customer:getCustomerServiceUrlData(PlatformId) of
                CustomerServiceTupleList when is_list(CustomerServiceTupleList) ->
                    List =
                        lists:filtermap(
                            fun({MatchRegion, CustomerServiceUrl}) ->
                                ?IF(MatchRegion =:= Region, {true, CustomerServiceUrl}, false)
                            end,
                            CustomerServiceTupleList
                        ),
                    if
                        length(List) =< 0 ->
                            {ok, 1, [?DEFAULT_CUSTOMER]};
                        true ->
                            {ok, length(List), List}
                    end;
                R when is_atom(R) ->
                    ?ERROR("update customer service url failure: ~p", [R]),
                    noop
            end
        end,
%%    Result = mod_cache:cache_data({?MODULE, customer}, Fun, ?GET_INTERVAL_TIME(PlatformId)),
%%    Result.
    Fun().
