%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         配置
%%% @end
%%% Created : 24. 六月 2021 上午 11:19:12
%%%-------------------------------------------------------------------
-module(game_config).
-author("Administrator").

-include("gen/db.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").

%% server_config
%%-export([
%%    get_server_game_config_int/1,
%%    get_server_game_config_str/1,
%%
%%    set_server_game_config_int/2,
%%    set_server_game_config_str/2
%%]).
%%
%%%% player_config
%%-export([
%%    get_player_game_config_int/2,
%%    get_player_game_config_str/2,
%%
%%    set_player_game_config_int/3,
%%    set_player_game_config_str/3
%%]).
%%
%%-export([
%%    get_db_server_game_config_list/0
%%]).

-export([
    init_set_all_game_config/0,

    set_game_server_config/3,
    get_game_server_config/2,
    delete_game_server_config/2
]).

-export([
    get_config_scene_adjust_chou_shui_value/1
]).

-define(CONFIG_TYPE_SCENE_ADJUST, 1).

%%-define(HTTP_GET_URL(PlatformId),
%%    if
%%        ?IS_DEBUG ->
%%            "http://192.168.31.100:7399/api/get_adjust_list";
%%        true ->
%%            "http://127.0.0.1:7399/api/get_adjust_list"
%%    if
%%        PlatformId =:= ?PLATFORM_LOCAL ->
%%            "http://192.168.31.100:7399/api/get_adjust_list";
%%        PlatformId =:= ?PLATFORM_TEST ->
%%            "http://127.0.0.1:7399/api/get_adjust_list";
%%        true ->
%%            "http://127.0.0.1:7199/api/get_adjust_list"
%%    end).


-define(HTTP_HOST(Env),
    if
        Env =:= "develop" ->
            "http://192.168.31.100:7399/api/get_adjust_list";
        Env =:= "testing" ->
            "http://127.0.0.1:7199/api/get_adjust_list";
        Env =:= "testing_oversea" ->
            "http://127.0.0.1:7199/api/get_adjust_list";
        true ->
            "http://127.0.0.1:7199/api/get_adjust_list"
    end).


init_set_all_game_config() ->
    PlatformId = mod_server_config:get_platform_id(),
    ParamList = lists:sort([
        {"platformId", PlatformId},
        {"server", mod_server:get_server_id()}
    ]),
    Env = env:get(env, "develop"),
    Url = ?HTTP_HOST(Env),
%%    case util_http:post(?HTTP_GET_URL(PlatformId), json, ParamList) of
    case util_http:post(Url, json, ParamList) of
        {ok, Result} ->
            ?DEBUG("post 请求结果 ： ~p", [Result]),
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p, data: ~p", [Code, is_list(Data)]),
            if
                Code =:= 0 ->
                    lists:foreach(
                        fun(Ele) ->
                            ConfigType = maps:get(<<"type">>, Ele),
                            ConfigId = maps:get(<<"refId">>, Ele),
                            Value = maps:get(<<"value">>, Ele),
                            ?DEBUG("game_server_config_data : ~p", [{ConfigType, ConfigId, Value}]),
                            set_game_server_config(ConfigType, ConfigId, Value)
                        end,
                        Data
                    );
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end.

get_game_server_config(ConfigType, ConfigId) ->
    mod_cache:get({?MODULE, ConfigType, ConfigId}).

set_game_server_config(ConfigType, ConfigId, Value) ->
    ?INFO("设置game_config : ~p", [{ConfigType, ConfigId, Value}]),
    mod_cache:update({?MODULE, ConfigType, ConfigId}, Value).

delete_game_server_config(ConfigType, ConfigId) ->
    ?INFO("删除game_config : ~p", [{ConfigType, ConfigId}]),
    mod_cache:delete({?MODULE, ConfigType, ConfigId}).

%%%% @doc 获得服务器游戏配置 int
%%get_server_game_config_int(ConfigId) ->
%%    case get_db_server_game_config(ConfigId) of
%%        null ->
%%            0;
%%        DbServerGameConfig ->
%%            DbServerGameConfig#db_server_game_config.int_data
%%    end.
%%%% @doc 获得服务器游戏配置 str
%%get_server_game_config_str(ConfigId) ->
%%    case get_db_server_game_config(ConfigId) of
%%        null ->
%%            "";
%%        DbServerGameConfig ->
%%            DbServerGameConfig#db_server_game_config.str_data
%%    end.
%%
%%%% @doc 设置服务器游戏配置 int
%%set_server_game_config_int(ConfigId, IntData) ->
%%    DbServerGameConfig = get_db_server_game_config_or_init(ConfigId),
%%    Tran =
%%        fun() ->
%%            db:write(DbServerGameConfig#db_server_game_config{int_data = IntData})
%%        end,
%%    db:do(Tran),
%%    IntData.
%%%% @doc 设置服务器游戏配置 str
%%set_server_game_config_str(ConfigId, StrData) ->
%%    DbServerGameConfig = get_db_server_game_config_or_init(ConfigId),
%%    Tran =
%%        fun() ->
%%            db:write(DbServerGameConfig#db_server_game_config{str_data = StrData})
%%        end,
%%    db:do(Tran),
%%    StrData.
%%
%%%% @doc 获得玩家游戏配置 int
%%get_player_game_config_int(PlayerId, ConfigId) ->
%%    case get_db_player_game_config(PlayerId, ConfigId) of
%%        null ->
%%            0;
%%        DbPlayerGameConfig ->
%%            DbPlayerGameConfig#db_player_game_config.int_data
%%    end.
%%%% @doc 获得玩家游戏配置 str
%%get_player_game_config_str(PlayerId, ConfigId) ->
%%    case get_db_player_game_config(PlayerId, ConfigId) of
%%        null ->
%%            "";
%%        DbPlayerGameConfig ->
%%            DbPlayerGameConfig#db_player_game_config.str_data
%%    end.
%%
%%%% @doc 设置服务器游戏配置 int
%%set_player_game_config_int(PlayerId, ConfigId, IntData) ->
%%    DbPlayerGameConfig = get_db_player_game_config_or_init(PlayerId, ConfigId),
%%    Tran =
%%        fun() ->
%%            db:write(DbPlayerGameConfig#db_player_game_config{int_data = IntData})
%%        end,
%%    db:do(Tran),
%%    IntData.
%%%% @doc 设置服务器游戏配置 str
%%set_player_game_config_str(PlayerId, ConfigId, StrData) ->
%%    DbPlayerGameConfig = get_db_player_game_config_or_init(PlayerId, ConfigId),
%%    Tran =
%%        fun() ->
%%            db:write(DbPlayerGameConfig#db_player_game_config{str_data = StrData})
%%        end,
%%    db:do(Tran),
%%    StrData.
%%
%%%% @doc DB 获得服务器游戏配置
%%get_db_server_game_config(ConfigId) ->
%%    db:read(#key_server_game_config{config_id = ConfigId}).
%%get_db_server_game_config_or_init(ConfigId) ->
%%    case db:read(#key_server_game_config{config_id = ConfigId}) of
%%        null ->
%%            #db_server_game_config{
%%                config_id = ConfigId
%%            };
%%        DbServerGameConfig ->
%%            DbServerGameConfig
%%    end.
%%
%%%% @doc DB 获得玩家游戏配置
%%get_db_player_game_config(PlayerId, ConfigId) ->
%%    db:read(#key_player_game_config{player_id = PlayerId, config_id = ConfigId}).
%%get_db_player_game_config_or_init(PlayerId, ConfigId) ->
%%    case db:read(#key_player_game_config{player_id = PlayerId, config_id = ConfigId}) of
%%        null ->
%%            #db_player_game_config{
%%                player_id = PlayerId,
%%                config_id = ConfigId
%%            };
%%        DbPlayerGameConfig ->
%%            DbPlayerGameConfig
%%    end.
%%
%%get_db_server_game_config_list() ->
%%    ets:tab2list(db_server_game_config).

get_config_scene_adjust_chou_shui_value(SceneId) ->
    get_game_server_config(?CONFIG_TYPE_SCENE_ADJUST, SceneId).