
% 玩家暗杀记录
-define(ETS_ASSASSINATE_RECORD, ets_assassinate_record).
-record(ets_assassinate_record, {
    row_key = {},            % key
    player_id = 0,          % 玩家Id
    fight_player_id = 0,    % 被暗杀玩家
    change_time = 0         % 操作时间
}).

