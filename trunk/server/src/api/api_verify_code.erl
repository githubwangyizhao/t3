%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 10月 2021 下午 03:26:26
%%%-------------------------------------------------------------------
-module(api_verify_code).
-author("Administrator").

%% API
-export([
    sms_code/2,
    get_area_code/2
]).

-include("p_message.hrl").
-include("p_enum.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% ----------------------------------
%% @doc 	玩家获取自己所使用的app隶属国家/地区的手机号码区号
%% @throws 	none
%% @end
%% ----------------------------------
get_area_code(
    #m_verify_code_get_area_code_tos{} = _Msg, State = #conn{player_id = PlayerId}
) ->
    Node1 =
        case mod_server_rpc:call_center(mod_server, get_login_server_node, []) of
            null -> [];
            R ->
                R#db_c_server_node.node
        end,
    Node = util:to_atom(Node1),
%%    ?INFO("Node: ~p", [Node]),
    #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
    {Currency, _AppIdInEts} =
        case rpc:call(Node,ets, lookup, [?ETS_LOGIN_CACHE, AccId]) of
            [SettingInEts] when is_record(SettingInEts, ets_login_cache) ->
                {SettingInEts#ets_login_cache.region, SettingInEts#ets_login_cache.app_id};
            [] -> {"TWD", "com.tb.custome.test"}
        end,
%%    {Region, AreaCode} =
%%        case mod_server_rpc:call_center(mod_region_info, get_region_info, [Currency, AppIdInEts]) of
%%            {'EXIT', Err} ->
%%                ?ERROR("获取获取地区区号与名字时失败: ~p", [Err]),
%%                {logic_get_region_by_currency:get(Currency), "886"};
%%            {AreaCodeByCurrency, RegionByCurrency} ->
%%                {AreaCodeByCurrency, RegionByCurrency}
%%        end,
%%    ?INFO("Region: ~p", [{PlayerId, AccId, Region, AreaCode}]),
%%    AreaCodeRegion = [#areacoderegion{area_code = AreaCode, region = util:to_binary(Region)}],
    RealRegionInfoList = get_areaCode_region_list(Currency),
    AreaCodeRegion =
        lists:foldr(
            fun(RegionInfo, RegionList) ->
                {_, AreaCode, Region} = RegionInfo,
                [#areacoderegion{area_code = AreaCode, region = util:to_binary(Region)} | RegionList]
            end,
            [],
            RealRegionInfoList
        ),
    ?DEBUG("AreaCodeRegion: ~p", [AreaCodeRegion]),
    Out = #m_verify_code_get_area_code_toc{area_code_region = AreaCodeRegion},
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

%% ----------------------------------
%% @doc 	下发短信验证码
%% @throws 	none
%% @end
%% ----------------------------------
sms_code(
    #m_verify_code_sms_code_tos{
        mobile = Mobile, operation = Operation
    },
    State = #conn{player_id = PlayerId}
) ->
    ReturnCode = ?IF(env:get(env, "production") =:= "develop", true, false),
    Out =
        case catch mod_verify_code:gen_sms_code(PlayerId, Mobile, Operation) of
            {'EXIT', invalid_mobile} ->
                #m_verify_code_sms_code_toc{result = ?P_INVALID_MOBILE, wait_time = util_time:timestamp()};
            {'EXIT', invalid_operation} ->
                #m_verify_code_sms_code_toc{result = ?P_SUCCESS, wait_time = util_time:timestamp() + ?SD_BIND_PHONE_AUTH_CODE_TIME};
            {'EXIT', Err} ->
                ?ERROR("error: ~p", [Err]),
                #m_verify_code_sms_code_toc{result = ?P_FAIL, wait_time = util_time:timestamp()};
            {Code, ExpireTime} ->
                Proto = #m_verify_code_sms_code_toc{result = ?P_SUCCESS, wait_time = ExpireTime},
                ?IF(ReturnCode =:= true, Proto#m_verify_code_sms_code_toc{code = Code}, Proto)
        end,
    mod_socket:send(proto:encode(Out)),
    State.


%% ----------------------------------
%% @doc 	获取国家区号等信息
%% @throws 	none
%% @end
%% ----------------------------------
get_areaCode_region_list(Currency) ->
    DefaultRegionList = logic_get_region_by_currency:get(Currency),
    DefaultRegionInfo = [{Currency, "886", hd(DefaultRegionList)}],
    {RegionInfoList, RegionInfoListInEts} =
%%        case mod_server_rpc:call_center(ets, tab2list, [?ETS_REGION_INFO]) of
        case mod_server_rpc:call_center(ets, tab2list, [?ETS_AREA_INFO]) of
            {'EXIT', Err1} -> ?ERROR("call to center to get area info: ~p", [Err1]),
                {DefaultRegionInfo, DefaultRegionInfo};
            Res ->
                ?DEBUG("Res: ~p", [Res]),
                RegionInfoListInEts1 =
                    lists:foldl(
                        fun(Ele, Tmp) ->
                            #ets_area_info{
%%                            #ets_region_info{
                                currency = CurrencyInEts, area_code = AreaCodeInEts, region = RegionInEts
                            } = Ele,
                            case lists:keyfind(CurrencyInEts, 1, Tmp) of
                                false -> ?IF(CurrencyInEts =/= [], [{CurrencyInEts, AreaCodeInEts, RegionInEts} | Tmp], Tmp);
                                {CurrencyInEts, _, _} -> Tmp
                            end
                        end,
                        [],
                        Res
                    ),
%%                RegionInfoListInEts1 = DefaultRegionInfo ++
%%                    [{Ele#ets_region_info.currency, Ele#ets_region_info.area_code, Ele#ets_region_info.region} || Ele <- Res],
                RegionInfoListFilter =
                    lists:filtermap(
                        fun({MatchCurrency, AreaCode, Region}) ->
                            if
                                MatchCurrency =:= Currency ->
                                    {true, {current, {MatchCurrency, AreaCode, Region}}};
                                true -> {true, {MatchCurrency, AreaCode, Region}}
                            end
                        end,
                        RegionInfoListInEts1
                    ),
                {RegionInfoListFilter, RegionInfoListInEts1}
        end,
    RealRegionInfoList =
        case lists:keyfind(current, 1, RegionInfoList) of
            false -> RegionInfoListInEts;
            {current, CurrentRegionInfo} ->
                OtherRegionInfoList = lists:keydelete(current, 1, RegionInfoList),
                [CurrentRegionInfo] ++ OtherRegionInfoList
        end,
    ?INFO("RegionInfoList: ~p", [RealRegionInfoList]),
    RealRegionInfoList.
