ALTER TABLE `consume_statistics` MODIFY COLUMN `value`  bigint(20) NOT NULL DEFAULT 0 COMMENT '数量' AFTER `log_type`;

ALTER TABLE `player_fight_adjust` ADD COLUMN `bottom_times` TINYINT not null DEFAULT '0' COMMENT '触底反弹次数使用' AFTER `pool_2`;
ALTER TABLE `player_fight_adjust` ADD COLUMN `bottom_times_time` INT not null DEFAULT '0' COMMENT '上一次触底反弹使用时间' AFTER `bottom_times`;
ALTER TABLE `player_fight_adjust` ADD COLUMN `is_bottom` TINYINT not null DEFAULT '0' COMMENT '是否是触底反弹' AFTER `bottom_times_time`;
