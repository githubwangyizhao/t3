%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc    热血修仙http
%%%%% Created : 30. 十月 2018 21:22
%%%%%-------------------------------------------------------------------
-module(weixin_http_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    handle_data_request/2,      % 根据请求切换不同的操作data方式返回
%%    terminate/2
%%]).
%%
%%-include("common.hrl").
%%-include("gen/db.hrl").
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
%%            ?ERROR("错误handle_request Method: ~p ~n", [Method]),
%%            ErrorMethod = "请求方式错误",
%%            ErrorList = [{'code', -9}, {'message', util:to_binary(util_string:to_utf8(result_msg(ErrorMethod)))}, {'list', []}],
%%            web_http_util:output_error_code(Req, ErrorList)
%%    end.
%%handle_body(Req, _Opts) ->
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    {ErrorCode, Error, List} =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            {ok, ResultCode, MsgL} when is_integer(ResultCode) ->
%%                {ResultCode, ok, MsgL};
%%            {ok, MsgL} ->
%%                {0, ok, MsgL};
%%            {'EXIT', R} ->
%%                Result = charge_result(R),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                ?ERROR("EXIT错误: ~p ~n ", [R]),
%%                {Result, R, []};
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                {-9, R1, []}
%%        end,
%%    ErrorList = [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error)))}, {'list', List}],
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2.
%%
%%
%%%% @fun 根据请求切换不同的操作data方式返回
%%handle_data_request(Req, Opts) ->
%%    Method = cowboy_req:method(Req),
%%    case Method of
%%        <<"GET">> ->
%%            handle_data_body(Req, Opts);
%%        <<"POST">> ->
%%            handle_data_body(Req, Opts);
%%        _ ->
%%            ?ERROR("错误handle_request Method: ~p ~n", [Method]),
%%            ErrorMethod = "请求方式错误",
%%            ErrorList = [{'code', -9}, {'message', util:to_binary(util_string:to_utf8(result_msg(ErrorMethod)))}, {'data', {}}],
%%            web_http_util:output_error_code(Req, ErrorList)
%%    end.
%%handle_data_body(Req, Opts) ->
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    {ErrorCode, Error, List} =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            {ok, ResultCode, MsgL} when is_integer(ResultCode) ->
%%                {ResultCode, ok, MsgL};
%%            {ok, MsgL} ->
%%                {0, ok, MsgL};
%%            {'EXIT', R} ->
%%                Result = charge_result(R),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                ?ERROR("EXIT错误: ~p ~n ", [R]),
%%                {Result, R, {}};
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%%%                {_, ParamStr} = get_req_param_str(Req),
%%                {-9, R1, {}}
%%        end,
%%    ErrorList = [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error)))}, {'data', List}],
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    {ok, Req2, Opts}.
%%
%%terminate(_Reason, _Req) ->
%%    ok.
%%
%%%% ================================================ 第三套充值 ================================================
%%%% @fun 微信获取玩家充值数据
%%path_request(<<"/game_wx_player_charge_data">>, <<"POST">>, Ip, Req) ->     % 微信获取玩家充值数据
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("微信获取玩家充值数据:~p~n", [{Ip, ParamStr}]),
%%    check_param_list(ParamInfoList),
%%    HttpNickName = util:to_list(get_list_value(<<"nick_name">>, ParamInfoList)),         % 玩家名字
%%    PlatformId = util:to_list(get_list_value(<<"platform_id">>, ParamInfoList)),         % 平台标识
%%    case string:split(HttpNickName, ".") of
%%        [Sid, Nickname] ->
%%            case mod_charge_server:game_player_charge_data(PlatformId, Sid, Nickname) of
%%                {ok, ServerId, ResultList} ->
%%                    {ok, [{Key, util:to_binary(Value)} || {Key, Value} <- [{sid, ServerId}, {nick_name, HttpNickName} | ResultList]]};
%%                R ->
%%                    R
%%            end;
%%        _ ->
%%            ?ERROR("微信获取玩家充值数据名字错误:~p~n", [HttpNickName]),
%%            exit(error_nick_name)
%%    end;
%%
%%%% @fun 微信获取玩家信息数据
%%path_request(<<"/game_wx_player_info">>, <<"POST">>, _Ip, Req) ->     % 微信获取玩家信息数据
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("微信获取玩家信息数据:~p~n", [ParamStr]),
%%    ParamList = [{util:to_atom(Key), util:to_list(Value)} || {Key, Value} <- ParamInfoList],
%%    check_param_list(ParamInfoList),
%%    PlayerId = util:to_int(get_list_value(player_id, ParamList)),         % 玩家id
%%    {NickName, ServerId, ActivityShopList} = mod_charge:get_charge_http_shop_info(PlayerId),
%%    NewActivityShopList = [[{type, Type}, {type_name, util:to_binary(TypeName)},
%%        {charge_list, [[{charge_item_id, ChargeItemId}, {charge_name, util:to_binary(RechargeName)}, {money, Money}, {ingot, Ingot}] || {ChargeItemId, RechargeName, Money, Ingot} <- NewValueList]}]
%%        || {Type, TypeName, NewValueList} <- ActivityShopList],
%%    {ok, [{nick_name, util:to_binary(NickName)}, {sid, util:to_binary(ServerId)}, {shop_list, NewActivityShopList}]};
%%
%%%% @fun 微信获取玩家充值数据
%%path_request(<<"/game_wx_charge_info">>, <<"POST">>, _Ip, Req) ->     % 微信获取玩家充值数据
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("微信获取玩家充值数据:~p~n", [ParamStr]),
%%    ParamList = [{util:to_atom(Key), util:to_list(Value)} || {Key, Value} <- ParamInfoList],
%%    check_param_list(ParamInfoList),
%%    PlayerId = util:to_int(get_list_value(player_id, ParamList)),         % 玩家id
%%    ChargeItemId = util:to_int(get_list_value(charge_item_id, ParamList)),         % 充值道具id
%%    case mod_charge:charge_platform_item(PlayerId, ?PLATFORM_WX, ChargeItemId, 1, "") of
%%        ok ->
%%            {ok, []};
%%        {ok, List} ->
%%            {ok, [{util:to_atom(Key), util:to_binary(Value)} || {Key, Value} <- List]};
%%        R ->
%%            {R, []}
%%    end;
%%
%%%% ================================================ 第四套充值 ================================================
%%path_request(<<"/web_get_role_info">>, _, Ip, Req) ->     % 4微信获取玩家数据
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("4微信获取玩家数据:~p~n", [{Ip, ParamStr}]),
%%    web_check_param_list(ParamInfoList),
%%    PlayerId =
%%        case get_list_value(<<"role_id">>, ParamInfoList) of
%%            <<>> -> 0;
%%            PlayerIdStr -> util:to_int(PlayerIdStr)
%%        end,         % 玩家id
%%    PlatformId = ?PLATFORM_WX,         % 平台标识
%%    {RoleId, UserName, ServerId, ServerName} =
%%        if
%%            PlayerId > 0 ->
%%                GameNode = get_player_id_node(PlayerId),
%%                case ?TRY_CATCH2(rpc_call(util:to_atom(GameNode), mod_player, get_player_name, [PlayerId])) of
%%                    HttpNickName when is_list(HttpNickName) ->
%%                        [Sid, _Nickname] = string:split(HttpNickName, "."),
%%                        {PlayerId, HttpNickName, Sid, Sid};
%%                    _Error ->
%%                        exit(null_player_id)
%%                end;
%%            true ->
%%                HttpNickName = util:to_list(get_list_value(<<"user_name">>, ParamInfoList)),         % 玩家名字
%%                case string:split(HttpNickName, ".") of
%%                    [Sid, Nickname] ->
%%                        ServerData = mod_server:get_game_server(PlatformId, Sid),
%%                        ?ASSERT(is_record(ServerData, db_c_game_server) == true, not_find_node),
%%                        GameNode = ServerData#db_c_game_server.node,
%%                        case ?TRY_CATCH2(rpc_call(util:to_atom(GameNode), mod_player, get_player_id_by_server_id_nickname, [Sid, Nickname])) of
%%                            {ok, {PlayerId1, _MakeSex1}} ->
%%                                {PlayerId1, HttpNickName, Sid, Sid};
%%                            _ ->
%%                                ?ERROR("4微信获取玩家数据未找到玩家数据:~p~n", [HttpNickName]),
%%                                exit(error_nick_name)
%%                        end;
%%                    _ ->
%%                        ?ERROR("4微信获取玩家数据名字错误:~p~n", [HttpNickName]),
%%                        exit(error_nick_name)
%%                end
%%        end,
%%    {ok, 1, [{role_id, RoleId}, {user_name, util:to_binary(UserName)}, {server_id, util:to_binary(ServerId)}, {server_name, util:to_binary(ServerName)}]};
%%path_request(<<"/web_get_charge_info">>, _, _Ip, Req) ->     % 4微信获取玩家充值数据
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("4微信获取玩家充值数据:~p~n", [ParamStr]),
%%    web_check_param_list(ParamInfoList),
%%    PlayerId = util:to_int(get_list_value(<<"role_id">>, ParamInfoList)),         % 玩家id
%%    GameNode = get_player_id_node(PlayerId),
%%    case ?TRY_CATCH2(rpc_call(util:to_atom(GameNode), mod_charge, get_charge_http_shop_info, [PlayerId])) of
%%        {_NickName, _ServerId, ActivityShopList} ->
%%            NewActivityShopList = [[{class_name, util:to_binary(TypeName)},
%%%%                {class_list, [[{charge_item_id, ChargeItemId}, {charge_name, util:to_binary(RechargeName)}, {money, Money}, {ingot, Ingot}] || {ChargeItemId, RechargeName, Money, Ingot} <- NewValueList]}]
%%                {class_list, [[{charge_id, ChargeItemId}, {charge_name, util:to_binary(RechargeName)}, {money, Money}] || {ChargeItemId, RechargeName, Money, Ingot} <- NewValueList]}]
%%                || {_Type, TypeName, NewValueList} <- ActivityShopList],
%%            {ok, 1, NewActivityShopList};
%%        _Error ->
%%            exit(null_player_id)
%%    end;
%%path_request(<<"/web_create_charge">>, _, _Ip, Req) ->     % 4微信创建玩家充值订单
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("4微信创建玩家充值订单:~p~n", [ParamStr]),
%%    web_check_param_list(ParamInfoList),
%%    PlayerId = util:to_int(get_list_value(<<"role_id">>, ParamInfoList)),   % 玩家id
%%    ChargeId = util:to_int(get_list_value(<<"charge_id">>, ParamInfoList)), % 充值道具id
%%    PlatformId = ?PLATFORM_WX,         % 平台标识
%%    GameNode = get_player_id_node(PlayerId),
%%    ConditionsParamType = 1, % 返利方式
%%    case ?TRY_CATCH2(rpc_call(util:to_atom(GameNode), mod_charge, get_charge_platform_conditions, [PlayerId, PlatformId, ChargeId, 1, ConditionsParamType])) of
%%        {ok, List} ->
%%            {ok, 1, [{util:to_atom(Key), util:to_binary(Value)} || {Key, Value} <- List]};
%%        _Error ->
%%            exit(null_player_id)
%%    end;
%%
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.
%%
%%%% @fun 返回内容转换
%%charge_result(Result) ->
%%    case Result of
%%        not_exists ->
%%            -1;
%%        error_sha ->
%%            -3;
%%        null_player_id ->
%%%%            ?DEBUG("无效玩家账号"),
%%            -101;
%%        error_md5 ->
%%%%            ?DEBUG("校验码错误"),
%%            -107;
%%        null_object ->
%%            -4;
%%        not_sign ->
%%            -5;
%%        error_nick_name ->
%%            -6;
%%        null_server ->
%%            -7;
%%        not_find_node ->
%%            -8;
%%        _ ->
%%            -9
%%    end.
%%%% @fun 返回内容转换msg
%%result_msg(Result) ->
%%    case Result of
%%        ok ->
%%            "成功";
%%        not_exists ->
%%            "用户不存在";
%%        error_sha ->
%%            "校验码错误";
%%        null_player_id ->
%%            "无效玩家账号";
%%        error_md5 ->
%%            "校验码错误";
%%        not_sign ->
%%            "没有sign字段";
%%        error_nick_name ->
%%            "名字缺少对应服内容";
%%        not_find_node ->
%%            "未找到节点";
%%        null_server ->
%%            "服务器不存在";
%%        _ ->
%%            ?ERROR("result_msg errror: ~p~n", [Result]),
%%            "其他错误"
%%    end.
%%
%%sign_str(List) ->
%%    ChargeShaStr = util_list:change_list_url(lists:sort(List)) ++ "AQWfux30VQ7jH3Kc",
%%    encrypt:sha(ChargeShaStr).
%%
%%%% 验证参数
%%check_param_list(ParamList1) ->
%%    ParamList = [{util:to_atom(Key1), util:to_list(Value1)} || {Key1, Value1} <- ParamList1],
%%    KeyAtom = sign,
%%    case lists:keytake(KeyAtom, 1, ParamList) of
%%        {value, {_, Hash}, OtherList} ->
%%            CheckHash = sign_str(OtherList),
%%            if
%%                CheckHash == Hash ->
%%                    noop;
%%                true ->
%%                    ?ERROR("检验码不一致: sign:~p  >> CalcHash: ~p~n~p~n", [Hash, CheckHash, OtherList]),
%%                    exit(error_sha)
%%            end;
%%        _ ->
%%            exit(not_sign)
%%    end.
%%
%%web_sign_str(List) ->
%%    ChargeShaStr = util_list:change_list_url(lists:sort(List)) ++ "Rc5TYYXduEOGQahH",
%%    encrypt:sha(ChargeShaStr).
%%
%%%% web验证参数
%%web_check_param_list(ParamList1) ->
%%    ParamList = [{util:to_atom(Key1), util:to_list(Value1)} || {Key1, Value1} <- ParamList1],
%%    KeyAtom = sign,
%%    case lists:keytake(KeyAtom, 1, ParamList) of
%%        {value, {_, Hash}, OtherList} ->
%%            CheckHash = web_sign_str(OtherList),
%%            if
%%                CheckHash == Hash ->
%%                    noop;
%%                true ->
%%                    ?ERROR("检验码不一致: sign:~p  >> CalcHash: ~p~n~p~n", [Hash, CheckHash, OtherList]),
%%                    exit(error_sha)
%%            end;
%%        _ ->
%%            exit(not_sign)
%%    end.
%%
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).
%%
%%
%%%% @doc fun 获得玩家的节点数据
%%get_player_id_node(PlayerId) ->
%%    F =
%%        fun() ->
%%            case ?TRY_CATCH2(mod_server_rpc:call_center(mod_global_player, get_global_player, [PlayerId])) of
%%                #db_global_player{
%%                    platform_id = PlatformId1,
%%                    server_id = ServerId1
%%                } ->
%%                    {PlatformId1, ServerId1};
%%                Error ->
%%                    exit(Error)
%%            end
%%        end,
%%    Key = {?MODULE, get_player_id_serverId, PlayerId},
%%    CacheData = mod_cache:cache_data(Key, F, 0),
%%    GameNode =
%%        case CacheData of
%%            {PlatformId, ServerId} ->
%%                mod_server:get_game_node(PlatformId, ServerId);
%%            _ ->
%%                null
%%        end,
%%    ?IF(GameNode == null, exit(not_find_node), GameNode).
%%
%%-spec rpc_call(Node, M, F, A) -> term() when
%%    Node :: node(),
%%    M :: module(),
%%    F :: atom(),
%%    A :: [term()].
%%rpc_call(Node, M, F, A) ->
%%    util:rpc_call(Node, M, F, A).