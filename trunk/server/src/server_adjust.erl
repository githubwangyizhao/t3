-module(server_adjust).
%%
%%-behaviour(gen_server).
%%-include("common.hrl").
%%-include("server_data.hrl").
%%-include("player_game_data.hrl").
%%-include("gen/table_enum.hrl").
%%%% API
%%-export([
%%    start_link/0,
%%    clean/0
%%]).
%%-export([
%%    add_server_adjust_cost/1,
%%    add_server_adjust_award/1,
%%    check_server_adjust/0,
%%    get_player_server_adjust_rate/1
%%]).
%%%% gen_server callbacks
%%-export([init/1,
%%    handle_call/3,
%%    handle_cast/2,
%%    handle_info/2,
%%    terminate/2,
%%    code_change/3]).
%%
%%-define(SERVER, ?MODULE).
%%
%%-record(state, {}).
%%
%%%%%===================================================================
%%%%% API
%%%%%===================================================================
%%
%%start_link() ->
%%    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%
%%add_server_adjust_cost(Add) ->
%%    ?SERVER ! {add_server_adjust_cost, Add}.
%%add_server_adjust_award(Add) ->
%%    ?SERVER ! {add_server_adjust_award, Add}.
%%
%%
%%%%%===================================================================
%%%%% gen_server callbacks
%%%%%===================================================================
%%init([]) ->
%%    erlang:send_after(?SD_SERVER_XIUZHENG_TIME, self(), check),
%%    {ok, #state{}}.
%%
%%handle_call(_Request, _From, State) ->
%%    ?WARNING("未知消息:~p", [_Request]),
%%    {reply, ok, State}.
%%
%%handle_cast(_Request, State) ->
%%    {noreply, State}.
%%
%%handle_info({add_server_adjust_cost, Add}, State) ->
%%    ?TRY_CATCH2(handle_add_server_adjust_cost(Add)),
%%    {noreply, State};
%%handle_info({add_server_adjust_award, Add}, State) ->
%%    ?TRY_CATCH2(handle_add_server_adjust_award(Add)),
%%    {noreply, State};
%%handle_info(check, State) ->
%%    ?TRY_CATCH2(check_server_adjust()),
%%    {noreply, State};
%%handle_info(_Info, State) ->
%%    ?WARNING("未知消息:~p", [_Info]),
%%    {noreply, State}.
%%
%%terminate(_Reason, _State) ->
%%    ok.
%%
%%code_change(_OldVsn, State, _Extra) ->
%%    {ok, State}.
%%
%%%%%===================================================================
%%%%% Internal functions
%%%%%===================================================================
%%
%%clean() ->
%%    mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_COST, 0),
%%    mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD, 0),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            case get_player_server_adjust_rate(PlayerId) of
%%                10000 ->
%%                    noop;
%%                _ ->
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SERVER_ADJUST_VALUE, 10000),
%%                    api_player:notice_player_xiu_zhen_value(PlayerId, [{2, 10000}])
%%            end
%%        end,
%%        mod_player:get_all_player_id()
%%    ),
%%    logger2:write(player_fight_log, clean).
%%
%%%%check() ->
%%%%    ?INFO("检测修正"),
%%%%    erlang:send_after(?SD_SERVER_XIUZHENG_TIME, self(), check),
%%%%    noop.
%%
%%%%服务器修正
%%handle_add_server_adjust_cost(Add) ->
%%    V = mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_COST),
%%    mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_COST, Add + V).
%%
%%handle_add_server_adjust_award(Add) ->
%%    V = mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD),
%%    mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD, Add + V).
%%
%%check_server_adjust() ->
%%    erlang:send_after(?SD_SERVER_XIUZHENG_TIME, self(), check),
%%
%%    Award = mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD),
%%    Cost = mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_COST),
%%
%%    [AMin, AMax] = ?SD_SERVER_XIUZHENG_INOPERATIVE_RANGE,
%%    [BMin, BMax] = ?SD_SERVER_XIUZHENG_RESET_RANGE,
%%    A = Award - Cost * ?SD_SERVER_XIUZHENG_EXPECT / 10000,
%%%%    ?INFO("服務器檢測修正:~p", [{Award, Cost, A, Award / (Cost + 1) * 10000, ?SD_SERVER_XIUZHENG_INOPERATIVE_RANGE, ?SD_SERVER_XIUZHENG_RESET_RANGE, ?SD_SERVER_XIUZHENG}]),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            case get_player_server_adjust_rate(PlayerId) of
%%                10000 ->
%%                    noop;
%%                _ ->
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SERVER_ADJUST_VALUE, 10000),
%%                    api_player:notice_player_xiu_zhen_value(PlayerId, [{2, 10000}])
%%            end
%%        end,
%%        mod_player:get_all_player_id()
%%    ),
%%    if
%%        Award > 200000 orelse Cost > 200000 ->
%%            {NewAward, NewCost} =
%%                if
%%                    Award >= Cost ->
%%                        {Award - (Cost / 2 / 10000 * ?SD_SERVER_XIUZHENG_EXPECT), Cost / 2};
%%                    true ->
%%                        {Award / 2, Cost - (Award / 2 / ?SD_SERVER_XIUZHENG_EXPECT * 10000)}
%%                end,
%%            mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_COST, util:to_int(NewCost)),
%%            mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD, util:to_int(NewAward));
%%        true ->
%%            noop
%%    end,
%%    if A >= AMin andalso A =< AMax ->
%%        Adjust =
%%            [
%%%%                {time, util_time:format_datetime()},  %% 玩家id
%%                {type, server_adjust}, %% 次数id
%%                {action, ignore}, %% 次数id
%%                {award, Award},
%%                {cost, Cost},
%%                {sign_player_list, []}
%%            ],
%%        logger2:write(player_fight_log, Adjust),
%%        logger2:write(server_adjust_log, Adjust),
%%        ?INFO("忽略:~p", [{Award, Cost, A, [AMin, AMax]}]);
%%        true ->
%%            B = Award / (Cost + 1) * 10000,
%%            if B >= BMin andalso B =< BMax ->
%%                Adjust = [
%%%%                        {time, util_time:format_datetime()},  %% 玩家id
%%                    {type, server_adjust}, %% 次数id
%%                    {action, clean}, %% 次数id
%%                    {award, Award},
%%                    {cost, Cost},
%%                    {player_list, []}
%%                ],
%%                logger2:write(player_fight_log, Adjust),
%%                logger2:write(server_adjust_log, Adjust),
%%                mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_COST, 0),
%%                mod_server_data:set_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD, 0),
%%                ?INFO("清空:~p", [{Award, Cost, B, [BMin, BMax]}]);
%%                true ->
%%                    Element = lists:foldl(
%%                        fun([Min1, Max1, L], Tmp) ->
%%                            if Tmp == null andalso B >= Min1 andalso (B =< Max1 orelse Max1 == 0) ->
%%                                L;
%%                                true ->
%%                                    Tmp
%%                            end
%%                        end,
%%                        null,
%%                        ?SD_SERVER_XIUZHENG
%%                    ),
%%                    Sum = lists:sum([R1 || [_, R1] <- Element]),
%%%%                    PlayerIdList = mod_player:get_all_player_id(),
%%                    PlayerIdList = mod_online:get_all_online_player_id(),
%%                    PlayerIdList11 = lists:foldl(
%%                        fun(ThisPlayerId, Tmp) ->
%%                            case mod_phone_unique_id:get_is_newbee_adjust(ThisPlayerId) of
%%                                true ->
%%                                    Tmp;
%%                                _ ->
%%                                    [ThisPlayerId | Tmp]
%%                            end
%%                        end,
%%                        [],
%%                        PlayerIdList
%%                    ),
%%                    Len = length(PlayerIdList11),
%%                    PlayerIdList12 = util_list:shuffle(PlayerIdList11),
%%                    L2 =
%%                        lists:foldl(
%%                            fun([Rate, NumRate], Tmp) ->
%%                                lists:duplicate(ceil(NumRate / Sum * Len), Rate) ++ Tmp
%%                            end,
%%                            [],
%%                            Element
%%                        ),
%%                    ?INFO("LL:~p", [{L2, length(PlayerIdList12)}]),
%%                    {_, SignList} =
%%                        lists:foldl(
%%                            fun(ThisPlayerId, {Tmp, SignL}) ->
%%                                [H | L] = Tmp,
%%                                mod_player_game_data:set_int_data(ThisPlayerId, ?PLAYER_GAME_DATA_SERVER_ADJUST_VALUE, H),
%%                                api_player:notice_player_xiu_zhen_value(ThisPlayerId, [{2, H}]),
%%%%                                api_player:notice_player_adjust_value(ThisPlayerId),
%%                                Len0 = length(Tmp),
%%                                if Len0 == 1 ->
%%                                    {Tmp, [{ThisPlayerId, H} | SignL]};
%%                                    true ->
%%                                        {L, [{ThisPlayerId, H} | SignL]}
%%                                end
%%                            end,
%%                            {L2, []},
%%                            PlayerIdList12
%%                        ),
%%                    Adjust = [
%%%%                            {time, util_time:format_datetime()},  %% 玩家id
%%                        {type, server_adjust}, %% 次数id
%%                        {action, sign}, %% 次数id
%%                        {award, Award},
%%                        {cost, Cost},
%%                        {player_list, SignList}
%%                    ],
%%                    logger2:write(player_fight_log, Adjust),
%%                    logger2:write(server_adjust_log, Adjust)
%%            end
%%    end.
%%
%%get_player_server_adjust_rate(PlayerId) ->
%%    case mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_SERVER_ADJUST_VALUE, -1) of
%%        -1 ->
%%            10000;
%%        V ->
%%            V
%%    end.
