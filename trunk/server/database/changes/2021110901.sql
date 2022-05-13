ALTER TABLE `charge_info_record` ADD COLUMN `gold` int(11) not null default 0 COMMENT '当前金币' AFTER `source`;
ALTER TABLE `charge_info_record` ADD COLUMN `bounty` int(11) not null default 0 COMMENT '当前赏金石' AFTER `gold`;
ALTER TABLE `charge_info_record` ADD COLUMN `coupon` int(11) not null default 0 COMMENT '当前点券' AFTER `bounty`;