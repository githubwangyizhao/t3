ALTER TABLE `player_fight_adjust` ADD COLUMN `fight_type`  tinyint(3) UNSIGNED NOT NULL COMMENT '战斗类型(0:概率战斗,1:血量战斗)' AFTER `prop_id`;
ALTER TABLE `player_fight_adjust` DROP PRIMARY KEY;
ALTER TABLE `player_fight_adjust` ADD PRIMARY KEY (`player_id`, `prop_id`, `fight_type`);
