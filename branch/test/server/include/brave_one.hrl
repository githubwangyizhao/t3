
-define(BRAVE_ONE_INFO_LIST, brave_one_info_list).
-define(BRAVE_ONE_CREATE, brave_one_create).
-define(BRAVE_ONE_ENTER, brave_one_enter).
-define(BRAVE_ONE_CLEAN, brave_one_clean).
-define(BRAVE_ONE_GET_WORKER, brave_one_get_worker).    %% 获得场景进程


-define(BRAVE_ONE_MISSION_WORKER, brave_one_mission_worker).    %% 副本进程
-define(BRAVE_ONE_MISSION_MONITOR_REF, brave_one_mission_monitor_ref).    %% 副本进程


-record(dict_brave_one, {
    main_player_id,       % 主玩家id
    fight_player_id       % 挑战玩家id
}).

-record(dict_brave_one_scene_data, {
    sceneWorker,
    missionType,
    missionId,
    sceneId,
    x,
    y,
    extraDataList
}).



