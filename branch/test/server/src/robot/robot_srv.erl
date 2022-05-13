-module(robot_srv).

-behaviour(gen_server).

%% API
-export([
    start_link/0,
    get_state/0,
    get_robot_account/0,
    stop/0,
    start/0,
    cleanup/0,
    arrange/2,
    update_last_create_role_time/0
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-include("common.hrl").
-include("robot.hrl").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get_state() ->
    gen_server:call(?MODULE, get_status).

get_robot_account() ->
    gen_server:call(?MODULE, get_robot_account).


stop() ->
    gen_server:call(?MODULE, stop).

cleanup() ->
    gen_server:call(?MODULE, cleanup).

start() ->
    gen_server:call(?MODULE, start).

update_last_create_role_time() ->
    ?MODULE ! update_last_create_role_time.

init([]) ->
    random_clock(),
    {ok, #state{}}.
handle_call(get_status, _From, State) ->
    {reply, State, State};
handle_call(get_robot_account, _From, State) ->
    {reply, erlang:length(State#state.robot_workers), State};
handle_call(stop, _From, State) ->
    NewState = State#state{status = false},
    {reply, ok, NewState};
handle_call(start, _From, State) ->
    NewState = State#state{status = true},
    {reply, ok, NewState};
handle_call(cleanup, _From, State) ->
    NewState = handle_cleanup(State),
    {reply, ok, NewState};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(clock, State) ->
    try handle_clock(State) of
        NewState ->
            {noreply, NewState}
    catch
        _:Reason ->
            ?ERROR("clock :~p", [Reason]),
            {noreply, State}
    end;
handle_info(update_last_create_role_time, State) ->
    NewState = State#state{last_create_role_time = util_time:timestamp()},
    {noreply, NewState};
handle_info({'DOWN', _Ref, process, RobotWorker, _Reason}, State) ->
    NewState = handle_robot_worker_down(RobotWorker, State),
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

random_clock() ->
    Time = util_random:random_number(150000, 400000),
%%    Time = util_random:random_number(2000, 5000),
    erlang:send_after(Time, self(), clock).

handle_clock(State = #state{status = Status, robot_workers = RobotWorkers, last_create_role_time = LastCreateRoleTime}) ->
    random_clock(),
    IsServerOpenTime = mod_server:is_server_open_time(),
%%    {Hour, _, _} = erlang:time(),
%%    Now = util_time:timestamp(),
    IsContinue = mod_server_config:is_create_robot() andalso IsServerOpenTime andalso Status == true,
    case IsContinue of
        true ->
            CommonOnlineCount = mod_online:get_common_online_player_count(),

            AllowRobotCount = max(0, 200 - CommonOnlineCount),
            RobotWorkersNum = length(RobotWorkers),
            NewRobotWorkers =
                if
                    AllowRobotCount - RobotWorkersNum > 0 ->
                        Pid = robot:start(),
                        MonitorRef = erlang:monitor(process, Pid),
                        arrange([{Pid, MonitorRef} | RobotWorkers], AllowRobotCount);
                    true ->
                        arrange(RobotWorkers, AllowRobotCount)
                end,
            State#state{robot_workers = NewRobotWorkers};
        _ ->
            State
    end.

arrange(RobotWorkers, AllowNum) ->
    L = arrange(lists:reverse(RobotWorkers), length(RobotWorkers), AllowNum),
    lists:reverse(L).

arrange(RobotWorkers, 0, _AllowNum) ->
    RobotWorkers;
arrange([H | L], Num, AllowNum) ->
    if Num > AllowNum ->
        {RobotWorker, MonitorRef} = H,
        erlang:demonitor(MonitorRef),
        catch robot:stop(RobotWorker),
        arrange(L, Num - 1, AllowNum);
        true ->
            [H | L]
    end.

handle_cleanup(State = #state{robot_workers = RobotWorkers}) ->
    lists:foreach(
        fun({RobotWorker, MonitorRef}) ->
            erlang:demonitor(MonitorRef),
            catch robot:stop(RobotWorker)
        end,
        RobotWorkers
    ),
    State#state{robot_workers = []}.

handle_robot_worker_down(RobotWorker, State = #state{robot_workers = RobotWorkers}) ->
    case lists:keytake(RobotWorker, 1, RobotWorkers) of
        {value, {RobotWorker, MonitorRef}, Left} ->
            erlang:demonitor(MonitorRef),
            State#state{robot_workers = Left};
        false ->
            State
    end.
