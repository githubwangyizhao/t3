%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 10月 2021 上午 11:01:18
%%%-------------------------------------------------------------------
-module(gift_mail).
-author("Administrator").

-include("gen/db.hrl").
-include("common.hrl").
-include("player_game_data.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    add_mail_template/7,
    add_mail_template_item/8,
    add_mail_template_item/9,

    add_mail/6,
    add_mail_item/7,

    srv_add_mail/1
]).

-export([
    get_db_player_gift_mail/2,
    get_db_player_gift_mail_by_player/1
]).

-export([
    get_t_give_mail/1
]).

-export([
    gm_add_mail/6
]).

-export([
    get_db_player_gift_mail_by_sender/1
]).

-define(MAX_MAIL_CONT, 500).    % 邮件最大数量

%% @doc
add_mail_template(SenderId, PlayerId, MailId, TitleParam, ContentParam, WeightValue, CurrTime) ->
    mail_srv:cast({srv_add_gift_mail, {SenderId, PlayerId, MailId, "", TitleParam, "", ContentParam, WeightValue, [], CurrTime}}).
add_mail_template_item(SenderId, PlayerId, MailId, TitleParam, ContentParam, WeightValue, ItemList, CurrTime) ->
    mail_srv:cast({srv_add_gift_mail, {SenderId, PlayerId, MailId, "", TitleParam, "", ContentParam, WeightValue, ItemList, CurrTime}}).
add_mail_template_item(GiveNode, SenderId, PlayerId, MailId, TitleParam, ContentParam, WeightValue, ItemList, CurrTime) ->
    mail_srv:cast(GiveNode, {srv_add_gift_mail, {SenderId, PlayerId, MailId, "", TitleParam, "", ContentParam, WeightValue, ItemList, CurrTime}}).

add_mail(SenderId, PlayerId, TitleContent, Content, WeightValue, CurrTime) ->
    mail_srv:cast({srv_add_gift_mail, {SenderId, PlayerId, 0, TitleContent, "", Content, "", WeightValue, [], CurrTime}}).
add_mail_item(SenderId, PlayerId, TitleContent, Content, WeightValue, ItemList, CurrTime) ->
    mail_srv:cast({srv_add_gift_mail, {SenderId, PlayerId, 0, TitleContent, "", Content, "", WeightValue, ItemList, CurrTime}}).

srv_add_mail({Sender, PlayerId, MailId, TitleContent, TitleParam, Content, ContentParam, WeightValue, ItemList, CurrTime}) ->
    srv_add_mail_1(Sender, PlayerId, MailId, TitleContent, TitleParam, Content, ContentParam, WeightValue, ItemList, CurrTime).
srv_add_mail_1(Sender, PlayerId, MailId, TitleContent, TitleParam, Content, ContentParam, WeightValue, ItemList, CurrTime) ->
    Tran =
        fun() ->
            PlayerGiftMailRealId = mod_player_game_data:add_1_player_global_value(PlayerId, ?PLAYER_GAME_DATA_ENUM_GIFT_MAIL_ID),

            DbPlayerGiftMailList = get_db_player_gift_mail_by_player(PlayerId),

            MailSortList = util_list:rSortKeyList([{false, #db_player_gift_mail.weight_value}, {false, #db_player_mail.create_time}], DbPlayerGiftMailList),
            Len = length(MailSortList),
            if
                Len >= ?MAX_MAIL_CONT ->
                    NewMailSortList = [MailSortList || MailSortList = #db_player_gift_mail{item_list = ThisItemList} <- MailSortList, ThisItemList == "[]"],
                    if
                        NewMailSortList == [] ->
                            noop;
                        true ->
                            DelMail = hd(NewMailSortList),
                            db:delete(DelMail),
                            api_gift:api_remove_mail(PlayerId, DelMail#db_player_gift_mail.mail_real_id)
                    end;
                Len >= 2000 ->
                    DelMail = hd(MailSortList),
                    db:delete(DelMail),
                    api_gift:api_remove_mail(PlayerId, DelMail#db_player_gift_mail.mail_real_id);
%%                    mod_mail:delete_player_mail(DelMail, ?MAIL_DEL_ADD_MAIL);
                true ->
                    noop
            end,

            PlayerGiftMail = #db_player_gift_mail{
                player_id = PlayerId,
                sender = Sender,
                mail_real_id = PlayerGiftMailRealId,
                weight_value = WeightValue,
                is_read = ?FALSE,
                state = ?IF(ItemList == [], ?AWARD_NONE, ?AWARD_CAN),
                mail_id = MailId,
                title_content = TitleContent,
                title_param = util_string:term_to_string(TitleParam),
                content = Content,
                content_param = util_string:term_to_string(ContentParam),
                item_list = util_string:term_to_string(ItemList),
                create_time = CurrTime
            },
%%            ?DEBUG("查看数据 ： ~p", [PlayerGiftMail]),
            db:write(PlayerGiftMail),
            mod_log:write_player_gift_mail_log(PlayerId, Sender, add, ItemList, {PlayerGiftMailRealId, MailId}),
            api_gift:api_add_mail(PlayerId, PlayerGiftMail)
        end,
    db:do(Tran),
    ok.

%% gm增加标题类邮件
gm_add_mail(PlayerIdList, TitleName, Content, ItemList, ConditionsId, ConditionsValue1) ->
    ?DEBUG("gm增加标题类邮件:~p~n", [{PlayerIdList, TitleName, Content, ItemList, ConditionsId, ConditionsValue1}]),
    SendPlayerList =
        if
            PlayerIdList == [] ->   % 全服的
                if
                    ConditionsId == 1 ->
                        ConditionsValue = util:to_int(ConditionsValue1),
                        lists:foldl(
                            fun(PlayerId, ConditionsL) ->
                                VipLevel = mod_conditions:get_player_conditions_data_number(PlayerId, ?CON_ENUM_VIP_LEVEL),
                                if
                                    VipLevel >= ConditionsValue ->
                                        [PlayerId | ConditionsL];
                                    true ->
                                        ConditionsL
                                end
                            end, [], mod_player:get_all_player_id());
                    true ->
                        mod_player:get_all_player_id()
                end;
            true ->
                PlayerIdList
        end,
    if
        SendPlayerList == [] ->
            noop;
        true ->
%%            add_mail_item(PlayerId, TitleContent, Content, 10, ItemList, CurrTime)
            gm_add_title_name_mail(SendPlayerList, TitleName, Content, ItemList)
    end.
gm_add_title_name_mail(PlayerIdList, TitleName, Content, ItemList) ->
    ?ASSERT(length(ItemList) =< 8, item_list_length_error),
    TitleNameLen = util_string:string_length(TitleName),
    ?ASSERT(1 =< TitleNameLen andalso TitleNameLen =< 64, title_length_error),
    ?ASSERT(util_string:string_length(Content) =< 300, length_error),
    lists:foreach(
        fun(ItemTuple) ->
            {ItemId, ItemNum} = mod_prop:tran_prop(ItemTuple),
            ?ASSERT(ItemId > 0 andalso ItemNum > 0, error_num_0)
        end, ItemList),
    CurrTime = util_time:timestamp(),
    lists:foreach(
        fun(PlayerId) ->
            add_mail_item(0, PlayerId, TitleName, Content, 10, ItemList, CurrTime)
        end,
        PlayerIdList
    ),
    ok.

%% ================================================ 数据操作 ================================================

%% @doc 获得玩家礼物邮件
get_db_player_gift_mail(PlayerId, MailReadId) ->
    db:read(#key_player_gift_mail{player_id = PlayerId, mail_real_id = MailReadId}).

%% @doc 获得玩家礼物邮件列表
get_db_player_gift_mail_by_player(PlayerId) ->
    DbGiftMailList = db_index:get_rows(#idx_player_gift_mail_by_player{player_id = PlayerId}),
    [DbGiftMail || DbGiftMail = #db_player_gift_mail{is_del = IsDel} <- DbGiftMailList, IsDel == ?FALSE].

%% @doc 获取由指定玩家的赠送出的邮件列表
get_db_player_gift_mail_by_sender(PlayerId) ->
    ets:select(player_gift_mail_log, [{
        #db_player_gift_mail_log{sender = PlayerId, _ = '_'}, [], ['$_']
    }]).
%%    db_index:get_rows(#idx_player_gift_mail_by_sender{sender = PlayerId}).

%% ================================================ 配置表操作 ================================================
%% @doc 获得赠礼表
get_t_give_mail(GiftMailId) ->
    t_give_mail:assert_get({GiftMailId}).