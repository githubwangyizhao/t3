%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            场景actor
%%% @end
%%% Created : 16. 十一月 2017 下午 8:27
%%%-------------------------------------------------------------------
-module(mod_scene_actor).
-include("scene.hrl").
-include("common.hrl").

%% API
-export([
%%    get_obj_scene_actor/1,
%%    get_obj_scene_actor/2,
%%    update_obj_scene_actor/1,
    add_obj_scene_actor/1,
    delete_obj_scene_actor/2,
    get_actor_id_list/1
]).

%%get_obj_scene_actor(ObjType, ObjId) ->
%%    get({?DICT_OBJ_SCENE_ACTOR, {ObjType, ObjId}}).

%%get_obj_scene_actor({ObjType, ObjId}) ->
%%    get({?DICT_OBJ_SCENE_ACTOR, {ObjType, ObjId}}).

add_obj_scene_actor(ObjSceneActor) ->
    #obj_scene_actor{
        key = Key,
        obj_type = ObjType,
        obj_id = ObjId
    } = ObjSceneActor,
    ?t_assert(Key == {ObjType, ObjId}),
    ?ASSERT(?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) == ?UNDEFINED, actor_exists),
    ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor),
    add_actor_list(ObjType, ObjId).

%%update_obj_scene_actor(ObjSceneActor) ->
%%    put({?DICT_OBJ_SCENE_ACTOR, ObjSceneActor#obj_scene_actor.key}, ObjSceneActor).

delete_obj_scene_actor(ObjType, ObjId) ->
    mod_log:write_monster_delete_log(ObjType, ObjId, ?IS_DEBUG),
    erase({?DICT_OBJ_SCENE_ACTOR, {ObjType, ObjId}}),
    delete_actor_list(ObjType, ObjId).

get_actor_id_list(ObjType) ->
    case get({actor_id_list, ObjType}) of
        ?UNDEFINED ->
            [];
        L ->
            L
    end.

add_actor_list(ObjType, ObjId) ->
    put({actor_id_list, ObjType}, [ObjId | get_actor_id_list(ObjType)]).


delete_actor_list(ObjType, ObjId) ->
    put({actor_id_list, ObjType}, lists:delete(ObjId, get_actor_id_list(ObjType))).


