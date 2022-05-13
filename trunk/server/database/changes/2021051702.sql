ALTER TABLE `charge_info_record` ADD COLUMN `status` tinyint(1) unsigned not null DEFAULT '1' COMMENT '状态(0为退款,1为成功,默认1)' AFTER `channel`;
