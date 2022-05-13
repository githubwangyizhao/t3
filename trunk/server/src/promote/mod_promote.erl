%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         推广
%%% @end
%%% Created : 09. 十二月 2020 下午 02:22:08
%%%-------------------------------------------------------------------
-module(mod_promote).
-author("Administrator").

-include("promote.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("gen/db.hrl").

%% API
-export([
    get_player_promote_data/1,

    get_award/1,
    charge/3,
    invitation_code/2,

    get_promote_record_list/1
]).

%% @doc 获得玩家推广数据
get_player_promote_data(PlayerId) ->
    {PlatformId, AccId} = get_platform_and_acc(PlayerId),
    mod_server_rpc:call_center(promote_srv_mod, get_player_promote_data, [PlatformId, AccId]).

%% @doc 获得推广记录列表
get_promote_record_list(PlayerId) ->
    {PlatformId, AccId} = get_platform_and_acc(PlayerId),
    promote_srv:call({?PROMOTE_GET_RECORD_LIST, PlatformId, AccId}).

%% @doc 获得奖励    vip经验其实是钻石   change_ingot其实是金币
get_award(PlayerId) ->
    {PlatformId, AccId} = get_platform_and_acc(PlayerId),
    ServerId = mod_player:get_player_server_id(PlayerId),
    {TotalMana, TotalVipExp} = promote_srv:call({?PROMOTE_GET_AWARD, PlatformId, AccId, PlayerId, ServerId}),
    ItemList = ?IF(TotalMana > 0, [{?ITEM_GOLD, TotalMana}], []) ++ ?IF(TotalVipExp > 0, [{?ITEM_RMB, TotalVipExp}], []),
    Tran =
        fun() ->
            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_PROMOTE_AWARD)
        end,
    db:do(Tran),
    {ok, TotalMana, TotalVipExp}.

%% @doc 充值回调    vip经验其实是钻石   change_ingot其实是金币
charge(PlayerId, ChargeIngot, VipExp) ->
    {PlatformId, AccId} = get_platform_and_acc(PlayerId),
    PlayerName = mod_player:get_player_name(PlayerId),
    promote_srv:cast({?PROMOTE_CHARGE, PlatformId, PlayerName, AccId, ChargeIngot, VipExp}).

%% @doc 邀请码
invitation_code(PlayerId, InvitationCode) ->
    #db_player{
        acc_id = InviteAccId,
        server_id = ServerId,
        nickname = NickName
    } = mod_player:get_player(PlayerId),
    PlatformId = mod_server_config:get_platform_id(),
    DoInvitationPlayerId = util_unique_invitation_code:decode(InvitationCode),
    promote_srv:call_do_deal_invite(PlatformId, PlayerId, DoInvitationPlayerId, InviteAccId, ServerId ++ "." ++ NickName).
%%    mod_server_rpc:call_center(promote_srv, do_deal_invite, [PlatformId,PlayerId, DoInvitationPlayerId, InviteAccId, ServerId ++ "." ++ NickName]).

get_platform_and_acc(PlayerId) ->
    AccId = mod_player:get_player_data(PlayerId, acc_id),
    PlatformId = mod_server_config:get_platform_id(),
    {PlatformId, AccId}.
