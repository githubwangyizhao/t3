CREATE TABLE `player_gift_mail`
(
    `player_id`    INTEGER      NOT NULL COMMENT '玩家id',
    `mail_real_id` INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件实际id',
    `weight_value` INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件重要级(重要级越小越先删除)',
    `is_read`      TINYINT      NOT NULL DEFAULT 0 COMMENT '状态0未读,1:已读',
    `state`        TINYINT      NOT NULL DEFAULT 0 COMMENT '状态0:没有附件,1有附件,2:已取附件',
    `mail_id`      INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件模板id',
    `title_content`VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '邮件标题内容',
    `title_param`  VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '标题参数',
    `content`      VARCHAR(512) NOT NULL DEFAULT '' COMMENT '邮件内容',
    `content_param`VARCHAR(256) NOT NULL DEFAULT '' COMMENT '内容参数',
    `item_list`    VARCHAR(512) NOT NULL DEFAULT '' COMMENT '道具列表',
    `create_time`  INTEGER      NOT NULL DEFAULT 0 COMMENT '创建时间',
    primary key (`player_id`, `mail_real_id`)
)
    COMMENT = '玩家礼物邮件'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';