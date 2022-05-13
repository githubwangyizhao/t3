ALTER TABLE `global_account` ADD COLUMN `registration_id` varchar(50) NOT NULL DEFAULT '' COMMENT '激光设备码' AFTER `region`;
