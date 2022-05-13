CREATE TABLE `player_special_prop`
(
    `player_id`     INT     unsigned NOT NULL COMMENT '玩家id',
    `prop_obj_id`   INT     unsigned NOT NULL COMMENT '道具唯一id',
    `prop_id`       INT     unsigned NOT NULL COMMENT '道具id',
    `expire_time`   int(10) unsigned NOT NULL COMMENT '过期时间',
    PRIMARY KEY (`player_id`, `prop_obj_id`)
)
    COMMENT = '玩家特殊道具'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';