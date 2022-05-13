ALTER TABLE `consume_statistics`
ADD COLUMN `scene_id` int(10) NOT NULL COMMENT '场景id' AFTER `value`,
DROP PRIMARY KEY,
ADD PRIMARY KEY (`player_id`, `prop_id`, `type`, `log_type`, `scene_id`) USING BTREE;