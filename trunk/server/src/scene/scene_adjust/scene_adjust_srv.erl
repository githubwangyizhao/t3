%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 8月 2021 下午 02:13:08
%%%-------------------------------------------------------------------
-module(scene_adjust_srv).
-author("Administrator").

-behaviour(gen_server).

-include("scene_adjust.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    start_link/0
]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-export([
    call/1,
    cast/1
]).

-define(SERVER, ?MODULE).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

call(Msg) ->
    gen_server:call(?MODULE, Msg).
cast(Msg) ->
    gen_server:cast(?MODULE, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
%% @doc Initializes the server
init([]) ->
    State =
        #scene_adjust_srv_state{
            scene_data_list = lists:map(
                fun([SceneId, RandomList]) ->
                    Time = util_random:random_number(RandomList) * ?SECOND_MS,
                    erlang:send_after(Time, self(), {?SCENE_ADJUST_MSG_UPDATE_ROOM, SceneId}),
                    #scene_adjust_scene_data{scene_id = SceneId, scene_room_pid_list = []}
                end,
                ?SD_RANDOMPROFITLOSS_ZHOUQI
            )
        },
    {ok, State}.

%% @private
%% @doc Handling call messages
handle_call({get_pool_value, SceneId}, _From, State = #scene_adjust_srv_state{}) ->
    Result = handle_scene_adjust_srv:get_pool_value(SceneId),
    {reply, Result, State};
handle_call(_Request, _From, State = #scene_adjust_srv_state{}) ->
    {reply, ok, State}.

-define(SCENE_ADJUST_SRV_CATCH(Fun, Msg),
    try Fun
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end
).

%% @private
%% @doc Handling cast messages
handle_cast({?SCENE_ADJUST_MSG_CREATE_ROOM, SceneId, Pid} = Msg, State = #scene_adjust_srv_state{scene_data_list = SceneDataList}) ->
    NewSceneDataList = ?SCENE_ADJUST_SRV_CATCH(handle_scene_adjust_srv:create_room(SceneId, Pid, SceneDataList), Msg),
    {noreply, State#scene_adjust_srv_state{scene_data_list = NewSceneDataList}};
handle_cast({?SCENE_ADJUST_MSG_CLOSE_ROOM, SceneId, Pid, PoolValue} = Msg, State = #scene_adjust_srv_state{scene_data_list = SceneDataList}) ->
    NewSceneDataList = ?SCENE_ADJUST_SRV_CATCH(handle_scene_adjust_srv:close_room(SceneId, Pid, SceneDataList, PoolValue), Msg),
    {noreply, State#scene_adjust_srv_state{scene_data_list = NewSceneDataList}};
handle_cast(?SCENE_ADJUST_MSG_TEST_LOG = Msg, State = #scene_adjust_srv_state{scene_data_list = SceneDataList}) ->
    ?SCENE_ADJUST_SRV_CATCH(handle_scene_adjust_srv:test_log(SceneDataList), Msg),
    {noreply, State};
handle_cast({?SCENE_ADJUST_MSG_ADD_BOSS_ADJUST_VALUE, SceneId, AddValue} = Msg, State) ->
    ?SCENE_ADJUST_SRV_CATCH(handle_scene_adjust_srv:handle_add_boss_adjust_value(SceneId, AddValue), Msg),
    {noreply, State};
handle_cast(_Request, State = #scene_adjust_srv_state{}) ->
    {noreply, State}.

%% @private
%% @doc Handling all non call/cast messages
handle_info({?SCENE_ADJUST_MSG_UPDATE_ROOM, SceneId} = Msg, State = #scene_adjust_srv_state{scene_data_list = SceneDataList}) ->
%%    ?DEBUG("查看定时器数据  : ~p", [{SceneId, SceneDataList}]),
    ?SCENE_ADJUST_SRV_CATCH(handle_scene_adjust_srv:update_room(SceneId, SceneDataList), Msg),
    {noreply, State};
handle_info(_Info, State = #scene_adjust_srv_state{}) ->
    {noreply, State}.

%% @private
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
terminate(_Reason, _State = #scene_adjust_srv_state{}) ->
    ok.

%% @private
%% @doc Convert process state when code is changed
code_change(_OldVsn, State = #scene_adjust_srv_state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================