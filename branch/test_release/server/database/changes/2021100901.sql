ALTER TABLE `consume_statistics` 
ADD INDEX `idx_consume_statistics_1`(`scene_id`, `log_type`, `type`) USING BTREE;