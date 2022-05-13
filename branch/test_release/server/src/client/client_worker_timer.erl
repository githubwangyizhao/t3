%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家进程定时器
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_worker_timer).
-include("common.hrl").
-include("client.hrl").
-export([
    handle_timeout/2
]).
%% ----------------------------------
%% @doc 	定时器
%% @throws 	none
%% @end
%% ----------------------------------
handle_timeout(TimerRef, TimerId) ->
    case util_timer:handle_timeout(TimerRef, TimerId) of
        ok ->
            PlayerId = get(?DICT_PLAYER_ID),
            case TimerId of
                {?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, PropId} ->
                    mod_prop:clean_player_prop(PlayerId, PropId);
                {?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_SPECIAL_PROP, PropObjId} ->
                    mod_special_prop:clean_player_prop(PlayerId, PropObjId);
                % 个人活动
                {?CLIENT_WORKER_TIMER_CLOSE_PERSON_ACTIVITY, ActivityId} ->
                    activity_person:close_activity(PlayerId, ActivityId);
                _ ->
                    ?WARNING("定时器未实现:~p", [TimerId])
            end;
        _ ->
            noop
    end.

%%
%%%% API
%%-export([
%%    start_timer/2,
%%    cancel_timer/1,
%%    is_timer_exists/1,
%%    handle_timer/2
%%]).
%%-include("common.hrl").
%%-include("client.hrl").
%%
%%
%%%%%===================================================================
%%%%% API
%%%%%===================================================================
%%
%%%% ----------------------------------
%%%% @doc 	启动定时器
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%start_timer(TimerId, Time)->
%%    ?DEBUG("启动定时器:~p~n", [{TimerId, Time}]),
%%    case get_timer_ref(TimerId) of
%%        undefined ->
%%            noop;
%%        OldTimerRef ->
%%            %% 取消旧定时器
%%            erlang:cancel_timer(OldTimerRef)
%%    end,
%%    TimerRef = erlang:start_timer(max(Time, 0), self(), {client_worker_timer, TimerId}),
%%    update_timer_ref(TimerId, TimerRef).
%%
%%%% ----------------------------------
%%%% @doc 	取消定时器
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%cancel_timer(TimerId) ->
%%    ?DEBUG("取消定时器:~p~n", [{TimerId}]),
%%    case get_timer_ref(TimerId) of
%%        undefined ->
%%            ?WARNING("定时器不存在:~p", [TimerId]);
%%        TimerRef ->
%%            erlang:cancel_timer(TimerRef),
%%            delete_timer_ref(TimerId)
%%    end.
%%
%%%% ----------------------------------
%%%% @doc 	定时器是否存在
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%is_timer_exists(TimerId) ->
%%    get_timer_ref(TimerId) =/= undefined.
%%
%%
%%%% ----------------------------------
%%%% @doc 	处理定时器
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_timer(TimerRef, TimerId) ->
%%    PlayerId = get(?DICT_PLAYER_ID),
%%    case get_timer_ref(TimerId) of
%%        TimerRef ->
%%            delete_timer_ref(TimerId),
%%            case TimerId of
%%                {?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, PropType, PropId} ->
%%                    mod_prop:clean_player_prop(PlayerId, PropType, PropId);
%%                _ ->
%%                    ?WARNING("定时器未实现:~p", [TimerId])
%%            end;
%%        _ ->
%%            ?WARNING("定时器ref不匹配:~p", [TimerId])
%%    end.
%%
%%
%%
%%%%%===================================================================
%%%%% Internal functions
%%%%%===================================================================
%%
%%%% ----------------------------------
%%%% @doc 	获取定时器ref
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_timer_ref(TimerId) ->
%%    get({client_worker_timer, TimerId}).
%%
%%%% ----------------------------------
%%%% @doc 	更新定时器ref
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%update_timer_ref(TimerId, TimerRef) ->
%%    ?DEBUG("更新定时器ref:~p~n", [{TimerId}]),
%%    put({client_worker_timer, TimerId}, TimerRef).
%%
%%
%%%% ----------------------------------
%%%% @doc 	移除定时器ref
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%delete_timer_ref(TimerId) ->
%%    erase({client_worker_timer, TimerId}).
