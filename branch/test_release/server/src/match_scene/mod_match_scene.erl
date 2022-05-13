%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 9月 2021 上午 11:42:08
%%%-------------------------------------------------------------------
-module(mod_match_scene).
-author("Administrator").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("system.hrl").

-record(?MODULE, {
    matching                %% 正在匹配的匹配场id
}).

%% API
-export([
    get_info/0,
    war_get_info/1,
    match/2,
    cancel_match/1,
    reset_match_data/0,

    get_db_match_scene_data/1,
    get_db_match_scene_data_init/1
]).

-export([
    get_server_type/1
]).


get_info() ->
    lists:map(
        fun({Id}) ->
            ServerType = get_server_type(Id),
            case ServerType of
                ?SERVER_TYPE_WAR_AREA ->
                    mod_server_rpc:call_war(?MODULE, war_get_info, [Id]);
                ?SERVER_TYPE_GAME ->
                    get_db_match_scene_data_init(Id)
            end
        end,
        t_mate:get_keys()
    ).
war_get_info(Id) ->
    DbMatchSceneData = get_db_match_scene_data_init(Id),
    #db_match_scene_data{
        player_id = PlayerId
    } = DbMatchSceneData,
    Nickname = mod_cache:cache_data(
        {?MODULE, PlayerId},
        fun() ->
            Node = mod_player:get_game_node(PlayerId),
            util:rpc_call(Node, mod_player, get_player_name_to_binary, [PlayerId])
        end,
        600),
    {DbMatchSceneData, Nickname}.

match(PlayerId, MatchId) ->
    #t_mate{
        cost_list = CostItems
    } = t_mate:get({MatchId}),
    mod_prop:assert_prop_num(PlayerId, CostItems),
    ?ASSERT(undefined == ?getModDict(matching), ?ERROR_FAIL), %% 已经在队伍中
    case catch match_scene_srv:match(MatchId, PlayerId) of
        {ok, TeamPlayerCount} ->
            ?setModDict(matching, MatchId),
            {ok, TeamPlayerCount};
        _ ->
            exit(?ERROR_FAIL)
    end.

cancel_match(PlayerId) ->
    case ?getModDict(matching) of
        undefined -> skip;
        MatchId when is_integer(MatchId) ->
            ?eraseModDict(matching),
            match_scene_srv:unmatch(MatchId, PlayerId)
    end,
    ok.

%% ----------------------------------
%% @doc 	重置匹配数据
%% @throws 	none
%% @end
%% ----------------------------------
reset_match_data() ->
    ?eraseModDict(matching).

get_server_type(Id) ->
    #t_mate{
        scene = SceneId
    } = t_mate:get({Id}),
    #t_scene{
        server_type = ServerType
    } = mod_scene:get_t_scene(SceneId),
    ServerType.

%% ================================================ 数据操作 ================================================

%% @doc DB 匹配场数据
get_db_match_scene_data(Id) ->
    db:read(#key_match_scene_data{id = Id}).

get_db_match_scene_data_init(Id) ->
    case get_db_match_scene_data(Id) of
        null ->
            #db_match_scene_data{
                id = Id
            };
        R ->
            R
    end.