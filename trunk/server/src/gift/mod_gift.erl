%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 10月 2021 上午 10:48:42
%%%-------------------------------------------------------------------
-module(mod_gift).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("global_data.hrl").

%% API
-export([
    select_player/1,

    give_gift/4,

    read_mail/2,

    get_item_mail/2,

    delete_mail/2
]).

%% @doc 查询玩家名字
select_player(PlayerId) ->
    mod_interface_cd:assert({?MODULE, select_player}, 300),
    GlobalData = global_data:get_global_player_data(PlayerId),
    ?ASSERT(GlobalData =/= null, ?ERROR_NONE),
    #global_player_data{
        db_player = DbPlayer
    } = GlobalData,
%%    DbPlayer = mod_player:get_player(PlayerId),
    ?ASSERT(DbPlayer =/= null, ?ERROR_NONE),
    {ok, mod_player:get_player_name_to_binary(DbPlayer)}.

%% @doc 送礼
give_gift(PlayerId, GivePlayerId, PropList, Code) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_GIVE),
    mod_interface_cd:assert({?MODULE, give_gift}, 500),
    LogType = ?LOG_TYPE_GIFT_MAIL,
    GlobalData = global_data:get_global_player_data(GivePlayerId),
    #global_player_data{
        db_player = DbGivePlayer
    } = GlobalData,
    #db_player{
        server_id = GiveServerId,
        nickname = GiveNickname
    } = DbGivePlayer,
    ?ASSERT(DbGivePlayer =/= null),
    PlatformId = mod_server_config:get_platform_id(),
    GiveNode = mod_server_rpc:call_war(mod_server, get_game_node, [PlatformId, GiveServerId]),
    ?ASSERT(GiveNode =/= null),
    PlayerVipLevel = mod_vip:get_vip_level(PlayerId),
    #t_vip_level{
        giveaway_fee = GiveawayFee
    } = t_vip_level:assert_get({PlayerVipLevel}),
    NewPropList = lists:map(
        fun({PropId, PropNum}) ->
            PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
            ?ASSERT(PlayerPropNum >= util_list:opt(PropId, ?SD_GIVEAWAY_LIMIT_HAVE_LIST)),
%%            ?ASSERT(PlayerPropNum - PropNum >= util_list:opt(PropId, ?SD_GIVEAWAY_LIMIT_HAVE_LIST)),
            GiftWithFee = floor(PropNum * (10000 + GiveawayFee) / 10000),
            ?ASSERT(PlayerPropNum - GiftWithFee >= util_list:opt(PropId, ?SD_GIVEAWAY_LIMIT_HAVE_LIST)),
            MinNum = util_list:opt(PropId, ?SD_GIVEAWAY_LIMIT_MIN_LIST),
            ?ASSERT(PropNum >= MinNum),
            ?ASSERT((PropNum - MinNum) rem util_list:opt(PropId, ?SD_GIVEAWAY_LIMIT_UNIT_LIST) == 0),
%%            {PropId, floor((10000 - GiveawayFee) * PropNum / 10000)}
            {PropId, PropNum}
        end,
        PropList
    ),
    mod_prop:assert_prop_num(PlayerId, NewPropList),
    #db_player{
        acc_id = AccId
    } = mod_player:get_player(PlayerId),
    Mobile = mod_server_rpc:call_center(mod_global_account, get_mobile, [PlatformId, AccId]),
    mod_verify_code:verify_code(Mobile, 2, Code),
    PlayerName = mod_player:get_player_name(PlayerId),
    GiftMailId = ?GIFT_MAIL_GIVE_MAIL_RUBY,
    TitleParamList = [PlayerName],
    ContentParamList = [PlayerName],
    #t_give_mail{
        weight_value = WeightValue
    } = gift_mail:get_t_give_mail(GiftMailId),
    CurrTime = util_time:timestamp(),
    Tran =
        fun() ->
            ?DEBUG("PropList: ~p", [PropList]),
            RealPropList =
                lists:foldl(
                    fun({PropId, PropNum}, Tmp) ->
                        [{PropId, floor(PropNum * (10000 + GiveawayFee) / 10000)} | Tmp]
                    end,
                    [],
                    PropList
                ),
            ?DEBUG("RealPropList: ~p", [RealPropList]),
            mod_prop:decrease_player_prop(PlayerId, RealPropList, LogType),
            PlayerGiftMailLog = #db_player_gift_mail_log{
                sender = PlayerId,
                create_time = CurrTime,
                receiver = GivePlayerId,
                receiver_nickname = GiveNickname,
                item_list = util_string:term_to_string(NewPropList)
            },
            db:write(PlayerGiftMailLog),
            case rpc:call(GiveNode, gift_mail, add_mail_template_item, [PlayerId, GivePlayerId, GiftMailId, TitleParamList, ContentParamList, WeightValue, NewPropList, CurrTime]) of
                {badrpc, Reason} ->
                    exit(Reason);
                _ ->
                    ok
            end
%%            gift_mail:add_mail_template_item(PlayerId, GivePlayerId, GiftMailId, TitleParamList, ContentParamList, WeightValue, NewPropList, CurrTime)
%%            gift_mail:add_mail_template_item(GiveNode, PlayerId, GivePlayerId, GiftMailId, TitleParamList, ContentParamList, WeightValue, NewPropList, CurrTime)
        end,
    db:do(Tran),
    ok.

%% @doc 读邮件
read_mail(PlayerId, MailRealId) ->
    DbPlayerGiftMail = gift_mail:get_db_player_gift_mail(PlayerId, MailRealId),
    ?ASSERT(DbPlayerGiftMail =/= null),
    #db_player_gift_mail{
        mail_id = MailId,
        content = Content,
        content_param = ContentParam,
        item_list = ItemListStr,
        is_read = IsRead,
        is_del = IsDel
    } = DbPlayerGiftMail,
    ?ASSERT(IsDel == ?FALSE),
    ItemList = util_string:string_to_list_term(ItemListStr),
    if
        IsRead == ?FALSE ->
            Tran =
                fun() ->
                    db:write(DbPlayerGiftMail#db_player_gift_mail{is_read = ?TRUE})
                end,
            db:do(Tran);
        true ->
            noop
    end,
    {ok, MailId, Content, util_string:string_to_list_term(ContentParam), ItemList}.

%% @doc 获得邮件附件
get_item_mail(PlayerId, 0) ->
    LogType = ?LOG_TYPE_GIFT_MAIL,
    DbPlayerGiftMailList = gift_mail:get_db_player_gift_mail_by_player(PlayerId),
    List = lists:foldl(
        fun(DbPlayerGiftMail, TmpL) ->
            #db_player_gift_mail{
                state = State
            } = DbPlayerGiftMail,
            if
                State == ?AWARD_CAN ->
                    [DbPlayerGiftMail | TmpL];
                true ->
                    TmpL
            end
        end,
        [], DbPlayerGiftMailList
    ),
    ?ASSERT(List =/= [], ?ERROR_NOT_AUTHORITY),
    Tran =
        fun() ->
            {MailRealIdList1, PropList1} =
                lists:foldl(
                    fun(DbPlayerGiftMail, {TmpL1, TmpL2}) ->
                        db:write(DbPlayerGiftMail#db_player_gift_mail{state = ?AWARD_ALREADY, is_read = ?TRUE}),
                        {
                            [DbPlayerGiftMail#db_player_gift_mail.mail_real_id | TmpL1],
                                util_string:string_to_list_term(DbPlayerGiftMail#db_player_gift_mail.item_list) ++ TmpL2
                        }
                    end,
                    {[], []}, List
                ),
            mod_prop:assert_give(PlayerId, PropList1),
            mod_award:give(PlayerId, PropList1, LogType),
            {ok, MailRealIdList1, PropList1}
        end,
    db:do(Tran);
get_item_mail(PlayerId, MailRealId) ->
    LogType = ?LOG_TYPE_GIFT_MAIL,
    DbPlayerGiftMail = gift_mail:get_db_player_gift_mail(PlayerId, MailRealId),
    ?ASSERT(DbPlayerGiftMail =/= null),
    #db_player_gift_mail{
        item_list = ItemListStr,
        state = State,
        is_del = IsDel
    } = DbPlayerGiftMail,
    ItemList = util_string:string_to_list_term(ItemListStr),
    mod_prop:assert_give(PlayerId, ItemList),
    ?ASSERT(State == ?AWARD_CAN andalso ItemList =/= [], ?ERROR_NOT_AUTHORITY),
    ?ASSERT(IsDel == ?FALSE),
    Tran =
        fun() ->
            mod_award:give(PlayerId, ItemList, LogType),
            db:write(DbPlayerGiftMail#db_player_gift_mail{state = ?AWARD_ALREADY})
        end,
    db:do(Tran),
    {ok, [MailRealId], ItemList}.

%% @doc 删除邮件
delete_mail(PlayerId, 0) ->
    DbPlayerGiftMailList = gift_mail:get_db_player_gift_mail_by_player(PlayerId),
    List = lists:foldl(
        fun(DbPlayerGiftMail, TmpL) ->
            #db_player_gift_mail{
                is_read = IsRead,
                state = State
            } = DbPlayerGiftMail,
            if
                IsRead == ?TRUE andalso State =/= ?AWARD_CAN ->
                    [DbPlayerGiftMail | TmpL];
                true ->
                    TmpL
            end
        end,
        [], DbPlayerGiftMailList
    ),
    ?ASSERT(List =/= [], ?ERROR_NONE),
    Tran =
        fun() ->
            lists:map(
                fun(DbPlayerGiftMail) ->
                    db:write(DbPlayerGiftMail#db_player_gift_mail{is_del = ?TRUE}),
                    DbPlayerGiftMail#db_player_gift_mail.mail_real_id
                end,
                List
            )
        end,
    IdList = db:do(Tran),
    {ok, IdList};
delete_mail(PlayerId, MailRealId) ->
    DbPlayerGiftMail = gift_mail:get_db_player_gift_mail(PlayerId, MailRealId),
    ?ASSERT(DbPlayerGiftMail =/= null, ?ERROR_NONE),
    #db_player_gift_mail{
        is_read = IsRead,
        state = State,
        is_del = IsDel
    } = DbPlayerGiftMail,
    ?ASSERT(State =/= ?AWARD_CAN, ?ERROR_NOT_AUTHORITY),
    ?ASSERT(IsRead == ?TRUE),
    ?ASSERT(IsDel == ?FALSE),
    Tran =
        fun() ->
            db:write(DbPlayerGiftMail#db_player_gift_mail{is_del = ?TRUE})
        end,
    db:do(Tran),
    {ok, [MailRealId]}.
