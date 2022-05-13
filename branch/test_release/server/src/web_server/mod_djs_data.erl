%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc
%%%%% Created : 25. 九月 2018 16:57
%%%%%-------------------------------------------------------------------
-module(mod_djs_data).
%%-author("home").
%%
%%%% API
%%-export([
%%    try_is_djs_have_key/1,
%%    djs_sell/8,
%%    srv_djs_sell/1,
%%    djs_rank/3
%%]).
%%
%%-include("error.hrl").
%%-include("gen/db.hrl").
%%-include("common.hrl").
%%-include("gen/table_enum.hrl").
%%
%%%% @fun 兑换积分
%%djs_sell(PlayerId, ChannelId, ServerId, UId, Id, NotifyId, MailTitle, MailMsg) ->
%%    PlatformId = mod_server:get_platform_by_channel(ChannelId),
%%    GameNode = get_game_node(PlatformId, ServerId),
%%    case djs_data_srv:call_sell({GameNode, PlayerId, UId, Id, PlatformId, NotifyId, MailTitle, MailMsg}) of
%%        ok ->
%%            ?INFO("djs兑换积分成功：~p~n", [{GameNode, PlayerId, NotifyId}]),
%%            ok;
%%        R ->
%%            R
%%    end.
%%
%%%% @fun 请求排行榜数据
%%djs_rank(ChannelId, ServerId, Type) ->
%%    PlatformId = mod_server:get_platform_by_channel(ChannelId),
%%    GameNode = get_game_node(PlatformId, ServerId),
%%%%    case rpc:call(GameNode, mod_rank, djs_get_rank, [Type]) of
%%    F = fun() -> rpc:call(GameNode, mod_rank, djs_get_rank, [Type, ChannelId]) end,
%%    case mod_cache:cache_data({?MODULE, djs_rank, GameNode, ChannelId}, F, 10) of
%%        {ok, List} ->
%%            {ok, List};
%%        R ->
%%            ?ERROR("djs请求排行榜数据错误:~p~n", [{ChannelId, PlatformId, ServerId, Type, R}]),
%%            {ok, []}
%%    end.
%%
%%
%%try_is_djs_have_key(KeyStr) ->
%%    ?ASSERT(is_have_key(?PLATFORM_DJS, KeyStr) == false, ?ERROR_ALREADY_HAVE).
%%
%%
%%
%%%% @fun 是否存在平台key
%%is_have_key(PlatformId, KeyStr) ->
%%    case get_platform_score_reward(PlatformId, KeyStr) of
%%        PlatformReward when is_record(PlatformReward, db_platform_score_reward) ->
%%            true;
%%        _ ->
%%            false
%%    end.
%%
%%
%%%% @fun 获得游戏服节点
%%get_game_node(PfId, SId) ->
%%    mod_server:get_game_node(PfId, SId).
%%
%%
%%%% ================================================ 进程操作 ================================================
%%%% @fun 兑换积分
%%srv_djs_sell({GameNode, PlayerId, UId, Id, PlatformId, NotifyId, MailTitle, MailMsg}) ->
%%    PlatformScoreInit = get_platform_score_reward_init(PlatformId, NotifyId),
%%    ?ASSERT(PlatformScoreInit#db_platform_score_reward.change_time == 0, ?ERROR_ALREADY_HAVE),
%%    case rpc:call(GameNode, djs, djs_sell, [PlayerId, UId, Id, NotifyId, MailTitle, MailMsg]) of
%%        ok ->
%%            Tran =
%%                fun() ->
%%                    db:write(PlatformScoreInit#db_platform_score_reward{player_id = PlayerId, id = Id, change_time = util_time:timestamp()})
%%                end,
%%            db:do(Tran),
%%            ok;
%%        R ->
%%            Result =
%%                case R of
%%                    {_, {_, ?ERROR_NO_ROLE}} ->
%%                        ?ERROR_NO_ROLE;
%%                    _ ->
%%                        ?ERROR_FAIL
%%                end,
%%            ?ERROR("djs进程兑换积分错误:~p~n", [{GameNode, PlayerId, Id, R}]),
%%            Result
%%    end.
%%
%%
%%
%%%% ================================================ 数据操作 ================================================
%%%% @fun 获得积分兑换数据
%%get_platform_score_reward(PlatformId, KeyStr) ->
%%    db:read(#key_platform_score_reward{platform_id = PlatformId, key_str = KeyStr}).
%%%% @fun 获得积分兑换数据并初始化
%%get_platform_score_reward_init(PlatformId, KeyStr) ->
%%    case get_platform_score_reward(PlatformId, KeyStr) of
%%        PlayerScore when is_record(PlayerScore, db_platform_score_reward) ->
%%            PlayerScore;
%%        _ ->
%%            #db_platform_score_reward{platform_id = PlatformId, key_str = KeyStr}
%%    end.