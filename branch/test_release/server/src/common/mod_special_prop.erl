%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         特殊道具(时空胶囊)
%%% @end
%%% Created : 15. 7月 2021 下午 02:28:24
%%%-------------------------------------------------------------------
-module(mod_special_prop).
-author("Administrator").

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").
-include("client.hrl").

%% API
-export([
    get_init_data_list/1,

    special_prop_merge/2,
    sell_special_prop/2,

    award_special_prop/4,
    get_special_prop_num/1
]).

-export([
    try_deal_expire_special_prop_before_enter_game/1,
    clean_player_prop/2
]).

%% @doc 获得初始化数据列表
get_init_data_list(PlayerId) ->
    [{PropObjId, PropId, 1, ExpireTime} || #db_player_special_prop{prop_obj_id = PropObjId, prop_id = PropId, expire_time = ExpireTime} <- get_db_player_special_prop_list(PlayerId)].

%% @doc 特殊道具合成(时空转换)
special_prop_merge(PlayerId, PropObjId) ->
    DbPlayerSpecialProp = get_db_player_special_prop(PlayerId, PropObjId),
    ?ASSERT(DbPlayerSpecialProp /= null, ?ERROR_NO_ENOUGH_PROP),
    #db_player_special_prop{
        prop_id = PropId,
        expire_time = ExpireTime
    } = DbPlayerSpecialProp,
    #t_item{
        effect = Effect,
        special_effect_list = SpecialEffectList
    } = mod_item:get_t_item(PropId),
    NeedPropNum = Effect,
    CostPropList = [{?ITEM_TIME_GEM, NeedPropNum}],
    mod_prop:assert_prop_num(PlayerId, CostPropList),
    Now = util_time:timestamp(),
    ?ASSERT(ExpireTime >= Now, ?ERROR_NOT_AUTHORITY),
    AwardPropList = SpecialEffectList,
    mod_prop:assert_give(PlayerId, AwardPropList),
    Tran =
        fun() ->
            cost_special_prop(DbPlayerSpecialProp, ?LOG_TYPE_SKZH),
            mod_prop:decrease_player_prop(PlayerId, CostPropList, ?LOG_TYPE_SKZH),
            mod_award:give(PlayerId, AwardPropList, ?LOG_TYPE_SKZH)
        end,
    db:do(Tran),
    {ok, PropId}.

%% @doc 出售特殊道具
sell_special_prop(PlayerId, PropObjId) ->
    DbPlayerSpecialProp = get_db_player_special_prop(PlayerId, PropObjId),
    ?ASSERT(DbPlayerSpecialProp /= null, ?ERROR_NONE),
    #db_player_special_prop{
        prop_id = PropId,
        expire_time = ExpireTime
    } = DbPlayerSpecialProp,
    Now = util_time:timestamp(),
    ?ASSERT(Now > ExpireTime),
    #t_item{
        sale_price = SalePrice
    } = mod_item:get_t_item(PropId),
    ?ASSERT(SalePrice > 0),
    Tran =
        fun() ->
            cost_special_prop(DbPlayerSpecialProp, ?LOG_TYPE_SELL_ITEM),
            mod_award:give(PlayerId, [{?ITEM_GOLD, SalePrice}], ?LOG_TYPE_SELL_ITEM)
        end,
    db:do(Tran),
    ok.

%% @doc 奖励特殊道具
award_special_prop(PlayerId, PropId, Num, LogType) ->
    #t_item{
        sale_price = SalePrice,
        end_time = EndTime
    } = mod_item:get_t_item(PropId),
    OldPropObjMaxId = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SPECIAL_PROP_ID),
    NewPropObjMaxId = OldPropObjMaxId + Num,
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SPECIAL_PROP_ID, NewPropObjMaxId),
    ExpireTime = util_time:timestamp() + EndTime,
    List = lists:map(
        fun(PropObjId) ->
            db:write(#db_player_special_prop{player_id = PlayerId, prop_obj_id = PropObjId, prop_id = PropId, expire_time = ExpireTime}),
            if
                SalePrice > 0 andalso EndTime > 0 ->
                    util_timer:start_timer({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_SPECIAL_PROP, PropObjId}, EndTime * 1000);
                true ->
                    noop
            end,
            {PropObjId, PropId, 1, ExpireTime}
        end,
        lists:seq(OldPropObjMaxId + 1, NewPropObjMaxId)
    ),
    db:tran_apply(fun() -> api_special_prop:notice_update_special_prop(PlayerId, List, LogType) end).

%% @doc 消耗特殊道具
cost_special_prop(DbPlayerSpecialProp, LogType) ->
    #db_player_special_prop{
        player_id = PlayerId,
        prop_obj_id = PropObjId,
        prop_id = PropId
    } = DbPlayerSpecialProp,
    #t_item{
        sale_price = SalePrice,
        end_time = EndTime
    } = mod_item:get_t_item(PropId),
    if
        SalePrice > 0 andalso EndTime > 0 ->
            util_timer:cancel_timer({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_SPECIAL_PROP, PropObjId});
        true ->
            noop
    end,
    db:delete(DbPlayerSpecialProp),
    api_special_prop:notice_update_special_prop(PlayerId, [{PropObjId, PropId, 0, 0}], LogType).

%% @doc 获得玩家特殊道具数量
get_special_prop_num(PlayerId) ->
    length(get_db_player_special_prop_list(PlayerId)).

%% ----------------------------------
%% @doc 	进入游戏前处理有效期特殊道具
%% @throws 	none
%% @end
%% ----------------------------------
try_deal_expire_special_prop_before_enter_game(PlayerId) ->
    DbPlayerSpecialPropList = get_db_player_special_prop_list(PlayerId),
    Now = util_time:timestamp(),
    Tran = fun() ->
        lists:foreach(
            fun(DbPlayerSpecialProp) ->
                #db_player_special_prop{
                    prop_obj_id = PropObjId,
                    prop_id = PropId,
                    expire_time = ExpireTime
                } = DbPlayerSpecialProp,
                #t_item{
                    sale_price = SalePrice
                } = mod_item:get_t_item(PropId),
                if
                    SalePrice == 0 andalso ExpireTime > 0 ->
                        if Now > ExpireTime ->
                            db:delete(DbPlayerSpecialProp);
                            true ->
                                util_timer:start_timer({?CLIENT_WORKER_TIMER_CLEAN_EXPIRE_SPECIAL_PROP, PropObjId}, (ExpireTime - Now) * 1000)
                        end;
                    true ->
                        noop
                end
            end,
            DbPlayerSpecialPropList
        )
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	道具过期删除道具
%% @throws 	none
%% @end
%% ----------------------------------
clean_player_prop(PlayerId, PropObjId) ->
    clean_player_prop(get_db_player_special_prop(PlayerId, PropObjId)).
clean_player_prop(DbPlayerSpecialProp) ->
    ?INFO("清理过期特殊道具:~p", [DbPlayerSpecialProp]),
    #db_player_special_prop{
        player_id = PlayerId,
        prop_id = PropId,
        prop_obj_id = PropObjId
    } = DbPlayerSpecialProp,
    Tran =
        fun() ->
            db:delete(DbPlayerSpecialProp),
            api_special_prop:notice_update_special_prop(PlayerId, [{PropObjId, PropId, 0, 0}], ?LOG_TYPE_PROP_EXPIRE)
        end,
    db:do(Tran).

%% ================================================ 数据操作 ================================================

%% @doc DB 获得玩家特殊道具
get_db_player_special_prop(PlayerId, PropObjId) ->
    db:read(#key_player_special_prop{player_id = PlayerId, prop_obj_id = PropObjId}).
%%get_db_player_special_prop_init(PlayerId, PropObjId) ->
%%    case get_db_player_special_prop(PlayerId, PropObjId) of
%%        R when is_record(R, db_player_special_prop) ->
%%            R;
%%        _ ->
%%            #db_player_special_prop{
%%                player_id = PlayerId,
%%                prop_obj_id = PropObjId
%%            }
%%    end.

%% @doc DB 获得玩家特殊道具列表
get_db_player_special_prop_list(PlayerId) ->
    db_index:get_rows(#idx_player_special_prop_by_player{player_id = PlayerId}).