ALTER TABLE `oauth_order_log` 
ADD COLUMN `buyer_player_id` int(11) NOT NULL DEFAULT 0 COMMENT '卖家编号 默认为0' AFTER `player_id`;