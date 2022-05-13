%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc
%%% @end
%%% Created : 27. 十二月 2017 下午 3:42
%%%-------------------------------------------------------------------
-module(mod_game).

-include("common.hrl").
-include("client.hrl").
-include("msg.hrl").
%% API
-export([
    init/0,
    enter_game/1,
    is_enter_game/0,
    leave_game/2
]).

init() ->
    mod_player:reset_all_player_online_status(),
    %% @doc 修复任务数据
    mod_task:repair_task(),
    %% @doc 修复功能数据
%%    mod_function:repair_check_function_list(),
    %% @doc 初始化HTTP游戏配置
    game_config:init_set_all_game_config(),
    ok.

%% ----------------------------------
%% @doc 	进入游戏
%% @throws 	none
%% @end
%% ----------------------------------
enter_game(State) ->
    #conn{
        player_id = PlayerId,
        sender_worker = SendWorker,
        login_time = LoginTime,
        status = ?CLIENT_STATE_WAIT_ENTER_GAME,
        ip = Ip
    } = State,

    %%  设置该进程玩家id
%%    put(?DICT_PLAYER_ID, PlayerId),
    %% 分配数据库进程
    db_proxy:init(PlayerId),
    %% 设置玩家发送进程
    ?INIT_PLAYER_SENDER_WORKER(PlayerId, SendWorker),
    put(?DICT_PLAYER_LOGIN_TIME, LoginTime),

    %% 初始化玩家对象
    mod_obj_player:init_obj_player(PlayerId, self(), SendWorker, Ip),
    %% 进入游戏前数据处理
    hook:before_enter_game(PlayerId),
    %% 进入游戏后异步数据处理
    client_worker:send_msg(self(), ?MSG_CLIENT_AFTER_ENTER_GAME),

    %% 通知初始化玩家数据
    api_player:init_player_data(State),

    put(?DICT_IS_ENTER_GAME, true),

    case mod_room:try_enter_room_if_exist(PlayerId) of
        true ->
            noop;
        false ->
            %% 进入场景
            mod_scene:player_enter_scene_when_enter_game(PlayerId)
    end,

%%    mod_scene:do_player_enter_scene(PlayerId),


    ?INFO("(~p)玩家进入游戏!", [Ip]),
    State#conn{status = ?CLIENT_STATE_ENTER_GAME}.

%% ----------------------------------
%% @doc 	是否已经进入游戏
%% @throws 	none
%% @end
%% ----------------------------------
is_enter_game() ->
    get(?DICT_IS_ENTER_GAME) == true.

%% ----------------------------------
%% @doc 	离开游戏
%% @throws 	none
%% @end
%% ----------------------------------
leave_game(State = #conn{player_id = PlayerId, login_time = _LoginTime}, Reason) ->
    put(?DICT_IS_LEAVE_GAME, true),
    ?TRY_CATCH(handle_reason(State, Reason)),
    %% 离开游戏前
    ?TRY_CATCH(hook:before_leave_game(PlayerId, Reason, State)),
    %% 离开场景
    ?TRY_CATCH(mod_scene:player_leave_scene(PlayerId)),
    %% 离开房间
    ?TRY_CATCH(mod_room:player_leave_room(PlayerId)),
    %% 删除玩家对象
    ?TRY_CATCH(mod_obj_player:delete_obj_player(PlayerId)),
    %% 释放数据库数据
    ?TRY_CATCH(db_load:safe_unload_hot_data(PlayerId)),
    %% 打点日志写入文件
    ?TRY_CATCH(mod_service_player_log:write_log(PlayerId)),
    %% 离开游戏后
    ?TRY_CATCH(hook:after_leave_game(PlayerId)).


%% ----------------------------------
%% @doc 	处理离线原因
%% @throws 	none
%% @end
%% ----------------------------------
handle_reason(_State, Reason) ->
    if Reason == ?CSR_LOGIN_IN_OTHER
        orelse Reason == ?CSR_SYSTEM_MAINTENANCE
        orelse Reason == ?CSR_MAX_PACK
        orelse Reason == ?CSR_MAX_ERROR
        orelse Reason == ?CSR_GM_KILL
        orelse Reason == ?CSR_DISABLE_LOGIN ->
        api_login:notice_logout(_State, Reason);
        true ->
            noop
    end.

