%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 17. 四月 2018 21:28
%%%-------------------------------------------------------------------
-module(api_sys_common).
-author("home").

%% API\
-export([
    init_player_sys_data/1,     %% 玩家初始化时给系统数据
    change_state/2,             %% 替换装备
    notice_sys_common/2         %% 通知公共系统数据变更
]).

-include("common.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
-include("p_message.hrl").

%% @fun 玩家初始化时给系统数据
init_player_sys_data(PlayerId) ->
    pack_sys_common_data_list(mod_sys_common:init_player_sys_data(PlayerId)).

%% @doc 替换装备
change_state(
    #m_sys_common_change_state_tos{id = Id},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("替换装备", Id),
    Result = api_common:api_result_to_enum(catch mod_sys_common:change_state(PlayerId, Id)),
    Out = proto:encode(#m_sys_common_change_state_toc{result = Result, id = Id}),
    mod_socket:send(Out),
    State.

%% 通知公共系统数据变更
notice_sys_common(PlayerId, SysCommonDataList)->
    ?DEBUG("通知公共系统数据变更:~p~n", [SysCommonDataList]),
    Out = proto:encode(#m_sys_common_notice_sys_common_toc{sysCommonDataList = pack_sys_common_data_list(SysCommonDataList)}),
    mod_socket:send(PlayerId, Out).

%% @fun 打包系统数据列表
pack_sys_common_data_list(List) ->
    [#syscommondata{id = Id, state = State} || {Id, State} <- List].
