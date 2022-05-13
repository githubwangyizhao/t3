%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc		邮件进程处理数据
%%% Created : 31. 一月 2018 14:06
%%%-------------------------------------------------------------------
-module(mail_srv_mod).
-author("home").

%% API
-export([
    srv_clear_old_mail/0,       %% 清除旧邮件
    srv_add_mail/1              %% 增加新邮件
]).

-define(MAX_MAIL_CONT, 150).    % 邮件最大数量
-define(MAX_TIME_NOT_SEND_MAIL, 10 * 86400). % 上线时间超过10天不发邮件

-include("gen/db.hrl").
-include("common.hrl").
-include("player_game_data.hrl").

-define(MAIL_DEL_ADD_MAIL, delAddMail). % 上限时删除
-define(MAIL_ADD_MAIL, addMail).        % 增加邮件

%% @doc     进程处理新邮件
srv_add_mail({PlayerId, MailId, WeightValue, TitleName, ItemList, ValidTime1, Param, Content, LogType}) ->
    PlayerList =
        if
            is_integer(PlayerId) ->
                [PlayerId];
            true ->
                PlayerId
        end,
    CurrTime = util_time:timestamp(),
    ErrorList =
        lists:foldl(
            fun(PlayerId1, L) ->
                case catch srv_add_mail(PlayerId1, MailId, WeightValue, TitleName, ItemList, ValidTime1, Param, Content, LogType, CurrTime) of
                    ok ->
                        L;
                    ERROR ->
                        ?DEBUG("ERROR : ~p", [ERROR]),
                        [PlayerId1 | L]
                end
            end, [], PlayerList),
    if
        ErrorList == [] ->
            noop;
        true ->
            mod_log:write_player_mail_error_log(ErrorList, LogType, MailId, ItemList)
    end,
    ok.

srv_add_mail(PlayerId, MailId, WeightValue, TitleName, ItemList, ValidTime, ParamList, ContentStr, LogType, CurrTime) ->
    #db_player{
        last_login_time = LastLoginTime
    } = mod_player:get_player(PlayerId),
    if
        ?MAX_TIME_NOT_SEND_MAIL > CurrTime - LastLoginTime orelse LastLoginTime == 0 ->
            PlayerMailId1 = mod_player_game_data:add_1_player_global_value(PlayerId, ?PLAYER_GAME_DATA_ENUM_MAIL_ID),
            Tran =
                fun() ->
                    PlayerMailId =
                        case mod_mail:get_player_mail(PlayerId, PlayerMailId1) of
                            CheckMail when is_record(CheckMail, db_player_mail) ->
                                ?INFO("邮件实际ID重复:~p~n", [{PlayerId, PlayerMailId1}]),
                                mod_player_game_data:add_1_player_global_value(PlayerId, ?PLAYER_GAME_DATA_ENUM_MAIL_ID);
                            _ ->
                                PlayerMailId1
                        end,
%%                    {DelMail, MaxCount} = get_mail_first_data_and_max_cont(PlayerId),
%%                    if
%%                        MaxCount >= ?MAX_MAIL_CONT ->
%%                            mod_mail:delete_player_mail(DelMail, ?MAIL_DEL_ADD_MAIL);
%%                        true ->
%%                            ok
%%                    end,

                    MailSortList = util_list:rSortKeyList([{false, #db_player_mail.weight_value}, {false, zeroMax, #db_player_mail.valid_time}, {false, #db_player_mail.create_time}], mod_mail:get_index_player_mail_1_player_id(PlayerId)),
                    Len = length(MailSortList),
                    if
                        Len >= ?MAX_MAIL_CONT ->
                            DelMail = hd(MailSortList),
                            mod_mail:delete_player_mail(DelMail, ?MAIL_DEL_ADD_MAIL);
                        true ->
                            noop
                    end,

%%                    NewPlayerMail = #db_player_mail{player_id = PlayerId, mail_real_id = PlayerMailId, mail_id = MailId, title_name = TitleName,
%%                        item_list = ItemList, valid_time = ValidTime, param = ParamList, content = ContentStr, log_type = LogType, create_time = CurrTime},
                    NewPlayerMail = db:write(#db_player_mail{player_id = PlayerId, mail_real_id = PlayerMailId, mail_id = MailId, weight_value = WeightValue, title_name = TitleName,
                        item_list = ItemList, valid_time = ValidTime, param = ParamList, content = ContentStr, log_type = LogType, create_time = CurrTime}),
                    mod_mail:init_timer_type(PlayerId),
                    mod_log:db_write_player_mail_log(PlayerId, ?MAIL_ADD_MAIL, LogType, ItemList, {PlayerMailId, MailId}),
                    api_mail:api_add_mail(PlayerId, NewPlayerMail),
                    ok
                end,
            db:do(Tran);
        true ->
            noop
    end.

%% @fun 获得第一封邮件和总数据
%%get_mail_first_data_and_max_cont(PlayerId) ->
%%    lists:foldl(
%%        fun(Mail, {Mail1, Count1}) ->
%%            if
%%                Mail1#db_player_mail.create_time == 0 orelse Mail1#db_player_mail.create_time > Mail#db_player_mail.create_time ->
%%                    {Mail, Count1 + 1};
%%                true ->
%%                    {Mail1, Count1 + 1}
%%            end
%%        end, {#db_player_mail{}, 0}, mod_mail:get_index_player_mail_1_player_id(PlayerId)).

%% @fun 清除旧邮件
srv_clear_old_mail() ->
    lists:foldl(
        fun(PlayerId, L) ->
            case mod_online:is_online(PlayerId) of
                true ->
                    L;
                _ ->
                    ?TRY_CATCH(mod_mail:clear_mail_old_time(PlayerId)),
                    [PlayerId | L]
            end
        end, [], mod_player:get_all_player_id()).


