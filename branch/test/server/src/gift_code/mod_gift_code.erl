%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         礼包码
%%% @end
%%% Created : 11. 8月 2021 上午 09:56:50
%%%-------------------------------------------------------------------
-module(mod_gift_code).

%% API
-export([
    get_award/2        %% 领取礼包码奖励
]).

%% ADMIN API
-export([
    delete/1,
    add_common_gift_code/9,
    add_universal_gift_code/10,
    append_gift_code/2
]).

%% @private
-export([
    handle_get_gift_code_info/1,
    handle_use_gift_code/1
]).
-include("common.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("gift_code.hrl").

-define(MAX_GIFT_CODE_NUM, 50000). %% 礼包码最大数量

%% @doc 领取礼包码奖励(默认直接领取)
%%get_award(PlayerId, GiftCode) ->
%%    get_award(PlayerId, GiftCode, false).
get_award(PlayerId, GiftCode0) ->
    GiftCode = util_string:str_to_lower(util_string:trim(GiftCode0)),
    ?INFO("领取礼包码:~p", [{PlayerId, GiftCode}]),
    mod_interface_cd:assert({?MODULE, get_award}, 1000),
%%    ?ASSERT(erlang:length(GiftCode) == ?GIFT_CODE_LEN, length_error),
    {ok, GiftCodeType, LimitPlatformId, LimitChannelList, Kind, AwardList, AllowRoleRepeatedGet, VipLimit, LevelLimit} = gift_code_srv:call({get_gift_code_info, GiftCode}),

    PlayerVipLevel = mod_player:get_player_data(PlayerId, vip_level),
    PlayerLevel = mod_player:get_player_data(PlayerId, level),
    ?ASSERT(PlayerVipLevel >= VipLimit, ?ERROR_NOT_ENOUGH_VIP_LEVEL),
    ?ASSERT(PlayerLevel >= LevelLimit, ?ERROR_PLAYER_LEVEL_LIMIT),

    PlatformId = mod_server_config:get_platform_id(),
    Channel = mod_player:get_player_channel(PlayerId),
    ?ASSERT(LimitPlatformId == "" orelse LimitPlatformId == PlatformId, {platform_limit, PlatformId, LimitPlatformId}),
    ?ASSERT(LimitChannelList == [[]] orelse lists:member(Channel, LimitChannelList), {channel_limit, Channel, LimitChannelList}),
    if AllowRoleRepeatedGet == ?FALSE ->
        % 不能重复领取
        ?ASSERT(get_db_player_gift_code(PlayerId, GiftCodeType) == null, ?ERROR_ALREADY_GET);
        true ->
            ?ASSERT(Kind =/= ?GIFT_CODE_KING_COMMON),
            noop
    end,
    OldDbPlayerGiftCode = get_db_player_gift_code_or_init(PlayerId, GiftCodeType),
    NewTimes = OldDbPlayerGiftCode#db_player_gift_code.times + 1,
    %% 硬性限制 次数
    ?ASSERT(NewTimes < 10, max_times),

    mod_prop:assert_give(PlayerId, AwardList),

    Tran = fun() ->
        case Kind of
            ?GIFT_CODE_KING_COMMON ->
                %% 一码通用
                noop;
            ?GIFT_CODE_KING_UNIVERSAL ->
                %% 多码
                use_gift_code(GiftCode)
        end,

        mod_award:give(PlayerId, AwardList, ?LOG_TYPE_GIFT_CODE),

        db:write(OldDbPlayerGiftCode#db_player_gift_code{times = NewTimes, change_time = util_time:timestamp()})
           end,
    db:do(Tran),
    {ok, AwardList}.


%% @private
use_gift_code(GiftCode) ->
    gift_code_srv:call({use_gift_code, GiftCode}).

%% @private
%% CALLBACK
handle_use_gift_code(GiftCode) ->
    DbGiftCode = get_db_gift_code(GiftCode),
    ?ASSERT(DbGiftCode =/= null, no_exists__db_gift_code),
    #db_gift_code{
        gift_code_type = GiftCodeType
    } = DbGiftCode,
    DbGiftCodeType = get_db_gift_code_type(GiftCodeType),
    ?ASSERT(DbGiftCodeType =/= null, no_exists_db_gift_code_type),
    #db_gift_code_type{
        kind = Kind
    } = DbGiftCodeType,
    ?ASSERT(Kind == ?GIFT_CODE_KING_UNIVERSAL, {kind_error, GiftCode, GiftCodeType}),
    Tran = fun() ->
        db:delete(DbGiftCode)
           end,
    db:do(Tran),
    ok.

%% @private
handle_get_gift_code_info(GiftCode) ->
    ?DEBUG("Handle_get_gift_code_info: ~p", [{GiftCode, get_db_gift_code(GiftCode)}]),
    case get_db_gift_code(GiftCode) of
        null ->
            % 礼包码不存在
            exit(?ERROR_NOT_EXISTS);
        DbGiftCode ->
            Now = util_time:timestamp(),
            #db_gift_code{
                gift_code_type = GiftCodeType
            } = DbGiftCode,
            DbGiftCodeType = get_db_gift_code_type(GiftCodeType),
            ?DEBUG("DbGiftCodeType: ~p", [DbGiftCodeType]),
            ?ASSERT(DbGiftCodeType =/= null, no_exists_db_gift_code_type),
            #db_gift_code_type{
                platform_id = PlatformId,
                channel_list = ChannelListJson,
                award_list = AwardListJson,
                kind = Kind,
                allow_role_repeated_get = IsRoleRepeatedGet,
                vip_limit = VipLimit,
                level_limit = LevelLimit,
                expire_time = ExpireTime
            } = DbGiftCodeType,
            ?DEBUG("Now: ~p", [{Now, ExpireTime, ExpireTime > 0 andalso Now >= ExpireTime}]),
            if ExpireTime > 0 andalso Now >= ExpireTime ->
                % 过期
                exit(?ERROR_EXPIRE_REQUEST);
                true ->
                    ChannelList = [
                        util:to_list(Channel)
                        || Channel <- util_json:decode(ChannelListJson)
                    ],
                    AwardList =
                        [
                            {
                                util_maps:get_integer(<<"itemId">>, Award),
                                util_maps:get_integer(<<"itemNum">>, Award)
                            }
                            || Award <- util_json:decode(AwardListJson)
                        ],
                    ?DEBUG("AwardList: ~p", [AwardList]),
                    {
                        ok,
                        GiftCodeType,
                        PlatformId,
                        ChannelList,
                        Kind,
                        AwardList,
                        IsRoleRepeatedGet,
                        VipLimit,
                        LevelLimit
                    }
            end
    end.

%% @doc 删除礼包码
delete(GiftCodeType) ->
    ?ASSERT(mod_server:is_center_server(), not_center_server),
    ?INFO("删除礼包码:~p", [GiftCodeType]),
    Tran = fun() ->
        db:select_delete(?GIFT_CODE_TYPE, [{#db_gift_code_type{type = GiftCodeType, _ = '_'}, [], ['$_']}]),
        db:select_delete(?GIFT_CODE, [{#db_gift_code{gift_code_type = GiftCodeType, _ = '_'}, [], ['$_']}])
           end,
    db:do(Tran).

%% @doc 添加礼包码 - 通码
add_common_gift_code(GiftCode, Name, PlatformId, ChannelList, AwardList, UserId, VipLimit, LevelLimit, ExpireTime) ->
    add_gift_code(GiftCode, Name, PlatformId, ChannelList, AwardList, ?GIFT_CODE_KING_COMMON, ?FALSE, 1, UserId, VipLimit, LevelLimit, ExpireTime).

%% @doc 添加礼包码 - 多码
add_universal_gift_code(Name, PlatformId, ChannelList, AwardList, AllowRoleRepeatedGet, Num, UserId, VipLimit, LevelLimit, ExpireTime) ->
    ?ASSERT(Num > 0 andalso Num =< ?MAX_GIFT_CODE_NUM, {num_error, Num}),
    add_gift_code("", Name, PlatformId, ChannelList, AwardList, ?GIFT_CODE_KING_UNIVERSAL, AllowRoleRepeatedGet, Num, UserId, VipLimit, LevelLimit, ExpireTime).

%% @private
add_gift_code(GiftCode, Name, PlatformId, ChannelList, AwardList, Kind, AllowRoleRepeatedGet, Num, UserId, VipLimit, LevelLimit, ExpireTime) ->
    ?INFO("add_gift_code:~p~n", [{GiftCode, Name, PlatformId, ChannelList, AwardList, Kind, AllowRoleRepeatedGet, Num, UserId, VipLimit, LevelLimit, ExpireTime}]),
%%    StringAwardList = util_string:term_to_string(AwardList),

%%    StringChannelList = util_string:term_to_string(ChannelList),
    ?ASSERT(length(PlatformId) < 128),
    ?ASSERT(length(Name) < 128),
%%    ?ASSERT(length(StringAwardList) < 512),
%%    ?ASSERT(length(StringChannelList) < 512),
%%    interface_cd:assert(add_gift_code, 10),
    Now = util_time:timestamp(),
%%    GiftCodeType = Now,
    ?ASSERT(get_db_gift_code_type_by_name(Name) == [], name_repeated),
    ?ASSERT(
        (Kind == ?GIFT_CODE_KING_COMMON andalso AllowRoleRepeatedGet == ?FALSE andalso Num == 1)
            orelse (Kind == ?GIFT_CODE_KING_UNIVERSAL andalso (Num >= 1 andalso Num =< ?MAX_GIFT_CODE_NUM)),
        {num_error, Num}
    ),
    DbGiftCodeType = #db_gift_code_type{
%%        type = GiftCodeType,
        name = Name,
        platform_id = PlatformId,
        channel_list = ChannelList,
        award_list = AwardList,
        kind = Kind,
        num = Num,
        allow_role_repeated_get = AllowRoleRepeatedGet,
        user_id = UserId,
        vip_limit = VipLimit,
        level_limit = LevelLimit,
        expire_time = ExpireTime,
        update_time = Now
    },
    Tran =
        fun() ->
            DbGiftCodeType_1 = db:write(DbGiftCodeType),
            GiftCodeType = DbGiftCodeType_1#db_gift_code_type.type,
            if
                Kind == ?GIFT_CODE_KING_COMMON andalso GiftCode =/= "" ->
                    Result = create_db_gift_code_one(GiftCodeType, GiftCode),
                    ?ASSERT(Result == ok, Result);
                true ->
                    create_db_gift_code(GiftCodeType, Num)
            end
        end,
    db:do(Tran),
    if Num > 1 ->
        timer:sleep(5000);
        true ->
            timer:sleep(1000)
    end.

%% @doc 追加礼包码
append_gift_code(GiftCodeType, AppendNum) ->
    ?INFO("追加礼包码:~p", [{GiftCodeType, AppendNum}]),
    DbGiftCodeType = get_db_gift_code_type(GiftCodeType),
    ?ASSERT(DbGiftCodeType =/= null, no_exists_db_gift_code_type),
    #db_gift_code_type{
        kind = Kind,
        num = Num
    } = DbGiftCodeType,
    ?ASSERT(Kind == ?GIFT_CODE_KING_UNIVERSAL, {kind_error, DbGiftCodeType}),
    Tran =
        fun() ->
            db:write(DbGiftCodeType#db_gift_code_type{
                num = Num + AppendNum
            }),
            create_db_gift_code(GiftCodeType, AppendNum)
        end,
    db:do(Tran),
    timer:sleep(5000).

create_db_gift_code(GiftCodeType, Num) ->
    create_db_gift_code_1(GiftCodeType, util_time:timestamp(), Num).

create_db_gift_code_1(_GiftCodeType, _RandomKey, 0) ->
    ok;
create_db_gift_code_1(GiftCodeType, RandomKey, Num) when Num > 0 ->
    GiftCode = lists:sublist(md5:make(lists:concat([GiftCodeType, ?GIFT_CODE_SALT, RandomKey, Num])), ?GIFT_CODE_LEN),
    create_db_gift_code_one(GiftCodeType, GiftCode),
    create_db_gift_code_1(GiftCodeType, RandomKey, Num - 1).

create_db_gift_code_one(GiftCodeType, GiftCode0) ->
    GiftCode = util_string:str_to_lower(GiftCode0),
    case get_db_gift_code(GiftCode) of
        null ->
            DbGiftCode = #db_gift_code{
                gift_code = GiftCode,
                gift_code_type = GiftCodeType
            },
            db:write(DbGiftCode),
            ok;
        _ ->
            ?WARNING("礼包码重复:~p", [{GiftCodeType, GiftCode}]),
            code_repeated
    end.

get_db_gift_code_type(GiftCodeType) ->
    db:read(#key_gift_code_type{type = GiftCodeType}).


get_db_gift_code(GiftCode) ->
    db:read(#key_gift_code{gift_code = GiftCode}).


get_db_gift_code_type_by_name(Name) ->
    db_index:get_rows(#idx_gift_code_type_1{name = Name}).

get_db_player_gift_code(PlayerId, GiftCodeType) ->
    db:read(#key_player_gift_code{player_id = PlayerId, gift_code_type = GiftCodeType}).

get_db_player_gift_code_or_init(PlayerId, GiftCodeType) ->
    case get_db_player_gift_code(PlayerId, GiftCodeType) of
        null ->
            #db_player_gift_code{
                player_id = PlayerId,
                gift_code_type = GiftCodeType,
                times = 0
            };
        DbPlayerGiftCode ->
            DbPlayerGiftCode
    end.
