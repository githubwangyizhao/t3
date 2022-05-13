%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		场景匹配服务
%%% @end
%%% Created : 13. 9月 2021 18:38
%%%-------------------------------------------------------------------
-module(match_scene_srv).
-author("yizhao.wang").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([
    match/2,
    unmatch/2,
    match_team_change/3,
    auto_player_leave_team/2
]).

-define(SERVER, ?MODULE).

-include("common.hrl").
-include("p_message.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/db.hrl").
-include("system.hrl").

-record(state, {}).

-record(?MODULE, {
    matching_map = #{}
}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

match(MatchId, PlayerId) ->
    CallNode =
        case mod_match_scene:get_server_type(MatchId) of
            ?SERVER_TYPE_WAR_AREA ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode};
            ?SERVER_TYPE_GAME ->
                ?MODULE
        end,
    gen_server:call(CallNode, {match, MatchId, PlayerId}, 3000).

unmatch(MatchId, PlayerId) ->
    CastNode =
        case mod_match_scene:get_server_type(MatchId) of
            ?SERVER_TYPE_WAR_AREA ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode};
            ?SERVER_TYPE_GAME ->
                ?MODULE
        end,
    gen_server:cast(CastNode, {unmatch, MatchId, PlayerId}).

%% 匹配人数变更
match_team_change(PlayerId, MatchId, PlayerCount) ->
    api_match_scene:notice_match_team_change(PlayerId, MatchId, PlayerCount).

%% 超时匹配失败
auto_player_leave_team(PlayerId, MatchId) ->
    api_match_scene:notice_match_fail(PlayerId, MatchId),
    mod_match_scene:reset_match_data().

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    try_everyday_balance(),
    {ok, #state{}}.

handle_call({match, MatchId, PlayerId}, _From, State) ->
    Reply =
        case t_mate:get({MatchId}) of
            #t_mate{lose = UnMatchTime, scene = MatchSceneId} ->
                case is_matching(MatchId, PlayerId) of
                    true ->
                        matching;
                    false ->
                        #t_scene{
                            max_player = MaxMatchPlayerCount
                        } = t_scene:assert_get({MatchSceneId}),
                        %% 匹配超时定时器
                        UnMatchTimerRef = erlang:start_timer(UnMatchTime, self(), {unmatch, MatchId, PlayerId}),
                        %% 加入匹配队伍
                        TeamPlayerCount = join_match_team(MatchId, PlayerId, UnMatchTimerRef, MaxMatchPlayerCount),
                        {ok, TeamPlayerCount}
                end;
            _ ->
                ?WARNING("~p Match failed, MatchId ~p not config!", [PlayerId, MatchId]),
                match_fail
        end,
    {reply, Reply, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({unmatch, MatchId, PlayerId}, State) ->
    case leave_match_team(MatchId, PlayerId) of
        true ->
            notice_match_team_change(MatchId);     %% 玩家主动离开
        false ->
            skip
    end,
    {noreply, State};

handle_cast({balance, Id, FirstData}, State) ->
    balance(Id, FirstData),
    {noreply, State};

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({everyday_balance, BalanceConfigTime}, State) ->
    Now = util_time:timestamp(),
    erlang:send_after((BalanceConfigTime - Now) * ?SECOND_MS, self(), {everyday_balance, BalanceConfigTime + ?DAY_S}),
    everyday_balance(BalanceConfigTime),
    {noreply, State};

handle_info({timeout, TimerRef, {unmatch, MatchId, PlayerId}}, State) ->
    case leave_match_team(MatchId, PlayerId, TimerRef) of
        true ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, match_scene_srv, auto_player_leave_team, [PlayerId, MatchId], normal),
            notice_match_team_change(MatchId);    %% 超时自动离开
        false ->
            skip
    end,
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% ----------------------------------
%% @doc 	是否正在匹配
%% @throws 	none
%% @end
%% ----------------------------------
is_matching(MatchId, PlayerId) ->
    case maps:find(MatchId, ?getModDict(matching_map)) of
        error ->
            false;
        {ok, MatchTeam} ->
            lists:keymember(PlayerId, 1, MatchTeam)
    end.

%% ----------------------------------
%% @doc 	加入匹配队伍
%% @throws 	none
%% @end
%% ----------------------------------
join_match_team(MatchId, PlayerId, UnMatchTimerRef, MaxMatchPlayerCount) ->
    OriMap = ?getModDict(matching_map),
    {IsNotice, NewMatchTeam} =
        case maps:find(MatchId, OriMap) of
            error ->    % 当前队伍为空
                {false, [{PlayerId, UnMatchTimerRef}]};
            {ok, OldMatchTeam} ->
                {true, [{PlayerId, UnMatchTimerRef} | OldMatchTeam]}
        end,
    ?setModDict(matching_map, maps:put(MatchId, NewMatchTeam, OriMap)),
    if
        IsNotice ->
            notice_match_team_change(MatchId, [PlayerId]);    %% 通知玩家加入
        true ->
            skip
    end,
    TeamPlayerCount = length(NewMatchTeam),
    case TeamPlayerCount >= MaxMatchPlayerCount of
        true -> %% 队伍匹配成功
            MatchPlayerIdList =
                [begin
                     erlang:cancel_timer(TimerRef),
                     TPlayerId
                 end || {TPlayerId, TimerRef} <- NewMatchTeam],
            match_scene:create_scene(MatchId, MatchPlayerIdList),
            ?setModDict(matching_map, maps:put(MatchId, [], OriMap));
        false ->
            skip
    end,
    TeamPlayerCount.

%% ----------------------------------
%% @doc 	离开匹配队伍
%% @throws 	none
%% @end
%% ----------------------------------
leave_match_team(MatchId, PlayerId) -> leave_match_team(MatchId, PlayerId, null).
leave_match_team(MatchId, PlayerId, UnMatchTimerRef) ->
    OriMap = ?getModDict(matching_map),
    case maps:find(MatchId, OriMap) of
        error ->
            false;
        {ok, MatchTeam} ->
            case lists:keytake(PlayerId, 1, MatchTeam) of
                {value, {PlayerId, TimerRef}, LeftMatchTeam} when UnMatchTimerRef =:= null ->    %% 主动退出
                    erlang:cancel_timer(TimerRef),
                    ?setModDict(matching_map, maps:put(MatchId, LeftMatchTeam, OriMap)),
                    true;
                {value, {PlayerId, TimerRef}, LeftMatchTeam} when TimerRef =:= UnMatchTimerRef ->    %% 超时自动退出
                    ?setModDict(matching_map, maps:put(MatchId, LeftMatchTeam, OriMap)),
                    true;
                false ->
                    false
            end
    end.

%% ----------------------------------
%% @doc 	通知匹配队伍变更
%% @throws 	none
%% @end
%% ----------------------------------
notice_match_team_change(MatchId) -> notice_match_team_change(MatchId, []).
notice_match_team_change(MatchId, ExcludePlayerIdList) ->
    MatchTeam = maps:get(MatchId, ?getModDict(matching_map)),
    PlayerCount = length(MatchTeam),
    if
        PlayerCount =:= 0 -> skip;
        true ->
            Func =
                fun({PlayerId, _}) ->
                    case lists:member(PlayerId, ExcludePlayerIdList) of
                        true -> skip;
                        false ->
                            Node = mod_player:get_game_node(PlayerId),
                            mod_apply:apply_to_online_player(Node, PlayerId, match_scene_srv, match_team_change, [PlayerId, MatchId, PlayerCount], normal)
                    end
                end,
            lists:foreach(Func, MatchTeam)
    end.

%% ----------------------------------
%% @doc 	尝试每日结算
%% @throws 	none
%% @end
%% ----------------------------------
try_everyday_balance() ->
    LastBalanceTime = mod_server_data:get_int_data(?SERVER_DATA_MATCH_SCENE_LAST_BALANCE_TIME),
    Now = util_time:timestamp(),
    TodayBalanceConfigTime = util_time:get_today_timestamp(list_to_tuple(?SD_SETTLE_ACCOUNTS)),
    LastBalanceConfigTime =
        if
            Now >= TodayBalanceConfigTime ->
                TodayBalanceConfigTime;
            true ->
                TodayBalanceConfigTime - ?DAY_S
        end,
    if
        LastBalanceTime < LastBalanceConfigTime ->
            everyday_balance(LastBalanceTime);
        true ->
            noop
    end,
    NextBalanceConfigTime = LastBalanceConfigTime + ?DAY_S,
    erlang:send_after((NextBalanceConfigTime - Now) * ?SECOND_MS, self(), {everyday_balance, NextBalanceConfigTime}).

%% ----------------------------------
%% @doc 	每日结算
%% @throws 	none
%% @end
%% ----------------------------------
everyday_balance(BalanceTime) ->
    Tran =
        fun() ->
            mod_server_data:set_int_data(?SERVER_DATA_MATCH_SCENE_LAST_BALANCE_TIME, BalanceTime),
            lists:foreach(
                fun({Id}) ->
                    case mod_match_scene:get_db_match_scene_data(Id) of
                        null ->
                            noop;
                        #db_match_scene_data{player_id = 0, score = 0, award = 0} ->
                            noop;
                        DbMatchSceneData ->
                            #db_match_scene_data{
                                player_id = PlayerId,
                                score = Score,
                                award = Award
                            } = DbMatchSceneData,
                            case lists:member(0, [PlayerId, Score, Award]) of
                                true ->
                                    db:delete(DbMatchSceneData);
                                false ->
                                    db:delete(DbMatchSceneData),
                                    #t_mate{
                                        scene = SceneId,
                                        award_item_id = AwardItemId
                                    } = t_mate:assert_get({Id}),
%%                                    #db_player{
%%                                        nickname = Nickname
%%                                    } = mod_player:get_player(PlayerId),
%%                                    Args = [Nickname, SceneId, Award],
%%                                    Fun =
%%                                        fun(Out) ->
%%                                            PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
%%                                            mod_socket:send_to_player_list(PlayerIdList, Out)
%%                                        end,
%%                                    api_chat:notice_system_template_message(?NOTICE_PIPIECHANG, [util:to_binary(NoticeContent) || NoticeContent <- Args], 5, Fun),
                                    Node = mod_player:get_game_node(PlayerId),
                                    mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_RANKING_AWARD, [{AwardItemId, Award}], [SceneId, Award], ?LOG_TYPE_MATCH_SCENE_RANK], game_worker)
%%                                    mod_mail:add_mail_param_item_list(PlayerId, ?MAIL_RANKING_AWARD, [{AwardItemId, Award}], [SceneId, Award], ?LOG_TYPE_MATCH_SCENE_RANK)
                            end
                    end
                end, t_mate:get_keys()
            )
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	单局结算
%% @throws 	none
%% @end
%% ----------------------------------
balance(Id, FirstData) ->
    DbMatchSceneData = mod_match_scene:get_db_match_scene_data_init(Id),
    {1, PlayerId, Score, _ZiDan, _} = FirstData,
    #db_match_scene_data{
        score = OldScore,
        award = Award
    } = DbMatchSceneData,
    #t_mate{
        mate_reward = MateReward
    } = match_scene:get_t_mate(Id),
    NewDbMatchSceneData =
        if
            Score > OldScore ->
                DbMatchSceneData#db_match_scene_data{player_id = PlayerId, score = Score, award = Award + MateReward};
            true ->
                DbMatchSceneData#db_match_scene_data{award = Award + MateReward}
        end,
    Tran =
        fun() ->
            db:write(NewDbMatchSceneData)
        end,
    db:do(Tran),
    ok.