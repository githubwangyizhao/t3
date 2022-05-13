%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            道具模块
%%% @end
%%% Created : 01. 十二月 2017 下午 3:34
%%%-------------------------------------------------------------------
-module(mod_prop).
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("gen/table_db.hrl").
-include("client.hrl").
%% API
-export([
    use_item/3,                 %% 使用物品
    sell_item/3,                %% 出售物品
    merge/3,                    %% 合成物品
    check_prop_num/2,           %% 道具是否足够
    check_prop_num/3,
    check_give/2,               %% 检测是否能装的下
    check_give/3,
    assert_give/2,              %% 检测是否能装的下
    assert_give/3,
    assert_prop_num/2,          %% 校验道具是否足够
    assert_prop_num/3,
    rate_prop/2,
    get_player_prop/2,          %% 获取玩家道具
    get_all_player_prop/1,      %% 获取玩家所有道具
%%    get_empty_equip_grid_num/1, %% 获取玩家装备空格子数量
    get_max_grid_num/1,         %% 获取最大格子数量

    get_player_prop_num/2,      %% 获得玩家道具的数量
    get_link_prop_num/2,        %% 获取关联的道具数量

    decrease_player_prop/3,     %% 扣除道具列表
    decrease_player_prop/4,     %% 扣除道具


    add_player_prop/3,          %% 加道具列表
    add_player_prop/4,          %% 加道具

    clean_player_prop/2,

    add_cost_item_conditions/2, %% 增加消耗道具列表条件
    try_deal_expire_prop_before_enter_game/1  %% 进入游戏前处理有效期道具
]).

-export([
    gm_decrease_player_prop/2,  %% gm扣除道具列表
    gm_decrease_player_prop/3,  %% gm扣除道具列表
    clean_player_all_prop/1,    % 些方法外网不可用会删除玩家的全部物品数据(元宝，铜钱和其他全部数据)
    try_t_log_type/1,
    tran_prop/1,                %% 转换成元组
    merge_prop_list/1
]).

%% ----------------------------------
%% @doc 	使用物品
%% @throws 	none
%% @end
%% ----------------------------------
use_item(PlayerId, ItemId, Num) ->
    assert_prop_num(PlayerId, ItemId, Num),
    #t_item{
        type = ItemType,
        effect = Effect,
        condition_list = ConditionList
    } = mod_item:get_t_item(ItemId),
    ?DEBUG("使用物品~p~n", [{ItemId, ItemType, Effect}]),
    if ConditionList == [] ->
        noop;
        true ->
            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ConditionList), ?ERROR_NO_CONDITION)
    end,
    Tran =
        fun() ->
            PropLists =
                case ItemType of
                    ?IT_GIFT_PACKAGE ->
                        AwardId = Effect,
                        AwardList = mod_award:decode_award_2(AwardId, Num),
                        mod_service_player_log:add_log(PlayerId, {?SERVICE_LOG_BACKPACK_OPNE_BOX_TYPE_COUNT, ItemId}, Num),
                        mod_award:give(PlayerId, AwardList, ?LOG_TYPE_ITEM_OPEN_BOX);
                    _ ->
                        ?WARNING("使用物品未实现:~p", [{PlayerId, ItemId, Num, ItemType}]),
                        []
                end,
            decrease_player_prop(PlayerId, ItemId, Num, ?LOG_TYPE_USE_ITEM),
            {ok, PropLists}
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	出售物品
%% @throws 	none
%% @end
%% ----------------------------------
sell_item(PlayerId, ItemId, Num) ->
    #t_item{
        type = ItemType,
        sale_price = SalePrice
    } = mod_item:get_t_item(ItemId),
    ?ASSERT(ItemType =/= ?IT_TIME_ITEM),
    ?ASSERT(Num > 0),
    ?ASSERT(SalePrice > 0),
    ?ASSERT(check_prop_num(PlayerId, ItemId, Num)),
    AwardItemList = [{?ITEM_GOLD, Num * SalePrice}],
    Tran =
        fun() ->
            decrease_player_prop(PlayerId, [{ItemId, Num}], ?LOG_TYPE_SELL_ITEM),
            mod_award:give(PlayerId, AwardItemList, ?LOG_TYPE_SELL_ITEM)
        end,
    db:do(Tran),
    {ok, AwardItemList}.

%% ----------------------------------
%% @doc 	合成物品
%% @throws 	none
%% @end
%% ----------------------------------
merge(PlayerId, MergeId, Num) ->
    #t_merge{
        item_list = CostItemList,
        is_condition = IsCondition
    } = t_merge:assert_get({MergeId}),
    AwardPropId = MergeId,
    MergePropList = [{AwardPropId, Num}],
    assert_give(PlayerId, MergePropList),
    NewCostItemList = rate_prop(CostItemList, Num),
    assert_prop_num(PlayerId, NewCostItemList),
    Tran =
        fun() ->
            decrease_player_prop(PlayerId, NewCostItemList, ?LOG_TYPE_MERGE),
            mod_award:give(PlayerId, MergePropList, ?LOG_TYPE_MERGE),
            if
                IsCondition =:= ?TRUE ->
                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_PROP_MERGE, MergeId}, ?CONDITIONS_VALUE_ADD, Num});
                true ->
                    noop
            end
        end,
    db:do(Tran),
    ok.

%% @fun 获得玩家道具的数量
get_player_prop_num(PlayerId, PropId) ->
    #db_player_prop{
        num = Num
    } = get_player_prop(PlayerId, PropId),
    Num + get_link_prop_num(PlayerId, PropId).

%% @fun 转换成元组
tran_prop({PropId, Num}) when is_integer(PropId) andalso is_integer(Num) ->
    {PropId, Num};
tran_prop([PropId, Num]) when is_integer(PropId) andalso is_integer(Num) ->
    {PropId, Num};
tran_prop(Other) ->
    ?ERROR("转换prop 失败:~p", [Other]),
    exit(tran_prop_error).

%% ----------------------------------
%% @doc 	道具是否足够
%% @throws 	none
%% @end
%% ----------------------------------
check_prop_num(PlayerId, PropList) ->
    lists:all(
        fun(Prop) ->
            {PropId, Num} = tran_prop(Prop),
            check_prop_num(PlayerId, PropId, Num)
        end,
        PropList
    ).

check_prop_num(PlayerId, PropId, Num) ->
    ?ASSERT(Num > 0, ?ERROR_NUM_0),
    CurrNum = get_player_prop_num(PlayerId, PropId),
    CurrNum >= Num.

get_link_prop_num(PlayerId, PropId) ->
    #t_item{
        limite_item_list = LinkItemList
    } = t_item:get({PropId}),
    if LinkItemList == [] ->
        0;
        true ->
            lists:foldl(
                fun(ItemId, Tmp) ->
                    get_player_prop_num(PlayerId, ItemId) + Tmp
                end,
                0,
                LinkItemList
            )
    end.

%% ----------------------------------
%% @doc 	校验道具是否足够
%% @throws 	none
%% @end
%% ----------------------------------
assert_prop_num(PlayerId, {PropId, Num}) ->
    assert_prop_num(PlayerId, PropId, Num);
assert_prop_num(PlayerId, [PropId, Num]) when is_integer(PropId) andalso is_integer(Num) ->
    assert_prop_num(PlayerId, PropId, Num);
assert_prop_num(PlayerId, PropList) ->
    lists:foreach(
        fun(Prop) ->
            {PropId, Num} = tran_prop(Prop),
            assert_prop_num(PlayerId, PropId, Num)
        end,
        PropList
    ).

assert_prop_num(PlayerId, PropId, Num) ->
    ?ASSERT(check_prop_num(PlayerId, PropId, Num), ?ERROR_NO_ENOUGH_PROP).

%% ----------------------------------
%% @doc    检查是否可以装的下
%% @throws 	none
%% @end
%% ----------------------------------
check_give(PlayerId, PropList) ->
    check_grid(PlayerId, PropList).

check_give(PlayerId, PropId, Num) ->
    check_grid(PlayerId, [{PropId, Num}]).

%% ----------------------------------
%% @doc 	获取最大的格子数量
%% @throws 	none
%% @end
%% ----------------------------------
get_max_grid_num(_PlayerId) ->
    10000.

check_grid(PlayerId, PropList) ->
    MaxGridNum = get_max_grid_num(PlayerId),
    PlayerPropList = get_all_player_prop(PlayerId),
    NewPropList = lists:foldl(
        fun(Prop, Tmp) ->
            {PropId, Num} = tran_prop(Prop),
            case lists:keytake(PropId, #db_player_prop.prop_id, Tmp) of
                {value, R, Left} ->
                    [R#db_player_prop{
                        num = Num + R#db_player_prop.num
                    } | Left];
                false ->
                    [#db_player_prop{
                        prop_id = PropId,
                        num = Num
                    } | Tmp]
            end
        end,
        PlayerPropList,
        PropList
    ),
    GridNum = get_grid_num(NewPropList) + mod_special_prop:get_special_prop_num(PlayerId),
    GridNum =< MaxGridNum.

%% ----------------------------------
%% @doc 	计算占用的格子数量
%% @throws 	none
%% @end
%% ----------------------------------
get_grid_num(PlayerPropList) ->
    get_grid_num(PlayerPropList, 0).

get_grid_num([], N) ->
    N;
get_grid_num([H | L], N) ->
    #db_player_prop{
        prop_id = PropId,
        num = Num
    } = H,
    NewNum =
        case mod_item:get_t_item(PropId) of
            null ->
                1;
            R ->
                #t_item{
                    is_stacked = IsStacked,
                    type = Type
                } = R,
                #t_item_type{
                    idx_sort = IdxSort
                } = t_item_type:assert_get({Type}),
                if
                    IdxSort =< 0 ->
                        0;
                    IsStacked == ?TRUE ->
                        1;
                    true ->
                        Num
                end
        end + N,
    get_grid_num(L, NewNum).

%% ----------------------------------
%% @doc 	奖励 * 倍率
%% @throws 	none
%% @end
%% ----------------------------------
rate_prop([PropId, PropNum], Rate) when is_integer(PropId) andalso is_integer(PropNum) ->
    [{PropId, trunc(PropNum * Rate)}];
rate_prop(PropList, Rate) ->
    [
        begin
            {PropId, Num} = tran_prop(Prop),
            {PropId, trunc(Num * Rate)}
        end
        || Prop <- PropList
    ].

%% ----------------------------------
%% @doc    检查是否可以装的下
%% @throws 	none
%% @end
%% ----------------------------------
assert_give(PlayerId, [PropId, Num]) when is_integer(PropId) andalso is_integer(Num) ->
    assert_give(PlayerId, PropId, Num);
assert_give(PlayerId, PropList) ->
    ?ASSERT(check_give(PlayerId, PropList), ?ERROR_NOT_ENOUGH_GRID).

assert_give(PlayerId, PropId, Num) ->
    ?ASSERT(check_give(PlayerId, PropId, Num), ?ERROR_NOT_ENOUGH_GRID).

%% ----------------------------------
%% @doc 	扣除道具列表
%% @throws 	none
%% @end
%% ----------------------------------
decrease_player_prop(_PlayerId, [], _LogType) ->
    noop;
decrease_player_prop(PlayerId, [PropId, PropNum], LogType) when is_integer(PropId) andalso is_integer(PropNum) ->
    decrease_player_prop(PlayerId, PropId, PropNum, LogType);
decrease_player_prop(PlayerId, PropList, LogType) ->
    MergePropList = merge_prop_list(PropList),
    lists:foreach(
        fun(Prop) ->
            {PropId, Num} = tran_prop(Prop),
            decrease_player_prop(PlayerId, PropId, Num, LogType)
        end,
        MergePropList
    ).

decrease_player_prop(PlayerId, PropId, Num, LogType) ->
    if LogType == ?LOG_TYPE_COMPOUND_PROP ->
        noop;
        true ->
            ?TRY_CATCH(mod_log:add_game_cost_log(PlayerId, [[PropId, Num]]))
    end,
    ?ASSERT(Num >= 0),
    #t_item{
        limite_item_list = LinkItemList
    } = t_item:get({PropId}),
    if LinkItemList == [] ->
        change_player_prop(PlayerId, PropId, -Num, LogType);
        true ->
            %% 优先扣除关联的道具
            LeftNum = decrease_link_player_prop(PlayerId, PropId, LinkItemList, Num, LogType),
            if LeftNum > 0 ->
                %% 扣除完后， 再扣除该道具
                change_player_prop(PlayerId, PropId, -LeftNum, LogType);
                true ->
                    noop
            end
    end,
    if
%%            PropId == ?ITEM_XINSHOUFUDAI_1 ->
%%                mod_charge:update_is_open_charge(PlayerId);
        true ->
            noop
    end.

decrease_link_player_prop(PlayerId, PropId, LinkItemList, DecreaseNum, LogType) ->
    lists:foldl(
        fun(LinkItemId, LeftNum) ->
            if LeftNum > 0 ->
                Num = get_player_prop_num(PlayerId, LinkItemId),
                if Num > 0 ->
                    D = min(LeftNum, Num),
                    change_player_prop(PlayerId, LinkItemId, -D, LogType, PropId),
                    LeftNum - D;
                    true ->
                        LeftNum
                end;
                true ->
                    LeftNum
            end
        end,
        DecreaseNum,
        LinkItemList
    ).

%% ----------------------------------
%% @doc 	增加道具列表
%% @throws 	none
%% @end
%% ----------------------------------
add_player_prop(PlayerId, PropList, LogType) ->
    MergePropList = merge_prop_list(PropList),
    lists:foreach(
        fun(Prop) ->
            {PropId, Num} = tran_prop(Prop),
            add_player_prop(PlayerId, PropId, Num, LogType)
        end,
        MergePropList
    ),
    ok.

add_player_prop(PlayerId, PropId, Num, LogType) ->
    ?ASSERT(Num > 0),
    assert_give(PlayerId, [{PropId, Num}]),
    case logic_code:is_prop_exists(PropId) of
        true ->
            change_player_prop(PlayerId, PropId, Num, LogType);
        false ->
            ?ERROR("unkown item ~p", [PropId])
    end.

%% @fun 些方法外网不可用会删除玩家的全部物品数据(元宝，铜钱和其他全部数据)
clean_player_all_prop(PlayerId) ->
    lists:foreach(
        fun(R) ->
            Tran = fun() ->
%%                ?ERROR("删除未知道具:~p", [R]),
                db:delete(R),
                api_prop:notice_update_prop(PlayerId, R#db_player_prop{num = 0}, ?LOG_TYPE_GM)
                   end,
            db:do(Tran)
        end,
        get_all_player_prop(PlayerId)
    ).

change_player_prop(_PlayerId, _PropId, 0, _LogType, _ConditionPropId) ->
    noop;
change_player_prop(PlayerId, PropId, Num, LogType, ConditionPropId) ->
    change_player_prop(get_player_prop(PlayerId, PropId), Num, LogType, ConditionPropId).

%% ----------------------------------
%% @doc 	改变玩家道具
%% @throws 	none
%% @end
%% ----------------------------------
change_player_prop(PlayerId, PropId, Num, LogType) when is_integer(PlayerId) ->
    change_player_prop(PlayerId, PropId, Num, LogType, PropId);
change_player_prop(PlayerProp, ChangeNum, LogType, ConditionPropId) ->
%%    ?t_assert(LogType > 0, log_type_zero),
%%    ?t_assert(t_log_type:get({LogType}) =/= null, {unknow_log_type, LogType}),
    try_t_log_type(LogType),
    #db_player_prop{
        player_id = PlayerId,
        prop_id = PropId,
        num = OldNum,
        expire_time = ExpireTime
    } = PlayerProp,
    NewNum = OldNum + ChangeNum,

    ?ASSERT(NewNum >= 0, ?ERROR_NO_ENOUGH_PROP),

    NewPlayerProp = PlayerProp#db_player_prop{
        num = NewNum
    },
    Tran = fun() ->
        if NewNum == 0 ->
            db:delete(PlayerProp);
            true ->
                db:write(NewPlayerProp)
        end,
%%        ?DEBUG("change_player_prop:~p~n", [{PlayerId, PropType, PropId, LogType, ChangeNum, NewNum}]),
        mod_log:write_prop_change_log(PlayerId, PropId, LogType, ChangeNum, NewNum),
        if ChangeNum < 0 ->
            add_cost_item_conditions(PlayerId, ConditionPropId, erlang:abs(ChangeNum), LogType),
            %% 钩子 消耗道具
            hook:after_cost_prop(PlayerId, PropId, erlang:abs(ChangeNum), NewNum, LogType);
            true ->
                if ExpireTime > 0 ->
                    case util_timer:is_timer_exists({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, PropId}) of
                        true ->
                            noop;
                        false ->
                            %% 启动过期定时器
                            util_timer:start_timer({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, PropId}, (ExpireTime - util_time:timestamp()) * 1000)
                    end;
                    true ->
                        noop
                end
        end,
        hook:after_prop_num_charge(PlayerId, PropId, OldNum, NewNum, LogType),
        api_prop:notice_update_prop(PlayerId, NewPlayerProp, LogType)
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	获取玩家道具
%% @throws 	none
%% @end
%% ----------------------------------
get_player_prop(PlayerId, PropId) ->
    case db:read(#key_player_prop{player_id = PlayerId, prop_id = PropId}) of
        null ->
            #db_player_prop{
                player_id = PlayerId,
                prop_id = PropId,
                num = 0,
                expire_time = get_prop_expire_time(PropId)
            };
        R ->
            R
    end.

%% ----------------------------------
%% @doc 	获取道具过期时间
%% @throws 	none
%% @end
%% ----------------------------------
get_prop_expire_time(PropId) ->
    #t_item{
        expire_time_list = ExpireTimeList
    } = t_item:get({PropId}),
    case ExpireTimeList of
        [] ->
            0;
        [today] ->
            util_time:get_today_zero_timestamp() + 86400;
        [[Y, M, D], [HH, MM, SS]] ->
            util_time:datetime_to_timestamp({{Y, M, D}, {HH, MM, SS}});
        Other ->
            ?ERROR("道具过期时间错误:~p", [{PropId, Other}]),
            0
    end.

%% ----------------------------------
%% @doc 	进入游戏前处理有效期道具
%% @throws 	none
%% @end
%% ----------------------------------
try_deal_expire_prop_before_enter_game(PlayerId) ->
    PlayerPropList = get_all_player_prop(PlayerId),
    Now = util_time:timestamp(),
    Tran = fun() ->
        lists:foreach(
            fun(PlayerProp) ->
                #db_player_prop{
                    prop_id = PropId,
                    expire_time = ExpireTime
                } = PlayerProp,
                if ExpireTime > 0 ->
                    if Now > ExpireTime ->
                        clean_player_prop(PlayerProp);
                        true ->
                            util_timer:start_timer({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, PropId}, (ExpireTime - Now) * 1000)
                    end;
                    true ->
                        noop
                end
            end,
            PlayerPropList
        )
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	道具过期删除道具
%% @throws 	none
%% @end
%% ----------------------------------
clean_player_prop(PlayerId, PropId) ->
    clean_player_prop(get_player_prop(PlayerId, PropId)).
clean_player_prop(PlayerProp) ->
    ?INFO("清理过期道具:~p", [PlayerProp]),
    #db_player_prop{
        player_id = PlayerId,
        prop_id = PropId,
        num = Num
    } = PlayerProp,
    Tran = fun() ->
        db:delete(PlayerProp),
        api_prop:notice_update_prop(PlayerId, PlayerProp#db_player_prop{
            num = 0
        }, ?LOG_TYPE_PROP_EXPIRE),
        mod_log:write_prop_change_log(PlayerId, PropId, ?LOG_TYPE_PROP_EXPIRE, - Num, 0)
           end,
    db:do(Tran).


%% ----------------------------------
%% @doc 	获取玩家所有道具
%% @throws 	none
%% @end
%% ----------------------------------
get_all_player_prop(PlayerId) ->
    db_index:get_rows(#idx_player_prop_1{player_id = PlayerId}).

%% ----------------------------------
%% @doc 	整合道具列表
%% @throws 	none
%% @end
%% ----------------------------------
merge_prop_list([]) -> [];
merge_prop_list(PropList) ->
    lists:foldl(fun(Prop, PropAcc) ->
        case tran_prop(Prop) of
            {0, _} -> PropAcc;
            {_, 0} -> PropAcc;
            {PropId, N} ->
                case lists:keytake(PropId, 1, PropAcc) of
                    false ->
                        [{PropId, N} | PropAcc];
                    {value, {PropId, M}, PropAcc2} ->
                        [{PropId, M + N} | PropAcc2]
                end
        end
                end, [], PropList).

%% @fun 日志类型
try_t_log_type(LogType) ->
    t_log_type:assert_get({LogType}).

%% @fun 增加消耗道具列表条件
add_cost_item_conditions(_PlayerId, []) ->
    noop;
add_cost_item_conditions(PlayerId, [PropTuple | List]) ->
    {PropId, ChangeNum} = tran_prop(PropTuple),
    add_cost_item_conditions(PlayerId, PropId, ChangeNum, ?LOG_TYPE_SHOP_BUY),
    add_cost_item_conditions(PlayerId, List).

%% @fun 增加道具消耗条件
add_cost_item_conditions(PlayerId, PropId, ChangeNum, _LogType) ->
    case logic_get_is_conditions_item(PropId) of
        true ->
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_USE_ITEM_NUM, PropId}, ?CONDITIONS_VALUE_ADD, ChangeNum});
        _ ->
            noop
    end,
    case PropId of
%%        ?ITEM_GOLD ->
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CONSUMPTION_OF_GOLD, ?CONDITIONS_VALUE_ADD, ChangeNum});
%%        ?ITEM_MANA ->
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CONSUMPTION_OF_MANA, ?CONDITIONS_VALUE_ADD, ChangeNum});
        _ ->
            noop
    end.

%% ================================================ gm操作 ================================================
%% @fun gm扣除道具列表
gm_decrease_player_prop(PlayerId, ItemList) ->
    gm_decrease_player_prop(PlayerId, ItemList, normal).
gm_decrease_player_prop(PlayerId, ItemList, Type) ->
    mod_apply:apply_to_online_player(PlayerId, mod_prop, decrease_player_prop, [PlayerId, ItemList, ?LOG_TYPE_GM], Type).

%% ================================================ 模板操作 ================================================

%% @fun 获得加条件的消耗道具
logic_get_is_conditions_item(ItemId) ->
    logic_get_is_conditions_item:get(ItemId).
