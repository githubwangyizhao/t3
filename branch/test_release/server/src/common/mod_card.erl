%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         卡牌图鉴系统
%%% @end
%%% Created : 07. 五月 2021 下午 05:53:15
%%%-------------------------------------------------------------------
-module(mod_card).
-author("Administrator").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("player_game_data.hrl").

%% API
-export([
    get_player_card_book_list/1,            %% 获得玩家卡牌图鉴列表

    get_award/3,                            %% 获得奖励

    add_card/3                              %% 增加卡牌
]).

-export([
    repair/1
]).

-define(CARD_BOOK, 1).
-define(CARD_TITLE, 2).
-define(CARD, 3).

%% @doc 获得玩家卡牌图鉴列表
get_player_card_book_list(PlayerId) ->
    lists:map(
        fun({CardBookId}) ->
            BookState =
                case get_db_player_card_book(PlayerId, CardBookId) of
                    null ->
                        ?AWARD_NONE;
                    _ ->
                        ?AWARD_ALREADY
                end,
            #t_card_book{
                card_title_list = CardTitleIdList
            } = get_t_card_book(CardBookId),
            PbCardTitleList = lists:map(
                fun(CardTitleId) ->
                    TitleState =
                        case get_db_player_card_title(PlayerId, CardTitleId) of
                            null ->
                                ?AWARD_NONE;
                            _ ->
                                ?AWARD_ALREADY
                        end,
                    #t_card_title{
                        card_item_list = CardIdList
                    } = get_t_card_title(CardTitleId),
                    PbCardList = lists:foldl(
                        fun(CardId, TmpL) ->
                            case get_db_player_card_or_init(PlayerId, CardId) of
                                null ->
                                    TmpL;
                                DbPlayerCard ->
                                    #db_player_card{
                                        state = CardState,
                                        num = CardNum
                                    } = DbPlayerCard,
                                    PbCard = api_card:pack_pb_card(CardId, CardState, CardNum),
                                    [PbCard | TmpL]
                            end
                        end,
                        [], CardIdList
                    ),
                    api_card:pack_pb_card_title(CardTitleId, TitleState, PbCardList)
                end,
                CardTitleIdList
            ),
            api_card:pack_pb_card_book(CardBookId, BookState, PbCardTitleList)
        end,
        t_card_book:get_keys()
    ).

%% @doc 获得奖励
-type prop() :: {integer(), integer()}.
-spec get_award(PlayerId, Type, Id) -> {ok, PropList} when
    PlayerId :: integer(),
    Type :: integer(),
    Id :: integer(),
    PropList :: [prop()].
get_award(PlayerId, Type, Id) ->
    case Type of
        ?CARD_BOOK ->
            ?ASSERT(get_db_player_card_book(PlayerId, Id) == null),
            #t_card_book{
                reward = RewardId,
                card_title_list = CardTitleIdList
            } = get_t_card_book(Id),
            IsAllGet = lists:all(
                fun(CardTitleId) ->
                    get_db_player_card_title(PlayerId, CardTitleId) =/= null
                end,
                CardTitleIdList
            ),
            ?ASSERT(IsAllGet, ?ERROR_NOT_AUTHORITY),
            AwardList = mod_award:decode_award(RewardId),
            mod_prop:assert_give(PlayerId, AwardList),
            Tran =
                fun() ->
                    db:write(#db_player_card_book{player_id = PlayerId, card_book_id = Id}),
                    mod_award:give(PlayerId, AwardList, ?LOG_TYPE_CARD_AWARD)
                end,
            db:do(Tran),
            {ok, AwardList};
        ?CARD_TITLE ->
            ?ASSERT(get_db_player_card_title(PlayerId, Id) == null),
            #t_card_title{
                reward = RewardId,
                card_item_list = CardIdList
            } = get_t_card_title(Id),
            IsAllGet = lists:all(
                fun(CardId) ->
                    #db_player_card{state = State} = get_db_player_card_or_init(PlayerId, CardId),
                    State == ?AWARD_ALREADY
                end,
                CardIdList
            ),
            ?ASSERT(IsAllGet, ?ERROR_NOT_AUTHORITY),
            AwardList = mod_award:decode_award(RewardId),
            mod_prop:assert_give(PlayerId, AwardList),
            Tran =
                fun() ->
                    db:write(#db_player_card_title{player_id = PlayerId, card_title_id = Id}),
                    mod_award:give(PlayerId, AwardList, ?LOG_TYPE_CARD_AWARD)
                end,
            db:do(Tran),
            {ok, AwardList};
        ?CARD ->
            DbPlayerCard = get_db_player_card_or_init(PlayerId, Id),
            #db_player_card{
                state = State,
                num = Num
            } = DbPlayerCard,
            ?ASSERT(State == ?AWARD_NONE),
            #t_card{
                reward = RewardId,
                goal_count = NeedNum
            } = get_t_card(Id),
            ?ASSERT(Num >= NeedNum, ?ERROR_NOT_AUTHORITY),
            AwardList = mod_award:decode_award(RewardId),
            mod_prop:assert_give(PlayerId, AwardList),
            Tran =
                fun() ->
                    TitleList = logic_get_card_title_list_by_card_id:assert_get(Id),
                    db:write(DbPlayerCard#db_player_card{state = ?AWARD_ALREADY}),
                    mod_award:give(PlayerId, AwardList, ?LOG_TYPE_CARD_AWARD),
                    lists:foreach(
                        fun(Title) ->
                            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_CARD, Title}, ?CONDITIONS_VALUE_ADD, 1}),
                            #t_card_title{
                                card_item_list = CardIdList
                            } = get_t_card_title(Title),
                            IsAll = lists:all(
                                fun(CardId) ->
                                    #db_player_card{state = ThisState} = get_db_player_card_or_init(PlayerId, CardId),
                                    ThisState == ?AWARD_ALREADY
                                end,
                                CardIdList
                            ),
                            if
                                IsAll ->
                                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_CARD_TITLE, Title}, ?CONDITIONS_VALUE_ADD, 1});
                                true ->
                                    noop
                            end
                        end,
                        TitleList
                    )
                end,
            db:do(Tran),
            {ok, AwardList}
    end.

%% @doc 增加卡牌
add_card(PlayerId, CardId, AddNum) ->
    DbPlayerCard = get_db_player_card_or_init(PlayerId, CardId),
    #db_player_card{
        state = State,
        num = Num
    } = DbPlayerCard,
    #t_card{
        goal_count = NeedNum
    } = get_t_card(CardId),
    if
        State == ?AWARD_NONE andalso NeedNum > Num ->
            NewNum = min(NeedNum, Num + AddNum),
            Tran =
                fun() ->
                    db:write(DbPlayerCard#db_player_card{num = NewNum}),
                    db:tran_apply(fun() -> api_card:notice_card_update(PlayerId, CardId, NewNum) end)
                end,
            db:do(Tran),
            ok;
        true ->
            noop
    end.

repair(PlayerId) ->
    IsRepair = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_CARD_CONDITION_IS_REPAIR, ?FALSE),
    case IsRepair of
        ?TRUE ->
            noop;
        ?FALSE ->
            Tran =
                fun() ->
                    lists:foreach(
                        fun({CardTitleId}) ->
                            #t_card_title{
                                card_item_list = CardIdList
                            } = get_t_card_title(CardTitleId),
                            Num =
                                lists:foldl(
                                    fun(CardId, TmpNum) ->
                                        case get_db_player_card(PlayerId, CardId) of
                                            null ->
                                                TmpNum;
                                            DbPlayerCard ->
                                                #db_player_card{
                                                    state = CardState
                                                } = DbPlayerCard,
                                                if
                                                    CardState == ?AWARD_ALREADY ->
                                                        TmpNum + 1;
                                                    true ->
                                                        TmpNum
                                                end
                                        end
                                    end,
                                    0, CardIdList
                                ),
                            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_CARD, CardTitleId}, ?CONDITIONS_VALUE_SET, Num})
                        end,
                        t_card_title:get_keys()
                    ),
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_CARD_CONDITION_IS_REPAIR, ?TRUE)
                end,
            db:do(Tran)
    end.

%% ================================================ 数据操作 ================================================

%% @doc DB 获得玩家卡牌图鉴
get_db_player_card_book(PlayerId, CardBookId) ->
    db:read(#key_player_card_book{player_id = PlayerId, card_book_id = CardBookId}).

%% @doc DB 获得玩家卡牌标题
get_db_player_card_title(PlayerId, CardTitleId) ->
    db:read(#key_player_card_title{player_id = PlayerId, card_title_id = CardTitleId}).

%% @doc DB 获得玩家卡牌
get_db_player_card(PlayerId, CardId) ->
    db:read(#key_player_card{player_id = PlayerId, card_id = CardId}).
get_db_player_card_or_init(PlayerId, CardId) ->
    case get_db_player_card(PlayerId, CardId) of
        R when is_record(R, db_player_card) ->
            R;
        _ ->
            #db_player_card{
                player_id = PlayerId,
                card_id = CardId
            }
    end.

%% ================================================ 配置表操作 ================================================

%% @doc 获得卡牌图鉴表
get_t_card_book(CardBookId) ->
    t_card_book:assert_get({CardBookId}).

%% @doc 获得卡牌标题表
get_t_card_title(CardTitleId) ->
    t_card_title:assert_get({CardTitleId}).

%% @doc 获得卡牌表
get_t_card(CardId) ->
    t_card:assert_get({CardId}).
