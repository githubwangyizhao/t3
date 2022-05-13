%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    gm游戏服充值
%%% Created : 19. 六月 2018 10:25
%%%-------------------------------------------------------------------
-module(gm_charge_handler).
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
                [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error)))}]
        end,
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

%% @fun 后台充值(自已)
path_request(<<"/gm_charge">>, <<"GET">>, Ip, Req) ->     % 后台充值
%%    mod_charge_server:check_gm_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
    GameChargeId = util:to_int(get_list_value(<<"game_charge_id">>, ParamList)),   % 游戏充值id
    PlayerId = util:to_int(get_list_value(<<"player_id">>, ParamList)),             % 玩家id
    ChargeItemId = util:to_int(get_list_value(<<"charge_item_id">>, ParamList)),   % 充值物品id
    ItemCount = util:to_int(get_list_value(<<"item_count">>, ParamList)),           % 物品数量
    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),                    % gm_id 员工编
    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 充值类型
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),                     % 数据的校验码
    if ItemCount > 0 -> noop; true -> exit(ingot_0) end,
    if ChargeType == ?CHARGE_TYPE_NORMAL -> exit({charge_type, ?CHARGE_TYPE_NORMAL}); true -> noop end,
%%    ParamStr = cowboy_req:qs(Req),
    ?DEBUG("后台==》充值:~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:check_gm_hash(Str, Hash),
    mod_game_charge:gm_charge(PlayerId, ChargeType, GameChargeId, ChargeItemId, ItemCount, Ip, GmId);

%% @fun 后台活动操作
path_request(<<"/gm_activity">>, <<"GET">>, _Ip, Req) ->     % 后台失败补充充值
%%    mod_charge_server:check_gm_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
%%    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),                    % gm_id 员工编
    ActivityId = util:to_int(get_list_value(<<"activity_id">>, ParamList)),    % 活动id
    ActivityType = util:to_int(get_list_value(<<"activity_type">>, ParamList)),        % 活动方式
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),                     % 数据的校验码
%%    ParamStr = cowboy_req:qs(Req),
    ?INFO("后台活动操作==》:~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:check_gm_hash(Str, Hash),
    Result =
        if
            ActivityType == 1 ->
                activity_srv_mod:gm_server_start_id(ActivityId);
            true ->
                activity_srv_mod:gm_server_close_id(ActivityId)
        end,
    ?DEBUG("后台活动操作 ~p~n", [{ActivityType, Result}]),
    Result;
%% @fun 后台失败补充充值
path_request(<<"/gm_repair">>, <<"GET">>, _Ip, Req) ->     % 后台失败补充充值
%%    mod_charge_server:check_gm_white_ip_list(Ip),
    {ParamList, ParamStr} = get_req_param_str(Req),
    GmId = util:to_list(get_list_value(<<"gm_id">>, ParamList)),                    % gm_id 员工编
    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),                     % 数据的校验码
%%    ParamStr = cowboy_req:qs(Req),
    ?DEBUG("后台失败补充充值==》:~p ~n", [ParamStr]),
    Str =
        case string:split(util:to_list(ParamStr), "&sign") of
            [Str1, _] ->
                Str1;
            _ ->
                exit(not_sign)
        end,
    mod_charge_server:check_gm_hash(Str, Hash),
    mod_charge:gm_all_repair_charge(GmId);
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