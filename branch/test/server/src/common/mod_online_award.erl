%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc            在线奖励
%%% Created : 21. 三月 2018 20:20
%%%-------------------------------------------------------------------
-module(mod_online_award).
-author("home").

%% API
-export([
    get_online_award_info/1,        %% 在线奖励信息
    give_online_award/2,            %% 领取在线奖励
    notice_get_online_award/1,      %% 通知领取在线奖励
    notice_get_online_award/2
]).

-export([
    get_online_award_init/2,
    set_today_online_time/2,
    zero_reset_online_award/2,      %% 0点重置在线奖励
    init_time/1,                    %% 初始在线奖励时间
    get_online_time/1,
    open_action/1,
    close_action/1,
    login_operation_online_award/1
]).

-define(HAVE_PREROGATIVE, 2).           %% 有特权卡奖励倍数
-define(NOT_PREROGATIVE, 1).           %% 无特权卡奖励倍数
-define(NEWBATCH, 1).           %% 开启在线奖励批次

-include("msg.hrl").
-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 在线奖励信息
get_online_award_info(PlayerId) ->
    ActivityState = true,
%%    {ActivityState, _ActivityStartTime} = get_open_state_and_start_time(),
    List =
        if
            ActivityState ->
                lists:foldl(
                    fun(Id, L) ->
                        Init = get_online_award_init(PlayerId, Id),

                        if
                            Init#db_player_online_award.state == ?AWARD_ALREADY ->
                                [Id | L];
                            true ->
                                L
                        end
                    end, [], logic_get_online_award_day_list());
            true ->
                []
        end,
    Time = get_online_time(PlayerId),
    {List, Time}.

%% 领取在线奖励
give_online_award(PlayerId, Id) ->
%%    mod_activity:try_is_open(PlayerId, ?ACT_ONLINE_ACTIVITY),
%%    {ActivityState, _ActivityStartTime} = get_open_state_and_start_time(),
%%    ?ASSERT(ActivityState == true, ?ERROR_ACTIVITY_NO_OPEN),
    OnlineAwardInit = get_online_award_init(PlayerId, Id),
    State = OnlineAwardInit#db_player_online_award.state,
    OnlineTime = get_online_time(PlayerId),
    ?ASSERT(State =/= ?AWARD_ALREADY, ?ERROR_ALREADY_HAVE),
    ?ASSERT(State == ?AWARD_CAN, ?ERROR_NOT_AUTHORITY),
%%    T_Online = try_get_online_award(Id),
%%    AwardList = T_Online#t_online_award.award_list,
%%    Time = T_Online#t_online_award.time,
    #t_online_award{
        award_list = AwardList,
        time = Time
    } = try_get_online_award(Id),
    ?ASSERT(OnlineTime >= Time, ?ERROR_NOT_AUTHORITY),
%%    PrerogativeList = mod_prerogative_card:get_all_prerogative_card_id_list(PlayerId),
%%    Multiple = if
%%                   PrerogativeList =/= [] ->
%%                       ?HAVE_PREROGATIVE;
%%                   true ->
%%                       ?NOT_PREROGATIVE
%%               end,
    NewAwardList = mod_prop:rate_prop(AwardList, ?NOT_PREROGATIVE),
    mod_prop:assert_give(PlayerId, NewAwardList),
    Tran =
        fun() ->
            db:write(OnlineAwardInit#db_player_online_award{id = Id, state = ?AWARD_ALREADY, change_time = util_time:timestamp()}),
            mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_ONLINE_AWARD),
            ok
        end,
    db:do(Tran).

%% 通知领取在线奖励
notice_get_online_award(PlayerId) ->
    notice_get_online_award(PlayerId, logic_get_online_award_day_list()).

notice_get_online_award(PlayerId, [Id | L]) ->
    OnlineData = get_online_award_init(PlayerId, Id),
    case util_time:is_today(OnlineData#db_player_online_award.change_time) of
        true ->
            notice_get_online_award(PlayerId, L);
        _ ->
            Tran =
                fun() ->
                    db:write(OnlineData#db_player_online_award{state = ?AWARD_CAN, change_time = util_time:timestamp()})
                end,
            db:do(Tran),
            Id
    end.

%% 0点重置在线奖励
zero_reset_online_award(PlayerId, _) ->
    Time = util_time:milli_timestamp(),
    api_player:notice_server_time(PlayerId, Time),
    client_msg_handle:init_timer_type(PlayerId, ?MSG_CLIENT_ONLINE_AWARD).

%% 登入操作
login_operation_online_award(PlayerId) ->
%%    case mod_activity:is_open(?ACT_ONLINE_ACTIVITY) of
%%        true ->
            lists:foreach(
                fun(Id) ->
                    OnlineTime = get_online_time(PlayerId),
                    OnlineData = get_online_award_init(PlayerId, Id),
                    case util_time:is_today(OnlineData#db_player_online_award.change_time) of
                        true ->
                            ok;
                        _ ->
                            T_Online = try_get_online_award(Id),
                            NeedTime = T_Online#t_online_award.time,
                            if
                                OnlineTime >= NeedTime ->
                                    Tran =
                                        fun() ->
                                            db:write(OnlineData#db_player_online_award{state = ?AWARD_CAN, change_time = util_time:timestamp()})
                                        end,
                                    db:do(Tran);
                                true ->
                                    ok
                            end
                    end
                end, logic_get_online_award_day_list()),
            client_msg_handle:init_timer_type(PlayerId, ?MSG_CLIENT_ONLINE_AWARD).
%%        _ ->
%%            clean_time()
%%    end.


%% 初始在线奖励时间
init_time(PlayerId) ->
    Time = get_online_time(PlayerId),
    init_time(PlayerId, Time, logic_get_online_award_day_list()).

init_time(_PlayerId, _Time, []) ->
    -1;
init_time(PlayerId, Time, [Id | L]) ->
    OnlineAwardData = get_online_award_init(PlayerId, Id),
    T_Online = try_get_online_award(Id),
    case util_time:is_today(OnlineAwardData#db_player_online_award.change_time) of
        true ->
            init_time(PlayerId, Time, L);
        _ ->
            OnlineTime = T_Online#t_online_award.time,
            NewTime = (OnlineTime - Time) * ?SECOND_MS,
            NewTime
    end.

%% 获得玩家在线时长
get_online_time(PlayerId) ->
    OnlineData = get_online_info_init(PlayerId),
    CurrTime = util_time:timestamp(),
    LoginTime = mod_player:get_player_data(PlayerId, last_login_time),
    calc_online_time({OnlineData#db_player_online_info.record_online_timestamps, OnlineData#db_player_online_info.total_hours_online_today}, {CurrTime, LoginTime}).


%% 设置今天在线时间
set_today_online_time(PlayerId, {Now, LoginTime}) ->
    OnlineInit = get_online_info_init(PlayerId),
    Time = calc_online_time({OnlineInit#db_player_online_info.record_online_timestamps, OnlineInit#db_player_online_info.total_hours_online_today}, {Now, LoginTime}),
    Tran =
        fun() ->
            db:write(OnlineInit#db_player_online_info{total_hours_online_today = Time, record_online_timestamps = Now})
        end,
    db:do(Tran),
    ok.

%% 计算剩余时间
calc_online_time({RecordOnlineTimestamps, TotalHoursOnlineToday}, {Now, LoginTime}) ->
    case util_time:is_today(LoginTime) of
        true ->
            case util_time:is_today(RecordOnlineTimestamps) of
                true ->
                    TotalHoursOnlineToday + Now - LoginTime;
                _ ->
                    Now - LoginTime
            end;
        _ ->
            Now - util_time:get_today_zero_timestamp()
    end.

%%get_open_state_and_start_time() ->
%%    mod_activity:get_open_state_and_start_time(?ACT_ONLINE_ACTIVITY).

%% @fun 取消记时器
clean_time() ->
    util:update_timer_value(?MSG_CLIENT_ONLINE_AWARD).

%% 活动开启
open_action(ActivityId) ->
    case mod_activity:is_open(ActivityId) of
        true ->
            lists:foreach(
                fun(PlayerId) ->
                    lists:foreach(
                        fun(Id) ->
                            OnlineTime = get_online_time(PlayerId),
                            OnlineData = get_online_award_init(PlayerId, Id),
                            case util_time:is_today(OnlineData#db_player_online_award.change_time) of
                                true ->
                                    ok;
                                _ ->
                                    T_Online = try_get_online_award(Id),
                                    NeedTime = T_Online#t_online_award.time,
                                    if
                                        OnlineTime >= NeedTime ->
                                            Tran =
                                                fun() ->
                                                    db:write(OnlineData#db_player_online_award{state = ?AWARD_CAN, change_time = util_time:timestamp()})
                                                end,
                                            db:do(Tran);
                                        true ->
                                            ok
                                    end
                            end
                        end, logic_get_online_award_day_list()),
                    client_msg_handle:init_timer_type(PlayerId, ?MSG_CLIENT_ONLINE_AWARD)
                end, mod_online:get_all_online_player_id());
        _ ->
            noop
    end.

%% 活动关闭
close_action({Id, _}) ->
    lists:foreach(
        fun(_PlayerId) ->
            case mod_activity:is_open(Id) of
                false ->
                    clean_time();
                _ ->
                    noop
            end
        end, mod_online:get_all_online_player_id()).

%% ================================================ 数据操作 ================================================
%% 获得在线奖励数据
get_online_award(PlayerId, Id) ->
    db:read(#key_player_online_award{player_id = PlayerId, id = Id}).

%% 获得在线奖励数据     并初始化
get_online_award_init(PlayerId, Id) ->
    case get_online_award(PlayerId, Id) of
        OnlineAwardData when is_record(OnlineAwardData, db_player_online_award) ->
            case util_time:is_today(OnlineAwardData#db_player_online_award.change_time) of
                true ->
                    OnlineAwardData;
                _ ->
                    OnlineAwardData#db_player_online_award{state = ?AWARD_NONE}
            end;
        _ ->
            #db_player_online_award{player_id = PlayerId, id = Id}
    end.

%% 玩家在线数据
get_online_info_init(PlayerId) ->
    case db:read(#key_player_online_info{player_id = PlayerId}) of
        OnlineData when is_record(OnlineData, db_player_online_info) ->
            OnlineData;
        _ ->
            #db_player_online_info{player_id = PlayerId}
    end.

%% ================================================ 模板操作 ================================================
%% 获得在线模板
try_get_online_award(Id) ->
    T_Online = t_online_award:get({Id}),
    ?IF(is_record(T_Online, t_online_award), T_Online, exit({null_t_online_award, {Id}})).

logic_get_online_award_day_list() ->
    case logic_get_online_award_day_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.
