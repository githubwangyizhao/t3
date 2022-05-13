CREATE TABLE `player_chat_data`  (
  `player_id`       int(11)             NOT NULL COMMENT '玩家id',
  `id`              int(11)             NOT NULL COMMENT '消息id',
  `send_player_id`  int(11)             NOT NULL COMMENT '发送玩家id',
  `chat_msg`        varchar(64)         NOT NULL DEFAULT ''  COMMENT '聊天消息',
  `level`           SMALLINT unsigned   NOT NULL DEFAULT '0' COMMENT '等级',
  `vip_level`       tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT 'vip等级',
  `head_id`         INT                 NOT NULL DEFAULT '1' COMMENT '头像',
  `nickname`        varchar(64)         NOT NULL DEFAULT '' COMMENT '昵称',
  `sex`             tinyint(4)          NOT NULL DEFAULT '0' COMMENT '性别, 0:男 1:女',
  `head_frame_id`   int(11)             NOT NULL DEFAULT '0' COMMENT '头像框',
  `send_time`       int(11)             NOT NULL DEFAULT '0' COMMENT '时间',
  PRIMARY KEY (`player_id`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家聊天数据' ROW_FORMAT = Compact;