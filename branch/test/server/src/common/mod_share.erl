%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            分享
%%% @end
%%% Created : 20. 六月 2016 下午 1:46
%%%-------------------------------------------------------------------
-module(mod_share).
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("promote.hrl").
%% API
-export([
    deal_invite/4,                  %% 处理邀请
    is_valid_friend_code/1,
%%    do_deal_invite/5,
    do_deal_invite_2/3,
    finish_conditions/2,            %% 完成分享条件
    do_finish_conditions/5,
    do_finish_conditions_2/3,
    get_share_type/1                %% 获取分享类型
]).

%% ----------------------------------
%% @doc 	处理好友邀请
%% @throws 	none
%% @end
%% ----------------------------------
deal_invite(AccId, PlayerId, FriendCode, NickName) ->
%%    noop.
    ?DEBUG("deal_invite:~p", [FriendCode]),
%%    [ShareSid, SharePlayerId] = string:split(FriendCode, "_"),
    PlatformId = mod_server_config:get_platform_id(),
    SharePlayerId = util_unique_invitation_code:decode(FriendCode),
    promote_srv:cast_do_deal_invite(PlatformId, PlayerId, SharePlayerId, AccId, NickName).

do_deal_invite_2(PlayerId, InviteAccId, ShareType) ->
    mod_platform_function:invite_friend(PlayerId, InviteAccId, ShareType).

%% ----------------------------------
%% @doc 	好友完成条件触发
%% @throws 	none
%% @end
%% ----------------------------------
finish_conditions(PlayerId, TaskTypeList) ->
    ?DEBUG("finish_conditions:~p", [TaskTypeList]),
    Player = mod_player:get_player(PlayerId),
    #db_player{
        friend_code = FriendCode,
        acc_id = AccId
    } = Player,
    if FriendCode == "" ->
        noop;
        FriendCode == "undefined" ->
            noop;
        true ->
            {ShareSid, SharePlayerId, _} = decode_friend_code(FriendCode),
%%            [ShareSid, SharePlayerId] = string:split(FriendCode, "_"),
            PlatformId = mod_server_config:get_platform_id(),
%%            IntSharePlayerId = util:to_int(SharePlayerId),
            mod_server_rpc:cast_center(mod_share, do_finish_conditions, [PlatformId, ShareSid, SharePlayerId, TaskTypeList, AccId])
    end.


do_finish_conditions(PlatformId, ServerId, PlayerId, TaskTypeList, AccId) ->
%%    mod_apply:apply_to_online_player(mod_share, do_finish_conditions_2, [PlayerId, TaskTypeList, AccId], store),
    mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_apply, apply_to_online_player, [PlayerId, mod_share, do_finish_conditions_2, [PlayerId, TaskTypeList, AccId], store]).
%%    mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_platform_function, add_player_share, [PlayerId, TaskTypeList, AccId]).

do_finish_conditions_2(PlayerId, TaskTypeList, AccId) ->
    mod_platform_function:add_player_share(PlayerId, TaskTypeList, AccId).

%% ----------------------------------
%% @doc 	解析分享码
%% @throws 	none
%% @end
%% ----------------------------------
decode_friend_code(FriendCode) ->
%%    [ShareSid, SharePlayerId] = string:split(FriendCode, "_"),
    [ShareSid, SharePlayerId | _] = string:tokens(FriendCode, "_"),
%%    ?DEBUG("~p", [{ [ShareSid, SharePlayerId, ShareType]}]),
%%    {ShareSid, util:to_int(SharePlayerId), ?SHARE_TYPE_SHARE_NORMAL}.
    {ShareSid, util:to_int(SharePlayerId), 1}.


%% ----------------------------------
%% @doc 	是否有效分享码
%% @throws 	none
%% @end
%% ----------------------------------
is_valid_friend_code("") ->
    true;
is_valid_friend_code(FriendCode) ->
    try decode_friend_code(FriendCode) of
        _ ->
            true
    catch
        _:_ ->
            false
    end.
%% ----------------------------------
%% @doc 	分享类型
%% @throws 	none
%% @end
%% ----------------------------------
get_share_type(PlayerId) ->
%%    #db_player{
%%        friend_code = FriendCode
%%    } = mod_player:get_player(PlayerId),
    1.
%%    if FriendCode == "" ->
%%        0;
%%        FriendCode == "undefined" ->
%%            0;
%%        true ->
%%            {_, _, ShareType} = decode_friend_code(FriendCode),
%%            ShareType
%%    end.


