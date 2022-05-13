%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc    勇敢者（1v1）
%%% @end
%%% Created : 10. 3月 2021 下午 11:05:42
%%%-------------------------------------------------------------------
-module(mod_brave_one).
-author("Administrator").

%% API
-export([
    get_info_list/2,    % 获得当前信息列表
    create/3,           % 创建勇敢者房间数据
    enter/2,            % 进入房间
    clean/1             % 取消房间
]).

-export([
    enter_game_notice_brave_one_data/1,   % 进游戏通知勇者对战数据
    get_t_mission_brave_one/1,              % 勇敢者模板
    mission_balance/4   % 副本结算
%%    notice_player_enter_scene/2     % 通知其他玩家进入场景
]).

-include("error.hrl").
-include("gen/db.hrl").
-include("common.hrl").
-include("brave_one.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 获得当前信息列表
get_info_list(_PlayerId, Page) ->
    case brave_one_srv:call({?BRAVE_ONE_INFO_LIST, {Page, node()}}) of
        {ok, L} -> L;
        Result ->
            ?WARNING("get_info_list:~p~n", [Result]),
            []
    end.

%% 创建勇敢者房间数据
create(PlayerId, Id, PosId) ->
    #t_mission_brave_one{
        enter_conditions_list = EnterConditionsList,
        tips = BraveType,
        cost_list = ItemList
    } = get_t_mission_brave_one(Id),

    mod_prop:assert_prop_num(PlayerId, ItemList),
    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList) == true, ?ERROR_NOT_AUTHORITY),
    ServerId = mod_player:get_player_server_id(PlayerId),

    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, ItemList, ?LOG_TYPE_BRAVE_ONE_SYS),
            case brave_one_srv:call({?BRAVE_ONE_CREATE, {PlayerId, BraveType, Id, PosId, ServerId}}) of
                {ok, DbBraveOne} ->
                    {ok, DbBraveOne};
                Result ->
                    exit(Result)
            end
        end,
    db:do(Tran).

%% 进入房间
enter(PlayerId, CreatePlayerId) ->
    ?ASSERT(PlayerId =/= CreatePlayerId, ?ERROR_ALREADY_HAVE),

    DbBraveOne = mod_server_rpc:call_war(brave_one_srv_mod, get_db_brave_one, [CreatePlayerId]),
    ?ASSERT(is_record(DbBraveOne, db_brave_one), ?ERROR_NONE),
    #db_brave_one{
        id = Id,
        fight_player_id = FightPlayerId
    } = DbBraveOne,
    ?ASSERT(FightPlayerId == 0, ?ERROR_ALREADY_HAVE),
    #t_mission_brave_one{
        enter_conditions_list = EnterConditionsList,
        cost_list = ItemList
    } = get_t_mission_brave_one(Id),
    mod_prop:assert_prop_num(PlayerId, ItemList),
    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList) == true, ?ERROR_NOT_AUTHORITY),

    ServerId = mod_player:get_player_server_id(PlayerId),

    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),

    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, ItemList, ?LOG_TYPE_BRAVE_ONE_SYS),
            case brave_one_srv:call({?BRAVE_ONE_ENTER, {PlayerId, CreatePlayerId, ServerId, ModelHeadFigure}}) of
%%                {ok, #dict_brave_one_scene_data{sceneWorker = SceneWorker, missionType = MissionType, missionId = MissionId, sceneId = SceneId, x = X, y = Y, extraDataList = ExtraDataList}} ->
%%                    mod_scene:player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, null),
%%                    api_mission:notice_challenge_mission(PlayerId, MissionType, MissionId),
%%                    ok;
                {ok, DbBraveOneTuple} ->
                    {ok, DbBraveOneTuple};
                Result ->
                    exit(Result)
            end
        end,
    db:do(Tran).

%% 取消房间
clean(PlayerId) ->
    DbBraveOne = mod_server_rpc:call_war(brave_one_srv_mod, get_db_brave_one, [PlayerId]),
    case DbBraveOne of
        #db_brave_one{id = Id, fight_player_id = FightPlayerId} when FightPlayerId == 0 ->
            #t_mission_brave_one{
                cost_list = ItemList
            } = get_t_mission_brave_one(Id),
            mod_prop:assert_give(PlayerId, ItemList),

            Tran =
                fun() ->
                    mod_award:give(PlayerId, ItemList, ?LOG_TYPE_BRAVE_ONE_SYS),
                    case brave_one_srv:call({?BRAVE_ONE_CLEAN, PlayerId}) of
                        ok -> ok;
                        Result ->
                            exit(Result)
                    end
                end,
            db:do(Tran),
            ok;
        _ -> noop
    end.

%% 进游戏通知勇者对战数据
enter_game_notice_brave_one_data(PlayerId) ->
    mod_server_rpc:cast_war(brave_one_srv_mod, enter_game_notice_brave_one_data, [PlayerId]).

%% 通知其他玩家进入场景
%%notice_player_enter_scene(PlayerId, NoticeBraveOneTuple, #dict_brave_one_scene_data{sceneWorker = SceneWorker, missionType = MissionType, missionId = MissionId, sceneId = SceneId, x = X, y = Y, extraDataList = ExtraDataList}) ->
%%    mod_scene:player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, null),
%%    api_mission:notice_challenge_mission(PlayerId, MissionType, MissionId),

%% 副本结算 WinModelHeadFigure=null:没打
mission_balance(PlayerId, Id, WinPlayerId, WinModelHeadFigure) ->
    #t_mission_brave_one{
        cost_list = AwardList,
        win_list = WinAwardList
    } = get_t_mission_brave_one(Id),
    if
        WinModelHeadFigure == null ->
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_BRAVE_ONE_SYS);
        true ->
            if
                PlayerId == WinPlayerId -> mod_award:give(PlayerId, WinAwardList, ?LOG_TYPE_BRAVE_ONE_SYS);
                true -> noop
            end,
            api_brave_one:win_player(WinPlayerId, Id, WinModelHeadFigure)
    end.

%% ================================================ 模板操作 ================================================
%% 勇敢者模板
get_t_mission_brave_one(Id) ->
    t_mission_brave_one:get({Id}).

