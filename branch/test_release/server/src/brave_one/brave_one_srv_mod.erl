%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc    勇敢者（1v1）进程处理数据
%%%
%%% @end
%%% Created : 10. 3月 2021 下午 11:20:38
%%%-------------------------------------------------------------------
-module(brave_one_srv_mod).
-author("Administrator").

%% API
-export([
    get_info_list_srv/1,   % 创建勇敢者房间数据
    create_srv/1,   % 创建勇敢者房间数据
    enter_srv/1,    % 进入房间
    clean_srv/1     % 取消房间
]).

-export([
    get_player_brave_one_data/1,    % 获得玩家勇敢者数据
    get_mission_worker/1,   % 获得副本进程
    get_db_brave_one/1,     % db勇敢者
    enter_game_notice_brave_one_data/1, % 进游戏通知勇者对战数据
    clean_brave_one_data/2  % 清理勇敢者（1v1）数据
]).

-include("error.hrl").
-include("gen/db.hrl").
-include("common.hrl").
-include("brave_one.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 获得玩家勇敢者数据
get_player_brave_one_data(PlayerId) ->
    case get_db_brave_one(PlayerId) of
        DbBraveOne when is_record(DbBraveOne, db_brave_one) ->
            DbBraveOne;
        _ ->
            case get_idx_db_brave_one_by_fightPlayerId(PlayerId) of
                [DbFightBraveOne] ->
                    DbFightBraveOne;
                _ ->
                    null
            end
    end.

%% 获得api数据打包结构
get_api_brave_one_data(CreatePlayerId) when is_integer(CreatePlayerId) ->
    get_player_brave_one_data(get_db_brave_one(CreatePlayerId));
get_api_brave_one_data(DbBraveOne) when is_record(DbBraveOne, db_brave_one) ->
    {DbBraveOne, call_player_game_head_figure(DbBraveOne#db_brave_one.player_id)};
get_api_brave_one_data({DbBraveOne, ModelFigure}) when is_record(DbBraveOne, db_brave_one) ->
    {DbBraveOne, ModelFigure};
get_api_brave_one_data(_) ->
    null.


%% 获得信息列表
get_info_list_srv({Page, _Node}) ->
    UpdateFun = fun() ->
        lists:foldl(
            fun(#db_brave_one{fight_player_id = FightPlayerId} = DbBraveOne, L) ->
                if
                    FightPlayerId == 0 ->
%%                        PlayerTuple =
%%                            case mod_player:get_game_node(PlayerId) == Node of
%%                                true ->
%%                                    {PlayerId, PosId, PlayerId};
%%                                _ ->
%%                        PlayerTuple = {PlayerId, PosId, call_player_game_head_figure(PlayerId)},
%%                            end,
                        [get_api_brave_one_data(DbBraveOne) | L];
                    true ->
                        L
                end
            end, [],
            util_list:rSortKeyList([{false, #db_brave_one.pos_id}, {false, #db_brave_one.change_time}], get_db_brave_one_by_BraveType(Page)))
                end,
    List = mod_cache:cache_data({?MODULE, get_info_list_srv}, UpdateFun, 1),
    {ok, List}.


%% 创建勇敢者房间数据
create_srv({PlayerId, BraveType, Id, PosId, ServerId}) ->
    ?ASSERT(get_db_brave_one(PlayerId) == null, ?ERROR_ALREADY_HAVE),
    ?ASSERT(get_idx_db_brave_one_by_fightPlayerId(PlayerId) == [], ?ERROR_ALREADY_HAVE), % 还在挑战中

    DbBraveOneInit = get_db_brave_one_init(PlayerId),
    Tran =
        fun() ->
            mod_player:update_player_server_data_init(PlayerId, mod_server_config:get_platform_id(), ServerId),
            NewDbBraveOne = db:write(DbBraveOneInit#db_brave_one{id = Id, brave_type = BraveType, pos_id = PosId, change_time = util_time:timestamp()}),
            {ok, NewDbBraveOne}
        end,
    db:do(Tran).

%% 进入房间
enter_srv({PlayerId, CreatePlayerId, ServerId, ModelFigure}) ->
    ?ASSERT(not is_record(get_db_brave_one(PlayerId), db_brave_one), ?ERROR_ALREADY_HAVE),
    DbBraveOne = get_db_brave_one(CreatePlayerId),
    ?ASSERT(is_record(DbBraveOne, db_brave_one), ?ERROR_NONE),
    ?ASSERT(DbBraveOne#db_brave_one.fight_player_id == 0, ?ERROR_ALREADY_HAVE),
    PlatformId = mod_server_config:get_platform_id(),
    StartTime = util_time:timestamp() + ?SD_GROUP_MISSION_WAIT_TIME,
    Tran =
        fun() ->
            mod_player:update_player_server_data_init(PlayerId, PlatformId, ServerId),
            NewDbBraveOne = db:write(DbBraveOne#db_brave_one{fight_player_id = PlayerId, start_time = StartTime}),
            Result = {ok, get_api_brave_one_data(NewDbBraveOne)},
%%            {ok, SceneTuple} = create_scene(PlayerId, CreatePlayerId),
            ok = create_scene(PlayerId, CreatePlayerId),
            ?TRY_CATCH(cast_game_player(CreatePlayerId, api_brave_one, notice_fight_scene, [CreatePlayerId, get_api_brave_one_data({NewDbBraveOne#db_brave_one{player_id = PlayerId, pos_id = 2}, ModelFigure})])),
            Result
        end,
    Result = db:do(Tran),
    Result.

%% 取消房间
clean_srv(PlayerId) ->
    DbBraveOne = get_db_brave_one(PlayerId),
    ?ASSERT(is_record(DbBraveOne, db_brave_one), ?ERROR_NONE),
    ?ASSERT(DbBraveOne#db_brave_one.fight_player_id == 0, ?ERROR_ALREADY_HAVE),
    Tran =
        fun() ->
            db:delete(DbBraveOne)
        end,
    db:do(Tran),
    ok.


%% 进游戏通知勇者对战数据
enter_game_notice_brave_one_data(PlayerId) ->
    DbBraveOne = get_player_brave_one_data(PlayerId),
    if
        DbBraveOne == null -> DbBraveOne;
        true ->
            ModelFigure =
                if
                    DbBraveOne#db_brave_one.fight_player_id > 0 ->
                        if
                            DbBraveOne#db_brave_one.fight_player_id == PlayerId ->
                                call_player_game_head_figure(DbBraveOne#db_brave_one.player_id);
                            true ->
                                call_player_game_head_figure(DbBraveOne#db_brave_one.fight_player_id)
                        end;
                    true ->
                        PlayerId
                end,
            ?TRY_CATCH(cast_game_player(PlayerId, api_brave_one, notice_fight_scene, [PlayerId, get_api_brave_one_data({DbBraveOne#db_brave_one{player_id = PlayerId, pos_id = 2}, ModelFigure})]))
    end.
%% 清理勇敢者（1v1）数据
clean_brave_one_data(CreatePlayer, FightPlayerId) ->
    DbBraveOne = get_db_brave_one(CreatePlayer),
    erase_mission_worker(CreatePlayer, FightPlayerId),
    case is_record(DbBraveOne, db_brave_one) of
        true ->
            Tran =
                fun() ->
                    db:delete(DbBraveOne)
                end,
            db:do(Tran);
        _ -> noop
    end.

%% 创建场景
create_scene(PlayerId, MainPlayerId) ->
    {_MissionType, MissionId, SceneId} = get_mission_tuple(),
    ExtraDataList = [{mission_id, MissionId}, {main_player_id, MainPlayerId}, {fight_player_id, PlayerId}],
    {ok, SceneWorker} = scene_master:get_scene_worker(SceneId, ExtraDataList),
    MonitorRef = erlang:monitor(process, SceneWorker),
    put({?BRAVE_ONE_MISSION_MONITOR_REF, MonitorRef}, #dict_brave_one{main_player_id = MainPlayerId, fight_player_id = PlayerId}),
    set_mission_worker(PlayerId, MainPlayerId, SceneWorker),
%%    {ok, #dict_brave_one_scene_data{sceneWorker = SceneWorker, missionType = MissionType, missionId = MissionId, sceneId = SceneId, x = 0, y = 0, extraDataList = ExtraDataList}}.
    ok.


%% 获得副本进程
get_mission_worker(PlayerId) ->
    case get({?BRAVE_ONE_MISSION_WORKER, PlayerId}) of
        ?UNDEFINED -> null;
        SceneWorker ->
            case util:is_pid_alive(SceneWorker) of
                true -> SceneWorker;
                _ -> null
            end
    end.

%% 设置副本进程
set_mission_worker(PlayerId, MainPlayerId, Worker) ->
    put({?BRAVE_ONE_MISSION_WORKER, PlayerId}, Worker),
    put({?BRAVE_ONE_MISSION_WORKER, MainPlayerId}, Worker).
%% 清理副本进程
erase_mission_worker(MainPlayerId, FightPlayerId) ->
    erase({?BRAVE_ONE_MISSION_WORKER, FightPlayerId}),
    erase({?BRAVE_ONE_MISSION_WORKER, MainPlayerId}).

%% 获得副本数据
get_mission_tuple() ->
    MissionType = ?MISSION_TYPE_BRAVE_ONE_SYS,
    MissionId = 1,
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    {MissionType, MissionId, SceneId}.

%% 游戏服获得玩家头像
call_player_game_head_figure(PlayerId) ->
    util:rpc_call(mod_player:get_game_node(PlayerId), api_player, pack_model_head_figure, [PlayerId]).

-spec cast_game_player(PlayerId, M, F, A) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()].
%% 通知玩家进程处理数据
cast_game_player(PlayerId, M, F, A) ->
    mod_apply:apply_to_online_player(mod_player:get_game_node(PlayerId), PlayerId, M, F, A, normal).

%% ================================================ 数据操作 ================================================
%% db 勇敢者（1v1）
get_db_brave_one(PlayerId) ->
    db:read(#key_brave_one{player_id = PlayerId}).
%% db 勇敢者（1v1） 初始化
get_db_brave_one_init(PlayerId) ->
    #db_brave_one{player_id = PlayerId, fight_player_id = 0}.

%% db 勇敢者（1v1)对手数据
get_idx_db_brave_one_by_fightPlayerId(PlayerId) ->
    db_index:get_rows(#idx_brave_one_1{fight_player_id = PlayerId}).
%% db 获得全部的勇敢者数据
get_db_brave_one_by_BraveType(BraveType) ->
    MatchSpec = [{#db_brave_one{brave_type = BraveType, _ = '_'}, [], ['$_']}],
    db:select(?BRAVE_ONE, MatchSpec).

%% db 获得全部的勇敢者数据
get_all_db_brave_one() ->
    ets:tab2list(?BRAVE_ONE).
%%    MatchSpec = [{#db_brave_one{_ = ''}, [], ['$_']}],
%%    db:select(?BRAVE_ONE, MatchSpec).
