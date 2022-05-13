%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc    掌中宝
%%%%% Created : 15. 七月 2018 19:22
%%%-------------------------------------------------------------------
-module(zzy_charge_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("logger.hrl").
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
%%    {ErrorCode, _Msg} =
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
%%    ResultText =
%%        if
%%            ErrorCode == 0 orelse ErrorCode == -102 ->
%%                "SUCCESS";
%%            true ->
%%                "FAIL"
%%        end,
%%    web_http_util:output_text(Req, ResultText).
%%terminate(_Reason, _Req) ->
%%    ok.
%%
%%%% @doc     掌中宝地址充值
%%path_request(<<"/game_charge_zzy">>, <<"POST">>, Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("掌中宝游戏服充值:~p ~n", [ParamStr]),
%%    platform_zzy:check_param_list(ParamList),
%%    OrderId = util:to_list(get_list_value(<<"cp_order_id">>, ParamList)),
%%    Money = util:str_to_float(get_list_value(<<"order_amount">>, ParamList)),
%%    GameOrderNoStr = util:to_list(get_list_value(<<"extra">>, ParamList)),
%%    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money, ?CHANNEL_ZZY);
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
%%            504;
%%        already_have ->
%%%%            ?DEBUG("订单号已存在"),
%%            -102;
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
%%            502;
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
