%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 30. 一月 2018 17:45
%%%-------------------------------------------------------------------
-module(api_mail).
-author("home").

%% API
-export([
    get_mail_info/2,            %% 邮件信息
    read_mail/2,                %% 读邮件
    get_item_mail/2,            %% 提取附件邮件
    delete_mail/2,              %% 删除邮件
    remove_mail/2,            %% 删除邮件广播数据%% api邮件减少数据
    add_mail/2                    %% 增加新邮件
]).

-export([
    api_remove_mail/2,        %% api邮件减少数据
    api_add_mail/2            %% api新增邮件数据
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").

%% @doc     邮件信息
get_mail_info(
    #m_mail_get_mail_info_tos{},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("邮件信息"),
    MailSimpleInfo = [pack_mail_simple_info(PlayerMail) || PlayerMail <- mod_mail:get_mail_info(PlayerId)],
    Out = proto:encode(#m_mail_get_mail_info_toc{mail_simple_info = MailSimpleInfo}),
    mod_socket:send(Out),
    State.

%% @doc     读邮件
read_mail(
    #m_mail_read_mail_tos{mail_real_id = MailRealId},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("读邮件"),
    {Result, Mail} =
        case catch mod_mail:read_mail(PlayerId, MailRealId) of
            {ok, M} ->
                {?P_SUCCESS, M};
            _R ->
                {?P_FAIL, null}
        end,
    Out = proto:encode(#m_mail_read_mail_toc{result = Result, mail_info = pack_mail_info(Mail)}),
    mod_socket:send(Out),
    State.

%% @doc     提取附件邮件
get_item_mail(
    #m_mail_get_item_mail_tos{mail_real_id = MailRealId},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("提取附件邮件: " ++ util:to_list(MailRealId)),
    {Result, MailRealList} =
        case catch mod_mail:get_item_mail(PlayerId, MailRealId) of
            {ok, {Result1, List1, ItemsInMails}} ->
                ?DEBUG("ItemsInMails: ~p ~p", [length(ItemsInMails), ItemsInMails]),
                if
                    MailRealId =:= 0 ->
                        Out2 =
                            #m_mail_read_mail_toc{
                                result = 1,
                                mail_info = #mail_info{
                                    mail_real_id = 1,
                                    mail_id = 2,
                                    title_name = "title",
                                    state = 2,
                                    content = "content",
                                    param_list = ["param_list"],
                                    prop_list = [#prop{prop_id = ItemId, num = Num} || {ItemId, Num} <- ItemsInMails],
                                    valid_time = util_time:timestamp(),
                                    create_time = util_time:timestamp()
                                }
                            },
                        ?DEBUG("Out2: ~p", [Out2]),
                        mod_socket:send(proto:encode(Out2));
                    true -> false
                end,
                Result2 = api_common:api_error_to_enum(Result1),
                ?DEBUG("List1: ~w", [List1]),
                {Result2, List1};
            R ->
                ?WARNING("提取附件邮件失败:~p~n", [R]),
                R1 = api_common:api_result_to_enum(R),
                {R1, []}
        end,
    Out = proto:encode(#m_mail_get_item_mail_toc{result = Result, mail_real_id = MailRealList}),
    mod_socket:send(Out),
    State.

%% @doc     删除邮件
delete_mail(
    #m_mail_delete_mail_tos{mail_real_id = MailRealId},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("删除邮件"),
    {Result, MailRealList} =
        case catch mod_mail:delete_mail(PlayerId, MailRealId) of
            {ok, List1} ->
                {?P_SUCCESS, List1};
            R ->
				R1 = api_common:api_result_to_enum(R),
                {R1, []}
        end,
    Out = proto:encode(#m_mail_delete_mail_toc{result = Result, mail_real_id = MailRealList}),
    mod_socket:send(Out),
    State.

%% @doc     更新新邮件
add_mail(PlayerId, List) ->
    Out = proto:encode(#m_mail_add_mail_toc{mail_simple_info = [pack_mail_simple_info(PlayerMail) || PlayerMail <- List]}),
    mod_socket:send(PlayerId, Out).

%% @doc     移除邮件数据
remove_mail(PlayerId, List) when is_list(List) ->
    Out = proto:encode(#m_mail_remove_mail_toc{mail_real_id = List}),
    mod_socket:send(PlayerId, Out).

%% api新增邮件数据
api_add_mail(PlayerId, PlayerMail) ->
    db:tran_merge_apply({?MODULE, add_mail, PlayerId}, PlayerMail).
%% api邮件减少数据
api_remove_mail(PlayerId, MailRealId) ->
    db:tran_merge_apply({?MODULE, remove_mail, PlayerId}, MailRealId).

%% 邮件信息打包
pack_mail_info(PlayerMail) ->
    case is_record(PlayerMail, db_player_mail) of
        true ->
            MailItemList = util_string:string_to_list_term(PlayerMail#db_player_mail.item_list),
            ParamList = util_string:string_to_list_term(PlayerMail#db_player_mail.param),
            PropList = api_prop:pack_prop_list(MailItemList),
%%			MailParamData = [#mailparam_data{param = Param} || Param <- ParamList],
            #mail_info{
                mail_real_id = PlayerMail#db_player_mail.mail_real_id,
                mail_id = PlayerMail#db_player_mail.mail_id,
                title_name = util:to_binary(PlayerMail#db_player_mail.title_name),
                state = PlayerMail#db_player_mail.state,
                param_list = [util:to_binary(Param) || Param <- ParamList],
                content = util:to_binary(PlayerMail#db_player_mail.content),
                prop_list = PropList,
                valid_time = PlayerMail#db_player_mail.valid_time,
                create_time = PlayerMail#db_player_mail.create_time
            };
        _ ->
            #mail_info{
                mail_real_id = 0,
                mail_id = 0,
                title_name = <<>>,
                state = 0,
                param_list = [],
                content = <<>>,
                prop_list = [],
                valid_time = 0,
                create_time = 0
            }
    end.

%% 邮件简单信息打包
pack_mail_simple_info(PlayerMail) ->
    case is_record(PlayerMail, db_player_mail) of
        true ->
            ItemList = util_string:string_to_list_term(PlayerMail#db_player_mail.item_list),
            IsAttach =
                if
                    ItemList =/= [] ->
                        1;
                    true ->
                        0
                end,
            #mailsimple_info{
                mail_real_id = PlayerMail#db_player_mail.mail_real_id,
                mail_id = PlayerMail#db_player_mail.mail_id,
                title_name = erlang:list_to_binary(PlayerMail#db_player_mail.title_name),
                state = PlayerMail#db_player_mail.state,
                is_attach = IsAttach,
                valid_time = PlayerMail#db_player_mail.valid_time,
                create_time = PlayerMail#db_player_mail.create_time
            };
        _ ->
            #mailsimple_info{
                mail_real_id = 0,
                mail_id = 0,
                title_name = "",
                state = 0,
                is_attach = 0,
                valid_time = 0,
                create_time = 0
            }
    end.
