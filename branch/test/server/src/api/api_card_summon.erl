%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      API 图鉴召唤
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(api_card_summon).
-author("yizhao.wang").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    do_summon/2
]).

%% @doc 召唤
do_summon(
    #m_card_summon_do_summon_tos{
        type = Type
    },
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropList} =
        case catch mod_card_summon:do_summon(PlayerId, Type) of
            {ok, _PropList} ->
                {?P_SUCCESS, _PropList};
            {'EXIT', Error} ->
                {api_common:api_error_to_enum(Error), []}
        end,
    Out = proto:encode(#m_card_summon_do_summon_toc{
        result = Result,
        prop_list = api_prop:pack_prop_list(PropList)
    }),
    mod_socket:send(Out),
    State.