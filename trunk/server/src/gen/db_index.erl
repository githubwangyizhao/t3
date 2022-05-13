%%% Generated automatically, no need to modify.
-module(db_index).
-include("gen/db.hrl").
-compile({no_auto_import,[get_keys/1]}).

%% API
-export([
    get_keys/1, 
    get_rows/1
]).

%%Internal functions
-export([
    insert_indexs/1, 
    insert_index/1, 
    update_index/2,
    erase_index/1, 
    erase_indexs/1, 
    erase_all_index/1
]).

get_rows(Index) ->
    [
        begin
          R = db:read(Key),
          if R =/= null -> noop; true -> exit({get_rows_null, Index, Key}) end,
          R
        end
        || Key <- get_keys(Index)
    ].

get_keys(#idx_wheel_result_record_accumulate_1{type = Type, u_id = UId, record_type = RecordType})->
    [
       #key_wheel_result_record_accumulate{type = IndexKeyType,u_id = IndexKeyUId,record_type = IndexKeyRecordType,id = IndexKeyId}
       || {_, {IndexKeyType, IndexKeyUId, IndexKeyRecordType, IndexKeyId}}  <- ets:lookup(idx_wheel_result_record_accumulate_1, {Type, UId, RecordType})
    ];
get_keys(#idx_wheel_result_record_by_type{type = Type})->
    [
       #key_wheel_result_record{type = IndexKeyType,id = IndexKeyId}
       || {_, {IndexKeyType, IndexKeyId}}  <- ets:lookup(idx_wheel_result_record_by_type, {Type})
    ];
get_keys(#idx_wheel_player_bet_record_today_by_player{type = Type, player_id = PlayerId})->
    [
       #key_wheel_player_bet_record_today{player_id = IndexKeyPlayerId,type = IndexKeyType,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyType, IndexKeyId}}  <- ets:lookup(idx_wheel_player_bet_record_today_by_player, {Type, PlayerId})
    ];
get_keys(#idx_wheel_player_bet_record_by_id{type = Type, id = Id})->
    [
       #key_wheel_player_bet_record{player_id = IndexKeyPlayerId,type = IndexKeyType,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyType, IndexKeyId}}  <- ets:lookup(idx_wheel_player_bet_record_by_id, {Type, Id})
    ];
get_keys(#idx_wheel_player_bet_record_by_type_and_player{type = Type, player_id = PlayerId})->
    [
       #key_wheel_player_bet_record{player_id = IndexKeyPlayerId,type = IndexKeyType,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyType, IndexKeyId}}  <- ets:lookup(idx_wheel_player_bet_record_by_type_and_player, {Type, PlayerId})
    ];
get_keys(#idx_robot_player_scene_cache_1{player_id = PlayerId})->
    [
       #key_robot_player_scene_cache{id = IndexKeyId}
       || {_, {IndexKeyId}}  <- ets:lookup(idx_robot_player_scene_cache_1, {PlayerId})
    ];
get_keys(#idx_robot_player_data_1{nickname = Nickname})->
    [
       #key_robot_player_data{player_id = IndexKeyPlayerId}
       || {_, {IndexKeyPlayerId}}  <- ets:lookup(idx_robot_player_data_1, {Nickname})
    ];
get_keys(#idx_rank_info_1_rank_id{rank_id = RankId})->
    [
       #key_rank_info{rank_id = IndexKeyRankId,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyRankId, IndexKeyPlayerId}}  <- ets:lookup(idx_rank_info_1_rank_id, {RankId})
    ];
get_keys(#idx_rank_info_2{rank_id = RankId, rank = Rank})->
    [
       #key_rank_info{rank_id = IndexKeyRankId,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyRankId, IndexKeyPlayerId}}  <- ets:lookup(idx_rank_info_2, {RankId, Rank})
    ];
get_keys(#idx_rank_info_3_old_rank{rank_id = RankId, old_rank = OldRank})->
    [
       #key_rank_info{rank_id = IndexKeyRankId,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyRankId, IndexKeyPlayerId}}  <- ets:lookup(idx_rank_info_3_old_rank, {RankId, OldRank})
    ];
get_keys(#idx_promote_record_1{platform_id = PlatformId, acc_id = AccId})->
    [
       #key_promote_record{real_id = IndexKeyRealId}
       || {_, {IndexKeyRealId}}  <- ets:lookup(idx_promote_record_1, {PlatformId, AccId})
    ];
get_keys(#idx_player_title_1{player_id = PlayerId})->
    [
       #key_player_title{player_id = IndexKeyPlayerId,title_id = IndexKeyTitleId}
       || {_, {IndexKeyPlayerId, IndexKeyTitleId}}  <- ets:lookup(idx_player_title_1, {PlayerId})
    ];
get_keys(#idx_player_times_data{player_id = PlayerId})->
    [
       #key_player_times_data{player_id = IndexKeyPlayerId,times_id = IndexKeyTimesId}
       || {_, {IndexKeyPlayerId, IndexKeyTimesId}}  <- ets:lookup(idx_player_times_data, {PlayerId})
    ];
get_keys(#idx_player_sys_common_by_player{player_id = PlayerId})->
    [
       #key_player_sys_common{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_sys_common_by_player, {PlayerId})
    ];
get_keys(#idx_player_sys_common_by_state{player_id = PlayerId, state = State})->
    [
       #key_player_sys_common{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_sys_common_by_state, {PlayerId, State})
    ];
get_keys(#idx_player_sys_attr_1{player_id = PlayerId})->
    [
       #key_player_sys_attr{player_id = IndexKeyPlayerId,fun_id = IndexKeyFunId}
       || {_, {IndexKeyPlayerId, IndexKeyFunId}}  <- ets:lookup(idx_player_sys_attr_1, {PlayerId})
    ];
get_keys(#idx_player_special_prop_by_player{player_id = PlayerId})->
    [
       #key_player_special_prop{player_id = IndexKeyPlayerId,prop_obj_id = IndexKeyPropObjId}
       || {_, {IndexKeyPlayerId, IndexKeyPropObjId}}  <- ets:lookup(idx_player_special_prop_by_player, {PlayerId})
    ];
get_keys(#idx_player_prop_1{player_id = PlayerId})->
    [
       #key_player_prop{player_id = IndexKeyPlayerId,prop_id = IndexKeyPropId}
       || {_, {IndexKeyPlayerId, IndexKeyPropId}}  <- ets:lookup(idx_player_prop_1, {PlayerId})
    ];
get_keys(#idx_player_prerogative_card_1{player_id = PlayerId})->
    [
       #key_player_prerogative_card{player_id = IndexKeyPlayerId,type = IndexKeyType}
       || {_, {IndexKeyPlayerId, IndexKeyType}}  <- ets:lookup(idx_player_prerogative_card_1, {PlayerId})
    ];
get_keys(#idx_player_passive_skill_1{player_id = PlayerId})->
    [
       #key_player_passive_skill{player_id = IndexKeyPlayerId,passive_skill_id = IndexKeyPassiveSkillId}
       || {_, {IndexKeyPlayerId, IndexKeyPassiveSkillId}}  <- ets:lookup(idx_player_passive_skill_1, {PlayerId})
    ];
get_keys(#idx_player_offline_apply_1{player_id = PlayerId})->
    [
       #key_player_offline_apply{id = IndexKeyId}
       || {_, {IndexKeyId}}  <- ets:lookup(idx_player_offline_apply_1, {PlayerId})
    ];
get_keys(#idx_player_mail_1_player_id{player_id = PlayerId})->
    [
       #key_player_mail{player_id = IndexKeyPlayerId,mail_real_id = IndexKeyMailRealId}
       || {_, {IndexKeyPlayerId, IndexKeyMailRealId}}  <- ets:lookup(idx_player_mail_1_player_id, {PlayerId})
    ];
get_keys(#idx_player_hero_parts_by_player{player_id = PlayerId})->
    [
       #key_player_hero_parts{player_id = IndexKeyPlayerId,parts_id = IndexKeyPartsId}
       || {_, {IndexKeyPlayerId, IndexKeyPartsId}}  <- ets:lookup(idx_player_hero_parts_by_player, {PlayerId})
    ];
get_keys(#idx_player_hero_by_player{player_id = PlayerId})->
    [
       #key_player_hero{player_id = IndexKeyPlayerId,hero_id = IndexKeyHeroId}
       || {_, {IndexKeyPlayerId, IndexKeyHeroId}}  <- ets:lookup(idx_player_hero_by_player, {PlayerId})
    ];
get_keys(#idx_player_gift_mail_by_player{player_id = PlayerId})->
    [
       #key_player_gift_mail{player_id = IndexKeyPlayerId,mail_real_id = IndexKeyMailRealId}
       || {_, {IndexKeyPlayerId, IndexKeyMailRealId}}  <- ets:lookup(idx_player_gift_mail_by_player, {PlayerId})
    ];
get_keys(#idx_player_gift_mail_by_sender{sender = Sender})->
    [
       #key_player_gift_mail{player_id = IndexKeyPlayerId,mail_real_id = IndexKeyMailRealId}
       || {_, {IndexKeyPlayerId, IndexKeyMailRealId}}  <- ets:lookup(idx_player_gift_mail_by_sender, {Sender})
    ];
get_keys(#idx_player_function_1{player_id = PlayerId})->
    [
       #key_player_function{player_id = IndexKeyPlayerId,function_id = IndexKeyFunctionId}
       || {_, {IndexKeyPlayerId, IndexKeyFunctionId}}  <- ets:lookup(idx_player_function_1, {PlayerId})
    ];
get_keys(#idx_player_daily_task_1{player_id = PlayerId})->
    [
       #key_player_daily_task{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_daily_task_1, {PlayerId})
    ];
get_keys(#idx_player_daily_points_1{player_id = PlayerId})->
    [
       #key_player_daily_points{player_id = IndexKeyPlayerId,bid = IndexKeyBid}
       || {_, {IndexKeyPlayerId, IndexKeyBid}}  <- ets:lookup(idx_player_daily_points_1, {PlayerId})
    ];
get_keys(#idx_player_client_data_1{player_id = PlayerId})->
    [
       #key_player_client_data{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_client_data_1, {PlayerId})
    ];
get_keys(#idx_player_chat_data_by_player{player_id = PlayerId})->
    [
       #key_player_chat_data{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_chat_data_by_player, {PlayerId})
    ];
get_keys(#idx_player_charge_record_1{player_id = PlayerId})->
    [
       #key_player_charge_record{order_id = IndexKeyOrderId}
       || {_, {IndexKeyOrderId}}  <- ets:lookup(idx_player_charge_record_1, {PlayerId})
    ];
get_keys(#idx_player_bounty_task_1{player_id = PlayerId})->
    [
       #key_player_bounty_task{player_id = IndexKeyPlayerId,id = IndexKeyId}
       || {_, {IndexKeyPlayerId, IndexKeyId}}  <- ets:lookup(idx_player_bounty_task_1, {PlayerId})
    ];
get_keys(#idx_player_activity_info_1{player_id = PlayerId})->
    [
       #key_player_activity_info{player_id = IndexKeyPlayerId,activity_id = IndexKeyActivityId}
       || {_, {IndexKeyPlayerId, IndexKeyActivityId}}  <- ets:lookup(idx_player_activity_info_1, {PlayerId})
    ];
get_keys(#idx_player_activity_game_1{activity_id = ActivityId, activity_start_time = ActivityStartTime})->
    [
       #key_player_activity_game{player_id = IndexKeyPlayerId,activity_id = IndexKeyActivityId}
       || {_, {IndexKeyPlayerId, IndexKeyActivityId}}  <- ets:lookup(idx_player_activity_game_1, {ActivityId, ActivityStartTime})
    ];
get_keys(#idx_player_1{nickname = Nickname})->
    [
       #key_player{id = IndexKeyId}
       || {_, {IndexKeyId}}  <- ets:lookup(idx_player_1, {Nickname})
    ];
get_keys(#idx_player_2{acc_id = AccId, server_id = ServerId})->
    [
       #key_player{id = IndexKeyId}
       || {_, {IndexKeyId}}  <- ets:lookup(idx_player_2, {AccId, ServerId})
    ];
get_keys(#idx_one_vs_one_rank_data_by_type{type = Type})->
    [
       #key_one_vs_one_rank_data{type = IndexKeyType,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyType, IndexKeyPlayerId}}  <- ets:lookup(idx_one_vs_one_rank_data_by_type, {Type})
    ];
get_keys(#idx_mission_ranking_1{mission_type = MissionType, mission_id = MissionId, id = Id})->
    [
       #key_mission_ranking{mission_type = IndexKeyMissionType,mission_id = IndexKeyMissionId,id = IndexKeyId,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyMissionType, IndexKeyMissionId, IndexKeyId, IndexKeyPlayerId}}  <- ets:lookup(idx_mission_ranking_1, {MissionType, MissionId, Id})
    ];
get_keys(#idx_mission_ranking_by_rank_id{mission_type = MissionType, mission_id = MissionId, id = Id, rank_id = RankId})->
    [
       #key_mission_ranking{mission_type = IndexKeyMissionType,mission_id = IndexKeyMissionId,id = IndexKeyId,player_id = IndexKeyPlayerId}
       || {_, {IndexKeyMissionType, IndexKeyMissionId, IndexKeyId, IndexKeyPlayerId}}  <- ets:lookup(idx_mission_ranking_by_rank_id, {MissionType, MissionId, Id, RankId})
    ];
get_keys(#idx_gift_code_type_1{name = Name})->
    [
       #key_gift_code_type{type = IndexKeyType}
       || {_, {IndexKeyType}}  <- ets:lookup(idx_gift_code_type_1, {Name})
    ];
get_keys(#idx_brave_one_1{fight_player_id = FightPlayerId})->
    [
       #key_brave_one{player_id = IndexKeyPlayerId}
       || {_, {IndexKeyPlayerId}}  <- ets:lookup(idx_brave_one_1, {FightPlayerId})
    ].


insert_indexs(Rows) ->
    lists:foreach(
        fun(Row) ->
            insert_index(Row)
        end,
        Rows
    ).


erase_indexs(Rows) ->
    lists:foreach(
        fun(Row) ->
            erase_index(Row)
        end,
        Rows
    ).

insert_index(Row) when is_record(Row, db_wheel_result_record_accumulate) ->
    RowKey = Row#db_wheel_result_record_accumulate.row_key,
    RecordType = Row#db_wheel_result_record_accumulate.record_type,
    Type = Row#db_wheel_result_record_accumulate.type,
    UId = Row#db_wheel_result_record_accumulate.u_id,
    ets:insert(idx_wheel_result_record_accumulate_1, {{Type, UId, RecordType}, RowKey});
insert_index(Row) when is_record(Row, db_wheel_result_record) ->
    RowKey = Row#db_wheel_result_record.row_key,
    Type = Row#db_wheel_result_record.type,
    ets:insert(idx_wheel_result_record_by_type, {{Type}, RowKey});
insert_index(Row) when is_record(Row, db_wheel_player_bet_record_today) ->
    RowKey = Row#db_wheel_player_bet_record_today.row_key,
    PlayerId = Row#db_wheel_player_bet_record_today.player_id,
    Type = Row#db_wheel_player_bet_record_today.type,
    ets:insert(idx_wheel_player_bet_record_today_by_player, {{Type, PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_wheel_player_bet_record) ->
    RowKey = Row#db_wheel_player_bet_record.row_key,
    Id = Row#db_wheel_player_bet_record.id,
    PlayerId = Row#db_wheel_player_bet_record.player_id,
    Type = Row#db_wheel_player_bet_record.type,
    ets:insert(idx_wheel_player_bet_record_by_id, {{Type, Id}, RowKey}),
    ets:insert(idx_wheel_player_bet_record_by_type_and_player, {{Type, PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_robot_player_scene_cache) ->
    RowKey = Row#db_robot_player_scene_cache.row_key,
    PlayerId = Row#db_robot_player_scene_cache.player_id,
    ets:insert(idx_robot_player_scene_cache_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_robot_player_data) ->
    RowKey = Row#db_robot_player_data.row_key,
    Nickname = Row#db_robot_player_data.nickname,
    ets:insert(idx_robot_player_data_1, {{Nickname}, RowKey});
insert_index(Row) when is_record(Row, db_rank_info) ->
    RowKey = Row#db_rank_info.row_key,
    OldRank = Row#db_rank_info.old_rank,
    Rank = Row#db_rank_info.rank,
    RankId = Row#db_rank_info.rank_id,
    ets:insert(idx_rank_info_1_rank_id, {{RankId}, RowKey}),
    ets:insert(idx_rank_info_2, {{RankId, Rank}, RowKey}),
    ets:insert(idx_rank_info_3_old_rank, {{RankId, OldRank}, RowKey});
insert_index(Row) when is_record(Row, db_promote_record) ->
    RowKey = Row#db_promote_record.row_key,
    AccId = Row#db_promote_record.acc_id,
    PlatformId = Row#db_promote_record.platform_id,
    ets:insert(idx_promote_record_1, {{PlatformId, AccId}, RowKey});
insert_index(Row) when is_record(Row, db_player_title) ->
    RowKey = Row#db_player_title.row_key,
    PlayerId = Row#db_player_title.player_id,
    ets:insert(idx_player_title_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_times_data) ->
    RowKey = Row#db_player_times_data.row_key,
    PlayerId = Row#db_player_times_data.player_id,
    ets:insert(idx_player_times_data, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_sys_common) ->
    RowKey = Row#db_player_sys_common.row_key,
    PlayerId = Row#db_player_sys_common.player_id,
    State = Row#db_player_sys_common.state,
    ets:insert(idx_player_sys_common_by_player, {{PlayerId}, RowKey}),
    ets:insert(idx_player_sys_common_by_state, {{PlayerId, State}, RowKey});
insert_index(Row) when is_record(Row, db_player_sys_attr) ->
    RowKey = Row#db_player_sys_attr.row_key,
    PlayerId = Row#db_player_sys_attr.player_id,
    ets:insert(idx_player_sys_attr_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_special_prop) ->
    RowKey = Row#db_player_special_prop.row_key,
    PlayerId = Row#db_player_special_prop.player_id,
    ets:insert(idx_player_special_prop_by_player, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_prop) ->
    RowKey = Row#db_player_prop.row_key,
    PlayerId = Row#db_player_prop.player_id,
    ets:insert(idx_player_prop_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_prerogative_card) ->
    RowKey = Row#db_player_prerogative_card.row_key,
    PlayerId = Row#db_player_prerogative_card.player_id,
    ets:insert(idx_player_prerogative_card_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_passive_skill) ->
    RowKey = Row#db_player_passive_skill.row_key,
    PlayerId = Row#db_player_passive_skill.player_id,
    ets:insert(idx_player_passive_skill_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_offline_apply) ->
    RowKey = Row#db_player_offline_apply.row_key,
    PlayerId = Row#db_player_offline_apply.player_id,
    ets:insert(idx_player_offline_apply_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_mail) ->
    RowKey = Row#db_player_mail.row_key,
    PlayerId = Row#db_player_mail.player_id,
    ets:insert(idx_player_mail_1_player_id, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_hero_parts) ->
    RowKey = Row#db_player_hero_parts.row_key,
    PlayerId = Row#db_player_hero_parts.player_id,
    ets:insert(idx_player_hero_parts_by_player, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_hero) ->
    RowKey = Row#db_player_hero.row_key,
    PlayerId = Row#db_player_hero.player_id,
    ets:insert(idx_player_hero_by_player, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_gift_mail) ->
    RowKey = Row#db_player_gift_mail.row_key,
    PlayerId = Row#db_player_gift_mail.player_id,
    Sender = Row#db_player_gift_mail.sender,
    ets:insert(idx_player_gift_mail_by_player, {{PlayerId}, RowKey}),
    ets:insert(idx_player_gift_mail_by_sender, {{Sender}, RowKey});
insert_index(Row) when is_record(Row, db_player_function) ->
    RowKey = Row#db_player_function.row_key,
    PlayerId = Row#db_player_function.player_id,
    ets:insert(idx_player_function_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_daily_task) ->
    RowKey = Row#db_player_daily_task.row_key,
    PlayerId = Row#db_player_daily_task.player_id,
    ets:insert(idx_player_daily_task_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_daily_points) ->
    RowKey = Row#db_player_daily_points.row_key,
    PlayerId = Row#db_player_daily_points.player_id,
    ets:insert(idx_player_daily_points_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_client_data) ->
    RowKey = Row#db_player_client_data.row_key,
    PlayerId = Row#db_player_client_data.player_id,
    ets:insert(idx_player_client_data_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_chat_data) ->
    RowKey = Row#db_player_chat_data.row_key,
    PlayerId = Row#db_player_chat_data.player_id,
    ets:insert(idx_player_chat_data_by_player, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_charge_record) ->
    RowKey = Row#db_player_charge_record.row_key,
    PlayerId = Row#db_player_charge_record.player_id,
    ets:insert(idx_player_charge_record_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_bounty_task) ->
    RowKey = Row#db_player_bounty_task.row_key,
    PlayerId = Row#db_player_bounty_task.player_id,
    ets:insert(idx_player_bounty_task_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_activity_info) ->
    RowKey = Row#db_player_activity_info.row_key,
    PlayerId = Row#db_player_activity_info.player_id,
    ets:insert(idx_player_activity_info_1, {{PlayerId}, RowKey});
insert_index(Row) when is_record(Row, db_player_activity_game) ->
    RowKey = Row#db_player_activity_game.row_key,
    ActivityId = Row#db_player_activity_game.activity_id,
    ActivityStartTime = Row#db_player_activity_game.activity_start_time,
    ets:insert(idx_player_activity_game_1, {{ActivityId, ActivityStartTime}, RowKey});
insert_index(Row) when is_record(Row, db_player) ->
    RowKey = Row#db_player.row_key,
    AccId = Row#db_player.acc_id,
    Nickname = Row#db_player.nickname,
    ServerId = Row#db_player.server_id,
    ets:insert(idx_player_1, {{Nickname}, RowKey}),
    ets:insert(idx_player_2, {{AccId, ServerId}, RowKey});
insert_index(Row) when is_record(Row, db_one_vs_one_rank_data) ->
    RowKey = Row#db_one_vs_one_rank_data.row_key,
    Type = Row#db_one_vs_one_rank_data.type,
    ets:insert(idx_one_vs_one_rank_data_by_type, {{Type}, RowKey});
insert_index(Row) when is_record(Row, db_mission_ranking) ->
    RowKey = Row#db_mission_ranking.row_key,
    Id = Row#db_mission_ranking.id,
    MissionId = Row#db_mission_ranking.mission_id,
    MissionType = Row#db_mission_ranking.mission_type,
    RankId = Row#db_mission_ranking.rank_id,
    ets:insert(idx_mission_ranking_1, {{MissionType, MissionId, Id}, RowKey}),
    ets:insert(idx_mission_ranking_by_rank_id, {{MissionType, MissionId, Id, RankId}, RowKey});
insert_index(Row) when is_record(Row, db_gift_code_type) ->
    RowKey = Row#db_gift_code_type.row_key,
    Name = Row#db_gift_code_type.name,
    ets:insert(idx_gift_code_type_1, {{Name}, RowKey});
insert_index(Row) when is_record(Row, db_brave_one) ->
    RowKey = Row#db_brave_one.row_key,
    FightPlayerId = Row#db_brave_one.fight_player_id,
    ets:insert(idx_brave_one_1, {{FightPlayerId}, RowKey});
insert_index(_)->noop.

update_index(OldRow, NewRow) when is_record(NewRow, db_wheel_result_record_accumulate) ->
    RowKey = NewRow#db_wheel_result_record_accumulate.row_key,
    OldRecordType = OldRow#db_wheel_result_record_accumulate.record_type,
    OldType = OldRow#db_wheel_result_record_accumulate.type,
    OldUId = OldRow#db_wheel_result_record_accumulate.u_id,
    NewRecordType = NewRow#db_wheel_result_record_accumulate.record_type,
    NewType = NewRow#db_wheel_result_record_accumulate.type,
    NewUId = NewRow#db_wheel_result_record_accumulate.u_id,
    if ({OldType, OldUId, OldRecordType} =/= {NewType, NewUId, NewRecordType}) -> ets:delete_object(idx_wheel_result_record_accumulate_1, {{OldType, OldUId, OldRecordType}, RowKey}), ets:insert(idx_wheel_result_record_accumulate_1, {{NewType, NewUId, NewRecordType}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_wheel_result_record) ->
    RowKey = NewRow#db_wheel_result_record.row_key,
    OldType = OldRow#db_wheel_result_record.type,
    NewType = NewRow#db_wheel_result_record.type,
    if ({OldType} =/= {NewType}) -> ets:delete_object(idx_wheel_result_record_by_type, {{OldType}, RowKey}), ets:insert(idx_wheel_result_record_by_type, {{NewType}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_wheel_player_bet_record_today) ->
    RowKey = NewRow#db_wheel_player_bet_record_today.row_key,
    OldPlayerId = OldRow#db_wheel_player_bet_record_today.player_id,
    OldType = OldRow#db_wheel_player_bet_record_today.type,
    NewPlayerId = NewRow#db_wheel_player_bet_record_today.player_id,
    NewType = NewRow#db_wheel_player_bet_record_today.type,
    if ({OldType, OldPlayerId} =/= {NewType, NewPlayerId}) -> ets:delete_object(idx_wheel_player_bet_record_today_by_player, {{OldType, OldPlayerId}, RowKey}), ets:insert(idx_wheel_player_bet_record_today_by_player, {{NewType, NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_wheel_player_bet_record) ->
    RowKey = NewRow#db_wheel_player_bet_record.row_key,
    OldId = OldRow#db_wheel_player_bet_record.id,
    OldPlayerId = OldRow#db_wheel_player_bet_record.player_id,
    OldType = OldRow#db_wheel_player_bet_record.type,
    NewId = NewRow#db_wheel_player_bet_record.id,
    NewPlayerId = NewRow#db_wheel_player_bet_record.player_id,
    NewType = NewRow#db_wheel_player_bet_record.type,
    if ({OldType, OldId} =/= {NewType, NewId}) -> ets:delete_object(idx_wheel_player_bet_record_by_id, {{OldType, OldId}, RowKey}), ets:insert(idx_wheel_player_bet_record_by_id, {{NewType, NewId}, RowKey}); true -> noop end,
    if ({OldType, OldPlayerId} =/= {NewType, NewPlayerId}) -> ets:delete_object(idx_wheel_player_bet_record_by_type_and_player, {{OldType, OldPlayerId}, RowKey}), ets:insert(idx_wheel_player_bet_record_by_type_and_player, {{NewType, NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_robot_player_scene_cache) ->
    RowKey = NewRow#db_robot_player_scene_cache.row_key,
    OldPlayerId = OldRow#db_robot_player_scene_cache.player_id,
    NewPlayerId = NewRow#db_robot_player_scene_cache.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_robot_player_scene_cache_1, {{OldPlayerId}, RowKey}), ets:insert(idx_robot_player_scene_cache_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_robot_player_data) ->
    RowKey = NewRow#db_robot_player_data.row_key,
    OldNickname = OldRow#db_robot_player_data.nickname,
    NewNickname = NewRow#db_robot_player_data.nickname,
    if ({OldNickname} =/= {NewNickname}) -> ets:delete_object(idx_robot_player_data_1, {{OldNickname}, RowKey}), ets:insert(idx_robot_player_data_1, {{NewNickname}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_rank_info) ->
    RowKey = NewRow#db_rank_info.row_key,
    OldOldRank = OldRow#db_rank_info.old_rank,
    OldRank = OldRow#db_rank_info.rank,
    OldRankId = OldRow#db_rank_info.rank_id,
    NewOldRank = NewRow#db_rank_info.old_rank,
    NewRank = NewRow#db_rank_info.rank,
    NewRankId = NewRow#db_rank_info.rank_id,
    if ({OldRankId} =/= {NewRankId}) -> ets:delete_object(idx_rank_info_1_rank_id, {{OldRankId}, RowKey}), ets:insert(idx_rank_info_1_rank_id, {{NewRankId}, RowKey}); true -> noop end,
    if ({OldRankId, OldRank} =/= {NewRankId, NewRank}) -> ets:delete_object(idx_rank_info_2, {{OldRankId, OldRank}, RowKey}), ets:insert(idx_rank_info_2, {{NewRankId, NewRank}, RowKey}); true -> noop end,
    if ({OldRankId, OldOldRank} =/= {NewRankId, NewOldRank}) -> ets:delete_object(idx_rank_info_3_old_rank, {{OldRankId, OldOldRank}, RowKey}), ets:insert(idx_rank_info_3_old_rank, {{NewRankId, NewOldRank}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_promote_record) ->
    RowKey = NewRow#db_promote_record.row_key,
    OldAccId = OldRow#db_promote_record.acc_id,
    OldPlatformId = OldRow#db_promote_record.platform_id,
    NewAccId = NewRow#db_promote_record.acc_id,
    NewPlatformId = NewRow#db_promote_record.platform_id,
    if ({OldPlatformId, OldAccId} =/= {NewPlatformId, NewAccId}) -> ets:delete_object(idx_promote_record_1, {{OldPlatformId, OldAccId}, RowKey}), ets:insert(idx_promote_record_1, {{NewPlatformId, NewAccId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_title) ->
    RowKey = NewRow#db_player_title.row_key,
    OldPlayerId = OldRow#db_player_title.player_id,
    NewPlayerId = NewRow#db_player_title.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_title_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_title_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_times_data) ->
    RowKey = NewRow#db_player_times_data.row_key,
    OldPlayerId = OldRow#db_player_times_data.player_id,
    NewPlayerId = NewRow#db_player_times_data.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_times_data, {{OldPlayerId}, RowKey}), ets:insert(idx_player_times_data, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_sys_common) ->
    RowKey = NewRow#db_player_sys_common.row_key,
    OldPlayerId = OldRow#db_player_sys_common.player_id,
    OldState = OldRow#db_player_sys_common.state,
    NewPlayerId = NewRow#db_player_sys_common.player_id,
    NewState = NewRow#db_player_sys_common.state,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_sys_common_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_sys_common_by_player, {{NewPlayerId}, RowKey}); true -> noop end,
    if ({OldPlayerId, OldState} =/= {NewPlayerId, NewState}) -> ets:delete_object(idx_player_sys_common_by_state, {{OldPlayerId, OldState}, RowKey}), ets:insert(idx_player_sys_common_by_state, {{NewPlayerId, NewState}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_sys_attr) ->
    RowKey = NewRow#db_player_sys_attr.row_key,
    OldPlayerId = OldRow#db_player_sys_attr.player_id,
    NewPlayerId = NewRow#db_player_sys_attr.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_sys_attr_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_sys_attr_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_special_prop) ->
    RowKey = NewRow#db_player_special_prop.row_key,
    OldPlayerId = OldRow#db_player_special_prop.player_id,
    NewPlayerId = NewRow#db_player_special_prop.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_special_prop_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_special_prop_by_player, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_prop) ->
    RowKey = NewRow#db_player_prop.row_key,
    OldPlayerId = OldRow#db_player_prop.player_id,
    NewPlayerId = NewRow#db_player_prop.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_prop_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_prop_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_prerogative_card) ->
    RowKey = NewRow#db_player_prerogative_card.row_key,
    OldPlayerId = OldRow#db_player_prerogative_card.player_id,
    NewPlayerId = NewRow#db_player_prerogative_card.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_prerogative_card_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_prerogative_card_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_passive_skill) ->
    RowKey = NewRow#db_player_passive_skill.row_key,
    OldPlayerId = OldRow#db_player_passive_skill.player_id,
    NewPlayerId = NewRow#db_player_passive_skill.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_passive_skill_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_passive_skill_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_offline_apply) ->
    RowKey = NewRow#db_player_offline_apply.row_key,
    OldPlayerId = OldRow#db_player_offline_apply.player_id,
    NewPlayerId = NewRow#db_player_offline_apply.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_offline_apply_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_offline_apply_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_mail) ->
    RowKey = NewRow#db_player_mail.row_key,
    OldPlayerId = OldRow#db_player_mail.player_id,
    NewPlayerId = NewRow#db_player_mail.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_mail_1_player_id, {{OldPlayerId}, RowKey}), ets:insert(idx_player_mail_1_player_id, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_hero_parts) ->
    RowKey = NewRow#db_player_hero_parts.row_key,
    OldPlayerId = OldRow#db_player_hero_parts.player_id,
    NewPlayerId = NewRow#db_player_hero_parts.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_hero_parts_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_hero_parts_by_player, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_hero) ->
    RowKey = NewRow#db_player_hero.row_key,
    OldPlayerId = OldRow#db_player_hero.player_id,
    NewPlayerId = NewRow#db_player_hero.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_hero_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_hero_by_player, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_gift_mail) ->
    RowKey = NewRow#db_player_gift_mail.row_key,
    OldPlayerId = OldRow#db_player_gift_mail.player_id,
    OldSender = OldRow#db_player_gift_mail.sender,
    NewPlayerId = NewRow#db_player_gift_mail.player_id,
    NewSender = NewRow#db_player_gift_mail.sender,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_gift_mail_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_gift_mail_by_player, {{NewPlayerId}, RowKey}); true -> noop end,
    if ({OldSender} =/= {NewSender}) -> ets:delete_object(idx_player_gift_mail_by_sender, {{OldSender}, RowKey}), ets:insert(idx_player_gift_mail_by_sender, {{NewSender}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_function) ->
    RowKey = NewRow#db_player_function.row_key,
    OldPlayerId = OldRow#db_player_function.player_id,
    NewPlayerId = NewRow#db_player_function.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_function_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_function_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_daily_task) ->
    RowKey = NewRow#db_player_daily_task.row_key,
    OldPlayerId = OldRow#db_player_daily_task.player_id,
    NewPlayerId = NewRow#db_player_daily_task.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_daily_task_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_daily_task_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_daily_points) ->
    RowKey = NewRow#db_player_daily_points.row_key,
    OldPlayerId = OldRow#db_player_daily_points.player_id,
    NewPlayerId = NewRow#db_player_daily_points.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_daily_points_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_daily_points_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_client_data) ->
    RowKey = NewRow#db_player_client_data.row_key,
    OldPlayerId = OldRow#db_player_client_data.player_id,
    NewPlayerId = NewRow#db_player_client_data.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_client_data_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_client_data_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_chat_data) ->
    RowKey = NewRow#db_player_chat_data.row_key,
    OldPlayerId = OldRow#db_player_chat_data.player_id,
    NewPlayerId = NewRow#db_player_chat_data.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_chat_data_by_player, {{OldPlayerId}, RowKey}), ets:insert(idx_player_chat_data_by_player, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_charge_record) ->
    RowKey = NewRow#db_player_charge_record.row_key,
    OldPlayerId = OldRow#db_player_charge_record.player_id,
    NewPlayerId = NewRow#db_player_charge_record.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_charge_record_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_charge_record_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_bounty_task) ->
    RowKey = NewRow#db_player_bounty_task.row_key,
    OldPlayerId = OldRow#db_player_bounty_task.player_id,
    NewPlayerId = NewRow#db_player_bounty_task.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_bounty_task_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_bounty_task_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_activity_info) ->
    RowKey = NewRow#db_player_activity_info.row_key,
    OldPlayerId = OldRow#db_player_activity_info.player_id,
    NewPlayerId = NewRow#db_player_activity_info.player_id,
    if ({OldPlayerId} =/= {NewPlayerId}) -> ets:delete_object(idx_player_activity_info_1, {{OldPlayerId}, RowKey}), ets:insert(idx_player_activity_info_1, {{NewPlayerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player_activity_game) ->
    RowKey = NewRow#db_player_activity_game.row_key,
    OldActivityId = OldRow#db_player_activity_game.activity_id,
    OldActivityStartTime = OldRow#db_player_activity_game.activity_start_time,
    NewActivityId = NewRow#db_player_activity_game.activity_id,
    NewActivityStartTime = NewRow#db_player_activity_game.activity_start_time,
    if ({OldActivityId, OldActivityStartTime} =/= {NewActivityId, NewActivityStartTime}) -> ets:delete_object(idx_player_activity_game_1, {{OldActivityId, OldActivityStartTime}, RowKey}), ets:insert(idx_player_activity_game_1, {{NewActivityId, NewActivityStartTime}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_player) ->
    RowKey = NewRow#db_player.row_key,
    OldAccId = OldRow#db_player.acc_id,
    OldNickname = OldRow#db_player.nickname,
    OldServerId = OldRow#db_player.server_id,
    NewAccId = NewRow#db_player.acc_id,
    NewNickname = NewRow#db_player.nickname,
    NewServerId = NewRow#db_player.server_id,
    if ({OldNickname} =/= {NewNickname}) -> ets:delete_object(idx_player_1, {{OldNickname}, RowKey}), ets:insert(idx_player_1, {{NewNickname}, RowKey}); true -> noop end,
    if ({OldAccId, OldServerId} =/= {NewAccId, NewServerId}) -> ets:delete_object(idx_player_2, {{OldAccId, OldServerId}, RowKey}), ets:insert(idx_player_2, {{NewAccId, NewServerId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_one_vs_one_rank_data) ->
    RowKey = NewRow#db_one_vs_one_rank_data.row_key,
    OldType = OldRow#db_one_vs_one_rank_data.type,
    NewType = NewRow#db_one_vs_one_rank_data.type,
    if ({OldType} =/= {NewType}) -> ets:delete_object(idx_one_vs_one_rank_data_by_type, {{OldType}, RowKey}), ets:insert(idx_one_vs_one_rank_data_by_type, {{NewType}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_mission_ranking) ->
    RowKey = NewRow#db_mission_ranking.row_key,
    OldId = OldRow#db_mission_ranking.id,
    OldMissionId = OldRow#db_mission_ranking.mission_id,
    OldMissionType = OldRow#db_mission_ranking.mission_type,
    OldRankId = OldRow#db_mission_ranking.rank_id,
    NewId = NewRow#db_mission_ranking.id,
    NewMissionId = NewRow#db_mission_ranking.mission_id,
    NewMissionType = NewRow#db_mission_ranking.mission_type,
    NewRankId = NewRow#db_mission_ranking.rank_id,
    if ({OldMissionType, OldMissionId, OldId} =/= {NewMissionType, NewMissionId, NewId}) -> ets:delete_object(idx_mission_ranking_1, {{OldMissionType, OldMissionId, OldId}, RowKey}), ets:insert(idx_mission_ranking_1, {{NewMissionType, NewMissionId, NewId}, RowKey}); true -> noop end,
    if ({OldMissionType, OldMissionId, OldId, OldRankId} =/= {NewMissionType, NewMissionId, NewId, NewRankId}) -> ets:delete_object(idx_mission_ranking_by_rank_id, {{OldMissionType, OldMissionId, OldId, OldRankId}, RowKey}), ets:insert(idx_mission_ranking_by_rank_id, {{NewMissionType, NewMissionId, NewId, NewRankId}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_gift_code_type) ->
    RowKey = NewRow#db_gift_code_type.row_key,
    OldName = OldRow#db_gift_code_type.name,
    NewName = NewRow#db_gift_code_type.name,
    if ({OldName} =/= {NewName}) -> ets:delete_object(idx_gift_code_type_1, {{OldName}, RowKey}), ets:insert(idx_gift_code_type_1, {{NewName}, RowKey}); true -> noop end;
update_index(OldRow, NewRow) when is_record(NewRow, db_brave_one) ->
    RowKey = NewRow#db_brave_one.row_key,
    OldFightPlayerId = OldRow#db_brave_one.fight_player_id,
    NewFightPlayerId = NewRow#db_brave_one.fight_player_id,
    if ({OldFightPlayerId} =/= {NewFightPlayerId}) -> ets:delete_object(idx_brave_one_1, {{OldFightPlayerId}, RowKey}), ets:insert(idx_brave_one_1, {{NewFightPlayerId}, RowKey}); true -> noop end;
update_index(_, _)->noop.

erase_index(Row) when is_record(Row, db_wheel_result_record_accumulate) ->
    RowKey = Row#db_wheel_result_record_accumulate.row_key,
    RecordType = Row#db_wheel_result_record_accumulate.record_type,
    Type = Row#db_wheel_result_record_accumulate.type,
    UId = Row#db_wheel_result_record_accumulate.u_id,
    ets:delete_object(idx_wheel_result_record_accumulate_1, {{Type, UId, RecordType}, RowKey});
erase_index(Row) when is_record(Row, db_wheel_result_record) ->
    RowKey = Row#db_wheel_result_record.row_key,
    Type = Row#db_wheel_result_record.type,
    ets:delete_object(idx_wheel_result_record_by_type, {{Type}, RowKey});
erase_index(Row) when is_record(Row, db_wheel_player_bet_record_today) ->
    RowKey = Row#db_wheel_player_bet_record_today.row_key,
    PlayerId = Row#db_wheel_player_bet_record_today.player_id,
    Type = Row#db_wheel_player_bet_record_today.type,
    ets:delete_object(idx_wheel_player_bet_record_today_by_player, {{Type, PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_wheel_player_bet_record) ->
    RowKey = Row#db_wheel_player_bet_record.row_key,
    Id = Row#db_wheel_player_bet_record.id,
    PlayerId = Row#db_wheel_player_bet_record.player_id,
    Type = Row#db_wheel_player_bet_record.type,
    ets:delete_object(idx_wheel_player_bet_record_by_id, {{Type, Id}, RowKey}),
    ets:delete_object(idx_wheel_player_bet_record_by_type_and_player, {{Type, PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_robot_player_scene_cache) ->
    RowKey = Row#db_robot_player_scene_cache.row_key,
    PlayerId = Row#db_robot_player_scene_cache.player_id,
    ets:delete_object(idx_robot_player_scene_cache_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_robot_player_data) ->
    RowKey = Row#db_robot_player_data.row_key,
    Nickname = Row#db_robot_player_data.nickname,
    ets:delete_object(idx_robot_player_data_1, {{Nickname}, RowKey});
erase_index(Row) when is_record(Row, db_rank_info) ->
    RowKey = Row#db_rank_info.row_key,
    OldRank = Row#db_rank_info.old_rank,
    Rank = Row#db_rank_info.rank,
    RankId = Row#db_rank_info.rank_id,
    ets:delete_object(idx_rank_info_1_rank_id, {{RankId}, RowKey}),
    ets:delete_object(idx_rank_info_2, {{RankId, Rank}, RowKey}),
    ets:delete_object(idx_rank_info_3_old_rank, {{RankId, OldRank}, RowKey});
erase_index(Row) when is_record(Row, db_promote_record) ->
    RowKey = Row#db_promote_record.row_key,
    AccId = Row#db_promote_record.acc_id,
    PlatformId = Row#db_promote_record.platform_id,
    ets:delete_object(idx_promote_record_1, {{PlatformId, AccId}, RowKey});
erase_index(Row) when is_record(Row, db_player_title) ->
    RowKey = Row#db_player_title.row_key,
    PlayerId = Row#db_player_title.player_id,
    ets:delete_object(idx_player_title_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_times_data) ->
    RowKey = Row#db_player_times_data.row_key,
    PlayerId = Row#db_player_times_data.player_id,
    ets:delete_object(idx_player_times_data, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_sys_common) ->
    RowKey = Row#db_player_sys_common.row_key,
    PlayerId = Row#db_player_sys_common.player_id,
    State = Row#db_player_sys_common.state,
    ets:delete_object(idx_player_sys_common_by_player, {{PlayerId}, RowKey}),
    ets:delete_object(idx_player_sys_common_by_state, {{PlayerId, State}, RowKey});
erase_index(Row) when is_record(Row, db_player_sys_attr) ->
    RowKey = Row#db_player_sys_attr.row_key,
    PlayerId = Row#db_player_sys_attr.player_id,
    ets:delete_object(idx_player_sys_attr_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_special_prop) ->
    RowKey = Row#db_player_special_prop.row_key,
    PlayerId = Row#db_player_special_prop.player_id,
    ets:delete_object(idx_player_special_prop_by_player, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_prop) ->
    RowKey = Row#db_player_prop.row_key,
    PlayerId = Row#db_player_prop.player_id,
    ets:delete_object(idx_player_prop_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_prerogative_card) ->
    RowKey = Row#db_player_prerogative_card.row_key,
    PlayerId = Row#db_player_prerogative_card.player_id,
    ets:delete_object(idx_player_prerogative_card_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_passive_skill) ->
    RowKey = Row#db_player_passive_skill.row_key,
    PlayerId = Row#db_player_passive_skill.player_id,
    ets:delete_object(idx_player_passive_skill_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_offline_apply) ->
    RowKey = Row#db_player_offline_apply.row_key,
    PlayerId = Row#db_player_offline_apply.player_id,
    ets:delete_object(idx_player_offline_apply_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_mail) ->
    RowKey = Row#db_player_mail.row_key,
    PlayerId = Row#db_player_mail.player_id,
    ets:delete_object(idx_player_mail_1_player_id, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_hero_parts) ->
    RowKey = Row#db_player_hero_parts.row_key,
    PlayerId = Row#db_player_hero_parts.player_id,
    ets:delete_object(idx_player_hero_parts_by_player, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_hero) ->
    RowKey = Row#db_player_hero.row_key,
    PlayerId = Row#db_player_hero.player_id,
    ets:delete_object(idx_player_hero_by_player, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_gift_mail) ->
    RowKey = Row#db_player_gift_mail.row_key,
    PlayerId = Row#db_player_gift_mail.player_id,
    Sender = Row#db_player_gift_mail.sender,
    ets:delete_object(idx_player_gift_mail_by_player, {{PlayerId}, RowKey}),
    ets:delete_object(idx_player_gift_mail_by_sender, {{Sender}, RowKey});
erase_index(Row) when is_record(Row, db_player_function) ->
    RowKey = Row#db_player_function.row_key,
    PlayerId = Row#db_player_function.player_id,
    ets:delete_object(idx_player_function_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_daily_task) ->
    RowKey = Row#db_player_daily_task.row_key,
    PlayerId = Row#db_player_daily_task.player_id,
    ets:delete_object(idx_player_daily_task_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_daily_points) ->
    RowKey = Row#db_player_daily_points.row_key,
    PlayerId = Row#db_player_daily_points.player_id,
    ets:delete_object(idx_player_daily_points_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_client_data) ->
    RowKey = Row#db_player_client_data.row_key,
    PlayerId = Row#db_player_client_data.player_id,
    ets:delete_object(idx_player_client_data_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_chat_data) ->
    RowKey = Row#db_player_chat_data.row_key,
    PlayerId = Row#db_player_chat_data.player_id,
    ets:delete_object(idx_player_chat_data_by_player, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_charge_record) ->
    RowKey = Row#db_player_charge_record.row_key,
    PlayerId = Row#db_player_charge_record.player_id,
    ets:delete_object(idx_player_charge_record_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_bounty_task) ->
    RowKey = Row#db_player_bounty_task.row_key,
    PlayerId = Row#db_player_bounty_task.player_id,
    ets:delete_object(idx_player_bounty_task_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_activity_info) ->
    RowKey = Row#db_player_activity_info.row_key,
    PlayerId = Row#db_player_activity_info.player_id,
    ets:delete_object(idx_player_activity_info_1, {{PlayerId}, RowKey});
erase_index(Row) when is_record(Row, db_player_activity_game) ->
    RowKey = Row#db_player_activity_game.row_key,
    ActivityId = Row#db_player_activity_game.activity_id,
    ActivityStartTime = Row#db_player_activity_game.activity_start_time,
    ets:delete_object(idx_player_activity_game_1, {{ActivityId, ActivityStartTime}, RowKey});
erase_index(Row) when is_record(Row, db_player) ->
    RowKey = Row#db_player.row_key,
    AccId = Row#db_player.acc_id,
    Nickname = Row#db_player.nickname,
    ServerId = Row#db_player.server_id,
    ets:delete_object(idx_player_1, {{Nickname}, RowKey}),
    ets:delete_object(idx_player_2, {{AccId, ServerId}, RowKey});
erase_index(Row) when is_record(Row, db_one_vs_one_rank_data) ->
    RowKey = Row#db_one_vs_one_rank_data.row_key,
    Type = Row#db_one_vs_one_rank_data.type,
    ets:delete_object(idx_one_vs_one_rank_data_by_type, {{Type}, RowKey});
erase_index(Row) when is_record(Row, db_mission_ranking) ->
    RowKey = Row#db_mission_ranking.row_key,
    Id = Row#db_mission_ranking.id,
    MissionId = Row#db_mission_ranking.mission_id,
    MissionType = Row#db_mission_ranking.mission_type,
    RankId = Row#db_mission_ranking.rank_id,
    ets:delete_object(idx_mission_ranking_1, {{MissionType, MissionId, Id}, RowKey}),
    ets:delete_object(idx_mission_ranking_by_rank_id, {{MissionType, MissionId, Id, RankId}, RowKey});
erase_index(Row) when is_record(Row, db_gift_code_type) ->
    RowKey = Row#db_gift_code_type.row_key,
    Name = Row#db_gift_code_type.name,
    ets:delete_object(idx_gift_code_type_1, {{Name}, RowKey});
erase_index(Row) when is_record(Row, db_brave_one) ->
    RowKey = Row#db_brave_one.row_key,
    FightPlayerId = Row#db_brave_one.fight_player_id,
    ets:delete_object(idx_brave_one_1, {{FightPlayerId}, RowKey});
erase_index(_)->noop.

erase_all_index(wheel_result_record_accumulate) ->
    ets:delete_all_objects(idx_wheel_result_record_accumulate_1);
erase_all_index(wheel_result_record) ->
    ets:delete_all_objects(idx_wheel_result_record_by_type);
erase_all_index(wheel_player_bet_record_today) ->
    ets:delete_all_objects(idx_wheel_player_bet_record_today_by_player);
erase_all_index(wheel_player_bet_record) ->
    ets:delete_all_objects(idx_wheel_player_bet_record_by_id),
    ets:delete_all_objects(idx_wheel_player_bet_record_by_type_and_player);
erase_all_index(robot_player_scene_cache) ->
    ets:delete_all_objects(idx_robot_player_scene_cache_1);
erase_all_index(robot_player_data) ->
    ets:delete_all_objects(idx_robot_player_data_1);
erase_all_index(rank_info) ->
    ets:delete_all_objects(idx_rank_info_1_rank_id),
    ets:delete_all_objects(idx_rank_info_2),
    ets:delete_all_objects(idx_rank_info_3_old_rank);
erase_all_index(promote_record) ->
    ets:delete_all_objects(idx_promote_record_1);
erase_all_index(player_title) ->
    ets:delete_all_objects(idx_player_title_1);
erase_all_index(player_times_data) ->
    ets:delete_all_objects(idx_player_times_data);
erase_all_index(player_sys_common) ->
    ets:delete_all_objects(idx_player_sys_common_by_player),
    ets:delete_all_objects(idx_player_sys_common_by_state);
erase_all_index(player_sys_attr) ->
    ets:delete_all_objects(idx_player_sys_attr_1);
erase_all_index(player_special_prop) ->
    ets:delete_all_objects(idx_player_special_prop_by_player);
erase_all_index(player_prop) ->
    ets:delete_all_objects(idx_player_prop_1);
erase_all_index(player_prerogative_card) ->
    ets:delete_all_objects(idx_player_prerogative_card_1);
erase_all_index(player_passive_skill) ->
    ets:delete_all_objects(idx_player_passive_skill_1);
erase_all_index(player_offline_apply) ->
    ets:delete_all_objects(idx_player_offline_apply_1);
erase_all_index(player_mail) ->
    ets:delete_all_objects(idx_player_mail_1_player_id);
erase_all_index(player_hero_parts) ->
    ets:delete_all_objects(idx_player_hero_parts_by_player);
erase_all_index(player_hero) ->
    ets:delete_all_objects(idx_player_hero_by_player);
erase_all_index(player_gift_mail) ->
    ets:delete_all_objects(idx_player_gift_mail_by_player),
    ets:delete_all_objects(idx_player_gift_mail_by_sender);
erase_all_index(player_function) ->
    ets:delete_all_objects(idx_player_function_1);
erase_all_index(player_daily_task) ->
    ets:delete_all_objects(idx_player_daily_task_1);
erase_all_index(player_daily_points) ->
    ets:delete_all_objects(idx_player_daily_points_1);
erase_all_index(player_client_data) ->
    ets:delete_all_objects(idx_player_client_data_1);
erase_all_index(player_chat_data) ->
    ets:delete_all_objects(idx_player_chat_data_by_player);
erase_all_index(player_charge_record) ->
    ets:delete_all_objects(idx_player_charge_record_1);
erase_all_index(player_bounty_task) ->
    ets:delete_all_objects(idx_player_bounty_task_1);
erase_all_index(player_activity_info) ->
    ets:delete_all_objects(idx_player_activity_info_1);
erase_all_index(player_activity_game) ->
    ets:delete_all_objects(idx_player_activity_game_1);
erase_all_index(player) ->
    ets:delete_all_objects(idx_player_1),
    ets:delete_all_objects(idx_player_2);
erase_all_index(one_vs_one_rank_data) ->
    ets:delete_all_objects(idx_one_vs_one_rank_data_by_type);
erase_all_index(mission_ranking) ->
    ets:delete_all_objects(idx_mission_ranking_1),
    ets:delete_all_objects(idx_mission_ranking_by_rank_id);
erase_all_index(gift_code_type) ->
    ets:delete_all_objects(idx_gift_code_type_1);
erase_all_index(brave_one) ->
    ets:delete_all_objects(idx_brave_one_1);
erase_all_index(_)->noop.

