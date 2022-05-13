%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 05. 二月 2018 12:26
%%%-------------------------------------------------------------------
-module(api_rank).
-author("home").

-include("p_message.hrl").

%% API
-export([
    get_rank_info/2             %% 排行榜信息
]).

-export([
    pack_rank_info/1,           % 打包排行榜数据
    api_pack_rank_info_list/1       %% api列表数据打包排行数据
]).

-include("common.hrl").
-include("p_message.hrl").

%% @doc     排行榜信息
get_rank_info(#m_rank_get_rank_info_tos{fun_id = FunId, page_num = PageNum},
    #conn{player_id = PlayerId} = State) ->
    ?REQUEST_INFO("排行榜信息" ++ util:to_list(FunId) ++ "_:_" ++ util:to_list(PageNum)),
    {FirstPlayerId, FirstValue, MyRank, RankList, LastRank} = mod_rank:get_rank_info(PlayerId, FunId, PageNum),
    Out = proto:encode(#m_rank_get_rank_info_toc{model_figure = api_player:pack_model_figure(FirstPlayerId), first_show_value = min(FirstValue, ?MAX_NUMBER_VALUE), my_rank = MyRank, fun_id = FunId, page_num = PageNum, total_num = LastRank, rank_info = api_pack_rank_info_list(RankList)}),
    mod_socket:send(Out),
    State.


%% @fun api列表数据打包排行数据
api_pack_rank_info_list(List) ->
    [pack_rank_info(Tuple) || Tuple <- List].

%% @fun 打包排行榜数据
pack_rank_info({}) ->
    ?UNDEFINED;
pack_rank_info(RankInfo) when is_record(RankInfo, rankinfo) ->
    RankInfo;
pack_rank_info(Tuple) ->
    {PlayerId, Rank, Value, Value1} =
        case Tuple of
            {PlayerId1, Rank1, Value11} ->
                {PlayerId1, Rank1, Value11, 0};
            _ ->
                Tuple
        end,
    #rankinfo{
        player_id = PlayerId,
        name = mod_player:get_player_name_to_binary(PlayerId),
        rank = Rank,
        vip_level = mod_vip:get_vip_level(PlayerId),
        sex = mod_player:get_player_data(PlayerId, sex),
        head_id = mod_player:get_player_data(PlayerId, head_id),
        value = Value,
%%        vip_prerogative_card = mod_prerogative_card:get_all_prerogative_card_id_list(PlayerId),
        vip_prerogative_card = [],
        other_value = Value1
    }.
