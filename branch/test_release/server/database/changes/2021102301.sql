ALTER TABLE `player_gift_mail` ADD COLUMN `sender` int(11) not null default 0 COMMENT '赠送者' AFTER `player_id`;
ALTER TABLE `player_gift_mail` DROP PRIMARY KEY,
    ADD PRIMARY KEY (`player_id`, `mail_real_id`) USING BTREE;