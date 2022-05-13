%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            服务器版本管理
%%% @end
%%% Created : 28. 十一月 2017 下午 1:41
%%%-------------------------------------------------------------------
-module(version).
-compile(export_all).

-include("system.hrl").
-include("gen/db.hrl").
-include("common.hrl").
-include("server_data.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("player_game_data.hrl").
%% ----------------------------------
%% @doc 	更新服务器版本号
%% @throws 	none
%% @end
%% ----------------------------------
set_server_version(Version) when is_integer(Version) ->
    mod_server_data:set_int_data(?SERVER_DATA_VERSION, Version).

%% ----------------------------------
%% @doc 	获取服务器版本号
%% @throws 	none
%% @end
%% ----------------------------------
get_server_version() ->
    mod_server_data:get_int_data(?SERVER_DATA_VERSION).

%% ----------------------------------
%% @doc 	更新
%% @throws 	none
%% @end
%% ----------------------------------
update() ->
    update(mod_server:get_code_version()).


%% ----------------------------------
%% @doc 	拉取所有玩家数据到内存， 修复完后重启节点(冷更新用)
%% @throws 	none
%% @end
%% ----------------------------------
%%repair(_NewVersion, Fun) ->
%%%%    db_backup:backup(io_lib:format("~p.sql", [NewVersion])),
%%%%    ServerVersion = get_server_version(),
%%%%    db_backup:backup(util:to_list(ServerVersion) ++ ".sql"),
%%    ?INFO("Loading all player database"),
%%    AllPlayerId = mod_player:get_all_player_id(),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            db_load:load_hot_data(PlayerId)
%%        end,
%%        AllPlayerId
%%    ),
%%    ?INFO("Loading database success."),
%%    ?INFO("Start exce repair function..."),
%%    Fun(),
%%    ?INFO("Finish repair function."),
%%    db_sync:sync(),
%%    timer:sleep(3000),
%%    init:restart().


update(NewVersion) ->
    OldVersion = get_server_version(),
    if OldVersion >= NewVersion ->
        noop;
        true ->
            ?INFO("版本更新:~p -> ~p~n", [OldVersion, NewVersion]),
            set_server_version(NewVersion),
            case mod_server_config:get_server_type() of
                ?SERVER_TYPE_GAME ->
                    do_update(OldVersion, NewVersion),
                    ?INFO("版本升级成功");
                _ ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	执行版本更新脚本
%% @throws 	none
%% @end
%% ----------------------------------
do_update(Version, Version) ->
    ?INFO("已将版本更新到 ~p", [Version]),
    ok;
do_update(2021041401, NewVersion) ->
    Version = 2021100501,
    Tran =
        fun() ->
            lists:foreach(
                fun(DbPlayerData) ->
                    #db_player_data{
                        player_id = PlayerId
                    } = DbPlayerData,
                    PlayerExpNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_EXP),
                    if
                        PlayerExpNum > 0 ->
                            ?INFO("版本2021100501修复，扣去全部经验值，玩家id:~p,数量:~p~n,", [PlayerId, PlayerExpNum]),
                            mod_prop:decrease_player_prop(PlayerId, [{?ITEM_EXP, PlayerExpNum}], ?LOG_TYPE_UPDATE_VERSION_REPAIR1);
                        true ->
                            noop
                    end
                end,
                ets:tab2list(player_data)
            )
        end,
    db:do(Tran),
    do_update(Version, NewVersion);
do_update(2021100501, NewVersion) ->
    do_update(2021102301, NewVersion),
    ok;
do_update(_OldVersion, _NewVersion) ->
    ?WARNING("版本升级忽略:~p", [{_OldVersion, _NewVersion}]),
    ignore.

get_player_version() ->
    2021110301.
%% @doc 注册初始版本
register_init_version(PlayerId) ->
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION, get_player_version()).
%% ----------------------------------
%% @doc 	版本数据修复
%% @throws 	none
%% @end
%% ----------------------------------
version_repair(PlayerId) ->
    Tran =
        fun() ->
            deal_player_version(PlayerId, 2021102301),
            deal_player_version(PlayerId, 2021102601),
            deal_player_version(PlayerId, 2021110301)
        end,
    db:do(Tran).
deal_player_version(PlayerId, Version = 2021102301) ->
    PlayerVersion = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION),
    if
        PlayerVersion < Version ->
            %% 主线任务全部过掉，进入赏金任务
            Now = util_time:timestamp(),
            DbPlayerTask = mod_task:get_db_player_task(PlayerId),
            #db_player_task{
                task_id = TaskId,
                status = Status
            } = DbPlayerTask,
            if
                TaskId /= 0 orelse Status /= ?AWARD_ALREADY ->
                    ?INFO("repair version ~p, playerid ~p, oritaskid ~p, oristatus ~p", [Version, PlayerId, TaskId, Status]),
                    db:write(DbPlayerTask#db_player_task{
                        task_id = 0,
                        status = ?AWARD_ALREADY,
                        update_time = Now
                    });
                true ->
                    noop
            end,
            %% 等级补偿英雄
            LevelRepairLists = [[15, 29, [1]], [30, 49, [1, 7]], [50, 0, [1, 7, 2]]],
            PlayerLevel = mod_player:get_player_data(PlayerId, level),
            LevelRepairHeroList = util_list:get_value_from_range_list(PlayerLevel, LevelRepairLists, []),
            %% vip补偿英雄
            VipRepairLists = [[5, 0, [4]]],
            PlayerVipLevel = mod_vip:get_vip_level(PlayerId),
            VipRepairHeroList = util_list:get_value_from_range_list(PlayerVipLevel, VipRepairLists, []),

            lists:foreach(
                fun(HeroId) ->
                    ?INFO("version ~p, playerid ~p, add heroid ~p,", [Version, PlayerId, HeroId]),
                    mod_hero:item_unlock_hero(PlayerId, HeroId)
                end,
                LevelRepairHeroList ++ VipRepairHeroList
            ),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION, Version);
        true ->
            noop
    end;
deal_player_version(PlayerId, Version = 2021102601) ->
    PlayerVersion = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION),
    if
        PlayerVersion < Version ->
            %% 主线任务全部过掉，进入赏金任务
            mod_function:version_repair(PlayerId, 2021102601),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION, Version);
        true ->
            noop
    end;
deal_player_version(PlayerId, Version = 2021110301) ->
    PlayerVersion = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION),
    if
        PlayerVersion < Version ->
            %% 主线任务全部过掉，进入赏金任务
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY, mod_player:get_player_data(PlayerId, level)),
            PlayerExpNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_EXP),
            mod_prop:decrease_player_prop(PlayerId, [{?ITEM_EXP, PlayerExpNum}], ?LOG_TYPE_UPDATE_VERSION_REPAIR1),
            mod_player:add_exp(PlayerId, max(PlayerExpNum, 1), ?LOG_TYPE_UPDATE_VERSION_REPAIR1),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_VERSION, Version);
        true ->
            noop
    end.