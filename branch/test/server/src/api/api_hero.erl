%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 五月 2021 下午 02:45:56
%%%-------------------------------------------------------------------
-module(api_hero).
-author("Administrator").

-include("p_enum.hrl").
-include("p_message.hrl").
-include("common.hrl").
-include("gen/db.hrl").

%% API
-export([
    api_get_player_hero/1,                  %% API 获得玩家英雄

    charge_hero_parts/2,                    %% 改变英雄及部件
    unlock_hero/2,                          %% 解锁英雄
    hero_up_star/2,                         %% 英雄升星
    notice_hero_up_star/3,                  %% 通知英雄升星

    notice_hero_unlock_parts/2,             %% 通知解锁英雄部件
    notice_unlock_hero/4,                   %% 通知解锁英雄

    pack_player_hero/5                      %% 结构化 玩家英雄
]).

%% @doc API 获得英雄
api_get_player_hero(PlayerId) ->
    mod_hero:get_player_hero(PlayerId).

%% @doc 改变英雄及部件
charge_hero_parts(
    #m_hero_charge_hero_parts_tos{id = HeroId, arms = Arms, ornaments = Ornaments},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_hero:charge_hero_parts(PlayerId, HeroId, Arms, Ornaments)),
    Out = proto:encode(#m_hero_charge_hero_parts_toc{result = Result, id = HeroId, arms = Arms, ornaments = Ornaments}),
    mod_socket:send(Out),
    State.

%% @doc 解锁英雄
unlock_hero(
    #m_hero_unlock_hero_tos{id = HeroId},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_hero:unlock_hero(PlayerId, HeroId)),
    Out = proto:encode(#m_hero_unlock_hero_toc{result = Result, id = HeroId}),
    mod_socket:send(Out),
    State.

%% @doc 升星
hero_up_star(
    #m_hero_hero_up_star_tos{id = HeroId},
    State = #conn{player_id = PlayerId}
) ->
    try mod_hero:hero_up_star(PlayerId, HeroId)
    catch
        _:ERROR ->
            notice_hero_up_star(api_common:api_error_to_enum(ERROR), HeroId, 0)
    end,
%%    case catch mod_hero:hero_up_star(PlayerId, HeroId) of
%%        {ok, NewStar1} ->
%%            {?P_SUCCESS, NewStar1};
%%        {'EXIT', ERROR} ->
%%
%%    end,
    State.
notice_hero_up_star(Result, HeroId, Star) ->
    Out = proto:encode(#m_hero_hero_up_star_toc{result = Result, id = HeroId, star = Star}),
    mod_socket:send(Out).

%% @doc 通知解锁英雄部件
notice_hero_unlock_parts(PlayerId, PartsId) ->
    Out = proto:encode(#m_hero_notice_hero_unlock_parts_toc{parts_id = PartsId}),
    mod_socket:send(PlayerId, Out).

%% @doc 通知解锁英雄
notice_unlock_hero(PlayerId, HeroId, Star, PartsIdList) ->
    Out = proto:encode(#m_hero_notice_unlock_hero_toc{id = HeroId, star = Star, parts_id = PartsIdList}),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc 结构化 玩家英雄
pack_player_hero(HeroId, Arms, Ornaments, PartsIdList, DbPlayerHeroList) ->
    #playerhero{
        id = HeroId,
        arms = Arms,
        ornaments = Ornaments,
        list = PartsIdList,
        hero_list = pack_hero_list(DbPlayerHeroList)
    }.

%% @doc 结构化 英雄 列表
pack_hero_list(DbPlayerHeroList) ->
    [pack_hero(DbPlayerHero) || DbPlayerHero <- DbPlayerHeroList].

%% @doc 结构化 英雄
pack_hero(DbPlayerHeroList) ->
    #db_player_hero{
        hero_id = HeroId,
        star = Star
    } = DbPlayerHeroList,
    #hero{
        id = HeroId,
        star = Star
    }.
