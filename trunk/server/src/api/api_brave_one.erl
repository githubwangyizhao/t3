%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 3月 2021 下午 04:13:43
%%%-------------------------------------------------------------------
-module(api_brave_one).
-author("Administrator").

%% API
-export([
    get_info_list/2,    % 获得当前信息列表
    create/2,           % 创建勇敢者房间数据
    enter/2,            % 创建勇敢者房间数据
    clean/2,            % 取消房间
    notice_fight_scene/2,   % 通知对手准备进入场景
    wait_scene/2,       % 等待其他玩家进入最后时间
    ready_start/2,      % 准备开始时间
    fight_player/3,     % 当前可以打的玩家
    win_player/3        % 赢的玩家数据
]).


-include("gen/db.hrl").
-include("common.hrl").
-include("p_message.hrl").

%% 获得当前信息列表
get_info_list(#m_brave_one_get_info_list_tos{page = Page},
    State = #conn{player_id = PlayerId}) ->
    List = mod_brave_one:get_info_list(PlayerId, Page),
    Out = proto:encode(#m_brave_one_get_info_list_toc{braveOneDataList = pack_brave_one_list(List), page = Page}),
    mod_socket:send(Out),
    State.

%% 创建勇敢者房间数据
create(#m_brave_one_create_tos{id = Id, pos_id = PosId},
    State = #conn{player_id = PlayerId}) ->
    {Result, DbBraveOneTuple} =
        case ?TRY_CATCH2(mod_brave_one:create(PlayerId, Id, PosId)) of
            {ok, DbBraveOne1} ->
                {ok, {DbBraveOne1, PlayerId}};
            Error ->
                {Error, null}
        end,
    Out = proto:encode(#m_brave_one_create_toc{result = api_common:api_result_to_enum(Result), id = Id, braveOneData = pack_brave_one(DbBraveOneTuple)}),
    mod_socket:send(Out),
    State.

%% 进入勇敢者房间数据
enter(#m_brave_one_enter_tos{realId = RealId},
    State = #conn{player_id = PlayerId}) ->
    {Result, DbBraveOneTuple} =
        case ?TRY_CATCH2(mod_brave_one:enter(PlayerId, RealId)) of
            {ok, DbBraveOneTuple1} ->
                {ok, DbBraveOneTuple1};
            Error ->
                {Error, null}
        end,
    Out = proto:encode(#m_brave_one_enter_toc{result = api_common:api_result_to_enum(Result), realId = RealId, braveOneData = pack_brave_one(DbBraveOneTuple)}),
    mod_socket:send(Out),
    State.

%% 取消房间
clean(#m_brave_one_clean_tos{},
    State = #conn{player_id = PlayerId}) ->
    Result = ?TRY_CATCH2(mod_brave_one:clean(PlayerId)),
    Out = proto:encode(#m_brave_one_clean_toc{result = api_common:api_result_to_enum(Result)}),
    mod_socket:send(Out),
    State.

%% 通知对手准备进入场景
notice_fight_scene(PlayerId, NoticeBraveOneTuple) ->
    Out = proto:encode(#m_brave_one_notice_fight_scene_toc{braveOneData = pack_brave_one(NoticeBraveOneTuple)}),
    mod_socket:send(PlayerId, Out).

%% 等待其他玩家进入最后时间
wait_scene(PlayerId, WaitEndTime) ->
    Out = proto:encode(#m_brave_one_wait_scene_toc{wait_end_time = WaitEndTime}),
    mod_socket:send(PlayerId, Out).

%% 准备开始时间
ready_start(PlayerId, FightEndTime) ->
    Out = proto:encode(#m_brave_one_ready_start_toc{start_time = FightEndTime}),
    mod_socket:send(PlayerId, Out).

%% 当前可以打的玩家
fight_player(PlayerId, FightPlayerId, FightEndTime) ->
    Out = proto:encode(#m_brave_one_fight_player_toc{player_id = FightPlayerId, end_fight_time = FightEndTime}),
    mod_socket:send(PlayerId, Out).
%% 赢的玩家数据
win_player(PlayerId, Id, PlayerTuple) ->
    Out = proto:encode(#m_brave_one_win_player_toc{id = Id, modelHeadFigure = api_player:pack_model_head_figure(PlayerTuple)}),
    mod_socket:send(PlayerId, Out).

%% pack打包勇敢者数据列表
pack_brave_one_list(List) ->
    [pack_brave_one(Tuple) || Tuple <- List].
%% pack打包勇敢者数据
pack_brave_one({#db_brave_one{player_id = PlayerId, id = Id, pos_id = PosId, start_time = StartTime}, PlayerTuple}) ->
    #braveonedata{realId = PlayerId, id = Id, pos_id = PosId, start_time = StartTime, modelHeadFigure = api_player:pack_model_head_figure(PlayerTuple)};
pack_brave_one({PlayerId, Id, PosId, StartTime, PlayerTuple}) ->
    #braveonedata{realId = PlayerId, id = Id, pos_id = PosId, start_time = StartTime, modelHeadFigure = api_player:pack_model_head_figure(PlayerTuple)};
pack_brave_one(_) ->
    ?UNDEFINED.

