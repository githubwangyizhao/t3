%%% Generated automatically, no need to modify.
-module(t_tongxingzheng_daily_task).
-export([get/1, get/2, assert_get/1, get_keys/0]).

get(Key, Default) ->
    case ?MODULE:get(Key) of
        null -> Default;
        Result -> Result
    end.

assert_get(Key) ->
    case ?MODULE:get(Key) of
        null -> exit({got_null, ?MODULE, Key});
        Result -> Result
    end.

get_keys() ->
     [{3},{4},{5},{6},{7},{8},{9},{10},{11},{13},{14},{15},{16},{17},{18},{19},{20},{21}].


get({3}) ->
     {t_tongxingzheng_daily_task,{3},3,[item_shop_buy_count,2],[],200};
get({4}) ->
     {t_tongxingzheng_daily_task,{4},4,[kill_get_gold,100000],[],1000};
get({5}) ->
     {t_tongxingzheng_daily_task,{5},5,[kill_get_gold,500000],[],500};
get({6}) ->
     {t_tongxingzheng_daily_task,{6},6,[change_head,1],[],200};
get({7}) ->
     {t_tongxingzheng_daily_task,{7},7,[change_head_frame,1],[],200};
get({8}) ->
     {t_tongxingzheng_daily_task,{8},8,[chat_count,5],[],200};
get({9}) ->
     {t_tongxingzheng_daily_task,{9},9,[sticker,5],[],200};
get({10}) ->
     {t_tongxingzheng_daily_task,{10},10,[dash_count,10],[],200};
get({11}) ->
     {t_tongxingzheng_daily_task,{11},11,[kill_monster_count,10],[],500};
get({13}) ->
     {t_tongxingzheng_daily_task,{13},13,[freeze_skill_count,2],[],500};
get({14}) ->
     {t_tongxingzheng_daily_task,{14},14,[speed_skill_count,2],[],500};
get({15}) ->
     {t_tongxingzheng_daily_task,{15},15,[attack_count,200],[],500};
get({16}) ->
     {t_tongxingzheng_daily_task,{16},16,[attack_count,400],[],200};
get({17}) ->
     {t_tongxingzheng_daily_task,{17},17,[kill_monster_count,100],[],500};
get({18}) ->
     {t_tongxingzheng_daily_task,{18},18,[kill_monster_count,150],[],200};
get({19}) ->
     {t_tongxingzheng_daily_task,{19},19,[kill_monster_count,150],[],200};
get({20}) ->
     {t_tongxingzheng_daily_task,{20},20,[freeze_skill_count,5],[],500};
get({21}) ->
     {t_tongxingzheng_daily_task,{21},21,[speed_skill_count,5],[],500};
get(_Id) ->
    null.
