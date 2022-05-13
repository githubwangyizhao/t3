%%%-------------------------------------------------------------------
%%% @author
%%% @copyright
%%% @doc      通知服务
%%% @end
%%%-------------------------------------------------------------------
-module(notice_srv).

-behaviour(gen_server).

-include("common.hrl").
%%-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    start_link/0,
    get_notice/1,
    get_player_name_str/0
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
    out
}).
%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    Out = handle_notice(),
    {ok, #state{out = Out}}.

get_notice(PlayerId) ->
    gen_server:cast(?MODULE, {get_notice, PlayerId}).

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({get_notice, PlayerId}, State) ->
    catch handle_get_notice(PlayerId, State#state.out),
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({timeout, _TimerRef, {timeout, notice}}, State) ->
    try handle_notice() of
        Out ->
%%            ?DEBUG(" 通知  的定时器回调 : ~p", [Out]),
            {noreply, State#state{out = Out}}
    catch
        _:Reason ->
            ?ERROR(" 通知  的定时器回调报错:~p~n~p", [Reason, erlang:get_stacktrace()]),
            {noreply, State}
    end;
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_get_notice(_PlayerId, _Out) ->
%%    ?DEBUG("通知数据~p", [{PlayerId, Out}]),
%%    mod_socket:send(PlayerId, Out).
    noop.

handle_notice() ->
    util_timer:start_timer(notice, ?SD_RANDOM_NOTICE_3),
    RandomMoneyList = [{Key, Value} || [Key, Value] <- []],
    RandomNoticeIdList = ?SD_RANDOM_NOTICE_1,
    RandomNoticeIdMax = length(RandomNoticeIdList),
    ?DEBUG("server_id_list: ~p", [mod_server:get_server_id_list()]),
    ServerId = hd(mod_server:get_server_id_list()),
    SceneIdList = lists:seq(1001,1006),
    SceneLength = length(SceneIdList),
    List = lists:filtermap(
        fun(_) ->
            PosId = util_random:random_number(RandomNoticeIdMax),
            NoticeId = lists:nth(PosId, RandomNoticeIdList),
            #t_notice{
                notice_type = Channel
            } = t_notice:assert_get({NoticeId}),
            case get_player_name_str() of
                "" ->
                    false;
                Nickname ->
                    PlayerStr = ServerId ++ "." ++ Nickname,
                    ArgsList =
                        case NoticeId of
                            ?NOTICE_ANALOG_3 ->
                                SceneId = lists:nth(util_random:random_number(SceneLength), SceneIdList),
%%                                #t_scene{
%%                                    drop_per = DropPet
%%                                } = mod_scene:get_t_scene(SceneId),
                                [PlayerStr, SceneId, util_random:get_probability_item(RandomMoneyList)];
                            ?NOTICE_ANALOG_5 ->
                                [PlayerStr, util_random:get_probability_item([{Key, Value} || [Key, Value] <- ?SD_RANDOM_NOTICE_6])];
                            _ ->
                                [PlayerStr, util_random:get_probability_item(RandomMoneyList)]
                        end,
                    NewList = [util:to_binary(NoticeContent) || NoticeContent <- ArgsList],
                    {true, api_chat:pack_msg_data(Channel, NoticeId, NewList)}
            end
        end,
        lists:seq(1, ?SD_RANDOM_NOTICE_2)
    ),
    ?DEBUG("长度~p", [length(List)]),
    api_chat:pack_chat_broadcast_channel_msg_list(List).

get_player_name_str() ->
    get_player_name_str(5).
get_player_name_str(0) ->
    "";
get_player_name_str(Times) ->
    {_, NickName} = random_name:get_name(),
    case mod_player:get_player_list_by_nickname(NickName) of
        [] ->
            NickName;
        _ ->
            get_player_name_str(Times - 1)
    end.
