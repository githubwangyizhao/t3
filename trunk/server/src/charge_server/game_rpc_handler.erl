%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc
%%% Created : 19. 三月 2019 18:31
%%%-------------------------------------------------------------------
-module(game_rpc_handler).
-author("home").

-export([
    init/2,
    terminate/2
]).

%%-include("logger.hrl").
-include("common.hrl").
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
    {ErrorCode, Msg} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, result_msg(ok)};
            {ok, ResultMsg1} ->
%%                {0, ?IF(is_list(ResultMsg1), ResultMsg1, util:to_list(ResultMsg1))};
                {0, util_string:term_to_string(ResultMsg1)};
            {'EXIT', R} ->
                ?ERROR("RPC_EXIT: ~p ~n ", [R]),
                Result = charge_result(R),
                ResultMsg = result_msg(R),
                {Result, ResultMsg};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                {1, result_msg(R1)}
        end,
%%    web_http_util:output_error_code(Req, [{error_code, ErrorCode}, {error_msg, util:to_binary(util_string:to_utf8(Msg))}]).
    web_http_util:output_error_code(Req, [{error_code, ErrorCode},{error_msg, util:to_binary(util_string:to_utf8(Msg))}]).
terminate(_Reason, _Req) ->
    ok.

%% @doc     游戏服rpc
path_request(<<"/game_rpc">>, <<"POST">>, _Ip, Req) ->
    {Params, ParamStr} = get_req_param_str(Req),
    ?INFO("游戏服rpc:~p ~n", [ParamStr]),
    ParamList = decode_params_pack(Params),
    Mod = util:to_atom(get_list_value(<<"mod">>, ParamList)),       % 模块
    F = util:to_atom(get_list_value(<<"fun">>, ParamList)),         % 方法
    ArgsStr = util:to_list(get_list_value(<<"args">>, ParamList)),  % 参数
    ArgsList = util_string:string_to_list_term(ArgsStr), % [3,[1,2]]
    Result = apply(Mod, F, ArgsList),
    ?INFO("游戏服rpc Result:~p ~n", [Result]),
    {ok, Result};
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

handle_debug_set_server_time(Req0) ->
    Fun = fun(Req, RequestParamList, _RequestData) ->
        ?ASSERT(?IS_DEBUG, not_debug),
        Data = util_cowboy:decode_data(RequestParamList),
        JsonMap = util_json:decode_to_map(Data),
        Time = util_maps:get_integer(<<"time">>, JsonMap),
%%        FileName = "../config/time.config",
%%        util_file:save_term(FileName, [{timestamp, Time}]),
        util_time:update_offset_time(Time),
        ?INFO("设置服务器时间...~p ", [util_time:timestamp_to_datetime(Time)]),
        init:restart(),
        util_cowboy:reply_json(
            Req,
            util_json:encode([{error_code, 0}])
        )
          end,
    util_cowboy:handle_request(Req0, Fun).

handle_debug_get_server_time(Req0) ->
    Fun = fun(Req, _RequestParamList, _RequestData) ->
        ?ASSERT(?IS_DEBUG, not_debug),
        DateStr = util_time:format_datetime(),
        util_cowboy:reply_json(
            Req,
            util_json:encode([{error_code, 0}, {data, util:to_binary(DateStr)}])
        )
          end,
    util_cowboy:handle_request(Req0, Fun).

%% @fun 解参数包
decode_params_pack(Params) ->
    Base64Data = util_list:opt(<<"data">>, Params),
    Data = cow_base64url:decode(Base64Data),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, Params)),
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
    ?ASSERT(StringSign == DataMd5, sign_error),
    jsone:decode(Data).

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
%% @fun 返回内容转换msg
result_msg(Result) ->
    case Result of
        ok ->
            "操作成功";
        not_exists ->
            "用户不存在";
        none ->
            "数据不存在";
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
        _ ->
            ?DEBUG("result_msg errror: ~p~n", [Result]),
            "其他错误"
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_json_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).
