%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    平台功能
%%% Created : 15. 六月 2018 17:51
%%%-------------------------------------------------------------------
-module(mod_platform_function).
-author("home").

%% API
-export([
%%    share/1,
%%    get_share_friend_give/2
%%    get_platfrom_fun_reward_give/2
]).

-export([
%%    get_app_friends_list/1,     % 获得玩家平台好友列表
    get_platform_friends_list/1,% 获得平台好友openId的列表
    get_collect_game_state/1,   % 获得收藏游戏状态
    get_share_count/1,          % 分享次数
    get_player_send_gamebar_msg_id/2, % 获得消息已上报的消息id
    db_writer_player_send_gamebar_msg/4, % 写入消息上报数据
%%    conditions_send_gamebar_msg/3,
%%    try_get_platform_conditions_send_data/1,
    get_share_friend_list/1,
    get_init_fun/1,             % 获取初始时 平台功能领取数据
%%    get_platform_concern_award/1,       %% 领取平台关注礼包
    get_concern_award_state/1,          %% 获得平台关注礼包状态
%%    get_platform_certification_award/1, %% 领取平台认证礼包
    get_certification_award_state/1     %% 获得平台认证礼包状态
]).

-export([
    get_invite_friend_task_info/2,  %% 获得邀请好友任务信息
    add_share/3,                    %% 增加被邀请者条件数
    invite_friend/3,                %% 邀请好友
    invite_friend/5,                %% 邀请好友
    get_share_task_award/3,         %% 领取分享任务奖励
    add_player_share/3,             %% 增加邀请者数据


    get_player_share_task_init/2,
    get_player_share_task_award/3
]).

%% 修复内容
-export([
    repair_invite_friend_task/1
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

-define(PLATFORM_FRIENDS_REQUEST_TIME, ?HOUR_S).  % 请求好友的间隔时间s

-define(PLAYER_TYPE, 2).

%% @doc     分享
%%share(PlayerId) ->
%%    PlayerShareInit = get_player_share_init(PlayerId),
%%    #db_player_share{
%%        count = OldCount
%%    } = PlayerShareInit,
%%    [DayCountLimit, ItemType, ItemId, ItemNum] = ?SD_SHARE_REWARD,
%%    NewCount = OldCount + 1,
%%    AllShareTimes = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_SHARE_TIMES_DATA),
%%    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_SHARE_TIMES_DATA, AllShareTimes + 1),
%%    ?ASSERT(DayCountLimit >= NewCount, ?ERROR_TIMES_LIMIT),
%%
%%    ItemList = [{ItemType, ItemId, ItemNum}],
%%    CurrTime = util_time:timestamp(),
%%    Tran =
%%        fun() ->
%%            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_SHARE_FRIEND_AWARD),
%%            db:write(PlayerShareInit#db_player_share{count = NewCount, change_time = CurrTime}),
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SHARE_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
%%            if
%%                DayCountLimit == NewCount ->
%%                    mod_charge:update_is_open_charge(PlayerId);
%%                true ->
%%                    noop
%%            end
%%%%            lists:foreach(
%%%%                fun(ShareFriendId) ->
%%%%                    PlayerShareFriendInit = get_player_share_friend_init(PlayerId, ShareFriendId),
%%%%                    db:write(PlayerShareFriendInit#db_player_share_friend{state = ?AWARD_CAN, change_time = CurrTime}),
%%%%                    api_platform_function:api_notice_share_friend(PlayerId, ShareFriendId, ?AWARD_CAN)
%%%%                end, IdList)
%%        end,
%%    db:do(Tran),
%%    ok.

%% @doc     领取好友邀请奖励
%%get_share_friend_give(PlayerId, Id) ->
%%%%    {PlayerId, Id}.
%%    PlayerShareFriend = get_player_share_friend(PlayerId, Id),
%%    ?ASSERT(is_record(PlayerShareFriend, db_player_share_friend), ?ERROR_NOT_AUTHORITY),
%%    ?ASSERT(PlayerShareFriend#db_player_share_friend.state =/= ?AWARD_ALREADY, ?ERROR_ALREADY_HAVE),
%%    AwardId =
%%        case util_list:key_find(Id, 1, ?SD_INVITE_REWARD) of
%%            [Id, AwardId1] ->
%%                AwardId1;
%%            _ ->
%%                exit(?ERROR_NOT_AUTHORITY)
%%        end,
%%    ItemList = mod_award:decode_award(AwardId),
%%    mod_prop:assert_give(PlayerId, ItemList),           %检查物品格子
%%    Tran =
%%        fun() ->
%%            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_SHARE_FRIEND_AWARD),
%%            db:write(PlayerShareFriend#db_player_share_friend{state = ?AWARD_ALREADY}),
%%            api_platform_function:api_notice_share_friend(PlayerId, Id, ?AWARD_ALREADY)
%%        end,
%%    db:do(Tran),
%%    ok.

%% @fun 获得收藏游戏状态
get_collect_game_state(PlayerId) ->
    mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_COLLECT_STATE).

%% @fun 分享次数
get_share_count(PlayerId) ->
    PlayerShareInit = get_player_share_init(PlayerId),
    PlayerShareInit#db_player_share.count.

%% @fun 获得好友邀请奖励列表
get_share_friend_list(_PlayerId) ->
    [].
%%    List =
%%        lists:foldl(
%%            fun([Id, _], L) ->
%%                case get_player_share_friend(PlayerId, Id) of
%%                    #db_player_share_friend{state = State} ->
%%                        [{Id, State} | L];
%%                    _ ->
%%                        L
%%                end
%%            end, [], ?SD_INVITE_REWARD),
%%    api_platform_function:pack_share_friend(List).

%% @fun 获得平台好友openId的列表
get_platform_friends_list(PlayerId) ->
    Ets = get_ets_platform_friends_data(PlayerId),
    Ets#ets_platform_friends_data.friends_openid_list.

%% @fun 获得消息已上报的消息id
get_player_send_gamebar_msg_id(PlayerId, Type) ->
    #db_player_send_gamebar_msg{
        msg_id = MsgId
    } = get_player_send_gamebar_msg_init(PlayerId, Type),
    MsgId.
%% @fun 写入消息上报数据
db_writer_player_send_gamebar_msg(PlayerId, Type, NewMsgId, CurrTime) ->
    PlayerSendMsgInit = get_player_send_gamebar_msg_init(PlayerId, Type),
    db:write(PlayerSendMsgInit#db_player_send_gamebar_msg{msg_id = NewMsgId, change_time = CurrTime}).

%%--------------------------------------------------- 任务

%% 获得邀请好友任务信息
get_invite_friend_task_info(PlayerId, PlayerShowType) ->
    lists:foldl(
        fun(TaskType, L) ->
            #t_share_task_type{
                show_type = ShowType
            } = try_get_t_share_task_type(TaskType),
            #db_player_share_task{
                value = Value
            } = get_player_share_task_init(PlayerId, TaskType),
            if
                ShowType == PlayerShowType ->
                    NewL =
                        lists:foldl(
                            fun({TaskId, _NeedValue}, List) ->
                                TaskAward = get_player_share_task_award_init(PlayerId, TaskType, TaskId),
                                [{TaskAward, Value} | List]
                            end, [], logic_get_share_type_task_id(TaskType)
                        ),
                    NewL ++ L;
                true ->
                    L
            end
        end, [], logic_get_invite_task_type_list()
    ).
%%            NewL =
%%                lists:foldl(
%%                    fun({TaskId, _NeedValue}, List) ->
%%                        TaskAward = get_player_share_task_award_init(PlayerId, TaskType, TaskId),
%%                        [{TaskAward, Value} | List]
%%                    end, [], logic_get_share_type_task_id(TaskType)
%%                ),
%%%%                if
%%%%                    TaskType == ?SHARE_SHARE_TASK ->
%%%%                        [{get_player_share_task_award_init(PlayerId, TaskType, TaskId), Value} || {TaskId, _NeedValue} <- TaskList];
%%
%%%%                    true ->
%%%%                        get_invite_friend_task(TaskList, PlayerId, TaskType, Value, [])
%%%%                end,
%%            NewL ++ L


%%get_invite_friend_task([], _PlayerId, _TaskType, _Value, List) ->
%%    List;
%%get_invite_friend_task([{TaskId, _NeedValue} | TaskList], PlayerId, TaskType, Value, List) ->
%%    TaskAward = get_player_share_task_award_init(PlayerId, TaskType, TaskId),
%%    State = TaskAward#db_player_share_task_award.state,
%%    if
%%        TaskType == ?SHARE_SHARE_TASK ->
%%            NewList = [{TaskAward, Value} | List],
%%            get_invite_friend_task(TaskList, PlayerId, TaskType, Value, NewList);
%%        true ->
%%            if
%%                State == ?AWARD_ALREADY ->
%%                    get_invite_friend_task(TaskList, PlayerId, TaskType, Value, [{TaskAward, Value}]);
%%                true ->
%%                    [{TaskAward, Value}]
%%            end
%%    end.


%% 领取分享任务奖励
get_share_task_award(PlayerId, TaskType, TaskId) ->
    ShareData = get_player_share_task_award(PlayerId, TaskType, TaskId),
    ?ASSERT(is_record(ShareData, db_player_share_task_award), ?ERROR_NOT_EXISTS),
    State = ShareData#db_player_share_task_award.state,
    ?ASSERT(State =/= ?AWARD_NONE, ?ERROR_NOT_AUTHORITY),
    ?ASSERT(State == ?AWARD_CAN, ?ERROR_ALREADY_HAVE),
    #t_share_task{
        item_list = ItemList
    } = try_get_t_share_task(TaskType, TaskId),
    mod_prop:assert_give(PlayerId, ItemList),
%%    TaskIdList = logic_get_share_type_task_id(TaskType),
    #db_player_share_task{
        value = Value
    } = get_player_share_task_init(PlayerId, TaskType),
%%    NextTaskId = TaskId + 1,
    Tran =
        fun() ->
            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_SHARE_TASK_AWARD),
            NewShareData = db:write(ShareData#db_player_share_task_award{state = ?AWARD_ALREADY}),
%%            ShareTaskData =
%%                if
%%                    TaskType == ?SHARE_SHARE_TASK ->
%%                        NewShareData;
%%                    true ->
%%                        case lists:keymember(NextTaskId, 1, TaskIdList) of
%%                            true ->
%%                                get_player_share_task_award_init(PlayerId, TaskType, NextTaskId);
%%                            _ ->
%%                                NewShareData
%%                        end
%%                end,
            {ok, NewShareData, Value}
        end,
    db:do(Tran).

%% 增加被邀请者条件数
add_share(PlayerId, TaskTypeList, Value) ->
    ShareType = mod_share:get_share_type(PlayerId),
    {ShareTaskList, NewTaskTypeList} =
        lists:foldl(
            fun(TaskType, {L1, L2}) ->
                #t_share_task_type{
                    type = Type,
                    approach_list = ConditionList,
                    activity_id = ActivityId
                } = try_get_t_share_task_type(TaskType),
                [_, NeedValue] = ConditionList,
                if
                    Type == ?TRUE ->
                        calc_be_share(PlayerId, TaskType, Value, NeedValue, {L1, L2});
                    true ->
                        IsOpen = activity:is_open(ActivityId),
                        if
                            IsOpen == true andalso Type == ShareType ->
                                calc_be_share(PlayerId, TaskType, Value, NeedValue, {L1, L2});
                            true ->
                                {L1, L2}
                        end
                end
%%                [_, NeedValue] = ConditionList,
%%                if
%%                    Value >= NeedValue ->
%%                        ShareTaskData = get_player_share_task_init(PlayerId, TaskType),
%%                        State = ShareTaskData#db_player_share_task.state,
%%                        if
%%                            State == ?FALSE ->
%%                                {[ShareTaskData#db_player_share_task{state = ?TRUE} | L1], [TaskType | L2]};
%%                            true ->
%%                                {L1, L2}
%%                        end;
%%                    true ->
%%                        {L1, L2}
%%                end
            end, {[], []}, TaskTypeList
        ),
%%    ?DEBUG("增加被邀请者条件数~p~n", [NewTaskTypeList]),
    if
        NewTaskTypeList == [] -> noop;
        true -> mod_share:finish_conditions(PlayerId, NewTaskTypeList)
    end,
    Tran =
        fun() ->
            [db:write(TaskData) || TaskData <- ShareTaskList],
            ok
        end,
    db:do(Tran).

calc_be_share(PlayerId, TaskType, Value, NeedValue, {L1, L2}) ->
    if
        Value >= NeedValue ->
            ShareTaskData = get_player_share_task_init(PlayerId, TaskType),
            State = ShareTaskData#db_player_share_task.state,
            if
                State == ?FALSE ->
                    {[ShareTaskData#db_player_share_task{state = ?TRUE} | L1], [TaskType | L2]};
                true ->
                    {L1, L2}
            end;
        true ->
            {L1, L2}
    end.

%% 邀请好友
invite_friend(PlayerId, BeInviteAccId, ShareType) ->
    invite_friend(PlayerId, BeInviteAccId, ShareType, "", 0).
invite_friend(PlayerId, BeInviteAccId, ShareType, ShareServerId, SharePlayerId) ->
    PlayerAccId = mod_player:get_player_data(PlayerId, acc_id),
    PlatformId = mod_server_config:get_platform_id(),
%%    LastShareTime = ?TRY_CATCH(mod_account_share:get_last_share_time(PlatformId, BeInviteAccId)),
    Time = util_time:timestamp(),
    if
        PlayerAccId == BeInviteAccId
%%            orelse Time =< (?SD_SHARE_TIME * 86400 + LastShareTime)
            ->
            noop;
        true ->
            AccData = get_player_invite_friend(BeInviteAccId, PlayerId),
            case is_record(AccData, db_player_invite_friend) of
                true ->
                    noop;
                _ ->
                    InviteTaskList =
                        lists:foldl(
                            fun(TaskTypeId, L) ->
                                #t_share_task_type{
                                    type = Type,
                                    activity_id = ActivityId
                                } = try_get_t_share_task_type(TaskTypeId),
                                if
                                    Type == ?TRUE ->
                                        [TaskTypeId | L];
                                    true ->
                                        IsOpen = activity:is_open(ActivityId),
                                        if
                                            IsOpen == true ->
                                                ?INFO("邀请好友1: ~p~n", [{ActivityId, Type, ShareType}]),
                                                [TaskTypeId | L];
                                            true ->
                                                L
                                        end
                                end
                            end, [], logic_get_share_id_list()
                        ),
                    ?INFO("邀请好友2: ~p~n", [InviteTaskList]),
                    NewAccData = get_player_invite_friend_init(BeInviteAccId, PlayerId),
                    InviteLogData = get_player_invite_friend_log_init(PlayerId, BeInviteAccId),
                    Tran =
                        fun() ->
                            db:write(NewAccData),
                            db:write(InviteLogData#db_player_invite_friend_log{type = ShareType, server_id = ShareServerId, share_player_id = SharePlayerId, change_time = Time}),
                            add_player_share(PlayerId, InviteTaskList, BeInviteAccId),
                            ?TRY_CATCH(mod_account_share:finish_share(PlatformId, BeInviteAccId)),
                            ok
                        end,
                    db:do(Tran)
%%            end
            end
    end.

%% 增加邀请者数据
add_player_share(PlayerId, TaskTypeList, AccId) ->
    CacheKeyShare = {?MODULE, add_player_share, PlayerId},
    ExpireTime = util_time:get_next_date_h_timestamp(0) - util_time:timestamp(),
    {NewShareTaskList, NewTaskAwardList, NewFinishDataList} =
        lists:foldl(
            fun(TaskTypeId, {ShareTaskList, TaskAwardList, FinishDataList}) ->
                PlayerFinishData = get_player_finish_share_task_init(AccId, TaskTypeId, PlayerId),
                if
                    PlayerFinishData#db_player_finish_share_task.state == ?TRUE ->
                        {ShareTaskList, TaskAwardList, FinishDataList};
                    true ->
                        DayShareCount = mod_cache:get(CacheKeyShare, 0) + 1,
                        if
                            DayShareCount =< 10 ->
                                mod_cache:update(CacheKeyShare, DayShareCount, ExpireTime),
                                ?INFO("今日邀请邀请人数：~p~n", [{PlayerId, DayShareCount}]),
                                PlayerData = get_player_share_task_init(PlayerId, TaskTypeId),
                                Value = PlayerData#db_player_share_task.value + 1,
                                ?INFO("增加邀请者数据: ~p~n", [{PlayerId, TaskTypeId, Value}]),
                                TaskIdList = [TaskId || {TaskId, NeedNum} <- logic_get_share_type_task_id(TaskTypeId), Value >= NeedNum],
                                AwardDataList =
                                    lists:foldl(
                                        fun(TaskId1, L1) ->
                                            AwardData = get_player_share_task_award_init(PlayerId, TaskTypeId, TaskId1),
                                            AwardState = AwardData#db_player_share_task_award.state,
                                            if
                                                AwardState == ?AWARD_NONE ->
                                                    [AwardData#db_player_share_task_award{state = ?AWARD_CAN} | L1];
                                                true ->
                                                    L1
                                            end
                                        end, [], TaskIdList),
                                {[PlayerData#db_player_share_task{value = Value} | ShareTaskList], AwardDataList ++ TaskAwardList, [PlayerFinishData#db_player_finish_share_task{state = ?TRUE} | FinishDataList]};
                            true -> {ShareTaskList, TaskAwardList, FinishDataList}
                        end
                end
            end, {[], [], []}, TaskTypeList
        ),
    Tran =
        fun() ->
            [db:write(ShareTask) || ShareTask <- NewShareTaskList],
            [db:write(TaskAward) || TaskAward <- NewTaskAwardList],
            [db:write(FinishData) || FinishData <- NewFinishDataList],
            ShareTaskDataList =
                lists:foldl(
                    fun(TaskType1, List) ->
                        #db_player_share_task{
                            value = Value1
                        } = get_player_share_task_init(PlayerId, TaskType1),
                        NewList = [{get_player_share_task_award_init(PlayerId, TaskType1, TaskId), Value1} || {TaskId, _NeedValue} <- logic_get_share_type_task_id(TaskType1)],
%%                            lists:foldl(
%%                                fun({TaskId, _NeedValue}, List) ->
%%                                    TaskAward = get_player_share_task_award_init(PlayerId, TaskType1, TaskId),
%%                                    [{TaskAward, Value1} | List]
%%                                end, [], logic_get_share_type_task_id(TaskType1)
%%                            ),
                        NewList ++ List
                    end, [], TaskTypeList),
            if
                ShareTaskDataList == [] ->
                    noop;
                true ->
                    api_platform_function:notice_share_task(PlayerId, ShareTaskDataList)
            end,
            ok
        end,
    db:do(Tran).

%%%% @fun 领取平台功能奖励
%%get_platfrom_fun_reward_give(PlayerId, FunId) ->
%%    #t_platform_function_reward{
%%        award_item_list = AwardItemList,        %% 奖励列表
%%        mail_id = MailId,                       %% 邮件id:大于0才生效
%%        init_award = InitAward,                 %% 初始领取
%%        log_type = LogType                      %% 日志类型:log_type
%%    } = try_get_t_platform_function_reward(FunId),
%%    mod_prop:try_t_log_type(LogType),
%%    PlayerRewardInit = get_player_platform_fun_reward_init(PlayerId, FunId),
%%    State = PlayerRewardInit#db_player_platform_fun_reward.state,
%%    ?ASSERT(State =/= ?AWARD_ALREADY, ?ERROR_ALREADY_HAVE),
%%    case FunId of
%%%%        ?FUNCTION_PLATFORM_COVER ->
%%%%            case mod_server_config:get_platform_id() of
%%%%                ?PLATFORM_QQ ->
%%%%                    {ok, IsUsed} = qq:judge_cover_type(PlayerId),
%%%%                    ?ASSERT(IsUsed == true, ?ERROR_NONE);
%%%%                ?PLATFORM_LOCAL ->
%%%%                    noop;
%%%%                ErrorPlatformId ->
%%%%                    ?ERROR("领取平台功能奖励:~p~n", [ErrorPlatformId]),
%%%%                    exit(?ERROR_FAIL)
%%%%            end,
%%%%            ok;
%%        _ ->
%%            ?ASSERT(State == ?AWARD_CAN orelse State == ?AWARD_NONE andalso InitAward == ?TRUE, ?ERROR_NOT_AUTHORITY)
%%    end,
%%    if
%%        MailId > 0 ->
%%            noop;
%%        true ->
%%            mod_prop:assert_give(PlayerId, AwardItemList)
%%    end,
%%    Tran =
%%        fun() ->
%%            if
%%                MailId > 0 ->
%%                    mod_award:give_mail(PlayerId, MailId, AwardItemList, LogType);
%%                true ->
%%                    mod_award:give(PlayerId, AwardItemList, LogType)
%%            end,
%%            db:write(PlayerRewardInit#db_player_platform_fun_reward{state = ?AWARD_ALREADY, change_time = util_time:timestamp()})
%%        end,
%%    db:do(Tran),
%%    ok.

%%%% 领取平台关注礼包
%%get_platform_concern_award(PlayerId) ->
%%%%    mod_function:assert_open(PlayerId, ?FUNCTION_PLATFORM_GUANZHU),
%%    State = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CONCERN_AWARD_STATE),
%%    ?ASSERT(State =/= ?TRUE, ?ERROR_ALREADY_HAVE),
%%    AwardList = ?SD_GUAN_ZHU_LI_BAO,
%%    Tran =
%%        fun() ->
%%            mod_mail:add_mail_item_list(PlayerId, ?MAIL_PLATFORM_CONCERN_AWARD, AwardList, ?LOG_TYPE_PLATFORM_CONCERN_AWARD),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CONCERN_AWARD_STATE, ?TRUE),
%%            ok
%%        end,
%%    db:do(Tran).


%% 获得平台关注礼包状态
get_concern_award_state(PlayerId) ->
    State = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CONCERN_AWARD_STATE),
    State.

%%%% 领取平台认证礼包
%%get_platform_certification_award(PlayerId) ->
%%%%    mod_function:assert_open(PlayerId, ?FUNCTION_PLATFORM_SHIMING),
%%    State = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CERTIFICATION_AWARD_STATE),
%%    ?ASSERT(State =/= ?TRUE, ?ERROR_ALREADY_HAVE),
%%    AwardList = ?SD_SHI_MING_LI_BAO,
%%    Tran =
%%        fun() ->
%%            mod_mail:add_mail_item_list(PlayerId, ?MAIL_PLATFORM_CERTIFICATION_AWARD, AwardList, ?LOG_TYPE_PLATFORM_CERTIFICATION_AWARD),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CERTIFICATION_AWARD_STATE, ?TRUE),
%%            ok
%%        end,
%%    db:do(Tran).

%% 获得平台认证礼包状态
get_certification_award_state(PlayerId) ->
    State = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLATFORM_CERTIFICATION_AWARD_STATE),
    State.

%% @fun 获取初始时 平台功能领取数据
get_init_fun(_PlayerId) ->
    [].
%%    lists:foldl(
%%        fun(FunId, L) ->
%%            case get_player_platform_fun_reward(PlayerId, FunId) of
%%                #db_player_platform_fun_reward{state = State} ->
%%                    [{FunId, State} | L];
%%                _ ->
%%                    L
%%            end
%%        end, [], logic_get_platform_function_reward_id_list() -- []).

%% ================================================ 修复数据操作 ================================================
%% @fun 修复玩家邀请数据
repair_invite_friend_task(PlayerId) ->
    Tran =
        fun() ->
            lists:foldl(
                fun(TaskType, L) ->
                    #db_player_share_task{
                        value = Value
                    } = get_player_share_task_init(PlayerId, TaskType),
                    if
                        Value > 0 ->
                            lists:foldl(
                                fun({TaskId, NeedValue}, List) ->
                                    TaskAward = get_player_share_task_award_init(PlayerId, TaskType, TaskId),
                                    State = TaskAward#db_player_share_task_award.state,
                                    if
                                        Value >= NeedValue andalso State == ?AWARD_NONE ->
                                            db:write(TaskAward#db_player_share_task_award{state = ?AWARD_CAN}),
                                            [{TaskType, TaskId} | List];
                                        true ->
                                            List
                                    end
                                end, L, logic_get_share_type_task_id(TaskType));
                        true ->
                            L
                    end
                end, [], logic_get_invite_task_type_list())
        end,
    Result = db:do(Tran),
    ?INFO("修复玩家邀请数据内容:~p~n", [Result]).


%% ================================================ ets数据操作 ================================================
%% @fun 平台玩家平台好友数据
get_ets_platform_friends_data(PlayerId) ->
    case ets:lookup(?ETS_PLATFORM_FRIENDS_DATA, PlayerId) of
        [Ets] ->
            Ets;
        _ ->
            #ets_platform_friends_data{player_id = PlayerId}
    end.

%%%% @fun 添加平台玩家平台好友数据
%%insert_ets_platform_friends_data(Ets) ->
%%    ets:insert(?ETS_PLATFORM_FRIENDS_DATA, Ets).

%% ================================================ 数据操作 ================================================
%% @fun 玩家分享数据
get_player_share(PlayerId) ->
    db:read(#key_player_share{player_id = PlayerId}).
%% @fun 玩家分享数据  并初始化
get_player_share_init(PlayerId) ->
    case get_player_share(PlayerId) of
        Share when is_record(Share, db_player_share) ->
            case util_time:is_today(Share#db_player_share.change_time) of
                true ->
                    Share;
                _ ->
                    Share#db_player_share{count = 0}
            end;
        _ ->
            #db_player_share{player_id = PlayerId}
    end.
%% @fun 玩家好友邀请
%%get_player_share_friend(PlayerId, Id) ->
%%    db:read(#key_player_share_friend{player_id = PlayerId, id = Id}).
%% @fun 玩家好友邀请  并初始化
%%get_player_share_friend_init(PlayerId, Id) ->
%%    case get_player_share_friend(PlayerId, Id) of
%%        ShareFriend when is_record(ShareFriend, db_player_share_friend) ->
%%            ShareFriend;
%%        _ ->
%%            #db_player_share_friend{player_id = PlayerId, id = Id}
%%    end.

%% @fun 获得玩家已上报的数据
get_player_send_gamebar_msg(PlayerId, Type) ->
    db:read(#key_player_send_gamebar_msg{player_id = PlayerId, msg_type = Type}).

%% @fun 获得玩家已上报的数据  并初始化
get_player_send_gamebar_msg_init(PlayerId, Type) ->
    case get_player_send_gamebar_msg(PlayerId, Type) of
        SendMsg when is_record(SendMsg, db_player_send_gamebar_msg) ->
            SendMsg;
        _ ->
            #db_player_send_gamebar_msg{player_id = PlayerId, msg_type = Type, msg_id = 0}
    end.

%% 获得玩家分享任务数据
get_player_share_task(PlayerId, TaskType) ->
    db:read(#key_player_share_task{player_id = PlayerId, task_type = TaskType}).

%% 获得玩家分享任务数据   并初始化
get_player_share_task_init(PlayerId, TaskType) ->
    case get_player_share_task(PlayerId, TaskType) of
        ShareTask when is_record(ShareTask, db_player_share_task) ->
            ShareTask;
        _ ->
            #db_player_share_task{player_id = PlayerId, task_type = TaskType}
    end.

%% 获得玩家平台礼包数据
%%get_player_platform_fun_reward(PlayerId, FunId) ->
%%    db:read(#key_player_platform_fun_reward{player_id = PlayerId, fun_id = FunId}).
%% 获得玩家平台礼包数据   并初始化
%%get_player_platform_fun_reward_init(PlayerId, FunId) ->
%%    case get_player_platform_fun_reward(PlayerId, FunId) of
%%        PlayerReward when is_record(PlayerReward, db_player_platform_fun_reward) ->
%%            PlayerReward;
%%        _ ->
%%            #db_player_platform_fun_reward{player_id = PlayerId, fun_id = FunId}
%%    end.

%% 获得玩家分享任务奖励数据
get_player_share_task_award(PlayerId, TaskType, TaskId) ->
    db:read(#key_player_share_task_award{player_id = PlayerId, task_type = TaskType, task_id = TaskId}).

%% 获得玩家分享任务奖励数据   并初始化
get_player_share_task_award_init(PlayerId, TaskType, TaskId) ->
    case get_player_share_task_award(PlayerId, TaskType, TaskId) of
        TaskAward when is_record(TaskAward, db_player_share_task_award) ->
            TaskAward;
        _ ->
            #db_player_share_task_award{player_id = PlayerId, task_type = TaskType, task_id = TaskId}
    end.

%% 获得邀请好友数据
get_player_invite_friend(AccId, PlayerId) ->
    db:read(#key_player_invite_friend{acc_id = AccId, player_id = PlayerId}).

%% 获得邀请好友数据     并初始化
get_player_invite_friend_init(AccId, PlayerId) ->
    case get_player_invite_friend(AccId, PlayerId) of
        F when is_record(F, db_player_invite_friend) ->
            F;
        _ ->
            #db_player_invite_friend{acc_id = AccId, player_id = PlayerId}
    end.

%% 获得邀请好友任务数据
get_player_finish_share_task(AccId, TaskType, PlayerId) ->
    db:read(#key_player_finish_share_task{acc_id = AccId, task_type = TaskType, player_id = PlayerId}).

%% 获得邀请好友任务数据       并初始化
get_player_finish_share_task_init(AccId, TaskType, PlayerId) ->
    case get_player_finish_share_task(AccId, TaskType, PlayerId) of
        F when is_record(F, db_player_finish_share_task) ->
            F;
        _ ->
            #db_player_finish_share_task{acc_id = AccId, task_type = TaskType, player_id = PlayerId}
    end.

%% 获得邀请好友日志数据
get_player_invite_friend_log(PlayerId, AccId) ->
    db:read(#key_player_invite_friend_log{player_id = PlayerId, acc_id = AccId}).

%% 获得邀请好友日志数据       并初始化
get_player_invite_friend_log_init(PlayerId, AccId) ->
    case get_player_invite_friend_log(PlayerId, AccId) of
        L when is_record(L, db_player_invite_friend_log) ->
            L;
        _ ->
            #db_player_invite_friend_log{player_id = PlayerId, acc_id = AccId}
    end.

%% ================================================ 模板操作 ================================================
%% @fun 获得平台条件上报数据
%%try_get_platform_conditions_send_data(MsgId) ->
%%    Table = t_platform_conditions_send_data:get({MsgId}),
%%    ?IF(is_record(Table, t_platform_conditions_send_data), Table, exit({t_platform_conditions_send_data, {MsgId}})).

%% 获得分享有礼任务类型模板
try_get_t_share_task_type(TaskTypeId) ->
    T_TaskTypeId = t_share_task_type:get({TaskTypeId}),
    ?IF(is_record(T_TaskTypeId, t_share_task_type), T_TaskTypeId, exit({null_t_share_task_type, {TaskTypeId}})).

%% 获得分享有礼任务模板
try_get_t_share_task(TaskTypeId, TaskId) ->
    T_TaskId = t_share_task:get({TaskTypeId, TaskId}),
    ?IF(is_record(T_TaskId, t_share_task), T_TaskId, exit({null_t_share_task, {TaskTypeId, TaskId}})).

%% 获得平台功能奖励模板
%%try_get_t_platform_function_reward(FunId) ->
%%    Table = t_platform_function_reward:get({FunId}),
%%    ?IF(is_record(Table, t_platform_function_reward), Table, exit({t_platform_function_reward, {FunId}})).

%% 获得分享有礼任务类型对应编号id
logic_get_share_type_task_id(TaskType) ->
    case logic_get_share_type_task_id:get(TaskType) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

logic_get_invite_task_type_list() ->
    case logic_get_invite_task_type_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 获得平台功能奖励id列表
%%logic_get_platform_function_reward_id_list() ->
%%    case logic_get_platform_function_reward_id_list:get(0) of
%%        List when is_list(List) ->
%%            List;
%%        _ ->
%%            []
%%    end.

logic_get_share_id_list() ->
    case logic_get_share_id_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.
