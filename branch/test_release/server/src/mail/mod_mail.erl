%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 30. 一月 2018 14:04
%%%-------------------------------------------------------------------
-module(mod_mail).
-author("home").

%% API
-export([
    get_mail_info/1,            %% 邮件信息
    read_mail/2,                %% 读邮件
    get_item_mail/2,            %% 提取附件邮件
    delete_mail/2               %% 删除邮件
]).

-export([
    get_player_mail/2,
    init_timer_type/1,              %% 玩家初始邮件定时器
    delete_player_mail/2,           %% 删除邮件操作
    clear_mail_old_time/1,          %% 清除过期的邮件
    get_player_mail_unread_list/1,  %% 未读邮件列表
    repair_table_weight_value/0,    %% 修复邮件品质度
    get_index_player_mail_1_player_id/1
]).

-export([
    add_mail_id/3,                  %% 模板数据增加邮件
    add_mail_item_list/4,           %% 道具包增加邮件
    add_mail_item_list/5,           %% 道具包增加邮件 和有效时间
    add_mail_award_id/4,            %% 奖励id增加邮件
    add_mail_award_id/5,            %% 奖励id增加邮件 和有效时间
    %% -------------------带参数----------
    add_mail_param/4,               %% 增加新邮件    只带参数
    add_mail_param_award_id/5,      %% 奖励组id增加邮件  带参数
    add_mail_param_item_list/5,     %% 道具包增加邮件  带参数
    add_mail_param/7,               %% 增加新邮件    带参数
    %% --------------------带参数   加标题---------
    add_mail_time_name_content_item_list/6,   %% 道具包增加邮件  带参数

    gm_add_title_name_mail/4,       %% gm增加标题类邮件
    gm_add_title_name_mail/6,       %% gm增加标题类邮件条件玩家
    gm_add_title_name_mail_by_channel/4,
    gm_del_mail/2,                  %% gm删除邮件
    gm_del_mail/3,                  %% gm删除邮件
    gm_mail_lock/1,                 %% 邮件锁
    test_fun_change/3               %% 测试使用的功能
]).

-define(SAVE_DAY, 15 * ?DAY_S).         % 道具有效时间段的最大天数
-define(SAVE_READ_DAY, 3 * ?DAY_S).     % 已读和已领取的最大天数
-define(MAX_MAIL_CONT, 100).    % 邮件最大数量

-define(MAIL_STATE_0, 0).           % 邮件未读
-define(MAIL_STATE_READ, 1).        % 邮件已阅读
-define(MAIL_STATE_GET_ITEM, 2).    % 邮件已提取附件


-include("msg.hrl").
-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

-define(MAIL_DEL_MAIL, delMail).    % 删除邮件
-define(MAIL_OUT_TIME, out_time).   % 过期
-define(MAIL_READ_MAIL, read_mail). % 读取
-define(MAIL_ITEM_MAIL, item_mail). % 提取附件

%% 邮件信息     0
get_mail_info(PlayerId) ->
    get_index_player_mail_1_player_id(PlayerId).

%% 阅读邮件     1
read_mail(PlayerId, MailRealId) ->
    PlayerMail = get_player_mail(PlayerId, MailRealId),
    ?ASSERT(is_record(PlayerMail, db_player_mail), ?ERROR_NOT_EXISTS),
    #db_player_mail{
        state = State,
        log_type = LogType
    } = PlayerMail,
    if
        State < ?MAIL_STATE_READ ->
            Tran =
                fun() ->
                    NewPlayerMail = db:write(PlayerMail#db_player_mail{state = ?MAIL_STATE_READ}),
                    mod_log:db_write_player_mail_log(PlayerId, ?MAIL_READ_MAIL, LogType, [], {MailRealId, PlayerMail#db_player_mail.mail_id}),
                    NewPlayerMail
                end,
            Result = db:do(Tran),
            {ok, Result};
        true ->
            {ok, PlayerMail}
    end.

%% 获得附件邮件   2
get_item_mail(PlayerId, MailRealId) ->
    CurrTime = util_time:timestamp(),
    LockState = mod_server_data:get_int_data(?SERVER_DATA_MAIL_LOCK),
    ?ASSERT(LockState == ?FALSE, ?ERROR_GM_CONFINE),
    PlayerMailList =
        if
            MailRealId > 0 ->
                PlayerMail = get_player_mail(PlayerId, MailRealId),
                ?ASSERT(is_record(PlayerMail, db_player_mail), ?ERROR_NOT_EXISTS),
                ?ASSERT(PlayerMail#db_player_mail.state < ?MAIL_STATE_GET_ITEM, old_item_mail_state),
                ?ASSERT(PlayerMail#db_player_mail.valid_time == 0 orelse PlayerMail#db_player_mail.valid_time >= CurrTime, ?ERROR_OLD_ITEM_TIME),
                ItemList = util_string:string_to_list_term(PlayerMail#db_player_mail.item_list),
                ?ASSERT(ItemList =/= [], ?ERROR_NOT_AUTHORITY),
                mod_prop:assert_give(PlayerId, ItemList),
                [PlayerMail];
            true ->
                get_index_player_mail_1_player_id(PlayerId)
        end,

    LogType = ?IF(MailRealId == 0, ?LOG_TYPE_MAIL_GET_ALL_ITEM, ?LOG_TYPE_MAIL_GET_ITEM),
    ?ASSERT(PlayerMailList =/= [], ?ERROR_NOT_AUTHORITY),
    Tran =
        fun() ->
            calc_get_item_mail(PlayerMailList, CurrTime, LogType, [])
        end,
    {Result, List} = db:do(Tran),
    MailIdList = [MailId || {MailId, _ItemListInMail} <- List],
    ?DEBUG("MailIdList: ~w", [MailIdList]),
    ItemsListInMail =
        lists:foldl(
            fun({_MailId, ItemListInMail}, Tmp) ->
                lists:merge(ItemListInMail, Tmp)
            end,
            [],
            List
        ),
    ItemsInMail =
        if
            length(ItemsListInMail) > 0 -> mod_prop:merge_prop_list(ItemsListInMail);
            true -> ItemsListInMail
        end,
    ?ASSERT(Result == ok andalso MailIdList =/= [] orelse Result =/= ok, ?ERROR_NOT_AUTHORITY),
    {ok, {Result, MailIdList, ItemsInMail}}.
%%    ?ASSERT(Result == ok andalso List =/= [] orelse Result =/= ok, ?ERROR_NOT_AUTHORITY),
%%    {ok, {Result, List}}.

calc_get_item_mail([], _CurrTime, _LogType, List) ->
    {ok, List};
calc_get_item_mail([PlayerMail | PlayerMailList], CurrTime, LogType, List) ->
    #db_player_mail{
        player_id = PlayerId,
        state = State,
        valid_time = ValidTime,
        item_list = ItemList1,
        mail_real_id = MailRealId,
        log_type = PropLogType
    } = PlayerMail,
    ItemList = util_string:string_to_list_term(ItemList1),
    ItemState = check_item_list(ItemList),
    if
        ItemState == true andalso State < ?MAIL_STATE_GET_ITEM andalso ItemList =/= [] andalso (ValidTime == 0 orelse ValidTime > CurrTime) ->
            case catch mod_award:give_no_mail(PlayerId, ItemList, PropLogType) of
                ok ->
                    db:write(PlayerMail#db_player_mail{state = ?MAIL_STATE_GET_ITEM}),
                    mod_log:db_write_player_mail_log(PlayerId, ?MAIL_ITEM_MAIL, PropLogType, ItemList, {MailRealId, PlayerMail#db_player_mail.mail_id}),
                    calc_get_item_mail(PlayerMailList, CurrTime, LogType, [{MailRealId, ItemList} | List]);
                {_, Error} ->
                    {Error, List};
                _ ->
                    {?ERROR_NONE, List}
            end;
        true ->
            calc_get_item_mail(PlayerMailList, CurrTime, LogType, List)
    end.

%% 删除邮件     4
delete_mail(PlayerId, MailRealId) ->
    {DelList, MailRealList} =
        if
            MailRealId == 0 ->
                CurrTime = util_time:timestamp(),
                lists:foldl(
                    fun(PlayerMail, {L, MailRealL}) ->
                        #db_player_mail{
                            state = State,
                            valid_time = ValidTime,
                            item_list = ItemList1,
                            mail_real_id = MailRealId1
                        } = PlayerMail,
                        ItemList = util_string:string_to_list_term(ItemList1),
%%                        if
%%                            PlayerMail#db_player_mail.valid_time > CurrTime andalso PlayerMail#db_player_mail.state =/= ?MAIL_STATE_GET_ITEM andalso ItemList =/= [] ->
%%                                {L, MailRealL};
%%                            true ->
%%                                {[PlayerMail | L], [PlayerMail#db_player_mail.mail_real_id | MailRealL]}
%%                        end
                        if
                            ValidTime > 0 andalso ValidTime =< CurrTime orelse State == ?MAIL_STATE_GET_ITEM orelse State == ?MAIL_STATE_READ andalso ItemList == [] ->
                                {[PlayerMail | L], [MailRealId1 | MailRealL]};
                            true ->
                                {L, MailRealL}
                        end
                    end, {[], []}, get_index_player_mail_1_player_id(PlayerId));
            true ->
                PlayerMail = get_player_mail(PlayerId, MailRealId),
                ?ASSERT(is_record(PlayerMail, db_player_mail), ?ERROR_NOT_EXISTS),
                {[PlayerMail], [MailRealId]}
        end,
%%	{NewList, _LogList, DeleteMailList} =
%%		lists:foldl(fun(MailRealId, {List, LogList1, DeleteMailList1}) ->
%%			case get_player_mail(PlayerId, MailRealId) of
%%				M when is_record(M, db_player_mail) ->
%%					MailId = M#db_player_mail.mail_id,
%%					{[MailRealId | List], [{MailRealId, MailId} | LogList1], [M | DeleteMailList1]};
%%				_ ->
%%					{List, LogList1, DeleteMailList1}
%%			end end, {[], [], []}, DelList),
    ?ASSERT(DelList =/= [], ?ERROR_NONE),
    Tran =
        fun() ->
            [delete_player_mail_notice(Mail, ?MAIL_DEL_MAIL, false) || Mail <- DelList]
%%			mod_log:write_player_mail_log(PlayerId, LogList, ?OT_MAIL_DELETE)
        end,
    db:do(Tran),
    init_timer_type(PlayerId),
    {ok, MailRealList}.

%% 检查物品列表的是否合法
check_item_list(List) ->
    check_item_list(List, true).
check_item_list([], State) ->
    State;
check_item_list([ItemTuple | List], State) ->
    case mod_prop:tran_prop(ItemTuple) of
        {_, 0, _} ->
            false;
        _ ->
            check_item_list(List, State)
    end.


%%======================================================== gm 操作 ========================================================
gm_add_title_name_mail_by_channel(ChannelList, TitleName, Content, ItemList) ->
    PlayerIdList = mod_player:get_player_id_list_by_channel(ChannelList),
    if PlayerIdList == [] ->
        noop;
        true ->
            gm_add_title_name_mail(PlayerIdList, TitleName, Content, ItemList)
    end.
%% gm增加标题类邮件
gm_add_title_name_mail(PlayerIdList, TitleName, Content, ItemList, ConditionsId, ConditionsValue1) ->
    ?DEBUG("gm增加标题类邮件:~p~n",[{PlayerIdList, TitleName, Content, ItemList, ConditionsId, ConditionsValue1}]),
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
            gm_add_title_name_mail(SendPlayerList, TitleName, Content, ItemList)
    end.
gm_add_title_name_mail(PlayerIdList, TitleName, Content, ItemList) ->
    ?ASSERT(length(ItemList) =< 8, ?ERROR_NUM_0),
    TitleNameLen = util_string:string_length(TitleName),
    ?ASSERT(1 =< TitleNameLen andalso TitleNameLen =< 30, ?ERROR_NAME_TOO_LONG),
    ?ASSERT(util_string:string_length(Content) =< 300, ?ERROR_MSG_TOO_LONG),
    lists:foreach(
        fun(ItemTuple) ->
            {ItemId, ItemNum} = mod_prop:tran_prop(ItemTuple),
            ?ASSERT(ItemId > 0 andalso ItemNum > 0, ?ERROR_NUM_0)
        end, ItemList),
    SendPlayerList =
        if
            PlayerIdList == [] ->   % 全服的
                mod_player:get_all_player_id();
%%            PlayerId == 1 ->   % 全服的在线的
%%                mod_online:get_all_online_player_id();
            true ->
                PlayerIdList
        end,
    add_mail_time_name_content_item_list(SendPlayerList, ?MAIL_GM_MAIL_SEND, TitleName, ItemList, Content, ?LOG_TYPE_GM),
    ok.

%% @fun gm删除邮件
gm_del_mail(MailId, CreateTime) ->
    gm_del_mail(MailId, CreateTime - 5, CreateTime + 5).
gm_del_mail(MailId, InitCreateTime, EndCreateTime) ->
    DelMailList = db:select(player_mail, [{#db_player_mail{mail_id = MailId, create_time = '$1', _ = '_'}, [{'and', {'=<', InitCreateTime, '$1'}, {'=<', '$1', EndCreateTime}}], ['$_']}]),
    DelList =
        lists:foldl(
            fun(#db_player_mail{player_id = PlayerId, mail_real_id = MailRealId, state = State, item_list = ItemList}, L) ->
                mod_apply:apply_to_online_player(PlayerId, ?MODULE, delete_player_mail, [{PlayerId, MailRealId}, delGmMail], game_worker),
                [{MailId, State, PlayerId, MailRealId, ItemList} | L]
            end, [], DelMailList),
    ?INFO("gm删除邮件:~p", [DelList]).

%% @doc     邮件锁 State:true/1 锁定；  State:false/0 解锁
gm_mail_lock(State) ->
    NewState = ?IF(State == false orelse State == ?FALSE, ?FALSE, ?TRUE),
    mod_server_data:set_int_data(?SERVER_DATA_MAIL_LOCK, NewState).

%%======================================================== 加邮件 操作 ========================================================
%% ----------------------------  没参数
%% 模板数据增加邮件
add_mail_id(PlayerId, MailId, LogType) ->
    add_mail(PlayerId, MailId, mail_id, 0, 0, LogType).
%% 道具包增加邮件
add_mail_item_list(PlayerId, MailId, ItemList, LogType) ->
    add_mail(PlayerId, MailId, item_list, ItemList, 0, LogType).
add_mail_item_list(PlayerId, MailId, ItemList, ValidTime, LogType) ->
    add_mail(PlayerId, MailId, item_list, ItemList, ValidTime, LogType).
%% 奖励id增加邮件
add_mail_award_id(PlayerId, MailId, AwardId, LogType) ->
    add_mail(PlayerId, MailId, award_id, AwardId, 0, LogType).
add_mail_award_id(PlayerId, MailId, AwardId, ValidTime, LogType) ->
    add_mail(PlayerId, MailId, award_id, AwardId, ValidTime, LogType).
%% 增加新邮件    没参数
add_mail(PlayerId, MailId, Type, Value, ValidTime1, LogType) ->
    add_mail_param(PlayerId, MailId, Type, Value, ValidTime1, [], LogType).

%% -----------------------------    带参数
%% 增加新邮件    带参数
add_mail_param(_PlayerId, _MailId, [], _LogType) ->
    ok;
add_mail_param(PlayerId, MailId, Param, LogType) ->
    add_mail_param(PlayerId, MailId, mail_id, 0, 0, Param, LogType).
add_mail_param_item_list(PlayerId, MailId, ItemList, Param, LogType) ->                     %% 道具包增加邮件
    ?IF(ItemList =/= [], add_mail_param(PlayerId, MailId, item_list, ItemList, 0, Param, LogType), ok).
add_mail_param_award_id(PlayerId, MailId, AwardId, Param, LogType) ->                       %% 奖励组id
    ?IF(AwardId > 0, add_mail_param(PlayerId, MailId, award_id, AwardId, 0, Param, LogType), ok).


%% -----------------------------    带参数   加标题
add_mail_time_name_content_item_list(PlayerId, MailId, TitleName, ItemList, Content, LogType) ->
    #t_mail{
        type = Type,
        weight_value = WeightValue
    } = try_get_t_mail(MailId),
    if
        Type == 2 ->
            ?ASSERT(util_string:string_length(TitleName) >= 1, ?ERROR_NUM_0),
            add_mail_title_name_param(PlayerId, MailId, WeightValue, TitleName, ItemList, 0, [], Content, LogType);
        true ->
            noop
    end.

add_mail_param(PlayerList, MailId, Type, Value, ValidTime1, Param, LogType) ->
    CurrTime = util_time:timestamp(),
    #t_mail{
        award_id = AwardId,
        valid_time = DefaultTime,
        weight_value = WeightValue
    } = try_get_t_mail(MailId),
    {ItemList, ValidTime} =
        case Type of
            mail_id ->
                {get_mail_item_list(AwardId, []), get_valid_time(-1, DefaultTime, CurrTime)};
            award_id ->
                {get_mail_item_list(Value, []), get_valid_time(ValidTime1, DefaultTime, CurrTime)};
            item_list ->
                MergeItemList = mod_prop:merge_prop_list(Value),
                {get_mail_item_list(0, MergeItemList), get_valid_time(ValidTime1, DefaultTime, CurrTime)}
        end,
%%	?DEBUG("add_mail_param ~p~n", [{DefaultTime, ValidTime}]),
    add_mail_title_name_param(PlayerList, MailId, WeightValue, "", ItemList, ValidTime, Param, "", LogType).

add_mail_title_name_param(0, _, _, _, _, _, _, _, _) ->
    ok;
add_mail_title_name_param([], _, _, _, _, _, _, _, _) ->
    ok;
add_mail_title_name_param(PlayerList, MailId, WeightValue, TitleName, ItemList, ValidTime, ParamList, Content, LogType) ->
    ?ASSERT(is_list(ParamList), {?ERROR_NUM_0, ParamList}),
    PlayerIdList =
        if
            is_list(PlayerList) ->
                PlayerList;
%%                [PlayerId || PlayerId <- PlayerList, mod_function:is_open(PlayerId, ?FUNCTION_MAIL_SYS)];
            true ->
                [PlayerList]
%%                case mod_function:is_open(PlayerList, ?FUNCTION_MAIL_SYS) of
%%                    true ->
%%                        [PlayerList];
%%                    _ ->
%%                        []
%%                end
        end,
    case PlayerIdList of
        [] ->
            ok;
        _ ->
            mail_srv:cast({srv_add_mail, {PlayerIdList, MailId, WeightValue, TitleName, util_string:term_to_string(ItemList), ValidTime, util_string:term_to_string(ParamList), Content, LogType}})
    end.

%% @fun 获得有效时间
get_valid_time(TimeFunTime, DefaultTime, CurrTime) ->
    if
        TimeFunTime >= 0 ->
            get_valid_time(TimeFunTime, CurrTime);
        true ->
            get_valid_time(DefaultTime, CurrTime)
    end.
get_valid_time(TimeFunTime, CurrTime) ->
    if
        TimeFunTime == 0 ->
            0;
        true ->
            if
                CurrTime < TimeFunTime andalso TimeFunTime < CurrTime + ?SAVE_DAY ->
                    TimeFunTime;
                TimeFunTime < ?SAVE_DAY ->
                    CurrTime + TimeFunTime;
                true ->     % 如果设置时间不合法，就使用当前时间，为物品马上过期
                    CurrTime
            end
    end.
%% @fun 获得邮件物品列表
get_mail_item_list(AwardId, ItemList) ->
    if
        AwardId > 0 ->
            mod_award:decode_award(AwardId);
        true ->
            ItemList
    end.

%% @fun 删除邮件操作
delete_player_mail(PlayerMail, ChangeType) ->
    delete_player_mail(PlayerMail, ChangeType, 0).
delete_player_mail({PlayerId, MailId}, ChangeType, LogType) when is_integer(MailId) ->
    case get_player_mail(PlayerId, MailId) of
        Mail when is_record(Mail, db_player_mail) ->
            Tran =
                fun() ->
                    delete_player_mail(Mail, ChangeType, LogType)
                end,
            db:do(Tran);
        _ ->
            noop
    end;
delete_player_mail(PlayerMail, ChangeType, LogType) ->
    delete_player_mail_notice(PlayerMail, ChangeType, LogType, true).
delete_player_mail_notice(PlayerMail, ChangeType, IsNotice) ->
    delete_player_mail_notice(PlayerMail, ChangeType, 0, IsNotice).
delete_player_mail_notice(PlayerMail, ChangeType, LogType, IsNotice) ->
    #db_player_mail{
        player_id = PlayerId,
        mail_real_id = MailRealId,
        mail_id = MailId,
        log_type = MailLogType
    } = PlayerMail,
    db:delete(PlayerMail),
    if
        IsNotice == true ->
            api_mail:api_remove_mail(PlayerId, MailRealId);
        true ->
            noop
    end,
    mod_log:db_write_player_mail_log(PlayerId, ChangeType, ?IF(LogType > 0, LogType, MailLogType), [], {MailRealId, MailId}).

%% @doc     获得玩家未读邮件列表
get_player_mail_unread_list(PlayerId) ->
    lists:foldl(
        fun(PlayerMail, MailL) ->
            #db_player_mail{
                state = State,
                item_list = ItemList1
            } = PlayerMail,
            ItemList = util_string:string_to_list_term(ItemList1),
            if
                State == ?MAIL_STATE_0 orelse State < ?MAIL_STATE_GET_ITEM andalso ItemList =/= [] ->
                    [PlayerMail#db_player_mail.mail_real_id | MailL];
                true ->
                    MailL
            end
        end, [], get_index_player_mail_1_player_id(PlayerId)).

%% @doc     玩家定时器
init_timer_type(PlayerId) ->
    case client_worker:get_player_id() == PlayerId of
        true ->
            client_msg_handle:init_timer_type(PlayerId, ?MSG_CLIENT_PLAYER_MAIL);
        _ ->
            mod_apply:apply_to_online_player(PlayerId, client_msg_handle, init_timer_type, [PlayerId, ?MSG_CLIENT_PLAYER_MAIL])
    end.

%% @doc     清除过期的邮件
clear_mail_old_time(PlayerId) ->
    CurrTime = util_time:timestamp(),
    OldClearTime = CurrTime - ?SAVE_DAY,
    OldClearReadTime = CurrTime - ?SAVE_READ_DAY,
    {DelL, NewClearTime} =
        lists:foldl(
            fun(PlayerMail, {DelL, ClearTime1}) ->
                #db_player_mail{
                    valid_time = ValidTime,
                    item_list = ItemList1,
                    state = State,
                    create_time = CreateTime
                } = PlayerMail,
                ItemList = util_string:string_to_list_term(ItemList1),
                if
                    0 < ValidTime andalso ValidTime =< CurrTime orelse  % 过期的
                    OldClearTime >= CreateTime orelse  % 超过15天的
                    % 已读已领取  为3天一清
                    CreateTime =< OldClearReadTime andalso (State == ?MAIL_STATE_GET_ITEM orelse ItemList == [] andalso State == ?MAIL_STATE_READ) ->
                        {[PlayerMail | DelL], ClearTime1};
                    true ->
                        Time = ?IF(ValidTime > 0, ValidTime, CreateTime + ?SAVE_DAY),
                        Time1 =
                            if
                                ClearTime1 == 0 orelse Time < ClearTime1 ->
                                    Time;
                                true ->
                                    ClearTime1
                            end,
                        {DelL, Time1}
                end
            end, {[], 0}, get_index_player_mail_1_player_id(PlayerId)),

    if
        DelL =/= [] ->
            Tran =
                fun() ->
                    [delete_player_mail(DelPlayerMail, ?MAIL_OUT_TIME) || DelPlayerMail <- DelL]
                end,
            db:do(Tran);
        true ->
            noop
    end,
    NewClearTime - CurrTime.

%% 测试使用的功能
test_fun_change(PlayerId, MailId, Value) ->
    try_get_t_mail(MailId),
    add_mail_award_id(PlayerId, MailId, Value, ?LOG_TYPE_GM),
    ok.

%% ================================================ 修复操作 ================================================
%% @fun 修复邮件品质度
repair_table_weight_value() ->
    Tran =
        fun() ->
            lists:foldl(
                fun(PlayerMail, L) ->
                    #db_player_mail{
                        player_id = PlayerId,
                        mail_real_id = MailRealId,
                        mail_id = MailId,
                        weight_value = WeightValue
                    } = PlayerMail,
                    #t_mail{
                        weight_value = TableWeightValue
                    } = try_get_t_mail(MailId),
                    if
                        TableWeightValue =/= WeightValue ->
                            db:write(PlayerMail#db_player_mail{weight_value = TableWeightValue}),
                            [{PlayerId, MailId, MailRealId, WeightValue, TableWeightValue} | L];
                        true ->
                            L
                    end
                end, [], ets:tab2list(player_mail))
        end,
    UpdateList = db:do(Tran),
    ?INFO("邮件修复WeightValue:~p", [UpdateList]),
    ok.


%% ================================================ 数据操作 ================================================
% 获得邮件信息
get_player_mail(PlayerId, MailId) ->
    db:read(#key_player_mail{player_id = PlayerId, mail_real_id = MailId}).

% 索引获得玩家邮件列表
get_index_player_mail_1_player_id(PlayerId) ->
    db_index:get_rows(#idx_player_mail_1_player_id{player_id = PlayerId}).

%% ================================================ 模板操作 ================================================
try_get_t_mail(MailId) ->
    Table = t_mail:get({MailId}),
    ?IF(is_record(Table, t_mail), Table, exit({null_t_mail, {MailId}})).


