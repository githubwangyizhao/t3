%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 15. 六月 2018 18:51
%%%-------------------------------------------------------------------
-module(api_platform_function).
-author("home").

%% API
-export([
    api_get_share_task_info/2,

    share/2,
    get_share_friend_give/2,
    notice_share_friend/2,
    api_notice_share_count/2,
    notice_platform_vip_level/3,

    get_share_task_info/2,
    get_share_task_award/2,
    notice_share_task/2,
    refresh_open_key/2                  %% 刷新open key
]).

-export([
    pack_share_friend/1,        % 打包好友邀请
    api_notice_share_friend/3   % api 通知好友邀请状态
]).

-include("gen/db.hrl").
-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("client.hrl").

%% @doc     分享
share(
    #m_platform_function_share_tos{},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("分享"),
    Result = api_common:api_result_to_enum(catch mod_platform_function:share(PlayerId)),
    Out = proto:encode(#m_platform_function_share_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% @doc     领取好友邀请奖励
get_share_friend_give(
    #m_platform_function_get_share_friend_give_tos{id = Id},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("领取好友邀请奖励"),
    Result = api_common:api_result_to_enum(catch mod_platform_function:get_share_friend_give(PlayerId, Id)),
    Out = proto:encode(#m_platform_function_get_share_friend_give_toc{result = Result, id = Id}),
    mod_socket:send(Out),
    State.

%% @doc     通知好友邀请状态
notice_share_friend(PlayerId, IdList) ->
    Out = proto:encode(#m_platform_function_notice_share_friend_toc{share_friend_data = pack_share_friend(IdList)}),
    mod_socket:send(PlayerId, Out).
%% @fun api 通知好友邀请状态
api_notice_share_friend(PlayerId, Id, State) ->
    db:tran_merge_apply({?MODULE, notice_share_friend, PlayerId}, {Id, State}).

%% @doc     0点通知分享次数
api_notice_share_count(PlayerId, ShareCount) ->
    Out = proto:encode(#m_platform_function_notice_share_count_toc{share_count = ShareCount}),
    mod_socket:send(PlayerId, Out).

%% @doc     当前通知vip等级
notice_platform_vip_level(PlayerId, PVipLevel, VipAwardState) ->
%%    ?DEBUG("当前通知vip等级 ~p~n", [{PlayerId, PVipLevel, VipAwardState}]),
    Out = proto:encode(#m_platform_function_notice_platform_vip_level_toc{p_vip_level = PVipLevel, p_vip_award_state = VipAwardState}),
    mod_socket:send(PlayerId, Out).

%% 获得邀请任务信息
get_share_task_info(
    #m_platform_function_get_share_task_info_tos{show_type = ShowType},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("获得邀请任务信息"),
    TaskList = api_get_share_task_info(PlayerId, ShowType),
    Out = proto:encode(#m_platform_function_get_share_task_info_toc{share_task_award_data = TaskList, show_type = ShowType}),
    mod_socket:send(Out),
    State.

api_get_share_task_info(PlayerId, ShowType) ->
    [pack_share_task(ShareTaskData, Value) || {ShareTaskData, Value} <- mod_platform_function:get_invite_friend_task_info(PlayerId, ShowType)].

%% 领取邀请任务奖励
get_share_task_award(#m_platform_function_get_share_task_award_tos{task_type = TaskType, task_id = TaskId},
    State = #conn{player_id = PlayerId}) ->
    ?REQUEST_INFO("领取邀请任务奖励"),
    {Result, ShareTask, Value} =
        case catch mod_platform_function:get_share_task_award(PlayerId, TaskType, TaskId) of
            {ok, ShareTask1, Value1} ->
                {?P_SUCCESS, ShareTask1, Value1};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, null, 0}
        end,
    ShareTaskData = pack_share_task(ShareTask, Value),
    Out = proto:encode(#m_platform_function_get_share_task_award_toc{result = Result, share_task_award_data = ShareTaskData}),
    mod_socket:send(Out),
    State.

notice_share_task(PlayerId, ShareTaskDataList) ->
    ShareDataList = [pack_share_task(ShareTaskData, Value) || {ShareTaskData, Value} <- ShareTaskDataList],
    Out = proto:encode(#m_platform_function_notice_share_task_toc{share_task_award_data = ShareDataList}),
    mod_socket:send(PlayerId, Out).

%% @fun 打包好友邀请
pack_share_friend(List) ->
    [#sharefrienddata{id = Id, state = State} || {Id, State} <- List].



pack_share_task(ShareTaskData, Value) ->
    {TaskType, TaskId, State} =
        case is_record(ShareTaskData, db_player_share_task_award) of
            true ->
                #db_player_share_task_award{
                    task_type = TaskType1,
                    task_id = TaskId1,
                    state = State1
                } = ShareTaskData,
                {TaskType1, TaskId1, State1};
            _ ->
                {0, 0, 0}
        end,
    #sharetaskawarddata{task_type = TaskType, task_id = TaskId, state = State, value = Value}.


%% @doc     刷新open key
refresh_open_key(
    #m_platform_function_refresh_open_key_tos{open_key = OpenKey},
    #conn{player_id = _PlayerId} = State) ->
    ?INFO("刷新openkey:~p~n", [{OpenKey}]),
    put(?DICT_PLATFORM_TICKET, util:to_list(OpenKey)),
    Out = proto:encode(#m_platform_function_refresh_open_key_toc{}),
    mod_socket:send(Out),
    State.
