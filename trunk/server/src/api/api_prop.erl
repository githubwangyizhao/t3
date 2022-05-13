%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017
%%% @doc
%%% @end
%%% Created : 16. 十一月 2017 下午 7:47
%%%-------------------------------------------------------------------
-module(api_prop).
-include("p_message.hrl").
-include("gen/db.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-export([
    use_item/2,
    sell_item/2,
    merge/2,
    pack_all_player_prop_list/1,
    notice_update_prop/3,
    pack_prop_list/1
]).

-export([
    do_notice_update_prop/3
]).

%% ----------------------------------
%% @doc  使用物品
%% @throws 	none
%% @end
%% ----------------------------------
use_item(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_prop_use_item_tos{item_id = ItemId, num = Num} = Msg,
    ?REQUEST_INFO("使用物品"),
    {Result, PropList} =
        try mod_prop:use_item(PlayerId, ItemId, Num) of
            {ok, RealGiveProps_} ->
                {?P_SUCCESS, RealGiveProps_}
        catch
            _:?ERROR_NO_CONDITION ->
                {?P_NO_CONDITION, []};
            _:Reason ->
                ?ERROR("使用物品:~p", [{Reason, Msg, erlang:get_stacktrace()}]),
                {?P_FAIL, []}
        end,
    Out = proto:encode(#m_prop_use_item_toc{
        result = Result,
        item_id = ItemId,
        num = Num,
        prop_list = pack_prop_list(PropList)
    }),
    mod_socket:send(Out),
    State.


%% ----------------------------------
%% @doc  出售物品
%% @throws 	none
%% @end
%% ----------------------------------
sell_item(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_prop_sell_item_tos{item_id = ItemId, num = Num} = Msg,
    ?REQUEST_INFO("出售物品"),
    {Result, PropList} =
        try mod_prop:sell_item(PlayerId, ItemId, Num) of
            {ok, PropList1} ->
                {?P_SUCCESS, PropList1}
        catch
            _:Reason ->
                ?ERROR("出售物品:~p", [{Reason, Msg, erlang:get_stacktrace()}]),
                {?P_FAIL, []}
        end,
    NewPropList = pack_prop_list(PropList),
    Out = proto:encode(#m_prop_sell_item_toc{result = Result, item_id = ItemId, num = Num, prop_list = NewPropList}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc  合成物品
%% @throws 	none
%% @end
%% ----------------------------------
merge(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_prop_merge_tos{id = MergeId, num = Num} = Msg,
    Result =
        try mod_prop:merge(PlayerId, MergeId, Num) of
            ok ->
                ?P_SUCCESS
        catch
            _:Reason ->
                ?ERROR("合成物品:~p", [{Reason, Msg, erlang:get_stacktrace()}]),
                api_common:api_error_to_enum(Reason)
        end,
    Out = proto:encode(#m_prop_merge_toc{result = Result, id = MergeId, num = Num}),
    mod_socket:send(Out),
    State.

pack_all_player_prop_list(PlayerId) ->
    [
        pack_player_prop(PlayerProp)
        ||
        PlayerProp <- mod_prop:get_all_player_prop(PlayerId)
    ].

pack_player_prop(#db_player_prop{prop_id = PropId, num = Num, expire_time = 0}) ->
    #prop{prop_id = PropId, num = Num};
%%pack_player_prop(#db_player_prop{prop_id = PropId, num = Num, expire_time = ExpireTime}) ->
%%    #prop{prop_id = PropId, num = Num, expire_time = ExpireTime}.
pack_player_prop(#db_player_prop{prop_id = PropId, num = Num}) ->
    #prop{prop_id = PropId, num = Num}.

pack_prop_list(L) ->
    pack_prop_list(L, []).
pack_prop_list([], PackList) ->
    PackList;
pack_prop_list([Tuple | T], PackList) ->
    {PropId, Num} = mod_prop:tran_prop(Tuple),
    pack_prop_list(T, [#prop{prop_id = PropId, num = Num} | PackList]).

%% ----------------------------------
%% @doc 	通知道具更新
%% @throws 	none
%% @end
%% ----------------------------------
notice_update_prop(PlayerId, PlayerProp, LogType) ->
    PlayerProp_1 = PlayerProp#db_player_prop{
        row_key = #key_player_prop{
            player_id = PlayerId,
            prop_id = PlayerProp#db_player_prop.prop_id
        }
    },
    MergeFun =
        fun([APlayerId, APlayerPropList, AThisLotType], B) ->
            case B of
                ?UNDEFINED ->
                    [APlayerId, APlayerPropList, AThisLotType];
                [BPlayerId, BPlayerPropList, BLotType] ->
                    NewPlayerPropList =
                        lists:foldl(
                            fun(ThisPlayerProp, Tmp) ->
                                [ThisPlayerProp | lists:keydelete(ThisPlayerProp#db_player_prop.row_key, #db_player_prop.row_key, Tmp)]
                            end,
                            BPlayerPropList,
                            APlayerPropList
                        ),
                    [BPlayerId, NewPlayerPropList, BLotType]
            end
        end,
    db:tran_merge_apply_2({?MODULE, do_notice_update_prop, [PlayerId, [PlayerProp_1], LogType]}, MergeFun).

do_notice_update_prop(PlayerId, PlayerPropList, LogType) ->
    PropList = [pack_player_prop(PlayerProp) || PlayerProp <- lists:reverse(PlayerPropList)],
    Out = proto:encode(#m_prop_notice_update_prop_toc{prop_list = PropList, log_type = LogType}),
    mod_socket:send(PlayerId, Out).