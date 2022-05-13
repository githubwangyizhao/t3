%%% Generated automatically, no need to modify.
-module(t_brisk_daily_task).
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
     [{3},{4},{5},{6},{7},{8},{9},{10},{11},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24}].


get({3}) ->
     {t_brisk_daily_task,{3},3,[49],[item_shop_buy_count,2],[19,150],200};
get({4}) ->
     {t_brisk_daily_task,{4},4,[49],[kill_get_gold,100000],[19,150],1000};
get({5}) ->
     {t_brisk_daily_task,{5},5,[49],[kill_get_gold,500000],[19,200],500};
get({6}) ->
     {t_brisk_daily_task,{6},6,[50],[change_head,1],[19,150],200};
get({7}) ->
     {t_brisk_daily_task,{7},7,[50],[change_head_frame,1],[19,150],200};
get({8}) ->
     {t_brisk_daily_task,{8},8,[50],[chat_count,5],[19,150],200};
get({9}) ->
     {t_brisk_daily_task,{9},9,[51],[sticker,5],[19,150],200};
get({10}) ->
     {t_brisk_daily_task,{10},10,[51],[dash_count,10],[19,150],200};
get({11}) ->
     {t_brisk_daily_task,{11},11,[51],[kill_monster_count,10],[19,100],500};
get({13}) ->
     {t_brisk_daily_task,{13},13,[52],[freeze_skill_count,2],[19,150],500};
get({14}) ->
     {t_brisk_daily_task,{14},14,[52],[speed_skill_count,2],[19,150],500};
get({15}) ->
     {t_brisk_daily_task,{15},15,[52],[attack_count,200],[19,100],500};
get({16}) ->
     {t_brisk_daily_task,{16},16,[53],[attack_count,400],[19,200],200};
get({17}) ->
     {t_brisk_daily_task,{17},17,[53],[kill_monster_count,100],[19,100],500};
get({18}) ->
     {t_brisk_daily_task,{18},18,[53],[kill_monster_count,150],[19,200],200};
get({19}) ->
     {t_brisk_daily_task,{19},19,[54],[kill_monster_count,150],[19,200],200};
get({20}) ->
     {t_brisk_daily_task,{20},20,[54],[freeze_skill_count,5],[19,150],500};
get({21}) ->
     {t_brisk_daily_task,{21},21,[54],[speed_skill_count,5],[19,150],500};
get({22}) ->
     {t_brisk_daily_task,{22},22,[55],[kill_monster_count,100],[19,100],500};
get({23}) ->
     {t_brisk_daily_task,{23},23,[55],[kill_monster_count,150],[19,200],200};
get({24}) ->
     {t_brisk_daily_task,{24},24,[55],[kill_monster_count,150],[19,200],200};
get(_Id) ->
    null.
