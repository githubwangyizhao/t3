CREATE TABLE `server_game_config`
(
#     `config_type` INTEGER          NOT NULL COMMENT '(1:全服,2:本服)',
    `config_id`   SMALLINT         NOT NULL COMMENT '配置id',
    `int_data`    INTEGER UNSIGNED NOT NULL DEFAULT '0' COMMENT '整型数据',
    `str_data`    VARCHAR(128)     NOT NULL DEFAULT '' COMMENT '字符串数据',
    `change_time` INTEGER          NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`config_id`)
)
    COMMENT = '服务器游戏配置'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_game_config`
(
    `player_id`   INTEGER          NOT NULL COMMENT '',
    `config_id`   SMALLINT         NOT NULL COMMENT '配置id',
    `int_data`    INTEGER UNSIGNED NOT NULL DEFAULT '0' COMMENT '整型数据',
    `str_data`    VARCHAR(128)     NOT NULL DEFAULT '' COMMENT '字符串数据',
    `change_time` INTEGER          NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `config_id`)
)
    COMMENT = '玩家游戏配置'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

ALTER TABLE `player_fight_adjust` ADD COLUMN `id` TINYINT not null DEFAULT '0' COMMENT '修正id' AFTER `is_bottom`;
