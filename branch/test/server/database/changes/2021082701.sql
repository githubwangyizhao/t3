ALTER TABLE charge_info_record
    ADD COLUMN `source` tinyint(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '来源(1为谷歌支付,2为app store支付,3为装备平台支付默认1)' AFTER `status`;