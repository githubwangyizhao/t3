%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            ETS 表初始化
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_ets).
-include("common.hrl").
%%-include("scene.hrl").
-include("system.hrl").
-include("room.hrl").

%% API
-export([init/0]).

-export([
    ets_delete/1
%%    get_ets_fight_recode_id/2,
%%    get_ets_fight_recode_init/2,
%%    insert_ets_fight_recode/1
]).

%% ----------------------------------
%% @doc 	初始化全局ets表
%% @throws 	none
%% @end
%% ----------------------------------
init() ->
    %% 通用ets缓存
    ets:new(?ETS_CACHE, ?ETS_INIT_ARGS(#ets_cache.id)),

    case mod_server_config:get_server_type() of
        %% 中心服
        ?SERVER_TYPE_CENTER ->
            ets:new(?ETS_OAUTH_STATE_JWT, [duplicate_bag , named_table, public, {keypos, #ets_oauth_state_jwt.code}, {write_concurrency, true}, {read_concurrency, true}]), % oauth登录
            ets:new(?ETS_ERGET_SETTING, ?ETS_INIT_ARGS(#ets_erget_setting.app_id)),
            ets:new(?ETS_EGRET_REVIEWING_VERSION, ?ETS_INIT_ARGS(#ets_egret_reviewing_version.app_id)),
            ets:new(?ETS_PLATFORM_SETTING, ?ETS_INIT_ARGS(#ets_platform_setting.platform)),
            ets:new(?ETS_TEST_ACCOUNT, ?ETS_INIT_ARGS(#ets_test_account.account)),
            ets:new(?ETS_CLIENT_STATIC_RESOURCE_RECORD, ?ETS_INIT_ARGS(#ets_client_static_resource_record.row_key)),
            ets:new(?ETS_CLIENT_HEARTBEAT_VERIFY, ?ETS_INIT_ARGS(#ets_client_heartbeat_verify.row_key)),
            ets:new(?ETS_APP_INFO, ?ETS_INIT_ARGS(#ets_app_info.app_id)),
            ets:new(?ETS_APP_NOTICE, ?ETS_INIT_ARGS(#ets_app_notice.row_key)),
            ets:new(?ETS_TRACKER_TOKEN, ?ETS_INIT_ARGS(#ets_tracker_token.tracker_token)),
            ets:new(?ETS_DOMAIN, ?ETS_INIT_ARGS(#ets_domain.app_id)),
            ets:new(?ETS_REGION_INFO, ?ETS_INIT_ARGS(#ets_region_info.tracker_token)),
            ets:new(?ETS_AREA_INFO, ?ETS_INIT_ARGS(#ets_area_info.currency)),
            noop;
        %% 游戏服
        ?SERVER_TYPE_GAME ->
            ets:new(?ETS_OBJ_PLAYER, ?ETS_INIT_ARGS(#ets_obj_player.id)),
            ets:new(?ETS_OFFLINE_PLAYER_SCENE_CACHE, ?ETS_INIT_ARGS(#ets_offline_player_scene_cache.player_id)),
            ets:new(?ETS_OFFLINE_PLAYER_ROOM_CACHE, ?ETS_INIT_ARGS(#ets_offline_player_room_cache.player_id)),
            ets:new(?ETS_ROOM_SUBSCRIBE, ?ETS_INIT_ARGS(#ets_room_subscribe.playerid)),
            ets:new(?ETS_PLATFORM_FRIENDS_DATA, ?ETS_INIT_ARGS(#ets_platform_friends_data.player_id)),      % 玩家平台好友列表
            ets:new(?ETS_RANK_COUNT_RECORD, ?ETS_INIT_ARGS(#ets_rank_count_record.row_key)),
            ets:new(?ETS_PROPS_TRADER_TOKEN, ?ETS_INIT_ARGS(#ets_props_trader_token.username)),     %% 玩家到装备交易平台支付所需的token
            ets:new(?ETS_PLAYER_CHAT_MSG, ?ETS_INIT_ARGS(#ets_player_chat_msg.player_id));                  % 玩家聊天信息
        %% 跨服
        ?SERVER_TYPE_WAR_ZONE ->
            ets:new(?ETS_OFFLINE_PLAYER_SCENE_CACHE, ?ETS_INIT_ARGS(#ets_offline_player_scene_cache.player_id));
        %% 登录服
        ?SERVER_TYPE_LOGIN_SERVER ->
            ets:new(?ETS_LOGIN_CACHE, ?ETS_INIT_ARGS(#ets_login_cache.account));
        %% 战区服
        ?SERVER_TYPE_WAR_AREA ->
            ets:new(?ETS_BOSS_ONE_ON_ONE_RECORD, ?ETS_INIT_ARGS(#ets_boss_one_on_one_record.row_key)),
            ets:new(?ETS_OBJ_PLAYER, ?ETS_INIT_ARGS(#ets_obj_player.id));
        _ ->
            noop
    end,
    ok.


%% ets表数据删除
ets_delete(null) ->
    ok;
ets_delete(Record) ->
    Table = erlang:element(1, Record),
    ets:delete_object(Table, Record).


%% ================================================ ets数据操作 ================================================
%%%% @fun 玩家战斗记录     并初始化
%%get_ets_fight_recode_init(PlayerId, Type) ->
%%    RecodeId = get_ets_fight_recode_id(PlayerId, Type),
%%    RowKey = {PlayerId, Type, RecodeId},
%%    #ets_fight_recode{row_key = RowKey, player_id = PlayerId, type = Type, id = RecodeId}.
%%%% @fun 增加玩家战斗记录数据
%%insert_ets_fight_recode(Ets) ->
%%    ets:insert(?ETS_FIGHT_RECODE, Ets).
%%
%%%% @fun 跨服竞技场玩家战斗记录id
%%get_ets_fight_recode_id(PlayerId, Type) ->
%%    RowKey = {PlayerId, Type},
%%    NewEts =
%%        case ets:lookup(?ETS_FIGHT_RECODE_ID, RowKey) of
%%            [Ets] ->
%%                Ets#ets_fight_recode_id{id = Ets#ets_fight_recode_id.id + 1};
%%            _ ->
%%                #ets_fight_recode_id{row_key = RowKey, player_id = PlayerId, type = Type}
%%        end,
%%    ets:insert(?ETS_FIGHT_RECODE_ID, NewEts),
%%    NewEts#ets_fight_recode_id.id.
