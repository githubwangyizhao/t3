%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 20. 九月 2018 20:45
%%%-------------------------------------------------------------------
-module(red_packet_srv).
-author("home").

%% API
-export([
    start_link/0,
    init/1,
    handle_call/3,
    handle_info/2,
    handle_cast/2,
    terminate/2,
    call/1,
    cast/1
]).

-include("common.hrl").
-include("gen/table_enum.hrl").

-define(RED_PACKET_QUEUE_LIST, red_packet_queue_list).  %% 红包排队列表
-define(RED_PACKET_NEXT_QUEUE_TIME, red_packet_next_queue_time).  %% 红包排队上一次发送时间


%%
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% 初始化所需数据
init(_) ->
    ets:new(?ETS_RED_PACKET_RECORD, ?ETS_INIT_ARGS(#ets_red_packet_record.r_id)),
    {ok, null}.

call(Request) ->
    gen_server:call(?MODULE, Request).

cast(Request) ->
    gen_server:cast(?MODULE, Request).

%% 领取红包奖励
handle_call({get_red_packet, PlayerId, RId}, _From, State) ->
    Result = ?TRY_CATCH2(red_packet_mod:get_red_packet(PlayerId, RId)),
    {reply, Result, State};
%% 同步处理消息
handle_call(_, _From, State) ->
    {reply, State, State}.


%% 发送红包
handle_cast({send_red_packet, PlayerId, Id, IsQueue, Tuple}, State) ->
    ?DEBUG("发送红包 ~p~n", [{PlayerId, Id, IsQueue, Tuple}]),
    if
        IsQueue == true ->
            NextQueueTime = util:get_dict(?RED_PACKET_NEXT_QUEUE_TIME, 0),
            OldQueueList = util:get_dict(?RED_PACKET_QUEUE_LIST, []),
            OldQueueLen =  length(OldQueueList),
            CurrTime = util_time:timestamp(),
            if
                CurrTime >= NextQueueTime andalso OldQueueLen == 0 ->
                    AddNextTime = get_next_time(OldQueueLen),
                    put(?RED_PACKET_NEXT_QUEUE_TIME, CurrTime + AddNextTime),
                    ?INFO("发送红包排队红包下次时间 ~p~n", [util_time:timestamp_to_datetime(AddNextTime + CurrTime)]),
                    ?TRY_CATCH(red_packet_mod:send_red_packet(PlayerId, Id, Tuple)),
                    Ref = erlang:send_after(AddNextTime * ?SECOND_MS, self(), queue_red_packet),
                    util:get_dict(queue_red_packet, Ref);
                true ->
                    put(?RED_PACKET_QUEUE_LIST, [{PlayerId, Id, Tuple} | OldQueueList]),
                    ?INFO("红包排队红包个数 ~p~n", [OldQueueLen + 1])
            end;
        true ->
            ?TRY_CATCH(red_packet_mod:send_red_packet(PlayerId, Id, Tuple))
    end,
    {noreply, State};
%% 增加红包条件
handle_cast({add_red_packet_condition, RedConditionIdList, Value}, State) ->
    ?TRY_CATCH(red_packet_mod:add_red_packet_condition(RedConditionIdList, Value)),
    {noreply, State};
%% 异步处理消息
handle_cast(_, State) ->
    {noreply, State}.

%% 排队红包
handle_info(queue_red_packet, State) ->
    OldQueueList = util:get_dict(?RED_PACKET_QUEUE_LIST, []),
    ?INFO("排队红包 ~p OldQueueList:~p~n", [util_time:local_datetime(), OldQueueList]),
    if
        OldQueueList =/= [] ->
            QueueData = lists:last(OldQueueList),
            {PlayerId, Id, Tuple} = QueueData,
            OldQueueLen =  length(OldQueueList) - 1,
            CurrTime = util_time:timestamp(),
            AddNextTime = get_next_time(OldQueueLen),
            put(?RED_PACKET_NEXT_QUEUE_TIME, CurrTime + AddNextTime),
            put(?RED_PACKET_QUEUE_LIST, OldQueueList -- [QueueData]),
            ?INFO("排队红包下次时间 ~p 排队红包个数:~p~n", [util_time:timestamp_to_datetime(AddNextTime + CurrTime), OldQueueLen]),
            ?TRY_CATCH(red_packet_mod:send_red_packet(PlayerId, Id, Tuple)),
            Ref = erlang:send_after(AddNextTime * ?SECOND_MS, self(), queue_red_packet),
            util:get_dict(queue_red_packet, Ref);
        true -> noop
    end,
    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

terminate(_, State) ->
    State.

get_next_time(Num) ->
   [MinTime, MaxTime] = get_next_time_handle(Num, ?SD_RED_PACKAGE_LINE_TIME),
    util_random:random_number(MinTime, MaxTime).

get_next_time_handle(_Num, []) ->
    [10, 10];
get_next_time_handle(Num, [{Min, Max, MinTime, MaxTime} | RangList]) ->
    if Num >= Min andalso (Num =< Max orelse Max == 0) ->
        [MinTime, MaxTime];
        true ->
            get_next_time_handle(Num, RangList)
    end.



