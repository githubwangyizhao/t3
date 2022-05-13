%%% Generated automatically, no need to modify.
-module(t_daily_task@group).
-export([get_group_keys/0, get/1, get_group_size/1]).
get_group_keys() ->
	 [8,7,6,5,4,3,2,1].
get(1) -> 
	 [{t_daily_task,{1},1,1,[login_day,1],[[55,20],[2,1000]],0}];
get(2) -> 
	 [{t_daily_task,{2},2,2,[freeze_skill_count,1],[[55,20],[202,1]],9},{t_daily_task,{3},3,2,[speed_skill_count,1],[[55,30],[201,1]],9}];
get(3) -> 
	 [{t_daily_task,{4},4,3,[kill_get_gold,10000],[[55,30],[2,5000]],9}];
get(4) -> 
	 [{t_daily_task,{5},5,4,[kill_effect_count,12,1],[[55,30],[2,2000]],9},{t_daily_task,{6},6,4,[kill_effect_count,13,1],[[55,30],[2,2000]],9},{t_daily_task,{7},7,4,[kill_effect_count,5,1],[[55,30],[2,2000]],9},{t_daily_task,{8},8,4,[kill_effect_count,14,1],[[55,30],[2,2000]],9}];
get(5) -> 
	 [{t_daily_task,{9},9,5,[complete_reward_task,1],[[55,30],[2,7000]],9}];
get(6) -> 
	 [{t_daily_task,{10},10,6,[kill_effect_count,17,1],[[55,30],[2,5000]],9},{t_daily_task,{11},11,6,[kill_effect_count,7,1],[[55,30],[2,5000]],9},{t_daily_task,{12},12,6,[kill_effect_count,8,1],[[55,30],[2,5000]],9}];
get(7) -> 
	 [{t_daily_task,{13},13,7,[charge_count,1],[[55,50],[2,10000]],10}];
get(8) -> 
	 [{t_daily_task,{14},14,8,[share_count,1],[[55,40],[2,5000]],4}];
get(_) -> 
	 undefined.
get_group_size(1) -> 1;
get_group_size(2) -> 2;
get_group_size(3) -> 1;
get_group_size(4) -> 4;
get_group_size(5) -> 1;
get_group_size(6) -> 3;
get_group_size(7) -> 1;
get_group_size(8) -> 1;
get_group_size(_) -> 0.
