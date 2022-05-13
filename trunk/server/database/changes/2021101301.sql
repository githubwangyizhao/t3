
ALTER TABLE `global_account`
    ADD COLUMN `mobile` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '0' COMMENT '手机号码' AFTER `registration_id`;