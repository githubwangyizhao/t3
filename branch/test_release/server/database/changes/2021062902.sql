CREATE TABLE `player_jiangjinchi` (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `scene_id` int(11) NOT NULL COMMENT '场景id',
  `atk_cost` bigint(20) NOT NULL DEFAULT '0' COMMENT '普攻总消耗',
  `atk_times` int(11) NOT NULL DEFAULT '0' COMMENT '普攻刀数',
  `state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态 0-抽奖条件未达成 1-抽奖阶段 2-翻倍阶段',
  `award_num` int(11) NOT NULL DEFAULT '0' COMMENT '当前累计奖励数量',
  `extra_award_num` int(11) NOT NULL DEFAULT '0' COMMENT '奖池奖励数量',
  `doubled_times` int(11) NOT NULL DEFAULT '0' COMMENT '翻倍次数',
  `change_time` int(11) NOT NULL DEFAULT '0' COMMENT '更新时间',
  `init_award_num` int(11) NOT NULL DEFAULT '0' COMMENT '初始奖励数量',
  PRIMARY KEY (`player_id`,`scene_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `jiangjinchi` (
  `scene_id` int(11) NOT NULL COMMENT ' 场景id',
  `pool` bigint(20) NOT NULL DEFAULT '0' COMMENT '当前奖池金额',
  `change_time` int(11) NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`scene_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;