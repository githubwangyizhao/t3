%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            global_player 模块(中心节点)
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_global_player).
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("mysql.hrl").
-include("system.hrl").
%% API
-export([
    get_global_player/1,
    add_global_player/1,
    do_add_global_player/7,
    try_add_global_player_list/1,
    try_add_global_player/7,
    get_user_list/3,
    repiar/0,
    change_player_name/2
]).


repiar() ->
    PlayerIdList = mod_player:get_all_player_id(),
    PlatformId = mod_server_config:get_platform_id(),
    L =
        lists:foldl(
            fun(PlayerId, Tmp) ->
                #db_player{
                    acc_id = AccId,
                    reg_time = RegTime,
                    server_id = ServerId,
                    channel = Channel,
                    nickname = Nickname
                } = mod_player:get_player(PlayerId),
                [[PlayerId, AccId, RegTime, PlatformId, ServerId, Channel, Nickname] | Tmp]
%%                mod_server_rpc:cast_center(mod_global_player, do_try_add_global_player, [PlayerId, AccId, RegTime, PlatformId, ServerId, Channel, Nickname])
%%            if PlatformId == ?PLATFORM_AF orelse PlatformId == ?PLATFORM_DJS orelse PlatformId == ?PLATFORM_LOCAL ->
%%                #db_player{
%%                    acc_id = AccId,
%%                    reg_time = RegTime,
%%                    server_id = ServerId,
%%                    channel = Channel,
%%                    nickname = Nickname
%%                } = mod_player:get_player(PlayerId),
%%                mod_server_rpc:cast_center(mod_global_player, do_try_add_global_player, [PlayerId, AccId, RegTime, PlatformId, ServerId, Channel, Nickname]);
%%                true ->
%%                    noop
%%            end
            end,
            [],
            PlayerIdList
        ),
    mod_server_rpc:cast_center(mod_global_player, try_add_global_player_list, [L]).

%% ----------------------------------
%% @doc 	中心服获取global_player
%% @throws 	none
%% @end
%% ----------------------------------
get_global_player(PlayerId) ->
    ?ASSERT(mod_server:is_center_server()),
    Sql = io_lib:format("SELECT * from `global_player` WHERE id = ~p ", [PlayerId]),
    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    Fun = fun(R) ->
        R#db_global_player{
            row_key = {R#db_global_player.id}
        }
          end,
    L = lib_mysql:as_record(Res1, db_global_player, record_info(fields, db_global_player), Fun),
    if L == [] ->
        null;
        true ->
            hd(L)
    end.

%% ----------------------------------
%% @doc 	中心服添加global_player
%% @throws 	none
%% @end
%% ----------------------------------
add_global_player(PlayerId) ->
    ?ASSERT(mod_server:is_game_server()),
    PlatformId = mod_server_config:get_platform_id(),
%%    if PlatformId == ?PLATFORM_AF orelse PlatformId == ?PLATFORM_DJS orelse PlatformId == ?PLATFORM_LOCAL ->
    #db_player{
        acc_id = AccId,
        reg_time = RegTime,
        server_id = ServerId,
        channel = Channel,
        nickname = Nickname
    } = mod_player:get_player(PlayerId),
    mod_server_rpc:cast_center(mod_global_player, do_add_global_player, [PlayerId, AccId, RegTime, PlatformId, ServerId, Channel, Nickname]).
%%        true ->
%%            noop
%%    end.

try_add_global_player_list(L) ->
    lists:foreach(
        fun([PlayerId, AccId, Time, PlatformId, ServerId, Channel, Nickname]) ->
            try_add_global_player(PlayerId, AccId, Time, PlatformId, ServerId, Channel, Nickname)
        end,
        L
    ).

try_add_global_player(PlayerId, AccId, Time, PlatformId, ServerId, Channel, Nickname) ->
    ?ASSERT(mod_server:is_center_server()),
    case is_exists(PlayerId) of
        true ->
            noop;
        false ->
            db:dirty_write(#db_global_player{
                id = PlayerId,
                account = AccId,
                create_time = Time,
                platform_id = PlatformId,
                server_id = ServerId,
                channel = Channel,
                nickanme = Nickname
            })
    end.

do_add_global_player(PlayerId, AccId, Time, PlatformId, ServerId, Channel, Nickname) ->
    ?ASSERT(mod_server:is_center_server()),
    db:dirty_write(#db_global_player{
        id = PlayerId,
        account = AccId,
        create_time = Time,
        platform_id = PlatformId,
        server_id = ServerId,
        channel = Channel,
        nickanme = Nickname
    }).

is_exists(PlayerId) ->
    Sql = io_lib:format("SELECT * from `global_player` WHERE id = ~p ", [PlayerId]),
    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    length(Res1#mysql_result.rows) > 0.

get_user_list(PlatformId, AccId, Channel) ->
    Sql = io_lib:format("SELECT * from `global_player` WHERE platform_id = '~s' and account = '~s' and channel = '~s'; ", [PlatformId, AccId, Channel]),

    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    Fun = fun(R) ->
        R#db_global_player{
            row_key = {R#db_global_player.id}
        }
          end,
    L = lib_mysql:as_record(Res1, db_global_player, record_info(fields, db_global_player), Fun),
    %%L = db:select(global_player, [{#db_global_player{platform_id = PlatformId, account = AccId,  _ = '_'}, [], ['$_']}]),
    ?DEBUG("get_user_list:~ts, ~p~n", [Sql, L]),
    lists:foldl(
        fun(E, Tmp) ->
            #db_global_player{
                id = PlayerId,
                platform_id = PlatformId,
                server_id = ServerId
            } = E,
            #db_c_game_server{
                desc = ServerName
            } = mod_server:get_game_server(PlatformId, ServerId),
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_player, get_player_info, [PlayerId]) of
                {error, null} ->
                    DeleteSql = io_lib:format("delete from `global_player` WHERE id = ~p; ", [PlayerId]),
                    ?TRY_CATCH(mysql:fetch(game_db, DeleteSql, 1000)),
                    Tmp;
                {ok, {CreateTime, Nickname, Level, Power}} ->
                    [[
                        {serverid, util:to_binary(ServerId)},
                        {servername, util:to_binary(ServerName)},
                        {creattime, util:to_binary(util_time:format_datetime(CreateTime))},
                        {userid, PlayerId},
                        {username, util:to_binary(Nickname)},
                        {power, Power},
                        {level, Level}
                    ] | Tmp];
                Other ->
                    ?ERROR("get user list:~p", [Other]),
                    Tmp
            end
        end,
        [],
        L
    ).

change_player_name(PlayerId, Name) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_CENTER ->
%%            DeleteSql = io_lib:format("update `global_player` set nickanme = ~s WHERE id = ~p; ", [Name, PlayerId]),
            NameBin = list_to_bin(Name),
            PlayerIdBin = int_to_bin(PlayerId),
            Sql =
                <<
                    "UPDATE `global_player` SET "
                    " `nickanme` = ", NameBin/binary,
                    " where `id` = ", PlayerIdBin/binary,
                    ";\n"
                >>,
            ?TRY_CATCH(db_proxy:fetch(Sql));
        _ ->
            mod_server_rpc:cast_center(?MODULE, change_player_name, [PlayerId, Name])
    end.

int_to_bin(undefined) ->
    <<"NULL">>;
int_to_bin(Value) ->
    list_to_binary(integer_to_list(Value)).
%%float_to_bin(undefined) ->
%%    <<"NULL">>;
%%float_to_bin(Value) ->
%%    list_to_binary(float_to_list(Value)).
list_to_bin(undefined) ->
    <<"NULL">>;
list_to_bin(List) ->
    List2 = escape_str(List, []),
    Bin = list_to_binary(List2),
    <<"'", Bin/binary, "'">>.
escape_str([], Result) ->
    lists:reverse(Result);
escape_str([$' | String], Result) ->
    escape_str(String, [$' | [$\\ | Result]]);
escape_str([$" | String], Result) ->
    escape_str(String, [$" | [$\\ | Result]]);
escape_str([$\\ | String], Result) ->
    escape_str(String, [$\\ | [$\\ | Result]]);
escape_str([Char | String], Result) ->
    escape_str(String, [Char | Result]).
