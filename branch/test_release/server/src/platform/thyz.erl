%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            天合游戏上报
%%% @end
%%% Created : 20. 六月 2016 下午 1:46
%%%-------------------------------------------------------------------
-module(thyz).

%% API
-export([
    report_register/3,      %% 注册上报
    report_create_role/1,   %% 创角上报
    report_login/1,         %% 登录上报
    report_logout/2,        %% 登出上报
    report_charge/7         %% 充值上报
]).
-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-ifdef(debug).
-define(THYZ_URL, "http://127.0.0.1:80/api/v1").
-define(THYZ_GAME_ID, 1).
-define(THYZ_GAME_KEY, "wrvm824nhfvn").
-else.
-define(THYZ_URL, "http://127.0.0.1:8000/v1").
-define(THYZ_GAME_ID, 1).
-define(THYZ_GAME_KEY, "wrvm824nhfvn").
-endif.

%% @doc 注册上报
report_register(Account, ServerId, _Channel) ->
    Now = util_time:timestamp(),
    URL = ?THYZ_URL ++ "/report_register?" ++ make_query_and_sign(
        [
            {"gameid", ?THYZ_GAME_ID},
            {"platformId", mod_server_config:get_platform_id()},
            {"channel", mod_server_config:get_platform_id()},
            {"account", Account},
            {"serverId", ServerId},
            {"time", Now}
        ]),
    do_report(URL, report_register_role, Account).
tran_system_code(From) ->
    case util_string:str_to_lower(From) of
        "android" ->
            %% 1:安卓
            1;
        "ios" ->
            %% 2:ios
            2;
        "windows pc" ->
            %% 3:windows
            3;
        "mac os" ->
            %% 4:mac
            4;
        _ ->
            %%其他
            0
    end.
%% @doc 创角上报
report_create_role(PlayerId) ->
    #db_player{
        server_id = ServerId,
        nickname = Nickname,
        acc_id = Account,
%%        channel = Channel,
        friend_code = FriendCode,
        from = From
    } = mod_player:get_player(PlayerId),
    Now = util_time:timestamp(),
    IsShare =
        if FriendCode == "" ->
            0;
            true ->
                1
        end,
    URL = ?THYZ_URL ++ "/report_create_role?" ++ make_query_and_sign(
        [
            {"gameid", ?THYZ_GAME_ID},
            {"platformId", mod_server_config:get_platform_id()},
            {"channel", mod_server_config:get_platform_id()},
            {"account", Account},
            {"serverId", ServerId},
            {"name", Nickname},
            {"isShare", IsShare},
            {"system", From},
            {"systemCode", tran_system_code(From)},
            {"time", Now}
        ]),
    do_report(URL, report_create_role, Account).

get_task_name(0) ->
    "";
get_task_name(TaskId) ->
    case mod_task:get_t_task(TaskId) of
        null ->
            "";
        R ->
%%            #t_task{
%%                title = Title
%%            } = R,
%%            Title
            ""
    end.

%% @doc 登录上报
report_login(PlayerId) ->
    #db_player{
        server_id = ServerId,
        nickname = Nickname,
        acc_id = Account,
%%        channel = Channel,
        last_login_ip = LastLoginIp,
        from = From
    } = mod_player:get_player(PlayerId),
    #db_player_data{
        level = Level
    } = mod_player:get_db_player_data(PlayerId),
    Now = util_time:timestamp(),
    TaskId = mod_task:get_player_task_id(PlayerId),
    URL = ?THYZ_URL ++ "/report_login?" ++ make_query_and_sign(
        [
            {"gameid", ?THYZ_GAME_ID},
            {"platformId", mod_server_config:get_platform_id()},
            {"channel", mod_server_config:get_platform_id()},
            {"account", Account},
            {"serverId", ServerId},
            {"name", Nickname},
            {"level", Level},
            {"taskId", TaskId},
            {"ip", LastLoginIp},
            {"taskName", get_task_name(TaskId)},
            {"systemCode", tran_system_code(From)},
            {"time", Now}
        ]),
    do_report(URL, report_login, Account).

%% @doc 登出上报
report_logout(PlayerId, OnlineTime) ->
    #db_player{
        server_id = ServerId,
        nickname = Nickname,
        acc_id = Account
%%        channel = Channel
    } = mod_player:get_player(PlayerId),
    #db_player_data{
        level = Level
    } = mod_player:get_db_player_data(PlayerId),
    Now = util_time:timestamp(),
    TaskId = mod_task:get_player_task_id(PlayerId),
    URL = ?THYZ_URL ++ "/report_logout?" ++ make_query_and_sign(
        [
            {"gameid", ?THYZ_GAME_ID},
            {"platformId", mod_server_config:get_platform_id()},
            {"channel", mod_server_config:get_platform_id()},
            {"account", Account},
            {"serverId", ServerId},
            {"name", Nickname},
            {"time", Now},
            {"level", Level},
            {"taskId", TaskId},
            {"taskName", get_task_name(TaskId)},
            {"onlinetime", OnlineTime}
        ]),
    do_report(URL, report_logout, Account).

%% @doc 充值上报
report_charge(PlayerId, OrderId, PlatformOrderId, Money, ItemId, ItemName, ChargeTime) ->
    ?INFO("thyz充值上报:~p", [{PlayerId, OrderId, Money, ChargeTime}]),
    #db_player{
        acc_id = Account,
        server_id = ServerId,
        nickname = Nickname,
        channel = Channel,
        from = From
    } = mod_player:get_player(PlayerId),
    #db_player_data{
        level = Level
    } = mod_player:get_db_player_data(PlayerId),
    try
        Now = util_time:timestamp(),
        TaskId = mod_task:get_player_task_id(PlayerId),
        URL = ?THYZ_URL ++ "/report_charge?" ++ make_query_and_sign(
            [
                {"gameid", ?THYZ_GAME_ID},
                {"platformId", mod_server_config:get_platform_id()},
                {"channel", mod_server_config:get_platform_id()},
                {"account", Account},
                {"serverId", ServerId},
                {"name", Nickname},
                {"time", Now},
                {"level", Level},
                {"taskId", TaskId},
                {"taskName", get_task_name(TaskId)},
                {"orderid", OrderId},
                {"platformorderid", PlatformOrderId},
                {"money", Money},
                {"itemId", ItemId},
                {"itemName", ItemName},
                {"chargetime", ChargeTime},
                {"systemCode", tran_system_code(From)}
            ]),
        do_report(URL, report_charge, Account, true)
    catch
        _:Reason ->
            ?ERROR("thyz report error:~p", [{Reason, Account, Channel, OrderId, Money, ChargeTime}])
    end.

do_report(URL, Type, Account) ->
    do_report(URL, Type, Account, false).
do_report(URL, Type, Account, IsSuccessInfoLog) ->
    case util_http:get(URL) of
        {ok, Result} ->
            {Code, Msg} = decode_result(Result),
            if Code == 0 ->
                if IsSuccessInfoLog ->
                    ?INFO("~p success:~p", [Type, Account]);
                    true ->
                        ?DEBUG("~p success:~p", [Type, Account])
                end;
                true ->
                    ?ERROR("\n ~p fail=>\n"
                    "  url: ~ts\n"
                    "  code: ~p\n"
                    "  msg: ~ts\n",
                        [Type, URL, Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n ~p fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Type, URL, Reason]),
            false
    end.

make_query_and_sign(Props) ->
    util_http_url:sign_and_encode(Props, md5, "sign", ?THYZ_GAME_KEY).

decode_result(Result) ->
    Response = util_json:decode(Result),
    Code = util_maps:get_integer(<<"code">>, Response),
    Msg = util_maps:get_string(<<"msg">>, Response),
    {Code, Msg}.
