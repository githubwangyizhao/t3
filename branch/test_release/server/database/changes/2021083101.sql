CREATE TABLE `player_adjust_rebound`(
    `player_id`        INT      unsigned        NOT NULL COMMENT '玩家id',
    `rebound_type`     TINYINT                  NOT NULL COMMENT '反弹类型(0:触底反弹 1:爆富反弹)',
    `trigger_times`    TINYINT                  NOT NULL DEFAULT 0 COMMENT '当前触发次数',
    `trigger_time`     INT      unsigned        NOT NULL DEFAULT 0 COMMENT '上次触发时间',
    primary key (`player_id` , `rebound_type`)
)
    COMMENT = '玩家修正反弹'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';