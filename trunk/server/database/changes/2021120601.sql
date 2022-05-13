CREATE TABLE `player_gift_mail_log`
(
    `sender`       INTEGER      NOT NULL COMMENT '赠送者',
    `create_time`  INTEGER      NOT NULL DEFAULT 0 COMMENT '创建时间',
    `receiver`     INTEGER      NOT NULL DEFAULT 0 COMMENT '接收者',
    `receiver_nickname` varchar(64)  NOT NULL DEFAULT '' COMMENT '接收者昵称',
    `item_list`    VARCHAR(512) NOT NULL DEFAULT '' COMMENT '道具列表',
    primary key (`sender`, `create_time`)
)
    COMMENT = '玩家礼物邮件日志'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';