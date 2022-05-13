-module(charge_handler).
%%-behaviour(cowboy_http_handler).

-export([
    init/2,
    terminate/2
]).

-export([
    charge_result/1,
    result_msg/2,
    get_req_param_str/1,    % 获得参数字符串
    get_req_param_json/1,   % 获得参数json形式
    get_req_param_xml/1,    % 获得参数xml形式
    get_list_value/2,       % 参数解析
    get_json_value/2        % 参数json解析
]).

-include("logger.hrl").

-define(NONE, none).        %% 接口废弃

init(Req, Opts) ->
    NewReq = handle_request(Req, Opts),
%%    case Opts of
%%        game_charge ->
%%            handle_post(Req, Opts);
%%        game_charge_request ->
%%            handle_post(Req, Opts);
%%        game_charge_info ->
%%            handle_post(Req, Opts);
%%        _ ->
%%            handle_get(Req, Opts)
%%    end,
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

handle_body(Req, Opts) ->
    {WebError, WebOtherError} = get_error_file_name(Opts),
%%    {WebError, WebOtherError} =
%%        case Opts of
%%            charge ->       % 平台正常充值
%%                {charge_error, charge_other_error};
%%            gm_charge ->    % 后台gm充值
%%                {gm_charge_error, gm_charge_other_error};
%%            game_charge ->  % 平台返回游戏充值
%%                {game_charge_error, game_charge_other_error};
%%            _ ->
%%                {web_error, web_other_error}
%%        end,
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    Path = cowboy_req:path(Req),
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {1, ok};
            {ok, MsgL} ->
                {ok, MsgL};
            {'EXIT', R} ->
                Result = charge_result(R),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(WebError, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(WebOtherError, {{ip, IP}, util:to_list(ParamStr), R1}),
                {0, R1}
        end,
    ErrorList =
        if
            ErrorCode == ok ->
                Error;
            true ->
                if
                    Opts == game_charge ->
                        {ErrorCode1, Error1} =
                            if
                                ErrorCode == 1 ->
                                    {0, Error};
                                ErrorCode == 0 ->
                                    {-3, none};
                                true ->
                                    {ErrorCode, Error}
                            end,
                        [{'code', ErrorCode1}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error1)))}];
                    true ->
                        [{'ErrorCode', ErrorCode}]
                end
        end,
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
%%Req2 = web_http_util:output_error_code(Req, ErrorCode),
%%%%Req2.
%%
%%handle_post(Req, Opts) ->
%%    {WebError, WebOtherError} = get_error_file_name(Opts),
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    {ErrorCode, Error} =
%%        case catch handle_post_request(Method, IP, Req) of
%%            ok ->
%%                {0, ok};
%%            {ok, MsgL} ->
%%                {ok, MsgL};
%%            {'EXIT', R} ->
%%                {_, ParamStr} = get_param_str(Req),
%%                Result = charge_result(R),
%%                logger2:write(WebError, {Result, {ip, IP}, util:to_list(ParamStr), R}),
%%                {Result, R};
%%            R1 ->
%%                ?DEBUG("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_param_str(Req),
%%                logger2:write(WebOtherError, {{ip, IP}, util:to_list(ParamStr), R1}),
%%                {-3, none}
%%        end,
%%    ErrorList =
%%        if
%%            ErrorCode == ok ->
%%                Error;
%%            true ->
%%                [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error)))}]
%%        end,
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2.

terminate(_Reason, _Req) ->
    ok.

%%
%%%% @fun get请求
%%handle_request(<<"GET">>, IP, Req) ->
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    path_request(Path, Ip, Req);
%%
%%handle_request(Method, _, _Req) ->
%%    ?ERROR("错误handle_request Method: ~p ~n", [Method]),
%%    not_method.
%%
%%%% @fun get请求
%%handle_post_request(<<"POST">>, IP, Req) ->
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    path_request(Path, util:to_list(Ip), Req);
%%handle_post_request(Method, _, _Req) ->
%%    ?ERROR("错误handle_request Method: ~p ~n", [Method]),
%%    not_method.


%% @fun 地址请求
path_request(<<"/game_charge">>, <<"POST">>, Ip, Req) ->     % 平台返回游戏服充值
    {ParamInfoList, _ParamStr} = get_req_param_str(Req),
%%    ?INFO("平台返回游戏服充值 ~p~n", [ParamList1]),
    ParamList = [{util:to_atom(Key), util:to_list(Value)} || {Key, Value} <- ParamInfoList],
    mod_signature:check_param_list(ParamInfoList),
    GameOrderNoStr = get_list_value(game_orderno, ParamList),   % 游戏服订单号
    OrderId = get_list_value(orderno, ParamList),                % 平台订单号
    Money = util:to_float(get_list_value(total_fee, ParamList)),                % 人民币
    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money);
%% @fun 请求平台中心服务
path_request(<<"/game_charge_request">>, <<"POST">>, _Ip, Req) ->     % 请求平台中心服务
    {ParamInfoList, _ParamStr} = get_req_param_str(Req),
%%    ?DEBUG("请求平台中心服务"),
    ParamList = [{util:to_atom(Key), util:to_list(Value)} || {Key, Value} <- ParamInfoList],
%%    mod_signature:check_param_list(ParamList),
    GameOrderNoStr = get_list_value(game_orderno, ParamList),   % 游戏服订单号
    GameKey = get_list_value(game_key, ParamList),                % 平台订单号
    Subject = get_list_value(subject, ParamList),               % 游戏道具名称
    Description = get_list_value(description, ParamList),       % 游戏道具描述
    Money = get_list_value(total_fee, ParamList),                % 人民币
    Url = get_list_value(notify_url, ParamList),                % url
    OrderNo = util_time:milli_timestamp(),
    List = [{game_key, GameKey}, {orderno, OrderNo}, {game_orderno, GameOrderNoStr}, {subject, Subject}, {description, Description}, {total_fee, Money}],
    SignStr = mod_signature:sign(List),
    Type = "application/x-www-form-urlencoded",
    HTTPOptions = [{timeout, 6000}],
    Options = [],
    Method = post,
    case httpc:request(Method, {Url, [], Type, SignStr}, HTTPOptions, Options) of
        {error, Reason} ->
            ?ERROR("{error, Reason} 33333333333 ~p~n ", [Reason]),
            exit(undefined);
        {ok, Result} ->
            case Result of
                {Re1, _HeadList, HtmlResultJson} ->
                    {_, HtmlResult, _} = Re1,
                    if
                        HtmlResult == 200 ->
                            NewHtmlResultJson = jsone:decode(util:to_binary(HtmlResultJson), [{object_format, proplist}]),
                            ListJson = [{util:to_atom(Code), Value} || {Code, Value} <- NewHtmlResultJson],
                            {ok, ListJson};
                        true ->
                            ?ERROR("{ok, Result} ~p~n ", [{HtmlResult, HtmlResultJson}]),
                            exit(undefined)
                    end;
                _ ->
                    ?ERROR("{ok, Result} 11111111111111 ~p~n ", [Result]),
                    exit(undefined)
            end;
        R ->
            ?ERROR("other 2222222222222 ~p~n ", [R]),
            exit(undefined)
    end;
%%    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money);

%%path_request(<<"/charge">>, <<"GET">>, Ip, Req) ->     % 平台充值
path_request(<<"/charge">>, ?NONE, Ip, Req) ->     % 平台充值
    mod_charge_server:check_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
    PartId = util:to_int(get_list_value(<<"partid">>, ParamList)),      % 平台id
    ServerId = util:to_list(get_list_value(<<"sid">>, ParamList)),      % 服务器id
    UserId = util:to_list(get_list_value(<<"uid">>, ParamList)),        % 账号
    OrderId = util:to_list(get_list_value(<<"orderSerial">>, ParamList)),    % 订单号
    GameChargeId = util:to_int(get_list_value(<<"game_charge_id">>, ParamList)),    % 游戏充值id
    Money = util:to_int(get_list_value(<<"money">>, ParamList)),        % 人民币
    Ingot = util:to_int(get_list_value(<<"gold">>, ParamList)),         % 元宝
    FTime = util:to_int(get_list_value(<<"ftime">>, ParamList)),        % 时间
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),         % 数据的校验码
    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 订单类型
%%    ParamStr = cowboy_req:qs(Req),
    ?DEBUG("平台充值:~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:charge(PartId, ServerId, UserId, GameChargeId, Money, Ingot, OrderId, Ip, FTime, ChargeType, Hash, Str);
path_request(<<"/gm_charge">>, <<"GET">>, Ip, Req) ->     % 后台充值
    mod_charge_server:check_gm_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
    PartId = util:to_int(get_list_value(<<"partid">>, ParamList)),      % 平台id
    ServerId = util:to_list(get_list_value(<<"sid">>, ParamList)),      % 服务器id
    UserId = util:to_list(get_list_value(<<"uid">>, ParamList)),        % 账号
    GameChargeId = util:to_int(get_list_value(<<"game_charge_id">>, ParamList)),    % 游戏充值id
    Ingot = util:to_int(get_list_value(<<"gold">>, ParamList)),         % 元宝
    FTime = util:to_int(get_list_value(<<"ftime">>, ParamList)),        % 时间
    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),        % gm_id 员工编号
    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 充值类型
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),         % 数据的校验码
    if Ingot > 0 -> noop; true -> exit(ingot_0) end,
%%    ParamStr = cowboy_req:qs(Req),
    ?DEBUG("后台==》充值:~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:gm_charge(PartId, ServerId, UserId, GameChargeId, Ingot, Ip, FTime, Hash, Str, GmId, ChargeType);
path_request(<<"/change_white_ip">>, <<"GET">>, Ip, Req) ->     % 白名单
    mod_charge_server:check_gm_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
    WhiteIp = util:to_list(get_list_value(<<"ip">>, ParamList)),        % 白名单ip
    WhiteIpState = util:to_list(get_list_value(<<"ip_state">>, ParamList)),        % 白名单ip
    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),        % 白名单ip
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),        % 数据的校验码
%%    ParamStr = cowboy_req:qs(Req),
    ?DEBUG("白名单>> :~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:change_white_ip(WhiteIp, WhiteIpState, Hash, Str, GmId);
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    Value = util_list:opt(Key, ParamList),
    case Value of
        undefined ->
            exit({param_type_error, util:to_atom(Key)});
        _ ->
            Value
    end.

%% @fun json参数解析
get_json_value(Key, ParamList) ->
    Value = (catch maps:get(Key, ParamList)),
    case Value of
        {'EXIT', Exit} ->
            ?ERROR("json参数解析错误 : ~p~n", [Exit]),
            exit({param_type_error, util:to_atom(Key)});
        _ ->
            Value
    end.

get_error_file_name(Opts) ->
    case Opts of
        charge ->           % 平台正常充值
            {charge_error, charge_other_error};
        gm_charge ->        % 后台gm充值
            {gm_charge_error, gm_charge_other_error};
        game_charge ->      % 平台返回游戏充值
            {game_charge_error, game_charge_other_error};
        _ ->
            {web_error, web_other_error}
    end.

%% @fun 返回内容转换
charge_result(Result) ->
%%    Msg = result_msg(Result),
%%    ?DEBUG(Msg),
    case Result of
        not_exists ->
            -1;
        already_have ->
%%            ?DEBUG("订单重复"),
            -2;
        error_sha ->
            -3;
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
    result_msg(?MODULE, Result).
result_msg(Mod, Result) ->
    case Result of
        ok ->
            "游戏支付成功";
        not_exists ->
            "用户不存在";
        error_sha ->
            "订单不存在";
        none ->
            "订单不存在";
        already_have ->
            "订单重复";
        sid ->
            "无效服务器编号";
        null_server ->
            "服务器不存在";
        null_player_id ->
            "无效玩家账号";
        error_order_id ->
            "订单号已存在";
        orderSerial ->
            "无效订单类型";
        old_time ->
            "无效时间戳";
        money ->
            "充值金额错误";
        money_ingot ->
            "充值金额大于游戏币";
        gold ->
            "游戏币数量错误";
        error_md5 ->
            "校验码错误";
        not_ip ->
            "ip 不合法";
        times_limit ->
            "购买次数限制";
        _ ->
            ?DEBUG("mod ~p; result_msg errror: ~p~n", [Mod, Result]),
            "其他错误"
    end.

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) -> server_http_charge_handler:get_req_param_data(Req).
%%    Path = cowboy_req:path(Req),
%%    case get({parambodylist, Path}) of
%%        undefined ->
%%            QsParamStrBin = cowboy_req:qs(Req),
%%            ParamBin =
%%                if
%%                    QsParamStrBin == <<>> ->
%%                        {ok, ParamBodyBin, _} = cowboy_req:read_body(Req),
%%                        ParamBodyBin;
%%                    true ->
%%                        QsParamStrBin
%%                end,
%%            Tuple = {cow_qs:parse_qs(ParamBin), util:to_list(ParamBin)},
%%            put({parambodylist, Path}, Tuple),
%%            Tuple;
%%        {ParamList, ParamStr} ->
%%            {ParamList, ParamStr}
%%    end.

%% @fun 获得参数json字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_json(Req) -> server_http_charge_handler:get_req_param_data(Req).
%%    Path = cowboy_req:path(Req),
%%    case get({parambodylist, Path}) of
%%        undefined ->
%%            QsParamStrBin = cowboy_req:qs(Req),
%%            ParamBin =
%%                if
%%                    QsParamStrBin == <<>> ->
%%                        {ok, ParamBodyBin, _} = cowboy_req:read_body(Req),
%%                        ParamBodyBin;
%%                    true ->
%%                        QsParamStrBin
%%                end,
%%%%            ?INFO("获得参数json字符串ParamBin:~p~n", [ParamBin]),
%%            JsonList =
%%                try
%%                    jsone:decode(ParamBin, [{object_format, proplist}])
%%                catch
%%                    _: R ->
%%                        ?ERROR("获得参数json字符串错误error:~p~n", [{ParamBin, R}]),
%%                        []
%%                end,
%%            Tuple = {JsonList, util:to_list(ParamBin)},
%%%%            ?INFO("获得参数json字符串:~p~n", [Tuple]),
%%            put({parambodylist, Path}, Tuple),
%%            Tuple;
%%        {ParamList, ParamStr} ->
%%            {ParamList, ParamStr}
%%    end.

%% @fun 获得参数xml字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_xml(Req) -> server_http_charge_handler:get_req_param_data(Req).
%%    Path = cowboy_req:path(Req),
%%    case get({parambodylist, Path}) of
%%        undefined ->
%%            QsParamStrBin = cowboy_req:qs(Req),
%%            ParamBin =
%%                if
%%                    QsParamStrBin == <<>> ->
%%                        {ok, ParamBodyBin, _} = cowboy_req:read_body(Req),
%%                        ParamBodyBin;
%%                    true ->
%%                        QsParamStrBin
%%                end,
%%%%            ?INFO("获得参数xml字符串ParamBin:~p~n", [ParamBin]),
%%            JsonList =
%%                try
%%                    xml:decode(ParamBin)
%%                catch
%%                    _: R ->
%%                        ?ERROR("获得参数xml字符串错误error:~p~n", [{ParamBin, R}]),
%%                        []
%%                end,
%%            Tuple = {JsonList, util:to_list(ParamBin)},
%%            put({parambodylist, Path}, Tuple),
%%            Tuple;
%%        {ParamList, ParamStr} ->
%%            {ParamList, ParamStr}
%%    end.