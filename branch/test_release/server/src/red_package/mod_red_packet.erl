%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, THYZ
%%% @doc        红包
%%% Created : 17. 六月 2019 10:44
%%%-------------------------------------------------------------------
-module(mod_red_packet).

%% API
-export([
    add_send_individual_red/3,  %% 增加发送个人红包
    send_red_packet/2,  %% 发送红包
    send_red_packet/4,  %% 发送红包
    add_red_packet_condition/2,
    get_red_packet/2    %% 领取红包
]).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 增加发送个人红包
add_send_individual_red(PlayerId, IndividualRedConditionIdList, Value) ->
    IndividualRedConditionIdL = util_list:rSortKeyList([2], IndividualRedConditionIdList),
    IndividualRedConditionId = calc_red_packet(IndividualRedConditionIdL, Value),
%%    ?DEBUG("增加发送个人红包:~p~n", [{IndividualRedConditionIdL, IndividualRedConditionId, Value}]),
    if
        IndividualRedConditionId > 0 ->
            send_red_packet(PlayerId, IndividualRedConditionId);
        true ->
            noop
    end.
%% 计算发送红包条件id
calc_red_packet([], _Value) ->
    0;
calc_red_packet([{IndividualRedConditionId, NeedValue} | IndividualRedConditionIdL], Value) ->
    if
        Value >= NeedValue ->
            IndividualRedConditionId;
        true ->
            calc_red_packet(IndividualRedConditionIdL, Value)
    end.
%% 发送红包
send_red_packet(PlayerId, Id) ->
    send_red_packet(PlayerId, Id, {}).
%% 发送红包(id:红包条件id, 玩家id, 武器倍率, 场景倍率)
send_red_packet(Id, PlayerId, WeaponRate, SceneRate) ->
    send_red_packet(PlayerId, Id, {PlayerId, WeaponRate, SceneRate}).
send_red_packet(PlayerId, Id, Tuple) ->
    NotQueueId = hd(?SD_MONSTER_EFFECT2_LIST),
    IsQueue =
        if
            NotQueueId == Id -> false;
            true -> true
        end,
    red_packet_srv:cast({send_red_packet, PlayerId, Id, IsQueue, Tuple}).

%% 增加红包多人触发公共条件
add_red_packet_condition(RedConditionIdList, Value) ->
    red_packet_srv:cast({add_red_packet_condition, RedConditionIdList, Value}).

%% 领取红包
get_red_packet(PlayerId, RId) ->
    case catch red_packet_srv:call({get_red_packet, PlayerId, RId}) of
        {ok, AwardList} ->
            {ok, AwardList};
        R ->
            case R of
                {'EXIT', Reason} ->
                    exit(Reason);
                _ ->
                    R
            end
    end.
