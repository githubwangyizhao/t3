ALTER TABLE global_account
    MODIFY COLUMN `app_id` varchar(50) NOT NULL DEFAULT 'com.ashram.t3' COMMENT 'app的包名';
ALTER TABLE global_account
    MODIFY COLUMN `region` varchar(50) NOT NULL DEFAULT 'TWD' COMMENT '国家/地区';