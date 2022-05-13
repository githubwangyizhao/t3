%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         特殊道具(时空胶囊)
%%% @end
%%% Created : 15. 7月 2021 下午 02:11:46
%%%-------------------------------------------------------------------
-module(api_special_prop).
-author("Administrator").

-include("p_enum.hrl").
-include("p_message.hrl").
-include("common.hrl").

%% API
-export([
    %% @doc init_data
    notice_init_data/1,                     %% 通知初始化数据
    %% @doc function
    special_prop_merge/2,                   %% 特殊道具合成(时空转换)
    sell_special_prop/2,                    %% 特殊道具出售
    %% @doc notice
    notice_update_special_prop/3            %% 通知更新特殊道具
]).

%% @doc 通知初始化数据
notice_init_data(PlayerId) ->
    Out = proto:encode(#m_special_prop_notice_init_data_toc{prop_list = pack_pb_special_prop_list(mod_special_prop:get_init_data_list(PlayerId))}),
    mod_socket:send(PlayerId, Out).

%% @doc 特殊道具合成(时空转换)
special_prop_merge(
    #m_special_prop_special_prop_merge_tos{prop_obj_id = PropObjId},
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropId} = api_common:api_result_to_enum_by_many(catch mod_special_prop:special_prop_merge(PlayerId, PropObjId), [0]),
    Out = proto:encode(#m_special_prop_special_prop_merge_toc{result = Result, prop_id = PropId}),
    mod_socket:send(Out),
    State.

%% @doc 特殊道具出售
sell_special_prop(
    #m_special_prop_sell_special_prop_tos{prop_obj_id = PropObjId},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_special_prop:sell_special_prop(PlayerId, PropObjId)),
    Out = proto:encode(#m_special_prop_sell_special_prop_toc{result = Result, prop_obj_id = PropObjId}),
    mod_socket:send(Out),
    State.

%% @doc 通知更新特殊道具
notice_update_special_prop(PlayerId, List, LogType) ->
    Out = proto:encode(#m_special_prop_notice_update_special_prop_toc{prop_list = pack_pb_special_prop_list(List), log_type = LogType}),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc PB 结构化
pack_pb_special_prop_list(List) ->
    [pack_pb_special_prop(PropObjId, PropId, Num, ExpireTime) || {PropObjId, PropId, Num, ExpireTime} <- List].
pack_pb_special_prop(PropObjId, PropId, Num, ExpireTime) ->
    #specialprop{
        prop_obj_id = PropObjId,
        prop_id = PropId,
        num = Num,
        expire_time = ExpireTime
    }.