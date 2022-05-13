%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         设备唯一id
%%% @end
%%% Created : 20. 四月 2021 下午 02:16:54
%%%-------------------------------------------------------------------
-module(mod_phone_unique_id).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("player_game_data.hrl").

%% API
-export([
%%    get_is_newbee_adjust/1,
    set_is_newbee_adjust/4,

    is_newbee_adjust/3
]).

%%-export([
%%    version_repair/0
%%]).

%% ----------------------------------
%% @doc 设置是否使用新手修正(创角的时候，执行一次)
%% ----------------------------------
set_is_newbee_adjust(PlatformId, AccId, UniqueId, PlayerId) ->
    case ?IS_DEBUG of
        true ->
            noop;
        false ->
            case
                mod_server_rpc:call_center(?MODULE, is_newbee_adjust, [PlatformId, AccId, UniqueId])
            of
                true ->
                    noop;
                false ->
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE)
            end
    end.

%%%% ----------------------------------
%%%% @doc 获得是否使用新手修正
%%%% ----------------------------------
%%get_is_newbee_adjust(PlayerId) ->
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST),
%%    ?TRAN_INT_2_BOOL(Value).
%%
%% ----------------------------------
%% @doc 是否使用新手池
%% ----------------------------------
is_newbee_adjust(PlatformId, AccId, UniqueId) ->
    ?ASSERT(mod_server:is_center_server()),
    case get_db_phone_unique_id(PlatformId, UniqueId) of
        null ->
            db:dirty_write(#db_phone_unique_id{platform_id = PlatformId, phone_unique_id = UniqueId, created_time = util_time:timestamp()}),
%%            insert_phone_unique_id(PlatformId, UniqueId),
            GlobalAccount = global_account_srv:get_global_account(PlatformId, AccId),
            #db_global_account{
                recent_server_list = OldRecentServerIdList
            } = GlobalAccount,
            OldList = mod_global_account:tran_recent_server_list(OldRecentServerIdList),
            if
                OldList == [] ->
                    true;
                true ->
                    false
            end;
        _R ->
            false
    end.

get_db_phone_unique_id(PlatformId, UniqueId) ->
    ?ASSERT(mod_server:is_center_server()),
    Sql = io_lib:format("SELECT * from `phone_unique_id` WHERE platform_id = '~s' and phone_unique_id = '~s' ", [PlatformId, UniqueId]),
    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    Fun = fun(R) ->
        R#db_phone_unique_id{
            row_key = {R#db_phone_unique_id.platform_id, R#db_phone_unique_id.phone_unique_id}
        }
          end,
    L = lib_mysql:as_record(Res1, db_phone_unique_id, record_info(fields, db_phone_unique_id), Fun),
    if L == [] ->
        null;
        true ->
            hd(L)
    end.

%%insert_phone_unique_id(PlatformId, UniqueId) ->
%%    PlatformIdBin = list_to_bin(PlatformId),
%%    AccIdBin = list_to_bin(UniqueId),
%%    CreatedTime = int_to_bin(util_time:timestamp()),
%%    Sql = <<
%%        "INSERT INTO `phone_unique_id` (`platform_id`, `account`, `created_time`) VALUES "
%%        " ( ", PlatformIdBin/binary,
%%        ",  ", AccIdBin/binary,
%%        ",  ", CreatedTime/binary,
%%        ");\n"
%%    >>,
%%    db_proxy:fetch(Sql).

%%%% 版本修复
%%version_repair() ->
%%    Tran = fun() ->
%%        lists:foreach(
%%            fun(PlayerId) ->
%%                case mod_player_adjust:is_new_adjust(PlayerId) of
%%                    true ->
%%                        mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?TRUE);
%%                    false ->
%%                        noop
%%                end
%%            end,
%%            mod_player:get_all_player_id()
%%        )
%%           end,
%%    db:do(Tran),
%%    ok.
