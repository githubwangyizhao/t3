%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         %% 赠送礼物
%%% @end
%%% Created : 14. 10月 2021 上午 10:13:48
%%%-------------------------------------------------------------------
-module(api_gift).
-author("Administrator").

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    init_data/1,            %% 初始化数据

    select_player/2,        %% 选择玩家
    give_gift/2,            %% 赠送
    read_mail/2,            %% 读取邮件
    get_item_mail/2,        %% 获得邮件附件
    delete_mail/2,          %% 删除邮件

    api_add_mail/2,         %% api增加邮件
    api_remove_mail/2,      %% api移除邮件
    add_mail/2,             %% 增加邮件
    remove_mail/2           %% 移除邮件
]).

-export([
    gift_mail_record/2,    %% api 获取指定玩家的赠送记录
    test_gift_mail_record/1
]).

%% @doc 初始化数据
init_data(PlayerId) ->
    DbPlayerGiftMailList = gift_mail:get_db_player_gift_mail_by_player(PlayerId),
    PbGiftMailInfoList = pack_pb_gift_mail_info_list(DbPlayerGiftMailList),
    Out = proto:encode(#m_gift_init_mail_info_toc{gift_mail_info_list = PbGiftMailInfoList}),
    mod_socket:send(Out).

%% @doc 查询玩家
select_player(
    #m_gift_select_player_tos{player_id = SelectPlayerId},
    State = #conn{player_id = _PlayerId}
) ->
    {Result, PlayerName} =
        case catch mod_gift:select_player(SelectPlayerId) of
            {ok, PlayerName1} ->
                {?P_SUCCESS, PlayerName1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), ?UNDEFINED}
        end,
    Out = proto:encode(#m_gift_select_player_toc{result = Result, player_name = PlayerName}),
    mod_socket:send(Out),
    State.

%% @doc 送礼
give_gift(
    #m_gift_give_gift_tos{player_id = GivePlayerId, prop_list = PbPropList, code = Code},
    State = #conn{player_id = PlayerId}
) ->
    PropList = [{PropId, Num} || #prop{prop_id = PropId, num = Num} <- PbPropList, lists:member(PropId, ?SD_RUBY_GIVEAWAY_NUMBER)],
    Result = api_common:api_result_to_enum(catch mod_gift:give_gift(PlayerId, GivePlayerId, PropList, util:to_list(Code))),
    Out = proto:encode(#m_gift_give_gift_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% @doc 读邮件
read_mail(
    #m_gift_read_mail_tos{mail_real_id = MailRealId},
    State = #conn{player_id = PlayerId}
) ->
    {Result, MailId, Content, ContentParam, ItemList} =
        case catch mod_gift:read_mail(PlayerId, MailRealId) of
            {ok, MailId1, Content1, ContentParam1, ItemList1} ->
                {?P_SUCCESS, MailId1, Content1, ContentParam1, ItemList1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), ?UNDEFINED}
        end,
    Out = proto:encode(#m_gift_read_mail_toc{
        result = Result,
        mail_real_id = MailRealId,
        mail_id = MailId,
        content = util:to_binary(Content),
        param_list = [util:to_binary(Param) || Param <- ContentParam],
        prop_list = api_prop:pack_prop_list(ItemList)
    }),
    mod_socket:send(Out),
    State.

%% @doc 提取邮件
get_item_mail(
    #m_gift_get_item_mail_tos{mail_real_id = MailRealId},
    State = #conn{player_id = PlayerId}
) ->
    {Result, MailRealIdList, PropList} =
        case catch mod_gift:get_item_mail(PlayerId, MailRealId) of
            {ok, MailRealIdList1, PropList1} ->
                {?P_SUCCESS, MailRealIdList1, PropList1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), [], []}
        end,
    Out = proto:encode(#m_gift_get_item_mail_toc{result = Result, mail_real_id_list = MailRealIdList, prop_list = api_prop:pack_prop_list(PropList)}),
    mod_socket:send(Out),
    State.

%% @doc 删除邮件
delete_mail(
    #m_gift_delete_mail_tos{mail_real_id = MailRealId},
    State = #conn{player_id = PlayerId}
) ->
    {Result, MailRealIdList} =
        case catch mod_gift:delete_mail(PlayerId, MailRealId) of
            {ok, MailRealIdList1} ->
                {?P_SUCCESS, MailRealIdList1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), []}
        end,
    Out = proto:encode(#m_gift_delete_mail_toc{result = Result, mail_real_id_list = MailRealIdList}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	获取指定玩家的赠送记录
%% @throws 	none
%% @end
%% ----------------------------------
gift_mail_record(
    #m_gift_gift_mail_record_tos{}, State = #conn{player_id = PlayerId}
) ->
    SenderRecord = gift_mail:get_db_player_gift_mail_by_sender(PlayerId),
    PbGiftMailReceiverInfoList = pack_sender_gift_mail_list(SenderRecord),
    Out = proto:encode(#m_gift_gift_mail_record_toc{
        result = ?P_SUCCESS,
        receiver_info_list = PbGiftMailReceiverInfoList}
    ),
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    State.

test_gift_mail_record(PlayerId) ->
    SenderRecord = gift_mail:get_db_player_gift_mail_by_sender(PlayerId),
    PbGiftMailReceiverInfoList = pack_sender_gift_mail_list(SenderRecord),
    Out = #m_gift_gift_mail_record_toc{
        result = ?P_SUCCESS,
        receiver_info_list = PbGiftMailReceiverInfoList
    },
    ?DEBUG("Out: ~p", [Out]).


%% @doc api新增邮件数据
api_add_mail(PlayerId, PlayerMail) ->
    db:tran_merge_apply({?MODULE, add_mail, PlayerId}, PlayerMail).
%% @doc 通知增加新邮件
add_mail(PlayerId, GiftMailInfoList) ->
    Out = proto:encode(#m_gift_add_mail_toc{gift_mail_info_list = pack_pb_gift_mail_info_list(GiftMailInfoList)}),
    mod_socket:send(PlayerId, Out).

%% @doc api邮件减少数据
api_remove_mail(PlayerId, MailRealId) ->
    db:tran_merge_apply({?MODULE, remove_mail, PlayerId}, MailRealId).
%% @doc 移除邮件数据
remove_mail(PlayerId, List) when is_list(List) ->
    Out = proto:encode(#m_gift_remove_mail_toc{mail_real_id = List}),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc 结构化 赠礼邮件信息
pack_pb_gift_mail_info_list(DbPlayerGiftMailList) ->
    [pack_pb_gift_mail_info(DbPlayerGiftMail) || DbPlayerGiftMail <- DbPlayerGiftMailList].
pack_pb_gift_mail_info(DbPlayerGiftMail) ->
    #db_player_gift_mail{
        mail_real_id = MailRealId,
        mail_id = MailId,
        title_content = TitleContent,
        title_param = TitleParam,
        is_read = IsRead,
        state = State,
        create_time = CreateTime
    } = DbPlayerGiftMail,
    #giftmailinfo{
        mail_real_id = MailRealId,
        mail_id = MailId,
        title_content = erlang:list_to_binary(TitleContent),
        param_list = [util:to_binary(Param) || Param <- util_string:string_to_list_term(TitleParam)],
        is_read = IsRead,
        attachment_state = State,
        create_time = CreateTime

    }.


%% ----------------------------------
%% @doc 	获取指定玩家的赠送记录
%% @throws 	none
%% @end
%% ----------------------------------
pack_sender_gift_mail_list(SenderRecordList) ->
    [pack_sender_gift_mail_info(SenderRecordInfo) || SenderRecordInfo <- SenderRecordList].
pack_sender_gift_mail_info(SenderRecordInfo) ->
    #db_player_gift_mail{
        create_time = CreatedAt,
        item_list = ItemList,
        player_id = PlayerId
    } = SenderRecordInfo,
    #receiverinfo{
        receiver = PlayerId,
        receiver_name = util:to_binary(mod_player:get_player_name(PlayerId)),
        prop_list = [#prop{prop_id = PropId, num = Num} || {PropId, Num} <- util_string:string_to_list_term(ItemList)],
        create_time = CreatedAt
    }.