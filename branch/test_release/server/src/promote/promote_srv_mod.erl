%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         推广
%%% @end
%%% Created : 09. 十二月 2020 下午 04:51:43
%%%-------------------------------------------------------------------
-module(promote_srv_mod).
-author("Administrator").

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("promote.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    %% RPC CALL
    get_player_promote_data/2,              %% 获得玩家推广数据
    %% CALL
    handle_get_record_list/2,               %% 获得记录列表
    handle_get_award/4,                     %% 获得奖励
    %% CAST
    handle_do_deal_invite/5,                %% 处理分享进入游戏
    handle_charge/5                         %% 处理充值
]).

-export([
    get_db_promote/2
]).

%% @doc 获得玩家推广数据
get_player_promote_data(PlatformId, AccId) ->
    DbPromote = get_db_promote_or_init(PlatformId, AccId),
    get_player_promote_data(DbPromote).
get_player_promote_data(DbPromote) ->
    #db_promote{
        platform_id = PlatformId,
        acc_id = AccId,
        use_times = UseTimes,
        is_red = IsRed
    } = DbPromote,
    List =
        lists:map(
            fun([Level, _Rate]) ->
                get_db_promote_info_or_init(PlatformId, AccId, Level)
            end,
            ?SD_PROMOTE_LIST
        ),
    {?SD_PROMOTE_AWARD_TODAY_TIMES_LIMIT - UseTimes, IsRed, List}.

%% @doc  获得记录列表
handle_get_record_list(PlatformId, AccId) ->
    L = get_db_promote_record_list(PlatformId, AccId),
    if
        L =:= [] ->
            noop;
        true ->
            DbPromote = get_db_promote_or_init(PlatformId, AccId),
            #db_promote{
                is_red = IsRed
            } = DbPromote,
            if
                IsRed =:= ?TRUE ->
                    Tran =
                        fun() ->
                            db:write(DbPromote#db_promote{is_red = ?FALSE})
                        end,
                    db:do(Tran);
                true ->
                    noop
            end
    end,
    L.

%% @doc 处理被邀请(Acc:被邀请人账号，DoInvitePlayerId:邀请人玩家id)
handle_do_deal_invite(PlatformId, AccId, PlayerId, SharePlayerId, NickName) ->
    DbPromote = get_db_promote_or_init(PlatformId, AccId),
    #db_promote{
        invite_player_id = InvitePlayerId
    } = DbPromote,
    case InvitePlayerId of
        0 ->
            Level = 1,
            Fun =
                fun() ->
                    Tran =
                        fun() ->
                            NewDbPromote = DbPromote#db_promote{
                                platform_id = PlatformId,
                                acc_id = AccId,
                                invite_player_id = SharePlayerId
                            },
                            db:write(NewDbPromote),
                            handle_do_deal_invite1(SharePlayerId, Level, NickName)
                        end,
                    db:do(Tran)
                end,
            DbGlobalPlayer = get_db_global_player(SharePlayerId),
            ?DEBUG("DbGlobalPlayer   ~p", [DbGlobalPlayer]),
            case DbGlobalPlayer of
                #db_global_player{platform_id = PlatformId, account = AccId} ->
                    %% 邀请人和被邀请人是同一个人
                    exit(?ERROR_NOT_AUTHORITY);
                null ->
                    %% 找不到邀请人
                    exit(?ERROR_NONE);
                #db_global_player{platform_id = PlatformId, server_id = ServerId, nickanme = SharePlayerNickName} ->
                    Fun(),
                    mod_server_rpc:cast_game_server(
                        PlatformId,
                        ServerId,
                        mod_apply,
                        apply_to_online_player,
                        [
                            PlayerId,
                            mod_mail,
                            add_mail_param,
                            [
                                PlayerId,
                                ?MAIL_INVITE_REWARDS,
                                [
                                        ServerId ++ "." ++ SharePlayerNickName
                                ],
                                ?LOG_TYPE_PROMOTE_AWARD
                            ],
                            store
                        ]),
                    mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_apply, apply_to_online_player, [SharePlayerId, mod_share, do_deal_invite_2, [SharePlayerId, AccId, 1], store]);
                _ ->
                    exit(?ERROR_FAIL)
            end;
        _ ->
            %% 被邀请过
            exit(?ERROR_ALREADY_GET)
    end,
    ok.
handle_do_deal_invite1(PlayerId, Level, DoInviteNickName) ->
    case util_list:opt(Level, ?SD_PROMOTE_LIST, null) of
        null ->
            noop;
        _Rate ->
            DbGlobalPlayer = get_db_global_player(PlayerId),
            case DbGlobalPlayer of
                null ->
                    noop;
                _ ->
                    #db_global_player{
                        platform_id = PlatformId,
                        account = AccId,
                        server_id = ServerId
                    } = DbGlobalPlayer,
                    DbPromote = get_db_promote_or_init(PlatformId, AccId),
                    #db_promote{
                        invite_player_id = InvitePlayerId,
                        is_red = IsRed
                    } = DbPromote,
                    DbPromoteInfo = get_db_promote_info_or_init(PlatformId, AccId, Level),
                    #db_promote_info{
                        number = OldNumber
                    } = DbPromoteInfo,
                    NewNumber = OldNumber + 1,
                    NewDbPromoteInfo = DbPromoteInfo#db_promote_info{
                        number = NewNumber
                    },
                    RecordRealId = get_record_real_id(),

                    ?IF(IsRed =:= ?TRUE, noop, db:write(DbPromote#db_promote{is_red = ?TRUE})),
                    db:write(NewDbPromoteInfo),
                    db:tran_apply(
                        fun() ->
                            mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_apply, apply_to_online_player, [PlayerId, api_promote, notice_player_promote_data, [PlayerId, get_player_promote_data(PlatformId, AccId)], normal])
                        end
                    ),
                    StringParamList = util_string:term_to_string([Level, DoInviteNickName]),
                    db:write(#db_promote_record{real_id = RecordRealId, platform_id = PlatformId, acc_id = AccId, id = ?PROMOTE_TEMPLATE_TYPE_1, param = StringParamList, time = util_time:timestamp()}),
                    if
                        InvitePlayerId > 0 ->
                            handle_do_deal_invite1(InvitePlayerId, Level + 1, DoInviteNickName);
                        true ->
                            noop
                    end
            end
    end.

%% @doc 获得奖励    vip经验其实是钻石   change_ingot其实是金币
handle_get_award(PlatformId, AccId, PlayerId, ServerId) ->
    DbPromote = get_db_promote_or_init(PlatformId, AccId),
    #db_promote{
        use_times = UseTimes
    } = DbPromote,
    ?ASSERT(?SD_PROMOTE_AWARD_TODAY_TIMES_LIMIT > UseTimes, ?ERROR_TIMES_LIMIT),
    Tran =
        fun() ->
            {TotalMana, TotalVipExp} =
                lists:foldl(
                    fun([Level, _Rate], {TmpMana, TmpVipExp}) ->
                        DbPromoteInfo = get_db_promote_info_or_init(PlatformId, AccId, Level),
                        #db_promote_info{
                            mana = Mana,
                            vip_exp = VipExp
                        } = DbPromoteInfo,
                        if
                            Mana =:= 0 andalso VipExp =:= 0 ->
                                {TmpMana, TmpVipExp};
                            true ->
                                db:write(DbPromoteInfo#db_promote_info{mana = 0, vip_exp = 0}),
                                {TmpMana + Mana, TmpVipExp + VipExp}
                        end
                    end,
                    {0, 0}, ?SD_PROMOTE_LIST
                ),
            if
                TotalMana > 0 orelse TotalVipExp > 0 ->
                    db:write(DbPromote#db_promote{use_times = UseTimes + 1, times_time = util_time:timestamp()}),
                    mod_server_rpc:cast_game_server(PlatformId, ServerId, api_promote, notice_player_promote_data, [PlayerId, get_player_promote_data(PlatformId, AccId)]);
                true ->
                    exit(?ERROR_NONE)
            end,
            {TotalMana, TotalVipExp}
        end,

    db:do(Tran).

%% @doc 充值回调    vip经验其实是钻石   change_ingot其实是金币
handle_charge(PlatformId, PlayerName, AccId, Mana, VipExp) ->
    case get_db_promote(PlatformId, AccId) of
        null ->
            noop;
        DbPromote ->
            Level = 1,
            #db_promote{
                platform_id = PlatformId,
                acc_id = AccId,
                invite_player_id = DoInvitePlayerId
            } = DbPromote,
            Tran =
                fun() ->
                    handle_charge_1(DoInvitePlayerId, PlayerName, Level, Mana, VipExp)
                end,
            db:do(Tran)
    end.
handle_charge_1(PlayerId, ChargePlayerName, Level, Mana, VipExp) ->
    case util_list:opt(Level, ?SD_PROMOTE_LIST, null) of
        null ->
            noop;
        Rate ->
            DbGlobalPlayer = get_db_global_player(PlayerId),
            if
                DbGlobalPlayer =:= null ->
                    noop;
                true ->
                    #db_global_player{
                        platform_id = PlatformId,
                        account = AccId
                    } = DbGlobalPlayer,
                    #db_global_account{
                        recent_server_list = RecentServerList
                    } = global_account_srv:get_global_account(PlatformId, AccId),
                    ServerIdList = mod_global_account:tran_recent_server_list(RecentServerList),
                    DbPromote = get_db_promote_or_init(PlatformId, AccId),
                    #db_promote{
                        invite_player_id = InvitePlayerId,
                        is_red = IsRed
                    } = DbPromote,
                    DbPromoteInfo = get_db_promote_info_or_init(PlatformId, AccId, Level),
                    #db_promote_info{
                        mana = OldMana,
                        vip_exp = OldVipExp
                    } = DbPromoteInfo,
                    AddMana = ceil(Mana * Rate / 10000),
                    AddVipExp = ceil(VipExp * Rate / 10000),
                    NewDbPromoteInfo = DbPromoteInfo#db_promote_info{
                        mana = OldMana + AddMana,
                        vip_exp = OldVipExp + AddVipExp
                    },
                    RecordRealId = get_record_real_id(),

                    ?IF(IsRed =:= ?TRUE, noop, db:write(DbPromote#db_promote{is_red = ?TRUE})),
                    db:write(NewDbPromoteInfo),
                    lists:foreach(
                        fun(ServerId) ->
                            db:tran_apply(
                                fun() ->
                                    mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_apply, apply_to_online_player, [PlayerId, api_promote, notice_player_promote_data, [PlayerId, get_player_promote_data(PlatformId, AccId)], normal])
                                end
                            )
                        end,
                        ServerIdList
                    ),
                    StringParamList = util_string:term_to_string([Level, ChargePlayerName, AddMana, AddVipExp]),
                    db:write(#db_promote_record{real_id = RecordRealId, platform_id = PlatformId, acc_id = AccId, id = ?PROMOTE_TEMPLATE_TYPE_2, param = StringParamList, time = util_time:timestamp()}),
                    if
                        InvitePlayerId > 0 ->
                            handle_charge_1(InvitePlayerId, ChargePlayerName, Level + 1, Mana, VipExp);
                        true ->
                            noop
                    end
            end
    end.


%% ================================================ UTIL ================================================

%% @doc 获得服务器推广记录唯一id
get_record_real_id() ->
    Value = mod_server_data:get_int_data(?SERVER_DATA_CENTER_PROMOTE_RECORD_REAL_ID),
    mod_server_data:set_int_data(?SERVER_DATA_CENTER_PROMOTE_RECORD_REAL_ID, Value + 1),
    Value + 1.

%% ================================================ 数据操作 ================================================

%% @doc Db 获得global_player
get_db_global_player(PlayerId) ->
    Sql = io_lib:format("SELECT * from `global_player` WHERE id = '~p'; ", [PlayerId]),
    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    Fun = fun(R) ->
        R#db_global_player{
            row_key = {R#db_global_player.id}
        }
          end,
    L = lib_mysql:as_record(Res1, db_global_player, record_info(fields, db_global_player), Fun),
%%    ?DEBUG("get_golbal_player_sql:~ts, ~p~n", [Sql, L]),
    case L of
        [DbGlobalPlayer] ->
            DbGlobalPlayer;
        [] ->
            null
    end.


%% @doc Db 获得推广数据
get_db_promote(PlatformId, AccId) ->
    db:read(#key_promote{platform_id = PlatformId, acc_id = AccId}).
get_db_promote_or_init(PlatformId, AccId) ->
    case get_db_promote(PlatformId, AccId) of
        null ->
            #db_promote{
                platform_id = PlatformId,
                acc_id = AccId
            };
        R ->
            #db_promote{
                times_time = TimesUseTime
            } = R,
            {{_YY, _MM, _DD}, {H, _M, _S}} = util_time:local_datetime(),
            IsNotReset =
                if
                    H >= 2 ->
                        util_time:is_today(TimesUseTime - 2 * ?HOUR_S);
                    true ->
                        util_time:is_yesterday(TimesUseTime - 2 * ?HOUR_S)
                end,
            case IsNotReset of
                true ->
                    R;
                false ->
                    R#db_promote{
                        use_times = 0
                    }
            end
    end.

%% @doc Db 获得推广信息
get_db_promote_info(PlatformId, AccId, Level) ->
    db:read(#key_promote_info{platform_id = PlatformId, acc_id = AccId, level = Level}).
get_db_promote_info_or_init(PlatformId, AccId, Level) ->
    case get_db_promote_info(PlatformId, AccId, Level) of
        null ->
            #db_promote_info{
                platform_id = PlatformId,
                acc_id = AccId,
                level = Level
            };
        R ->
            R
    end.
%%get_db_promote_info_list(PlatformId, AccId) ->
%%    lists:map(
%%        fun(Level) ->
%%            get_db_promote_info_or_init(PlatformId, AccId, Level)
%%        end,
%%        t_promote:get_keys()
%%    ).

%% @doc 获得推广记录列表
get_db_promote_record_list(PlatformId, AccId) ->
    db_index:get_rows(#idx_promote_record_1{platform_id = PlatformId, acc_id = AccId}).
