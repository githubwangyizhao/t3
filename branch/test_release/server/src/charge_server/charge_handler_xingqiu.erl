%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc    星球
%%% Created : 13. 八月 2019 21:16
%%%-------------------------------------------------------------------
-module(charge_handler_xingqiu).
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
    {ErrorCode, _Error} =
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
    ResultText =
        if
            ErrorCode == 0 orelse ErrorCode == -102 ->
                "success";
            true ->
                "fail"
        end,
    Req2 = web_http_util:output_text(Req, ResultText),
    Req2.
terminate(_Reason, _Req) ->
    ok.

%% @fun 星球平台地址请求
path_request(<<"/game_charge_xingqiu">>, <<"POST">>, Ip, Req) ->     % 星球平台返回游戏服充值
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("星球平台地址请求:~p", [ParamStr]),
    platform_xingqiu:http_charge_request(Ip, ParamList);
%%    mod_signature:check_param_list(lists:keydelete(<<"sign_type">>, 1, ParamList), ?CHANNEL_XINGQIU),
%%    Money = util:str_to_float(get_list_value(<<"total_amount">>, ParamList)),       % 人民币（元）
%%    OrderId = util:to_list(get_list_value(<<"out_trade_no">>, ParamList)),           % 订单号
%%    GameOrderNoStr = util:to_list(get_list_value(<<"passback_params">>, ParamList)),   % 游戏参数
%%    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money);
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
