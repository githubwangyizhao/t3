%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         礼包码
%%% @end
%%% Created : 11. 8月 2021 上午 09:56:50
%%%-------------------------------------------------------------------
-module(api_gift_code).


%% API
-export([
    gift_code/2
]).

-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("error.hrl").
%%-include("gen/db.hrl").

%% 礼包兑换码
gift_code(#m_gift_code_gift_code_tos{gift_code_id = GiftCodeId},
    State = #conn{player_id = PlayerId}) ->
    {Result, PropList} =
        try
            mod_gift_code:get_award(PlayerId, util:to_list(GiftCodeId)) of
            {ok, AwardList} ->
                ?INFO("gift_code success:~p~n", [{GiftCodeId, AwardList}]),
                {?P_SUCCESS, AwardList}
        catch
            _:Reason ->
                ?ERROR("gift_code fail:~p~n", [{Reason, GiftCodeId}]),
                Result_0 =
                    case Reason of
                        ?ERROR_NOT_EXISTS ->
                            ?P_NOT_EXISTS;
                        ?ERROR_ALREADY_GET ->
                            ?P_ALREADY_GET;
                        ?ERROR_NOT_ENOUGH_GRID ->
                            ?P_NOT_ENOUGH_GRID;
                        ?ERROR_EXPIRE_REQUEST ->
                            ?P_EXPIRE;
                        ?ERROR_NOT_ENOUGH_VIP_LEVEL ->
                            ?P_VIP_LEVEL_LIMIT;
%%                        ?ERROR_INTERFACE_CD_TIME ->
%%                            ?P_TOO_QUICK;
                        _ ->
                            ?P_FAIL
                    end,
                {Result_0, []}
        end,
    Out = proto:encode(#m_gift_code_gift_code_toc{result = Result, item_list = api_prop:pack_prop_list(PropList)}),
    mod_socket:send(Out),
    State.
