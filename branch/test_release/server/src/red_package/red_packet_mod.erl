%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 20. 九月 2018 20:46
%%%-------------------------------------------------------------------
-module(red_packet_mod).
-author("home").

%% API
-export([
    send_red_packet/1,      %% 发送红包
    send_red_packet/3,
    get_red_packet/2,       %% 领取红包
    add_red_packet_condition/2, %% 增加红包多人触发公共条件12
    get_t_red_condition/1
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

-define(ROUND_MULTIPLY_VALUE, 100000). % 红包轮数乘积数

%% 发送红包
send_red_packet(Id) ->
    send_red_packet(0, Id, {}).
send_red_packet(PlayerId, IdList, Tuple) when is_list(IdList) ->
    [send_red_packet(PlayerId, Id, Tuple) || Id <- IdList];
send_red_packet(PlayerId, Id, Tuple) ->
    #t_red_condition{
        type = Type,
        red_number_list = [Min, Max],
        red_time = RedTime,
        content_list = ContentList,
        is_individual = IsIndividual
    } = get_t_red_condition(Id),
    Num = util_random:random_number(Min, Max),
    IdL = logic_get_red_packet_id_by_type_list(Type),
    IdList = lists:sublist(util_list:shuffle(IdL), Num),
    Round = mod_server_data:get_int_data(?SERVER_DATA_RED_PACKET_ROUND_ID) + 1,
    ClearTime = util_time:timestamp() + RedTime,
    {PlayerIdL, WeaponRate, SceneRate} =
        case Tuple of
            {PlayerId1, WeaponRate1, SceneRate1} ->
                {[PlayerId1], WeaponRate1, SceneRate1};
            _ ->
                {mod_online:get_all_online_player_id(), 0, 0}
        end,
%%    ?DEBUG("发送红包:~p~n", [{Type, ContentList, PlayerId}]),
    ParamList =
        if
            IsIndividual == 0 ->
                Name = mod_player:get_player_name_to_binary(PlayerId),
                ConditionsKey =
                    case ContentList of
                        [ConditionsKey1, _Value] ->
                            ConditionsKey1;
                        _ ->
                            ?WARNING("条件未处理")
                    end,
                case ConditionsKey of
                    ?CON_ENUM_RECHARGE_MONEY_DALIY ->
                        [Name];
                    _ ->
                        []
                end;
            true ->
                []
        end,
    NoticeL =
        lists:foldl(
            fun(RedId, L) ->
                RId = Round * ?ROUND_MULTIPLY_VALUE + RedId,
                Ets = get_ets_red_packet_record(RId),
                insert_ets_red_packet_record(Ets#ets_red_packet_record{round = Round, id = RedId, state = ?AWARD_CAN, weapon_rate = WeaponRate, scene_rate = SceneRate}),
                [{RedId, RId, ClearTime} | L]
            end, [], IdList
        ),
    mod_server_data:set_int_data(?SERVER_DATA_RED_PACKET_ROUND_ID, Round),
    api_red_packet:notice_player_red_packet(PlayerIdL, {Id, NoticeL, ParamList}).


%% @doc 领取红包
get_red_packet(PlayerId, RId) ->
%%    ?INFO("领取红包:~p~n", [{PlayerId, CampId, Id, ServerId, ObjCampId}]),
    #ets_red_packet_record{
        state = State,
        id = Id,
        weapon_rate = WeaponRate,
        scene_rate = SceneRate
    } = get_ets_red_packet_record(RId),
    ?ASSERT(State == ?AWARD_CAN, ?ERROR_FAIL),
    #t_red_package{
        reward_list = RewardL,
        type = Type
    } = get_t_red_package(Id),
    [RedType, RedRate] = ?SD_MONSTER_EFFECT2_LIST,
    {PlayerIdList, RewardList} =
        if
            Type == RedType ->
                Rate = WeaponRate / 10000 * SceneRate / 10000 * RedRate / 10000,
                NewRewardL =
                    lists:foldl(
                        fun([ItemType, ItemId, ItemNum], L) ->
                            Num = trunc(ItemNum * Rate),
                            NewItemNum =
                                if
                                    Num > 0 ->
                                        Num;
                                    true ->
                                        1
                                end,
                            [[ItemType, ItemId, NewItemNum] | L]
                        end, [], RewardL
                    ),
                {[], NewRewardL};
            true ->
                {mod_online:get_all_online_player_id() -- [PlayerId], RewardL}
        end,
    case ets:lookup(?ETS_RED_PACKET_RECORD, RId) of
        [Ets] ->
            Ets;
        _ ->
            exit(?ERROR_FAIL)
    end,
    SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
    NewRewardList =
        if
            SceneId == 999 ->
                lists:map(
                    fun([ThisId, ThisNum]) ->
                        NewThisId = api_fight:get_item_id(SceneId, ThisId),
                        [NewThisId, ThisNum]
                    end,
                    RewardList
                );
            true ->
                RewardList
        end,
    Tran =
        fun() ->
            clear_ets_red_packet_record(RId),
            mod_award:give(PlayerId, NewRewardList, ?LOG_TYPE_RED_PACKET_AWARD),
            api_red_packet:notice_player_red_packet_clear(PlayerIdList, [RId]),
            {ok, NewRewardList}
        end,
    db:do(Tran).

%% 增加红包多人触发公共条件
add_red_packet_condition(RedConditionIdList, AddValue) ->
    CurrTime = util_time:timestamp(),
    Tran =
        fun() ->
            RedConditionIdL =
                lists:foldl(
                    fun({RedConditionId, NeedValue}, L) ->
                        DbRed = get_db_red_packet_condition_init(RedConditionId),
                        Value = DbRed#db_red_packet_condition.value + AddValue,
                        {NewValue, List} =
                            if
                                Value >= NeedValue ->
                                    {0, [RedConditionId | L]};
                                true ->
                                    {Value, L}
                            end,
                        db:write(DbRed#db_red_packet_condition{value = NewValue, change_time = CurrTime}),
                        List
                    end, [], RedConditionIdList
                ),
            send_red_packet(RedConditionIdL)
        end,
    db:do(Tran).

%% ================================================ 数据操作 ================================================
%% 获得红包条件数据表
get_db_red_packet_condition(RedConditionId) ->
    db:read(#key_red_packet_condition{id = RedConditionId}).

%% 获得红包条件数据表    并初始化
get_db_red_packet_condition_init(RedConditionId) ->
    case get_db_red_packet_condition(RedConditionId) of
        DbR when is_record(DbR, db_red_packet_condition) ->
            DbR;
        _ ->
            #db_red_packet_condition{id = RedConditionId}
    end.
%% ================================================ ets数据操作 ================================================
%% 获得红包数据
get_ets_red_packet_record(RId) ->
    case ets:lookup(?ETS_RED_PACKET_RECORD, RId) of
        [Ets] ->
            Ets;
        _ ->
            #ets_red_packet_record{r_id = RId}
    end.

%%插入红包信息
insert_ets_red_packet_record(Ets) ->
    ets:insert(ets_red_packet_record, Ets).

%% 清除红包信息
clear_ets_red_packet_record(RId) ->
    ets:delete(?ETS_RED_PACKET_RECORD, RId).
%%    Ets = get_ets_red_packet_round(RId),
%%    insert_ets_answer_activity_recode_value(Ets#ets_answer_activity_recode_value{answer_player_data = [], value = 0}).

%%================================================ 模板操作 ==================================================
%% @doc 获得红包模板数据
get_t_red_package(Id) ->
    t_red_package:assert_get({Id}).

%% @doc 获得红包id列表
get_t_red_condition(Id) ->
    t_red_condition:assert_get({Id}).

logic_get_red_packet_id_by_type_list(Type) ->
    logic_get_red_packet_id_by_type_list:get(Type, []).
