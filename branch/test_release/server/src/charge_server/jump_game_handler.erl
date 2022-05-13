%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc        跳转到游戏服充值
%%% Created : 27. 五月 2019 13:07
%%%-------------------------------------------------------------------
-module(jump_game_handler).
-author("home").

-export([
    init/2,
    terminate/2
]).

-export([
    jump_game_charge/5      % 跳转到游戏服充值
]).

-include("logger.hrl").
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
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {'EXIT', R} ->
                Result = charge_result(R),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {-3, R1}
        end,
    ErrorList = [{'Code', ErrorCode}, {'Msg', util:to_binary(Error)}],
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

path_request(<<"/jump_game_charge">>, <<"POST">>, Ip, Req) ->     % 跳转到游戏服充值
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("跳转到游戏服充值:~p", [ParamStr]),
    mod_signature:check_param_list(ParamList, ?PLATFORM_LOCAL),
    PlatformId = util:to_list(get_list_value(<<"platform_id">>, ParamList)),            % 平台服参数
    GameOrderNoStr = util:to_list(get_list_value(<<"extra_info">>, ParamList)),         % 游戏服参数
    OrderId = util:to_list(get_list_value(<<"order_sn">>, ParamList)),                  % 平台订单号
    Money = util:str_to_float(get_list_value(<<"pay_amount">>, ParamList)),    % 人民币
    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money, PlatformId);
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.


%% @doc fun 跳转到游戏服充值
jump_game_charge(PlatformId, Url, OrderId, GameOrderNoStr, Money) ->
    [NewMoney] = io_lib:format("~.2f", [util:to_float(Money)]),
    WebUrl = Url ++ "/jump_game_charge",
    HTTPOptions = [{timeout, 6000}],
    ContentType = "application/x-www-form-urlencoded",
    Options = [],
    ParamList = [
        {"platform_id", PlatformId},
        {"order_sn", OrderId},
        {"extra_info", GameOrderNoStr},
        {"pay_amount", NewMoney}
    ],
    SignaturePlatformId = ?PLATFORM_LOCAL,
    SignStr = mod_signature:sign_str(ParamList, SignaturePlatformId),
    KeyAtom = mod_signature:get_signature(SignaturePlatformId),
    ParamStr = util_list:change_list_url([{KeyAtom, SignStr} | ParamList]),
    case httpc:request(post, {WebUrl, [], ContentType, ParamStr}, HTTPOptions, Options) of
        {error, Reason} ->
            ?ERROR("跳转到游戏服充值---{error,Reason}~p~n ", [Reason]),
            exit(Reason);
        {ok, {{_, 200, _}, _HeadList, HtmlResultJsonStr}} ->
            ResultParamList = jsone:decode(util:to_binary(HtmlResultJsonStr)),
            ?INFO("跳转到游戏服充值数据:~p~n", [ResultParamList]),
            Code = maps:get(<<"Code">>, ResultParamList),
            if
                Code == <<"0">> orelse Code == 0 ->
                    ok;
                true ->
                    ErrReturnMsg = maps:get(<<"Msg">>, ResultParamList),
                    ?ERROR("跳转到游戏服充值==fail>>~p ~ts~n ", [Code, ErrReturnMsg]),
                    util:to_list(ErrReturnMsg)
            end;
        R ->
            ?ERROR("跳转到游戏服充值==other~p~n", [R]),
            exit(error_http)
    end.

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
            504;
        already_have ->
%%            ?DEBUG("订单号已存在"),
            -102;
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
            502;
        not_ip ->
%%            ?DEBUG("ip 不合法"),
            -109;
        _ ->
%%            ?DEBUG("其他错误: ~p ", [Result]),
            -108
    end.
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

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).
