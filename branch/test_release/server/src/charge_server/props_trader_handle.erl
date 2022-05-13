%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 8月 2021 上午 11:58:59
%%%-------------------------------------------------------------------
-module(props_trader_handle).
-author("Administrator").

-export([
    init/2,
    terminate/2
]).

-include("logger.hrl").
-include("platform.hrl").
-include("gen/table_enum.hrl").

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
    {_, ParamStr} = get_req_param_str(Req),
    {ErrorCode, Msg} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                logger2:write(game_charge_info, util:to_list(ParamStr)),
                {0, result_msg(ok)};
            {'EXIT', R} ->
                ?ERROR("EXIT: ~p ~n ", [R]),
                Result = charge_result(R),
%%                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
                {Result, result_msg(R)};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {1, result_msg(util:to_atom(R1))}
        end,
    ErrorList = [{code, ErrorCode}, {msg, list_to_binary(Msg)}],
    ?DEBUG("ErrorList: ~p", [ErrorList]),
    Req2 = web_http_util:output_json(Req, ErrorList),
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2 = web_http_util:output_text(Req, ResultText),
    Req2.

terminate(_Reason, _Req) ->
    ok.

%% @doc     装备交易平台充值
path_request(<<"/charge_props_trader">>, <<"POST">>, Ip, Req) ->
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("装备交易平台充值:~p ~n", [ParamStr]),
    Secret = util:to_list(get_list_value(<<"secret">>, ParamList)),          % 平台游戏币数量
    SecretList = flash:rc4_decode(Secret),
%%    UserId = util:to_list(get_list_value(<<"openid">>, ParamList)),                % 账号
%%    Amt = util:to_int(get_list_value(<<"amt">>, ParamList)),          % 平台游戏币数量
%%    OrderId = util:to_list(get_list_value(<<"bill_no">>, ParamList)),        % 订单号
%%    PlatformServerOrderIdStr = util:to_list(get_list_value(<<"app_remark">>, ParamList)),   % 游戏参数
%%    AccId = util:to_list(get_list_value(<<"acc_id">>, ParamList)),
%%    platform_qq_game:check_param_list("/charge_qq_game", ParamList),
    Amt = util:to_int(get_list_value("amt", SecretList)),          % 平台游戏币数量
    OrderId = util:to_list(get_list_value("bill_no", SecretList)),        % 订单号
    PlatformServerOrderIdStr = util:to_list(cow_qs:urldecode(util:to_binary(get_list_value("app_remark", SecretList)))),   % 游戏参数
    AccId = util:to_list(get_list_value("acc_id", SecretList)),
    Money = Amt / 1,
    case string:tokens(PlatformServerOrderIdStr, "^") of
        [GameUrl, GameOrderNoStr] when is_list(GameUrl) ->
            jump_game_handler:jump_game_charge(?PROPS_TRADER_CHARGE, GameUrl, OrderId, GameOrderNoStr, Money);
        _ ->
            mod_charge_server:server_charge(AccId, OrderId, Money, PlatformServerOrderIdStr, Ip, util_time:timestamp(), ?PROPS_TRADER_CHARGE)
    end;
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    case Result of
        sid ->
%%            ?DEBUG("无效服务器编号"),
            -100;
        null_server ->
%%            ?DEBUG("服务器不存在"),
            -100;
        null_player_id ->
%%            ?DEBUG("无效玩家账号"),
            -101;
        error_order_id ->
%%            ?DEBUG("订单号已存在"),
            -102;
        orderSerial ->
%%            ?DEBUG("无效订单类型"),
            -103;
        old_time ->
%%            ?DEBUG("无效时间戳"),
            -104;
        money ->
%%            ?DEBUG("充值金额错误"),
            -105;
        money_ingot ->
%%            ?DEBUG("充值金额大于游戏币"),
            -106;
        gold ->
%%            ?DEBUG("游戏币数量错误"),
            -106;
        error_md5 ->
%%            ?DEBUG("校验码错误"),
            -107;
        not_ip ->
%%            ?DEBUG("ip 不合法"),
            -109;
        _ ->
%%            ?DEBUG("其他错误: ~p ", [Result]),
            -108
    end.
%% @fun 返回内容转换msg
result_msg(Result) ->
    case Result of
        ok ->
            "success";
        not_exists ->
            "player not exists";
        error_sha ->
            "order not exists";
        none ->
            "none";
        already_have ->
            "already have";
        sid ->
            "invalid server";
        null_server ->
            "server not exists";
        null_player_id ->
            "invalid acc_id";
        error_order_id ->
            "order exists";
        orderSerial ->
            "invalid order type";
        old_time ->
            "invalid timestamp";
        money ->
            "invalid charge";
        money_ingot ->
            "invalid ingot";
        gold ->
            "invalid ingot number";
        error_md5 ->
            "failure";
        not_ip ->
            "invalid ip";
        _ ->
            ?DEBUG("result_msg errror: ~p~n", [Result]),
            "errors"
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_json(Req).

