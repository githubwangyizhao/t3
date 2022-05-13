%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc        爱微游
%%%%% Created : 21. 八月 2018 10:31
%%%%%-------------------------------------------------------------------
-module(awy_charge_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("logger.hrl").
%%-include("platform.hrl").
%%-include("gen/table_enum.hrl").
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
%%handle_body(Req, _Opts) ->
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    {_, ParamStr} = get_req_param_str(Req),
%%    {ErrorCode, Msg} =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            ok ->
%%                logger2:write(game_charge_info, util:to_list(ParamStr)),
%%                {0, result_msg(ok)};
%%            {'EXIT', R} ->
%%                ?ERROR("EXIT: ~p ~n ", [R]),
%%                Result = charge_result(R),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
%%                {Result, result_msg(R)};
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
%%                {1, result_msg(R1)}
%%        end,
%%    Req2 =
%%        if
%%            Path == <<"/charge_awy">> orelse Path == <<"/charge_djs">> ->
%%                ResultText =
%%                    if
%%                        ErrorCode == 0 orelse ErrorCode == -102 andalso Path == <<"/charge_djs">> ->
%%                            "SUCCESS";
%%                        true ->
%%                            "FAIL"
%%                    end,
%%                web_http_util:output_text(Req, ResultText);
%%            true ->
%%                ErrorList = [{'errcode:', ErrorCode}, {'errmsg:', Msg}],
%%                web_http_util:output_error_code(Req, ErrorList)
%%        end,
%%    Req2.
%%terminate(_Reason, _Req) ->
%%    ok.
%%%% @doc     爱微游平台充值
%%path_request(<<"/charge_awy">>, <<"GET">>, Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    UserId = util:to_list(get_list_value(<<"openid">>, ParamList)),        % 账号
%%    Money = util:str_to_float(get_list_value(<<"rmb">>, ParamList)),            % 人民币
%%    OrderId = util:to_list(get_list_value(<<"txid">>, ParamList)),          % 订单号
%%    NotifyId = util:to_list(get_list_value(<<"notify_id">>, ParamList)),    % 平台通知id
%%    GameOrderNoStr = util:to_list(get_list_value(<<"userdata">>, ParamList)),   % 游戏参数
%%    ?INFO("爱微游平台充值:~p ~n", [ParamStr]),
%%%%    awy:check_sign(ParamList),
%%    Pf = ?PLATFORM_AF,
%%    mod_signature:check_param_list(ParamList, Pf),
%%    HTTPOptions = [],
%%    Options = [],
%%    NotifyParamList = [
%%        {"gameid", ?AWY_GAME_ID},
%%        {"notify_id", NotifyId}
%%    ],
%%    NotifySignStr = mod_signature:sign(NotifyParamList, Pf),
%%    ChargeMoXieUrl = "https://login.11h5.com/pay/paygate/verify.php?" ++ NotifySignStr,
%%    case httpc:request(get, {ChargeMoXieUrl, []}, HTTPOptions, Options) of
%%        {ok, {_, _, Result}} ->
%%
%%            if
%%                Result == "SUCCESS" ->
%%                    noop;
%%                true ->
%%                    ?ERROR("爱微游平台充值 msg:~p ~p~n", [NotifyId, Result]),
%%                    exit(msg_error)
%%            end;
%%        Error ->
%%            ?ERROR("爱微游平台充值 请求验证失败 notify_id:~p ~p~n", [NotifyId, Error]),
%%            exit(not_http)
%%    end,
%%    mod_charge_server:server_charge(UserId, OrderId, Money, GameOrderNoStr, Ip, util_time:timestamp());
%%%% @doc     独角兽平台充值
%%path_request(<<"/charge_djs">>, <<"GET">>, Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    UserId = util:to_list(get_list_value(<<"uid">>, ParamList)),            % 账号
%%    ?INFO("独角兽平台充值 人民币 ~p~n", [get_list_value(<<"rmb">>, ParamList)]),
%%    Money = util:str_to_float(get_list_value(<<"rmb">>, ParamList)),            % 人民币
%%    AppId = util:to_list(get_list_value(<<"appid">>, ParamList)),          % 游戏的唯一标识
%%    OrderId = util:to_list(get_list_value(<<"txid">>, ParamList)),          % 订单号
%%    Channel = util:to_list(get_list_value(<<"channel">>, ParamList)),          % 渠道
%%    NotifyId = util:to_list(get_list_value(<<"notify_id">>, ParamList)),    % 平台通知id
%%    GameOrderNoStr = util:to_list(get_list_value(<<"userdata">>, ParamList)),   % 游戏参数
%%    ?INFO("独角兽平台充值:~p ~n", [ParamStr]),
%%%%    awy:check_sign(ParamList),
%%    Pf = ?PLATFORM_DJS,
%%    mod_signature:check_param_list(ParamList, Pf),
%%    HTTPOptions = [],
%%    Options = [],
%%    NotifyParamList = [
%%        {"appid", AppId},
%%        {"channel", Channel},
%%        {"notify_id", NotifyId}
%%    ],
%%    NotifySignStr = mod_signature:sign(NotifyParamList, Pf),
%%    ChargeMoXieUrl = "http://sdk.djsh5.com/verify.php?" ++ NotifySignStr,
%%    case httpc:request(get, {ChargeMoXieUrl, []}, HTTPOptions, Options) of
%%        {ok, {_, _, Result}} ->
%%            Response = jsone:decode(util:to_binary(Result)),
%%            Code = maps:get(<<"code">>, Response),
%%            if
%%                Code == 0 ->
%%                    Msg = maps:get(<<"errmsg">>, Response),
%%                    if
%%%%                        Msg == "SUCCESS" ->
%%                        Msg == <<"ok">> ->
%%                            noop;
%%                        true ->
%%                            ?INFO("errmsg: ~p~n", [Msg]),
%%                            exit(msg_error)
%%                    end;
%%                true ->
%%                    ?ERROR("独角兽平台充值验证 notify_id:~p ~p~n", [NotifyId, Code]),
%%                    exit(code_error)
%%            end;
%%        Error ->
%%            ?ERROR("独角兽平台充值 请求验证失败 notify_id:~p ~p~n", [NotifyId, Error]),
%%            exit(not_http)
%%    end,
%%    mod_charge_server:server_charge(UserId, OrderId, Money, GameOrderNoStr, Ip, util_time:timestamp(), Channel);
%%
%%%% @doc     疯狂平台充值
%%path_request(<<"/charge_fk">>, <<"POST">>, Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    UserId = util:to_list(get_list_value(<<"userId">>, ParamList)),            % 账号
%%    OrderId = util:to_list(get_list_value(<<"orderId">>, ParamList)),          % 订单号
%%    GoodsId = util:to_list(get_list_value(<<"goodsId">>, ParamList)),          % 商品id
%%    GameOrderNoStr = util:to_list(get_list_value(<<"ext">>, ParamList)),        % 游戏参数
%%    Time = util:to_int(get_list_value(<<"time">>, ParamList)),                 % 充值时间
%%    Sign = util:to_list(get_list_value(<<"sign">>, ParamList)),                 % 检验码
%%    ?INFO("疯狂平台充值:~p ~n", [ParamStr]),
%%    CheckParamList = [
%%        {"ext", GameOrderNoStr},
%%        {"userId", UserId},
%%        {"gameId", ?FK_GAME_ID},
%%        {"goodsId", GoodsId},
%%        {"time", Time},
%%        {"sign", Sign}
%%    ],
%%    fk:check_param_list(CheckParamList),
%%    mod_charge_server:server_charge(UserId, OrderId, GameOrderNoStr, Ip, Time);
%%
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.
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
%%%% @fun 返回内容转换msg
%%result_msg(Result) ->
%%    case Result of
%%        ok ->
%%            "游戏支付成功";
%%        not_exists ->
%%            "用户不存在";
%%        error_sha ->
%%            "订单不存在";
%%        none ->
%%            "订单不存在";
%%        already_have ->
%%            "订单重复";
%%        sid ->
%%            "无效服务器编号";
%%        null_server ->
%%            "服务器不存在";
%%        null_player_id ->
%%            "无效玩家账号";
%%        error_order_id ->
%%            "订单号已存在";
%%        orderSerial ->
%%            "无效订单类型";
%%        old_time ->
%%            "无效时间戳";
%%        money ->
%%            "充值金额错误";
%%        money_ingot ->
%%            "充值金额大于游戏币";
%%        gold ->
%%            "游戏币数量错误";
%%        error_md5 ->
%%            "校验码错误";
%%        not_ip ->
%%            "ip 不合法";
%%        _ ->
%%            ?DEBUG("result_msg errror: ~p~n", [Result]),
%%            "其他错误"
%%    end.
%%
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).
