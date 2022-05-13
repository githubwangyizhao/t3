ALTER TABLE `player_charge_info_record` ADD COLUMN `refused_money` decimal(20, 2) not null DEFAULT '0' COMMENT '退款总金额' AFTER `is_share`;
