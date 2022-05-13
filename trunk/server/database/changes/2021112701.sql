ALTER TABLE `wheel_player_bet_record_today` MODIFY COLUMN `bet_num` bigint(20) NOT NULL DEFAULT 0 COMMENT '投注数量';
ALTER TABLE `wheel_player_bet_record_today` MODIFY COLUMN `award_num` bigint(20) NOT NULL DEFAULT 0 COMMENT '投注奖励数量';

ALTER TABLE `wheel_player_bet_record` MODIFY COLUMN `bet_num` bigint(20) NOT NULL DEFAULT 0 COMMENT '投注数量';
ALTER TABLE `wheel_player_bet_record` MODIFY COLUMN `award_num` bigint(20) NOT NULL DEFAULT 0 COMMENT '投注奖励数量';