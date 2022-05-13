%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            单进程定时器
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(util_timer).

%% API
-export([
    start_timer/2,
    cancel_timer/1,
    is_timer_exists/1,
    get_timer_ref_info/1,   % 打印获取定时器ref
    handle_timeout/2
]).
-include("common.hrl").
-include("client.hrl").


%%%===================================================================
%%% API
%%%===================================================================

%% ----------------------------------
%% @doc 	启动定时器
%% @throws 	none
%% @end
%% ----------------------------------
start_timer(TimerId, Time) when is_integer(Time)->
    ?DEBUG("启动定时器:~p~n", [{TimerId, Time}]),
    case get_timer_ref(TimerId) of
        undefined ->
            noop;
        OldTimerRef ->
            %% 取消旧定时器
            ?DEBUG("取消旧定时器:~p", [TimerId]),
            erlang:cancel_timer(OldTimerRef)
    end,
    TimerRef = erlang:start_timer(max(Time, 0), self(), {timeout, TimerId}),
    update_timer_ref(TimerId, TimerRef).

%% ----------------------------------
%% @doc 	取消定时器
%% @throws 	none
%% @end
%% ----------------------------------
cancel_timer(TimerId) ->
    ?DEBUG("取消定时器:~p~n", [{TimerId}]),
    case get_timer_ref(TimerId) of
        undefined ->
            ?WARNING("定时器不存在:~p", [TimerId]);
        TimerRef ->
            erlang:cancel_timer(TimerRef),
            delete_timer_ref(TimerId)
    end.

%% ----------------------------------
%% @doc 	定时器是否存在
%% @throws 	none
%% @end
%% ----------------------------------
is_timer_exists(TimerId) ->
    get_timer_ref(TimerId) =/= undefined.


%% ----------------------------------
%% @doc 	处理定时器
%% @throws 	none
%% @end
%% ----------------------------------
handle_timeout(TimerRef, TimerId) ->
    case get_timer_ref(TimerId) of
        TimerRef ->
            delete_timer_ref(TimerId),
            ok;
        _ ->
            ?WARNING("定时器ref不匹配:~p", [TimerId])
    end.



%%%===================================================================
%%% Internal functions
%%%===================================================================

%% ----------------------------------
%% @doc 	获取定时器ref
%% @throws 	none
%% @end
%% ----------------------------------
get_timer_ref(TimerId) ->
    get({'timer_ref', TimerId}).

%% @fun 打印获取定时器ref
get_timer_ref_info(TimerId) ->
    ?INFO("获取定时器ref_Id:~p\t~p",[TimerId, get_timer_ref(TimerId)]).

%% ----------------------------------
%% @doc 	更新定时器ref
%% @throws 	none
%% @end
%% ----------------------------------
update_timer_ref(TimerId, TimerRef) ->
%%    ?DEBUG("更新定时器ref:~p~n", [{TimerId}]),
    put({'timer_ref', TimerId}, TimerRef).


%% ----------------------------------
%% @doc 	移除定时器ref
%% @throws 	none
%% @end
%% ----------------------------------
delete_timer_ref(TimerId) ->
    erase({'timer_ref', TimerId}).

