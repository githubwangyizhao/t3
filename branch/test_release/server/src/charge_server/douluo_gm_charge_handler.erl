%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    gm斗罗修仙充值
%%% Created : 19. 六月 2018 10:25
%%%-------------------------------------------------------------------
-module(douluo_gm_charge_handler).
-author("home").


-export([
    init/2,
    terminate/2
]).

-include("charge.hrl").
-include("logger.hrl").

init(Req, Opts) ->
    NewReq = handle_request(Req, Opts),
    {ok, NewReq, Opts}.

%% @fun 根据请求 切换不同的操作
handle_request(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            handle_body(Req, Opts);
        <<"POST">> ->
            handle_body(Req, Opts);
        _ ->
            ?ERROR("错误handle_request Method: ~p ~n", [Method])
    end.

handle_body(Req, _Opts) ->
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    Path = cowboy_req:path(Req),
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {ok, MsgL} ->
                {ok, MsgL};
            {'EXIT', R} ->
                Result = charge_result(R),
                ?ERROR("错误EXIT: ~p ~n ", [R]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(gm_game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(gm_game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {-3, R1}
        end,
    ErrorList =
        if
            ErrorCode == ok ->
                Error;
            true ->
                [{'code', ErrorCode}, {'msg', util:to_binary(util_string:to_utf8(result_msg(Error)))}]
        end,
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

%% @fun 平台申请代充(代玩家正式充值)
path_request(<<"/appply/agentMoney">>, <<"POST">>, Ip, Req) ->     % 平台申请代充
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("平台申请代充:~p", [ParamStr]),
    douluo:check_param_list(ParamList),
    AccId = util:to_list(get_list_value(<<"openId">>, ParamList)),           % 玩家账号
    ServerId = util:to_list(get_list_value(<<"gameZoneId">>, ParamList)),    % 区服
    ChargeItemId = util:to_int(get_list_value(<<"grade">>, ParamList)),     % 充值id
    OrderId1 = util:to_list(get_list_value(<<"agentNum">>, ParamList)),       % 订单号
    PartId = util:to_list(get_list_value(<<"remarks">>, ParamList)),        % 平台
    ?INFO("代充平台:~p", [PartId]),
    GmId = PartId ++ "_daichong",
    OrderId = OrderId1 ++ "_" ++ PartId,
    ItemCount = 1,
    ReportParam = 6,    % 代充支付类型
    mod_charge_server:server_game_charge(PartId, ServerId, AccId, ChargeItemId, ItemCount, OrderId, Ip, ?CHARGE_TYPE_NORMAL, GmId, ReportParam);
%% @fun 平台扶持金(gm充值)
path_request(<<"/appply/sponsorMoney">>, <<"POST">>, Ip, Req) ->     % 平台扶持金
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("平台扶持金:~p", [ParamStr]),
    douluo:check_param_list(ParamList),
    AccId = util:to_list(get_list_value(<<"openId">>, ParamList)),           % 玩家账号
    ServerId = util:to_list(get_list_value(<<"gameZoneId">>, ParamList)),    % 区服
    ChargeItemId = util:to_int(get_list_value(<<"grade">>, ParamList)),       % 充值id
    OrderId1 = util:to_list(get_list_value(<<"sponsorNum">>, ParamList)),     % 订单号
    PartId = util:to_list(get_list_value(<<"remarks">>, ParamList)),          % 平台
    ?INFO("扶持金平台:~p", [PartId]),
    GmId = PartId ++ "_fuchi",
    OrderId = OrderId1 ++ "_" ++ PartId,
    ItemCount = 1,
    ReportParam = 10,
    mod_charge_server:server_game_charge(PartId, ServerId, AccId, ChargeItemId, ItemCount, OrderId, Ip, ?CHARGE_TYPE_GM_NORMAL, GmId, ReportParam);
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    charge_handler:charge_result(Result).
%% @fun 返回内容转换msg
result_msg(Result) ->
    charge_handler:result_msg(?MODULE, Result).

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).