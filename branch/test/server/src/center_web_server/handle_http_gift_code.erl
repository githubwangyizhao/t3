%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         礼包码
%%% @end
%%% Created : 11. 8月 2021 上午 09:56:50
%%%%%-------------------------------------------------------------------
-module(handle_http_gift_code).

-export([
    init/2
]).

-include("gen/table_enum.hrl").
-include("common.hrl").
-include("gift_code.hrl").

init(Req0, Opts) ->
    Path = cowboy_req:path(Req0),
    router(Path, Req0),
    {ok, Req0, Opts}.

router(<<"/add_gift_code">>, Req) ->
    %% 添加礼包码
    handle_add_gift_code(Req);
router(<<"/append_gift_code">>, Req) ->
    %% 追加礼包码
    handle_append_gift_code(Req);
router(<<"/delete_gift_code">>, Req) ->
    %% 删除礼包码
    handle_delete_gift_code(Req);
%%router(<<"/update_game_args">>, Req) ->
%%    %% 更新游戏参数
%%    handle_update_game_args(Req);
%%router(<<"/delete_game_args">>, Req) ->
%%    %% 删除游戏参数
%%    handle_delete_game_args(Req);
%%router(<<"/update_client_version">>, Req) ->
%%    %% 更新客户端版本
%%    platform_version:handle_update_version(Req);
router(<<"/ping">>, _Req) ->
    ok;
router(Path, Req) ->
    {Ip, _} = cowboy_req:peer(Req),
    ?WARNING("Path no match:~p; ip:~p", [Path, Ip]).

%%%% 更新游戏参数
%%handle_update_game_args(Req0) ->
%%    Fun = fun(Req, RequestParamList, _RequestData) ->
%%        Data = util_cowboy:decode_data(RequestParamList),
%%        JsonMap = util_json:decode(Data),
%%        PlatformId = util_maps:get_string(<<"platformId">>, JsonMap),
%%        Key = util_maps:get_string(<<"key">>, JsonMap),
%%        IntValue = util_maps:get_integer(<<"intValue">>, JsonMap),
%%        StrValue = util_maps:get_string(<<"strValue">>, JsonMap),
%%        Type = util_maps:get_integer(<<"type">>, JsonMap),
%%        Comment = util_maps:get_string(<<"comment">>, JsonMap),
%%        IsAdd = util_maps:get_integer(<<"isAdd">>, JsonMap),
%%        UserId = util_maps:get_integer(<<"userId">>, JsonMap),
%%        IsExists = game_args:is_exists(PlatformId, Key),
%%        if IsAdd == 1 andalso IsExists == true->
%%            util_cowboy:reply_error_code(Req, 1, <<"key repeated">>);
%%            IsAdd == 0 andalso IsExists == false->
%%                util_cowboy:reply_error_code(Req, 1, <<"key no exists">>);
%%            true ->
%%                game_args:update_value(PlatformId, Key, Type, IntValue, StrValue, Comment, UserId),
%%                util_cowboy:reply_error_code(Req, 0)
%%        end
%%          end,
%%    util_cowboy:handle_request(Req0, Fun).
%%
%%handle_delete_game_args(Req0) ->
%%    Fun = fun(Req, RequestParamList, _RequestData) ->
%%        Data = util_cowboy:decode_data(RequestParamList),
%%        JsonMap = util_json:decode(Data),
%%        PlatformId = util_maps:get_string(<<"platformId">>, JsonMap),
%%        Key = util_maps:get_string(<<"key">>, JsonMap),
%%        game_args:delete(PlatformId, Key),
%%        util_cowboy:reply_error_code(Req, 0)
%%          end,
%%    util_cowboy:handle_request(Req0, Fun).

%% 添加礼包码
handle_add_gift_code(Req0) ->
    Fun = fun(Req, RequestParamList, _RequestData) ->
        Data = chk_sign(RequestParamList),
%%        Data = util_cowboy:decode_data(RequestParamList),
        ?INFO("data: ~p", [{Data, RequestParamList}]),
        JsonMap = util_json:decode(Data),
        Name = util_maps:get_string(<<"name">>, JsonMap),
        GiftCode = util_maps:get_string(<<"giftCode">>, JsonMap),
        PlatformId = util_maps:get_string(<<"platformId">>, JsonMap),
        ChannelList = util_maps:get(<<"channelList">>, JsonMap),
        AwardList = util_maps:get(<<"awardList">>, JsonMap),
        Kind = util_maps:get_integer(<<"kind">>, JsonMap),
        AllowRoleRepeatedGet = util_maps:get_integer(<<"allowRoleRepeatedGet">>, JsonMap),
        Num = util_maps:get_integer(<<"num">>, JsonMap),
        VipLimit = util_maps:get_integer(<<"vipLimit">>, JsonMap),
        LevelLimit = util_maps:get_integer(<<"levelLimit">>, JsonMap),
        UserId = util_maps:get_integer(<<"userId">>, JsonMap),
        ExpireTime = util_maps:get_integer(<<"expireTime">>, JsonMap),
%%        ChannelList = [util:to_list(Channel) || Channel <- ChannelList0],
%%        AwardList = lists:map(
%%            fun(Award) ->
%%                {
%%                    util_map:get_integer(<<"propType">>, Award),
%%                    util_map:get_integer(<<"propId">>, Award),
%%                    util_map:get_integer(<<"propNum">>, Award)
%%                }
%%            end,
%%            AwardList0
%%        ),
        S_ChannelList = util:to_list(util_json:encode(ChannelList)),
        S_AwardList = util:to_list(util_json:encode(AwardList)),
        case ?CATCH(
            if Kind == ?GIFT_CODE_KING_COMMON ->
                mod_gift_code:add_common_gift_code(GiftCode, Name, PlatformId, S_ChannelList, S_AwardList, UserId, VipLimit, LevelLimit, ExpireTime);
                Kind == ?GIFT_CODE_KING_UNIVERSAL ->
                    mod_gift_code:add_universal_gift_code(Name, PlatformId, S_ChannelList, S_AwardList, AllowRoleRepeatedGet, Num, UserId, VipLimit, LevelLimit, ExpireTime)
            end
        ) of
            {'EXIT', Reason} ->
                ?ERROR("handle_add_gift_code:~p~n", [{Reason}]),
                ErrorMsg =
                    case Reason of
                        name_repeated ->
                            util_string:string_to_binary("兑换码名称重复");
                        code_repeated ->
                            util_string:string_to_binary("兑换码重复");
                        _ ->
                            util:to_binary(util_string:term_to_string(Reason))
                    end,
                util_cowboy:reply_error_code(Req, 1, ErrorMsg);
            _ ->
                util_cowboy:reply_error_code(Req, 0)
        end
          end,
    util_cowboy:handle_request(Req0, Fun).

%% 追加礼包码
handle_append_gift_code(Req0) ->
    Fun = fun(Req, RequestParamList, _RequestData) ->
        Data = chk_sign(RequestParamList),
%%        Data = util_cowboy:decode_data(RequestParamList),
        ?INFO("data: ~p", [{Data, RequestParamList}]),
        JsonMap = util_json:decode(Data),
        GiftCodeType = util_maps:get_integer(<<"giftCodeType">>, JsonMap),
        Num = util_maps:get_integer(<<"num">>, JsonMap),

        case ?CATCH(mod_gift_code:append_gift_code(GiftCodeType, Num)) of
            {'EXIT', Reason} ->
                ?ERROR("handle_append_gift_code:~p~n", [{GiftCodeType, Num, Reason}]),
                ErrorMsg = util:to_binary(util_string:term_to_string(Reason)),
                util_cowboy:reply_error_code(Req, 1, ErrorMsg);
            _ ->
                util_cowboy:reply_error_code(Req, 0)
        end
          end,
    util_cowboy:handle_request(Req0, Fun).

%% 删除礼包码
handle_delete_gift_code(Req0) ->
    Fun = fun(Req, RequestParamList, _RequestData) ->
        Data = chk_sign(RequestParamList),
%%        Data = util_cowboy:decode_data(RequestParamList),
        ?INFO("data: ~p", [{Data, RequestParamList}]),
        JsonMap = util_json:decode(Data),
        GiftCodeType = util_maps:get_integer(<<"giftCodeType">>, JsonMap),
        mod_gift_code:delete(GiftCodeType),
        util_cowboy:reply_error_code(Req, 0)
          end,
    util_cowboy:handle_request(Req0, Fun).


chk_sign(RequestParamList) ->
    ?DEBUG("RequestParamList: ~p", [RequestParamList]),
    Base64Data = util_list:opt(<<"data">>, RequestParamList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, RequestParamList)),
    Data = cow_base64url:decode(Base64Data),
    handle_update_version:chk_sign(Data, StringSign),
    Data.