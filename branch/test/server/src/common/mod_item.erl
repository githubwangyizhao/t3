%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            物品模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_item).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-export([
%%    get_item_type/1,
    get_item_attr_list/1,
    get_item_name/1,
    get_t_item/1
]).
%%
%%-export([
%%    add_item/4,
%%    use_item/3,
%%    get_player_item/2,
%%    get_t_item/1,
%%    get_all_player_item/1
%%]).
%%
%%%% ----------------------------------
%%%% @doc 	使用物品
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%use_item(PlayerId, ItemId, DelNum) when DelNum > 0->
%%    Tran = fun() ->
%%        PlayerItem =  get_player_item(PlayerId, ItemId),
%%        #player_item{
%%            num = Num
%%        } = PlayerItem,
%%        NewNum = Num - DelNum,
%%        ?ASSERT(NewNum >= 0),
%%        game_db:write(PlayerItem#player_item{num = NewNum}),
%%        api_prop:notice_del_item(PlayerId, [{ItemId, DelNum}])
%%           end,
%%    game_db:do(Tran).
%%
%%
%%%% ----------------------------------
%%%% @doc 	添加物品
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%add_item(PlayerId, ItemId, AddNum, LogType) when AddNum > 0->
%%    Tran = fun() ->
%%        case get_player_item(PlayerId, ItemId) of
%%            null ->
%%                PlayerItem = #player_item{
%%                    player_id = PlayerId,
%%                    item_id = ItemId,
%%                    num = AddNum
%%                },
%%                game_db:write(PlayerItem);
%%            PlayerItem ->
%%                #player_item{
%%                    num = Num
%%                } = PlayerItem,
%%                NewNum = Num + AddNum,
%%                NewPlayerItem = PlayerItem#player_item{
%%                    num = NewNum
%%                },
%%                game_db:write(NewPlayerItem)
%%        end,
%%        api_prop:notice_add_item(PlayerId, [{ItemId, AddNum}])
%%           end,
%%    game_db:do(Tran).
%%
%%%% ----------------------------------
%%%% @doc 	获取玩家物品列表
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_all_player_item(PlayerId) ->
%%    game_db:select(player_item, [{#player_item{player_id = PlayerId, _ = '_'}, [], ['$_']}]).
%%
%%get_player_item(PlayerId, ItemId) ->
%%    game_db:read(#key_player_item{player_id = PlayerId, item_id = ItemId}).
%%
%%check_grid(PlayerId) ->
%%    ?ASSERT(get_all_player_item(PlayerId) =< get_max_item_grid(PlayerId), error_max_grid).
%%
%%get_max_item_grid(PlayerId) ->
%%    100.
%%

%%get_item_type(ItemId) ->
%%   #t_item{
%%       type = ItemType
%%   } = get_t_item(ItemId),
%%    ItemType.


%% @fun 获得物品属性
get_item_attr_list(ItemId) ->
    #t_item{
        attr_list = AttrList
    } = get_t_item(ItemId),
    AttrList.


%% 获得物品名
get_item_name(ItemId) ->
    #t_item{
        name = ItemName
    } = get_t_item(ItemId),
    ItemName.

get_t_item(ItemId) ->
    case t_item:get({ItemId}) of
        null ->
%%            ?ERROR("item no found:~p", [{ItemId}]),
%%            exit(item_null);
            null;
        R ->
            R
    end.
