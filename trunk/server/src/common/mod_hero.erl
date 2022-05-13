%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         英雄
%%% @end
%%% Created : 03. 五月 2021 下午 03:02:11
%%%-------------------------------------------------------------------
-module(mod_hero).
-author("Administrator").

-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("player_game_data.hrl").
-include("common.hrl").
-include("error.hrl").
-include("msg.hrl").
-include("p_enum.hrl").

%% API
-export([
    get_player_hero/1,          %% 获得 玩家英雄

    charge_hero_parts/4,        %% 改变英雄以及饰品
    unlock_hero/2,              %% 解锁英雄
    hero_up_star/2,             %% 英雄升星

    item_unlock_hero/2,         %% 物品解锁英雄
%%    add_hero_exp/2,             %% 增加英雄经验
    unlock_parts/2,             %% 解锁

    get_db_player_hero_use/1,
    get_db_player_hero_list_by_player/1
]).

-export([
    get_parts_add_attr/1,

    get_is_can_use_anger/1
]).

-define(ARMS_TYPE, 1).
-define(ORNAMENTS_TYPE, 2).

%% @doc 获得玩家英雄
get_player_hero(PlayerId) ->
    PlayerHeroUse = get_db_player_hero_use(PlayerId),
    #db_player_hero_use{
        hero_id = HeroId,
        arms = Arms,
        ornaments = Ornaments
    } = PlayerHeroUse,
    PartsIdList = get_db_player_hero_parts_id_list(PlayerId),
    DbPlayerHeroList = get_db_player_hero_list_by_player(PlayerId),
    api_hero:pack_player_hero(HeroId, Arms, Ornaments, PartsIdList, DbPlayerHeroList).

%% @doc 改变英雄部件
charge_hero_parts(PlayerId, HeroId, Arms, Ornaments) ->
    DbPlayerHeroUse = get_db_player_hero_use(PlayerId),
    NewDbPlayerHeroUse = DbPlayerHeroUse#db_player_hero_use{hero_id = HeroId, arms = Arms, ornaments = Ornaments},
    if
        DbPlayerHeroUse == NewDbPlayerHeroUse ->
            noop;
        true ->
            DbPlayerHero = get_db_player_hero(PlayerId, HeroId),
            ?ASSERT(DbPlayerHero =/= null),
%%            ?ASSERT(get_db_player_hero_parts(PlayerId, Arms) =/= null),
            #t_hero_parts{
                use_conditions_list = ArmsUseConditionList,
                type = ArmsType
            } = get_t_hero_parts(Arms),
            ?ASSERT(ArmsType == ?ARMS_TYPE),
            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ArmsUseConditionList), ?ERROR_NOT_AUTHORITY),
            if
                Ornaments > 0 ->
%%                    ?ASSERT(get_db_player_hero_parts(PlayerId, Ornaments) =/= null),
                    #t_hero_parts{
                        use_conditions_list = OrnamentsUseConditionList,
                        type = OrnamentsType
                    } = get_t_hero_parts(Ornaments),
                    ?ASSERT(OrnamentsType == ?ORNAMENTS_TYPE),
                    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, OrnamentsUseConditionList), ?ERROR_NOT_AUTHORITY);
                true ->
                    noop
            end,
            #db_player_hero{
                star = Star
            } = DbPlayerHero,
            #t_hero{
                hero_skill_unlock_star = HeroSkillUnlockStar
            } = get_t_hero(HeroId),
            IsCanAddAnger = Star >= HeroSkillUnlockStar,
            Tran =
                fun() ->
                    db:write(NewDbPlayerHeroUse),
                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_USE_HERO, HeroId}, ?CONDITIONS_VALUE_SET, 1}),
                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_USE_HERO_PARTS, Ornaments}, ?CONDITIONS_VALUE_SET, 1}),
                    mod_scene:tran_push_player_data_2_scene(
                        PlayerId,
                        [{?MSG_SYNC_HERO_ID, HeroId}, {?MSG_SYNC_HERO_ARMS, Arms}, {?MSG_SYNC_HERO_ORNAMENTS, Ornaments}, {?MSG_SYNC_IS_CAN_ADD_ANGER, IsCanAddAnger}]
                    ),
                    mod_charge_skill:hook_skill_times_effect_change(PlayerId, ?CHARGE_SKILL_TELEPORT)
                end,
            db:do(Tran),
            ok
    end,
    ok.

%% @doc 解锁英雄
unlock_hero(PlayerId, HeroId) ->
    DbPlayerHero = get_db_player_hero(PlayerId, HeroId),
    ?ASSERT(DbPlayerHero == null, ?ERROR_ALREADY_HAVE),
    #t_hero{
        unlock_item_list = UnlockItemList,
        unlock_parts_list = UnlockPartsList
    } = get_t_hero(HeroId),
    #t_hero_star{
        reward_id = RewardId
    } = get_t_hero_star(HeroId, 0),
    mod_prop:assert_prop_num(PlayerId, UnlockItemList),
    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, UnlockItemList, ?LOG_TYPE_HERO_UNLOCK),
            ?IF(RewardId > 0, mod_award:give(PlayerId, RewardId, ?LOG_TYPE_HERO_UNLOCK), noop),
            db:write(#db_player_hero{player_id = PlayerId, hero_id = HeroId, star = 0}),
            lists:foreach(
                fun(UnlockPartsId) ->
                    unlock_parts(PlayerId, UnlockPartsId)
                end,
                UnlockPartsList
            ),
            db:tran_apply(fun() -> api_hero:notice_unlock_hero(PlayerId, HeroId, 0, UnlockPartsList) end)
        end,
    db:do(Tran),
    ok.

%% @doc 英雄升阶
hero_up_star(PlayerId, HeroId) ->
    DbPlayerHero = get_db_player_hero(PlayerId, HeroId),
    ?ASSERT(DbPlayerHero =/= null, ?ERROR_NONE),
    #db_player_hero{
        star = Star
    } = DbPlayerHero,
    #t_hero_star{
        star_next = NextStar,
        item_list = ItemList
    } = get_t_hero_star(HeroId, Star),
    ?ASSERT(NextStar > 0, ?ERROR_NOT_AUTHORITY),
    #t_hero_star{
        reward_id = RewardId
    } = get_t_hero_star(HeroId, NextStar),
    mod_prop:assert_prop_num(PlayerId, ItemList),
    DbPlayerHeroUse = get_db_player_hero_use(PlayerId),
    #db_player_hero_use{
        hero_id = PlayerHeroId
    } = DbPlayerHeroUse,
    Tran =
        fun() ->
            ?IF(RewardId > 0, mod_award:give(PlayerId, RewardId, ?LOG_TYPE_HERO_UP_STAR), noop),
            db:write(DbPlayerHero#db_player_hero{player_id = PlayerId, hero_id = HeroId, star = NextStar}),
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_HERO_STAR, HeroId}, ?CONDITIONS_VALUE_ADD, 1}),
            mod_prop:decrease_player_prop(PlayerId, ItemList, ?LOG_TYPE_HERO_UP_STAR),
            api_hero:notice_hero_up_star(?P_SUCCESS, HeroId, NextStar),
            if
                PlayerHeroId =:= HeroId ->
                    #t_hero{
                        hero_skill_unlock_star = HeroSkillUnlockStar
                    } = get_t_hero(HeroId),
                    if
                        NextStar =:= HeroSkillUnlockStar ->
                            mod_scene:tran_push_player_data_2_scene(
                                PlayerId,
                                [{?MSG_SYNC_IS_CAN_ADD_ANGER, true}]
                            );
                        true ->
                            noop
                    end;
                true ->
                    noop
            end
        end,
    db:do(Tran),
    {ok, NextStar}.

%% @doc 解锁英雄
item_unlock_hero(PlayerId, HeroId) ->
%%    ?INFO("---------------------- ~p", [HeroId]),
    case get_db_player_hero(PlayerId, HeroId) of
        null ->
            #t_hero{
                unlock_parts_list = UnlockPartsList
            } = get_t_hero(HeroId),
            #t_hero_star{
                reward_id = RewardId
            } = get_t_hero_star(HeroId, 0),
            DbPlayerHeroUse = get_db_player_hero_use(PlayerId),
            Tran =
                fun() ->
                    db:write(#db_player_hero{player_id = PlayerId, hero_id = HeroId, star = 0}),
                    lists:foreach(
                        fun(UnlockPartsId) ->
                            unlock_parts(PlayerId, UnlockPartsId, false)
                        end,
                        UnlockPartsList
                    ),
                    if
                        DbPlayerHeroUse == null ->
                            db:write(#db_player_hero_use{
                                player_id = PlayerId,
                                hero_id = HeroId,
                                arms = get_first_parts_id(UnlockPartsList, ?ARMS_TYPE),
                                ornaments = get_first_parts_id(UnlockPartsList, ?ORNAMENTS_TYPE)
                            });
                        true ->
                            noop
                    end,
                    api_hero:notice_unlock_hero(PlayerId, HeroId, 0, UnlockPartsList),
                    ?IF(RewardId > 0, mod_award:give(PlayerId, RewardId, ?LOG_TYPE_HERO_UP_STAR), noop)
                end,
            db:do(Tran),
            ok;
        R when is_record(R, db_player_hero) ->
            noop
    end.

%% @doc 增加英雄经验
%%add_hero_exp(PlayerId, AddExp) ->
%%    DbPlayerHeroUse = get_db_player_hero_use(PlayerId),
%%    #db_player_hero_use{
%%        hero_id = HeroId
%%    } = DbPlayerHeroUse,
%%    case get_db_player_hero(PlayerId, HeroId) of
%%        DbPlayerHero when is_record(DbPlayerHero, db_player_hero) ->
%%            #db_player_hero{
%%                star = OldStar,
%%                exp = OldExp
%%            } = DbPlayerHero,
%%            {NewStar, NewExp} = calc_star_and_exp(HeroId, OldStar, OldExp + AddExp),
%%            if
%%                NewExp =/= OldExp orelse NewStar =/= OldStar ->
%%                    Tran =
%%                        fun() ->
%%                            db:write(DbPlayerHero#db_player_hero{star = NewStar, exp = NewExp}),
%%                            db:tran_apply(fun() ->
%%                                api_hero:notice_hero_data_update(PlayerId, HeroId, NewStar, NewExp) end),
%%                            if
%%                                NewStar > OldStar ->
%%                                    lists:foreach(
%%                                        fun(AwardStar) ->
%%                                            #t_hero_star{
%%                                                reward_id = RewardId
%%                                            } = get_t_hero_star(HeroId, AwardStar),
%%                                            ?IF(RewardId > 0, mod_award:give(PlayerId, RewardId, ?LOG_TYPE_HERO_UP_STAR), noop)
%%                                        end,
%%                                        lists:seq(OldStar + 1, NewStar)
%%                                    );
%%                                true ->
%%                                    noop
%%                            end
%%                        end,
%%                    db:do(Tran),
%%                    ok;
%%                true ->
%%                    noop
%%            end;
%%        true ->
%%            noop
%%    end.

%% @doc 解锁部件
unlock_parts(PlayerId, PartsId) ->
    unlock_parts(PlayerId, PartsId, true).
unlock_parts(PlayerId, PartsId, IsNotice) ->
    case get_db_player_hero_parts(PlayerId, PartsId) of
        null ->
            Tran =
                fun() ->
                    db:write(#db_player_hero_parts{player_id = PlayerId, parts_id = PartsId}),
                    ?IF(IsNotice, db:tran_apply(fun() ->
                        api_hero:notice_hero_unlock_parts(PlayerId, PartsId) end), noop)
                end,
            db:do(Tran),
            ok;
        R when is_record(R, db_player_hero_parts) ->
            noop
    end.

%% @doc  计算等级和经验
%%calc_star_and_exp(HeroId, NowStar, NowExp) ->
%%    #t_hero_star{
%%        proficiency = NeedExp,
%%        star_next = NextStar
%%    } = get_t_hero_star(HeroId, NowStar),
%%    if NextStar == 0 ->
%%        {NowStar, NowExp};
%%        true ->
%%            if
%%                NowExp > NeedExp ->
%%                    calc_star_and_exp(HeroId, NextStar, NowExp - NeedExp);
%%                NowExp == NeedExp ->
%%                    {NextStar, 0};
%%                NowExp < NeedExp ->
%%                    {NowStar, NowExp}
%%            end
%%    end.

get_first_parts_id([], _Type) ->
    0;
get_first_parts_id([PartsId | List], Type) ->
    #t_hero_parts{
        type = PartsType
    } = get_t_hero_parts(PartsId),
    if
        PartsType == Type ->
            PartsId;
        true ->
            get_first_parts_id(List, Type)
    end.

get_parts_add_attr(PlayerId) ->
    #db_player_hero_use{
        arms = ArmsId,
        ornaments = OrnamentsId
    } = mod_hero:get_db_player_hero_use(PlayerId),
    {ArmsSkillDashChargePer, ArmsSkillDashTimesAdd} =
        if
            ArmsId > 0 ->
                #t_hero_parts{
                    skill_dash_charge_per = SkillDashChargePer1,
                    skill_dash_times_add = SkillDashTimesAdd1
                } = get_t_hero_parts(ArmsId),
                {SkillDashChargePer1, SkillDashTimesAdd1};
            true ->
                {0, 0}
        end,
    {OrnamentsSkillDashChargePer, OrnamentsSkillDashTimesAdd} =
        if
            OrnamentsId > 0 ->
                #t_hero_parts{
                    skill_dash_charge_per = SkillDashChargePer2,
                    skill_dash_times_add = SkillDashTimesAdd2
                } = get_t_hero_parts(OrnamentsId),
                {SkillDashChargePer2, SkillDashTimesAdd2};
            true ->
                {0, 0}
        end,
    {ArmsSkillDashChargePer + OrnamentsSkillDashChargePer, ArmsSkillDashTimesAdd + OrnamentsSkillDashTimesAdd}.

get_is_can_use_anger(PlayerId) when is_integer(PlayerId) ->
    DbPlayerHeroUse = get_db_player_hero_use(PlayerId),
    get_is_can_use_anger(DbPlayerHeroUse);
get_is_can_use_anger(DbPlayerHeroUse) when is_record(DbPlayerHeroUse, db_player_hero_use) ->
    #db_player_hero_use{
        player_id = PlayerId,
        hero_id = HeroId
    } = DbPlayerHeroUse,
    #db_player_hero{
        star = Star
    } = get_db_player_hero(PlayerId, HeroId),
    #t_hero{
        hero_skill_unlock_star = HeroSkillUnlockStar
    } = get_t_hero(HeroId),
    Star >= HeroSkillUnlockStar.

%% ================================================ 数据操作 ================================================

%% @doc DB 获得玩家英雄数据
get_db_player_hero(PlayerId, HeroId) ->
    db:read(#key_player_hero{player_id = PlayerId, hero_id = HeroId}).
%%get_db_player_hero_init(PlayerId, HeroId) ->
%%    case get_db_player_hero(PlayerId, HeroId) of
%%        R when is_record(R, db_player_hero) ->
%%            R;
%%        _ ->
%%            #db_player_hero{
%%                player_id = PlayerId,
%%                hero_id = HeroId,
%%                star = 1,
%%                exp = 0
%%            }
%%    end.

%% @doc DB 获得玩家英雄部件数据
get_db_player_hero_parts(PlayerId, PartsId) ->
    db:read(#key_player_hero_parts{player_id = PlayerId, parts_id = PartsId}).

%% @doc DB 获得玩家英雄使用数据
get_db_player_hero_use(PlayerId) ->
    db:read(#key_player_hero_use{player_id = PlayerId}).
%%get_db_player_hero_use_init(PlayerId) ->
%%    case get_db_player_hero_use(PlayerId) of
%%        R when is_record(R, db_player_hero_use) ->
%%            R;
%%        _ ->
%%            #db_player_hero_use{
%%                player_id = PlayerId,
%%                hero_id = HeroId,
%%                star = 1,
%%                exp = 0
%%            }
%%    end.

%% @doc DB 获得玩家英雄数据列表 根据玩家
get_db_player_hero_list_by_player(PlayerId) ->
    db_index:get_rows(#idx_player_hero_by_player{player_id = PlayerId}).

%% @doc DB 获得玩家英雄部件数据列表 根据玩家
get_db_player_hero_parts_list_by_player(PlayerId) ->
    db_index:get_rows(#idx_player_hero_parts_by_player{player_id = PlayerId}).

%% @doc DB 获得玩家英雄部件数据列表 根据玩家和英雄
%%get_db_player_hero_parts_list_by_player_and_hero(PlayerId, HeroId) ->
%%    List = get_db_player_hero_parts_list_by_player(PlayerId),
%%    lists:filter(
%%        fun(DbPlayerHeroParts) ->
%%            #db_player_hero_parts{
%%                parts_id = PartsId
%%            } = DbPlayerHeroParts,
%%            #t_hero_parts{
%%                hero_id = PartsHeroId
%%            } = get_t_hero_parts(PartsId),
%%            HeroId == PartsHeroId
%%        end,
%%        List
%%    ).

get_db_player_hero_parts_id_list(PlayerId) ->
    [PartsId || #db_player_hero_parts{parts_id = PartsId} <- get_db_player_hero_parts_list_by_player(PlayerId)].

%% ================================================ 模板操作 ================================================

%% @doc 获得英雄表
get_t_hero(HeroId) ->
    t_hero:assert_get({HeroId}).

%% @doc 获得英雄星级表
get_t_hero_star(HeroId, Star) ->
    t_hero_star:assert_get({HeroId, Star}).

%% @doc 获得英雄部件表
get_t_hero_parts(PartsId) ->
    t_hero_parts:assert_get({PartsId}).
