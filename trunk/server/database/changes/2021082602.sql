ALTER TABLE `player`
    ADD COLUMN `oauth_source` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'vistor' COMMENT '授权登录来源' AFTER `friend_code`;