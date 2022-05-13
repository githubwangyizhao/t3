ALTER TABLE `player_conditions_data` ADD COLUMN `type2` int(11) NOT NULL DEFAULT '0' COMMENT '类型2' AFTER `type`;
ALTER TABLE `player_conditions_data` DROP PRIMARY KEY;
ALTER TABLE `player_conditions_data` ADD PRIMARY KEY (`player_id`, `type`, `type2`, `conditions_id`);