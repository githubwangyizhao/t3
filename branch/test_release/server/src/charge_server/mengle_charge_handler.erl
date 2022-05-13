%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc    萌乐充值
%%%%% Created : 4. 六月 2018 15:54
%%%%%-------------------------------------------------------------------
-module(mengle_charge_handler).
%%%%-behaviour(cowboy_http_handler).
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("logger.hrl").
%%
%%
%%init(Req, Opts) ->
%%    NewReq = handle_request(Req, Opts),
%%    {ok, NewReq, Opts}.
%%
%%%% @fun 根据请求 切换不同的操作
%%handle_request(Req, Opts) ->
%%    Method = cowboy_req:method(Req),
%%    case Method of
%%        <<"GET">> ->
%%            handle_body(Req, Opts);
%%        <<"POST">> ->
%%            handle_body(Req, Opts);
%%        _ ->
%%            ?ERROR("错误handle_request Method: ~p ~n", [Method])
%%    end.
%%
%%handle_body(Req, Opts) ->
%%    {WebError, WebOtherError} = get_error_file_name(Opts),
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    ErrorCode =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            ok ->
%%                1;
%%            {'EXIT', R} ->
%%                Result = charge_result(R),
%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(WebError, {Result, {ip, IP}, util:to_list(ParamStr), R}),
%%                Result;
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(WebOtherError, {{ip, IP}, util:to_list(ParamStr), R1}),
%%                0
%%        end,
%%    ErrorList = [{'ErrorCode', ErrorCode}],
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2.
%%terminate(_Reason, _Req) ->
%%    ok.
%%
%%path_request(<<"/charge">>, <<"GET">>, Ip, Req) ->     % 平台充值
%%    mod_charge_server:check_white_ip_list(Ip),
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    PartId = util:to_int(get_list_value(<<"partid">>, ParamList)),      % 平台id
%%    ServerId = util:to_list(get_list_value(<<"sid">>, ParamList)),      % 服务器id
%%    UserId = util:to_list(get_list_value(<<"uid">>, ParamList)),        % 账号
%%    OrderId = util:to_list(get_list_value(<<"orderSerial">>, ParamList)),    % 订单号
%%    GameChargeId = util:to_int(get_list_value(<<"game_charge_id">>, ParamList)),    % 游戏充值id
%%    Money = util:to_int(get_list_value(<<"money">>, ParamList)),        % 人民币
%%    Ingot = util:to_int(get_list_value(<<"gold">>, ParamList)),         % 元宝
%%    FTime = util:to_int(get_list_value(<<"ftime">>, ParamList)),        % 时间
%%    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),         % 数据的校验码
%%    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 订单类型
%%%%    ParamStr = cowboy_req:qs(Req),
%%    ?DEBUG("平台充值:~p ~n", [ParamStr]),
%%    Str =
%%        case string:split(util:to_list(ParamStr), "&sign") of
%%            [Str1, _] ->
%%                Str1;
%%            _ ->
%%                exit(not_sign)
%%        end,
%%    mod_charge_server:charge(PartId, ServerId, UserId, GameChargeId, Money, Ingot, OrderId, Ip, FTime, ChargeType, Hash, Str);
%%path_request(<<"/gm_charge">>, <<"GET">>, Ip, Req) ->     % 后台充值
%%    mod_charge_server:check_gm_white_ip_list(Ip),
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    PartId = util:to_int(get_list_value(<<"partid">>, ParamList)),      % 平台id
%%    ServerId = util:to_list(get_list_value(<<"sid">>, ParamList)),      % 服务器id
%%    UserId = util:to_list(get_list_value(<<"uid">>, ParamList)),        % 账号
%%    GameChargeId = util:to_int(get_list_value(<<"game_charge_id">>, ParamList)),    % 游戏充值id
%%    Ingot = util:to_int(get_list_value(<<"gold">>, ParamList)),         % 元宝
%%    FTime = util:to_int(get_list_value(<<"ftime">>, ParamList)),        % 时间
%%    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),        % gm_id 员工编号
%%    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 充值类型
%%    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),         % 数据的校验码
%%    if Ingot > 0 -> noop; true -> exit(ingot_0) end,
%%%%    ParamStr = cowboy_req:qs(Req),
%%    ?DEBUG("后台==》充值:~p ~n", [ParamStr]),
%%    Str =
%%        case string:split(util:to_list(ParamStr), "&sign") of
%%            [Str1, _] ->
%%                Str1;
%%            _ ->
%%                exit(not_sign)
%%        end,
%%    mod_charge_server:gm_charge(PartId, ServerId, UserId, GameChargeId, Ingot, Ip, FTime, Hash, Str, GmId, ChargeType);
%%path_request(<<"/change_white_ip">>, <<"GET">>, Ip, Req) ->     % 白名单
%%    mod_charge_server:check_gm_white_ip_list(Ip),
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    WhiteIp = util:to_list(get_list_value(<<"ip">>, ParamList)),        % 白名单ip
%%    WhiteIpState = util:to_list(get_list_value(<<"ip_state">>, ParamList)),        % 白名单ip
%%    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),        % 白名单ip
%%    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),        % 数据的校验码
%%%%    ParamStr = cowboy_req:qs(Req),
%%    ?DEBUG("白名单>> :~p ~n", [ParamStr]),
%%    Str =
%%        case string:split(util:to_list(ParamStr), "&sign") of
%%            [Str1, _] ->
%%                Str1;
%%            _ ->
%%                exit(not_sign)
%%        end,
%%    mod_charge_server:change_white_ip(WhiteIp, WhiteIpState, Hash, Str, GmId);
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.
%%
%%
%%get_error_file_name(Opts) ->
%%    case Opts of
%%        charge ->           % 平台正常充值
%%            {charge_error, charge_other_error};
%%        gm_charge ->        % 后台gm充值
%%            {gm_charge_error, gm_charge_other_error};
%%        game_charge ->      % 平台返回游戏充值
%%            {game_charge_error, game_charge_other_error};
%%        _ ->
%%            {web_error, web_other_error}
%%    end.
%%
%%%% @fun 返回内容转换
%%charge_result(Result) ->
%%    case Result of
%%        sid ->
%%%%            ?DEBUG("无效服务器编号"),
%%            -100;
%%        null_server ->
%%%%            ?DEBUG("服务器不存在"),
%%            -100;
%%        null_player_id ->
%%%%            ?DEBUG("无效玩家账号"),
%%            -101;
%%        error_order_id ->
%%%%            ?DEBUG("订单号已存在"),
%%            -102;
%%        orderSerial ->
%%%%            ?DEBUG("无效订单类型"),
%%            -103;
%%        old_time ->
%%%%            ?DEBUG("无效时间戳"),
%%            -104;
%%        money ->
%%%%            ?DEBUG("充值金额错误"),
%%            -105;
%%        money_ingot ->
%%%%            ?DEBUG("充值金额大于游戏币"),
%%            -106;
%%        gold ->
%%%%            ?DEBUG("游戏币数量错误"),
%%            -106;
%%        error_md5 ->
%%%%            ?DEBUG("校验码错误"),
%%            -107;
%%        not_ip ->
%%%%            ?DEBUG("ip 不合法"),
%%            -109;
%%        _ ->
%%%%            ?DEBUG("其他错误: ~p ", [Result]),
%%            -108
%%    end.
%%%%%% @fun 返回内容转换msg
%%%%result_msg(Result) ->
%%%%    case Result of
%%%%        ok ->
%%%%            "游戏支付成功";
%%%%        not_exists ->
%%%%            "用户不存在";
%%%%        error_sha ->
%%%%            "订单不存在";
%%%%        none ->
%%%%            "订单不存在";
%%%%        already_have ->
%%%%            "订单重复";
%%%%        sid ->
%%%%            "无效服务器编号";
%%%%        null_server ->
%%%%            "服务器不存在";
%%%%        null_player_id ->
%%%%            "无效玩家账号";
%%%%        error_order_id ->
%%%%            "订单号已存在";
%%%%        orderSerial ->
%%%%            "无效订单类型";
%%%%        old_time ->
%%%%            "无效时间戳";
%%%%        money ->
%%%%            "充值金额错误";
%%%%        money_ingot ->
%%%%            "充值金额大于游戏币";
%%%%        gold ->
%%%%            "游戏币数量错误";
%%%%        error_md5 ->
%%%%            "校验码错误";
%%%%        not_ip ->
%%%%            "ip 不合法";
%%%%        _ ->
%%%%            ?DEBUG("result_msg errror: ~p~n", [Result]),
%%%%            "其他错误"
%%%%    end.
%%
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).