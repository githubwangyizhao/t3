%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 六月 2021 下午 04:37:29
%%%-------------------------------------------------------------------
-module(scene_notice).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("scene.hrl").

-export([
    kill_monster/4,                         %% 击杀怪物
    kill_huoqiu_monster/1,                  %% 击杀火球怪
    kill_shandian_monster/1,                %% 击杀闪电链怪
    kill_dizhen_monster/1,                  %% 击杀地震怪
    shen_long_draw_award/2,                 %% 神龙抽奖奖励
    get_shen_long_buff/1,                   %% 获得神龙buff
    player_enter_scene/2,                   %% 玩家进入场景
    player_bankruptcy/1,                    %% 玩家破产
    player_charge/2,                        %% 玩家充值
    kill_fanpai_monster/2                   %% 击杀翻牌怪
]).

%% API
-export([
    notice_scene_msg/2
]).

%% @doc 击杀怪物
kill_monster(PlayerName, MonsterId, ItemList, SceneId) ->
    #t_scene{
        notice_list = NoticeList
    } = mod_scene:get_t_scene(SceneId),
    case NoticeList of
        [] ->
            noop;
        [NoticeId, SceneNoticePropList1] ->
            SceneNoticePropList = [{ThisPropId, ThisPropNum} || [ThisPropId, ThisPropNum] <- SceneNoticePropList1],
            lists:foreach(
                fun({PropId, PropNum}) ->
                    case lists:keyfind(PropId, 1, SceneNoticePropList) of
                        false ->
                            noop;
                        {_, NeedNum} ->
                            if
                                PropNum >= NeedNum ->
                                    notice_scene_msg(NoticeId, [PlayerName, MonsterId, PropId, PropNum]);
                                true ->
                                    noop
                            end
                    end
                end,
                ItemList
            )
    end.

get_player_name(PlayerId) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            "";
        ObjPlayer ->
            #obj_scene_actor{
                server_id = ServerId,
                nickname = Nickname
            } = ObjPlayer,
            mod_player:get_player_name(ServerId, Nickname)
    end.

%% @doc 击杀火球怪
kill_huoqiu_monster(PlayerId) ->
    notice_scene_msg(?NOTICE_NOTICE2, [get_player_name(PlayerId)]).

%% @doc 击杀闪电链怪
kill_shandian_monster(PlayerId) ->
    notice_scene_msg(?NOTICE_NOTICE3, [get_player_name(PlayerId)]).

%% @doc 击杀地震怪
kill_dizhen_monster(PlayerId) ->
    notice_scene_msg(?NOTICE_NOTICE4, [get_player_name(PlayerId)]).

%% @doc 神龙抽奖奖励
shen_long_draw_award(PlayerId, [PropId, PropNum]) ->
    notice_scene_msg(?NOTICE_NOTICE5, [get_player_name(PlayerId), PropId, PropNum]).

%% @doc 获得神龙buff
get_shen_long_buff(PlayerId) ->
    notice_scene_msg(?NOTICE_NOTICE6, [get_player_name(PlayerId)]).

%% @doc 玩家进入场景
player_enter_scene(PlayerId, SceneId) ->
    notice_scene_msg(?NOTICE_NOTICE7, [get_player_name(PlayerId), SceneId]).

%% @doc 玩家破产
player_bankruptcy(PlayerId) ->
    notice_scene_msg(?NOTICE_NOTICE8, [get_player_name(PlayerId)]).

%% @doc 玩家充值
player_charge(PlayerId, Money) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    erlang:send(SceneWorker, {apply, ?MODULE, notice_scene_msg, [?NOTICE_NOTICE9, [get_player_name(PlayerId), util:to_int(Money)]]}).
%%    notice_scene_msg(?NOTICE_NOTICE9, [mod_player:get_player_name(PlayerId), mod_charge:get_charge_name(RechargeId)]).

%% @doc 击杀翻牌怪物
kill_fanpai_monster(PlayerId, ItemList) ->
    [{PropId, PropNum} | _] = ItemList,
    erlang:send_after(20000, self(), {apply, ?MODULE, notice_scene_msg, [?NOTICE_NOTICE10, [get_player_name(PlayerId), PropId, PropNum]]}).
%%    notice_scene_msg(?NOTICE_NOTICE10, [mod_player:get_player_name(PlayerId), PropId, PropNum]).

%% @doc 通知场景消息
notice_scene_msg(TemplateId, ArgsList) ->
%%    ?DEBUG("通知场景消息 ~p~n, arg_list: ~p", [TemplateId, ArgsList]),
    Fun =
        fun(Out) ->
            PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
            mod_socket:send_to_player_list(PlayerIdList, Out)
        end,
    api_chat:notice_system_template_message(TemplateId, [util:to_binary(NoticeContent) || NoticeContent <- ArgsList], 5, Fun).
