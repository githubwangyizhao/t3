%%% Generated automatically, no need to modify.
-module(t_log_type).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24},{25},{26},{27},{28},{29},{30},{31},{32},{33},{34},{35},{36},{37},{38},{39},{40},{41},{42},{43},{44},{45},{46},{47},{48},{49},{50},{51},{52},{53},{54},{55},{56},{57},{58},{59},{60},{61},{62},{63},{64},{65},{66},{67},{68},{69},{70},{71},{72},{74},{75},{76},{77},{78},{79},{80},{81},{82},{83},{85},{86},{87},{88},{89},{90},{91},{92},{93},{94},{95},{96},{97},{98},{99},{100},{101},{103},{104},{105},{106},{107},{108},{109},{110},{111},{112},{113},{114},{115},{116},{117},{118},{119},{120},{121},{122},{123},{124},{125},{126},{127},{128},{129},{130},{131},{132},{133},{134},{136},{137},{138},{139},{140},{141},{142},{143},{144},{145},{999},{1000}].


get({1}) ->
     {t_log_type,{1},1,[103,109],[229,144,142,229,143,176]};
get({2}) ->
     {t_log_type,{2},2,[99,104,97,114,103,101,95,103,101,116],[229,133,133,229,128,188,232,142,183,229,190,151]};
get({3}) ->
     {t_log_type,{3},3,[99,104,97,114,103,101,95,115,101,110,100],[229,133,133,229,128,188,232,181,160,233,128,129]};
get({4}) ->
     {t_log_type,{4},4,[102,105,110,105,115,104,95,116,97,115,107],[229,174,140,230,136,144,228,187,187,229,138,161]};
get({5}) ->
     {t_log_type,{5},5,[111,102,102,108,105,110,101,95,97,119,97,114,100],[231,166,187,231,186,191,229,165,150,229,138,177]};
get({6}) ->
     {t_log_type,{6},6,[98,117,121,95,116,105,109,101,115],[232,180,173,228,185,176,230,172,161,230,149,176]};
get({7}) ->
     {t_log_type,{7},7,[103,97,116,104,101,114,95,103,101,116],[230,128,170,231,137,169,230,142,137,232,144,189]};
get({8}) ->
     {t_log_type,{8},8,[115,119,101,101,112],[230,137,171,232,141,161,229,138,159,232,131,189]};
get({9}) ->
     {t_log_type,{9},9,[109,97,105,108,95,103,101,116,95,105,116,101,109],[233,130,174,228,187,182,233,153,132,228,187,182,233,162,134,229,143,150]};
get({10}) ->
     {t_log_type,{10},10,[109,97,105,108,95,103,101,116,95,97,108,108,95,105,116,101,109],[233,130,174,228,187,182,233,153,132,228,187,182,228,184,128,233,148,174,233,162,134,229,143,150]};
get({11}) ->
     {t_log_type,{11},11,[116,105,116,108,101,95,117,112,103,114,97,100,101],[231,167,176,229,143,183,229,141,135,231,186,167]};
get({12}) ->
     {t_log_type,{12},12,[97,99,104,105,101,118,101,109,101,110,116,95,97,119,97,114,100],[230,136,144,229,176,177,229,165,150,229,138,177,233,162,134,229,143,150]};
get({13}) ->
     {t_log_type,{13},13,[97,99,104,105,101,118,101,109,101,110,116,95,97,105,109,95,97,119,97,114,100],[230,136,144,229,176,177,231,155,174,230,160,135,229,165,150,229,138,177,233,162,134,229,143,150]};
get({14}) ->
     {t_log_type,{14},14,[115,104,111,112,95,98,117,121],[229,149,134,229,186,151,232,180,173,228,185,176]};
get({15}) ->
     {t_log_type,{15},15,[109,121,115,116,101,114,121,95,115,104,111,112,95,98,117,121],[231,165,158,231,167,152,229,149,134,229,186,151,232,180,173,228,185,176]};
get({16}) ->
     {t_log_type,{16},16,[97,100,100,95,116,105,116,108,101],[229,162,158,229,138,160,231,167,176,229,143,183]};
get({17}) ->
     {t_log_type,{17},17,[104,111,110,101,95,108,101,118,101,108],[229,142,134,231,187,131,229,141,135,231,186,167]};
get({18}) ->
     {t_log_type,{18},18,[117,115,101,95,105,116,101,109],[228,189,191,231,148,168,231,137,169,229,147,129]};
get({19}) ->
     {t_log_type,{19},19,[101,118,101,114,121,100,97,121,95,115,105,103,110],[230,175,143,230,151,165,231,173,190,229,136,176]};
get({20}) ->
     {t_log_type,{20},20,[104,111,111,107],[230,140,130,230,156,186]};
get({21}) ->
     {t_log_type,{21},21,[115,101,118,101,110,95,108,111,103,105,110],[228,184,131,229,164,169,231,153,187,229,133,165]};
get({22}) ->
     {t_log_type,{22},22,[111,110,108,105,110,101,95,97,119,97,114,100],[229,156,168,231,186,191,229,165,150,229,138,177]};
get({23}) ->
     {t_log_type,{23},23,[116,114,101,97,115,117,114,101,95,104,111,117,115,101,95,111,112,101,110],[232,151,143,229,174,157,233,152,129,229,188,128,229,144,175]};
get({24}) ->
     {t_log_type,{24},24,[103,101,116,95,109,105,115,115,105,111,110,95,114,97,116,101,95,97,119,97,114,100],[233,162,134,229,143,150,229,137,175,230,156,172,229,164,154,229,128,141,229,165,150,229,138,177]};
get({25}) ->
     {t_log_type,{25},25,[112,114,101,114,111,103,97,116,105,118,101,95,99,97,114,100],[232,180,173,228,185,176,231,137,185,230,157,131,229,141,161]};
get({26}) ->
     {t_log_type,{26},26,[112,114,101,114,111,103,97,116,105,118,101,95,99,97,114,100,95,97,119,97,114,100],[231,137,185,230,157,131,229,141,161,230,175,143,230,151,165,229,165,150,229,138,177]};
get({27}) ->
     {t_log_type,{27},27,[118,105,112,95,97,119,97,114,100],[118,105,112,229,165,150,229,138,177,233,162,134,229,143,150]};
get({28}) ->
     {t_log_type,{28},28,[116,105,109,101,95,108,105,109,105,116,95,116,97,115,107,95,103,105,118,101],[233,153,144,230,151,182,228,187,187,229,138,161,233,162,134,229,143,150]};
get({29}) ->
     {t_log_type,{29},29,[115,121,115,116,101,109,95,115,101,110,100],[231,179,187,231,187,159,232,181,160,233,128,129]};
get({30}) ->
     {t_log_type,{30},30,[117,112,103,114,97,100,101,95,115,107,105,108,108],[229,141,135,231,186,167,230,138,128,232,131,189]};
get({31}) ->
     {t_log_type,{31},31,[97,99,116,105,118,105,116,121,95,112,111,119,101,114,95,105,110,118,101,115,116,109,101,110,116],[230,180,187,229,138,168,230,136,152,229,138,155,230,138,149,232,181,132,229,165,150,229,138,177,233,162,134,229,143,150]};
get({32}) ->
     {t_log_type,{32},32,[97,99,116,105,118,105,116,121,95,99,111,110,115,117,109,101,95,101,118,101,114,121,100,97,121],[230,180,187,229,138,168,230,175,143,230,151,165,230,182,136,232,180,185,229,165,150,229,138,177,233,162,134,229,143,150]};
get({33}) ->
     {t_log_type,{33},33,[97,99,116,105,118,105,116,121,95,99,111,110,115,117,109,101,95,114,97,110,107,95,103,101,116],[230,180,187,229,138,168,230,182,136,232,180,185,230,142,146,232,161,140,229,165,150,229,138,177,233,162,134,229,143,150]};
get({34}) ->
     {t_log_type,{34},34,[97,99,116,105,118,105,116,121,95,99,111,110,115,117,109,101,95,114,97,110,107,95,103,105,118,101],[230,180,187,229,138,168,230,182,136,232,180,185,230,142,146,232,161,140,230,142,146,232,161,140,230,166,156,229,165,150,229,138,177,229,143,145,230,148,190]};
get({35}) ->
     {t_log_type,{35},35,[97,99,116,105,118,105,116,121,95,115,107,105,108,108,95,98,111,111,107,95,103,101,116],[230,180,187,229,138,168,230,138,128,232,131,189,229,174,157,229,133,184,229,165,150,229,138,177,233,162,134,229,143,150]};
get({36}) ->
     {t_log_type,{36},36,[97,99,116,105,118,105,116,121,95,115,107,105,108,108,95,98,111,111,107,95,98,117,121],[230,180,187,229,138,168,230,138,128,232,131,189,229,174,157,229,133,184,232,180,173,228,185,176]};
get({37}) ->
     {t_log_type,{37},37,[97,99,116,105,118,105,116,121,95,115,107,105,108,108,95,98,111,111,107,95,99,108,111,115,101,95,103,105,118,101],[230,180,187,229,138,168,230,138,128,232,131,189,229,174,157,229,133,184,230,180,187,229,138,168,231,187,147,230,157,159,231,187,147,231,174,151]};
get({38}) ->
     {t_log_type,{38},38,[116,114,101,97,115,117,114,101,95,104,111,117,115,101,95,99,108,111,115,101,95,103,105,118,101],[231,143,141,229,174,157,233,152,129,231,187,147,231,174,151]};
get({39}) ->
     {t_log_type,{39},39,[115,104,111,112,95,108,105,109,105,116,95,116,105,109,101,95,98,117,121],[233,153,144,230,151,182,230,138,162,232,180,173,229,149,134,229,186,151,232,180,173,228,185,176]};
get({40}) ->
     {t_log_type,{40},40,[111,112,101,110,95,115,101,114,118,105,99,101,95,103,111,97,108,115,95,97,119,97,114,100],[229,188,128,230,156,141,231,155,174,230,160,135,229,165,150,229,138,177]};
get({41}) ->
     {t_log_type,{41},41,[109,97,103,105,99,95,119,101,97,112,111,110,95,117,112,103,114,97,100,101,95,108,101,118,101,108],[230,179,149,229,174,157,229,141,135,231,186,167]};
get({42}) ->
     {t_log_type,{42},42,[103,111,115,115,105,112,95,99,111,109,112,101,116,105,116,105,111,110],[229,133,171,229,141,166,231,155,152,230,142,160,229,164,186]};
get({43}) ->
     {t_log_type,{43},43,[114,97,110,107,95,99,97,108,99,95,97,119,97,114,100],[230,142,146,232,161,140,230,166,156,231,187,159,228,184,128,231,187,147,231,174,151,229,165,150,229,138,177]};
get({44}) ->
     {t_log_type,{44},44,[99,111,108,108,101,99,116,95,103,97,109,101],[230,148,182,232,151,143,230,184,184,230,136,143,229,165,150,229,138,177]};
get({45}) ->
     {t_log_type,{45},45,[115,104,97,114,101,95,100,97,121,95,103,97,109,101],[230,175,143,230,151,165,229,136,134,228,186,171,230,184,184,230,136,143]};
get({46}) ->
     {t_log_type,{46},46,[115,104,97,114,101,95,102,114,105,101,110,100,95,97,119,97,114,100],[229,136,134,228,186,171,229,165,189,229,143,139,232,191,155,229,133,165,230,184,184,230,136,143,229,165,150,229,138,177]};
get({47}) ->
     {t_log_type,{47},47,[99,108,111,116,104,101,115],[229,141,135,231,186,167,230,151,182,232,163,133,233,129,147,229,133,183,230,182,136,232,128,151]};
get({48}) ->
     {t_log_type,{48},48,[117,112,100,97,116,101,95,99,111,109,112,101,110,115,97,116,101],[231,137,136,230,156,172,230,155,180,230,150,176,232,161,165,229,129,191]};
get({49}) ->
     {t_log_type,{49},49,[99,111,109,112,111,117,110,100,95,112,114,111,112],[233,129,147,229,133,183,229,144,136,230,136,144]};
get({50}) ->
     {t_log_type,{50},50,[101,118,101,114,121,100,97,121,95,109,117,108,116,105,112,108,101,95,114,101,99,104,97,114,103,101,95,98,111,120,95,103,101,116],[230,175,143,230,151,165,233,166,150,229,133,133,229,174,157,231,174,177,233,162,134,229,143,150]};
get({51}) ->
     {t_log_type,{51},51,[109,97,103,105,99,95,116,104,117,110,100,101,114,95,108,101,118,101,108],[230,179,149,229,174,157,233,151,170,231,148,181,233,147,190,229,141,135,231,186,167]};
get({52}) ->
     {t_log_type,{52},52,[101,118,101,114,121,100,97,121,95,109,117,108,116,105,112,108,101,95,114,101,99,104,97,114,103,101,95,103,101,116],[230,175,143,230,151,165,233,166,150,229,133,133,233,162,134,229,143,150]};
get({53}) ->
     {t_log_type,{53},53,[97,99,116,105,118,105,116,121,95,116,97,115,107,95,97,119,97,114,100],[230,180,187,229,138,168,228,187,187,229,138,161,229,165,150,229,138,177,233,162,134,229,143,150]};
get({54}) ->
     {t_log_type,{54},54,[103,105,102,116,95,99,111,100,101],[231,164,188,229,140,133,231,160,129,229,133,145,230,141,162]};
get({55}) ->
     {t_log_type,{55},55,[112,108,97,116,102,111,114,109,95,99,111,110,99,101,114,110,95,97,119,97,114,100],[229,185,179,229,143,176,229,133,179,230,179,168,231,164,188,229,140,133]};
get({56}) ->
     {t_log_type,{56},56,[112,108,97,116,102,111,114,109,95,99,101,114,116,105,102,105,99,97,116,105,111,110,95,97,119,97,114,100],[229,185,179,229,143,176,232,174,164,232,175,129,231,164,188,229,140,133]};
get({57}) ->
     {t_log_type,{57},57,[97,99,116,105,118,105,116,121,95,115,101,118,101,110,95,108,111,103,105,110,95,99,108,111,115,101,95,109,97,105,108],[230,180,187,229,138,168,228,184,131,229,164,169,231,153,187,229,133,165,229,133,179,233,151,173,233,130,174,228,187,182,233,162,134,229,143,150]};
get({58}) ->
     {t_log_type,{58},58,[115,104,97,114,101,95,116,97,115,107,95,97,119,97,114,100],[229,136,134,228,186,171,228,187,187,229,138,161,229,165,150,229,138,177,233,162,134,229,143,150]};
get({59}) ->
     {t_log_type,{59},59,[98,111,115,115,95,114,101,98,105,114,116,104],[98,111,115,115,229,164,141,230,180,187]};
get({60}) ->
     {t_log_type,{60},60,[112,114,111,112,95,101,120,112,105,114,101],[233,129,147,229,133,183,232,191,135,230,156,159]};
get({61}) ->
     {t_log_type,{61},61,[115,101,108,108,95,105,116,101,109],[229,135,186,229,148,174,231,137,169,229,147,129]};
get({62}) ->
     {t_log_type,{62},62,[97,110,115,119,101,114,95,101,110,114,111,108,108],[231,173,148,233,162,152,230,138,165,229,144,141,230,182,136,232,128,151]};
get({63}) ->
     {t_log_type,{63},63,[97,110,115,119,101,114,95,105,110,115,112,105,114,101],[231,173,148,233,162,152,233,188,147,232,136,158,230,182,136,232,128,151]};
get({64}) ->
     {t_log_type,{64},64,[97,110,115,119,101,114,95,114,101,115,117,114,114,101,99,116,105,111,110],[231,173,148,233,162,152,229,164,141,230,180,187]};
get({65}) ->
     {t_log_type,{65},65,[97,110,115,119,101,114,95,114,101,109,111,118,101,114,95,101,114,114,111,114,115],[231,173,148,233,162,152,229,142,187,233,153,164,233,148,153,232,175,175,231,173,148,230,161,136]};
get({66}) ->
     {t_log_type,{66},66,[97,110,115,119,101,114,95,99,108,101,97,114,105,110,103],[231,173,148,233,162,152,231,187,147,231,174,151,229,165,150,229,138,177]};
get({67}) ->
     {t_log_type,{67},67,[118,105,100,101,111],[232,167,134,233,162,145,229,165,150,229,138,177]};
get({68}) ->
     {t_log_type,{68},68,[114,101,115,111,117,114,99,101,95,103,101,116,95,98,97,107],[232,181,132,230,186,144,230,137,190,229,155,158]};
get({69}) ->
     {t_log_type,{69},69,[122,104,111,117,95,110,105,97,110,95,113,105,110,103,95,97,119,97,114,100],[229,145,168,229,185,180,229,186,134,229,165,150,229,138,177]};
get({70}) ->
     {t_log_type,{70},70,[104,101,95,99,104,97,110,103,95,105,116,101,109],[229,144,136,230,136,144,231,137,169,229,147,129]};
get({71}) ->
     {t_log_type,{71},71,[109,97,110,121,95,112,101,111,112,108,101,95,98,111,115,115],[229,164,154,228,186,186,98,111,115,115]};
get({72}) ->
     {t_log_type,{72},72,[112,97,103,111,100,97,95,115,119,101,101,112],[231,136,172,229,161,148,230,137,171,232,141,161]};
get({74}) ->
     {t_log_type,{74},74,[102,105,103,104,116],[230,136,152,230,150,151]};
get({75}) ->
     {t_log_type,{75},75,[100,97,105,108,121,95,116,97,115,107],[230,175,143,230,151,165,228,187,187,229,138,161]};
get({76}) ->
     {t_log_type,{76},76,[109,105,115,115,105,111,110,95,119,111,114,108,100,95,98,111,115,115],[229,137,175,230,156,172,228,184,150,231,149,140,98,111,115,115]};
get({77}) ->
     {t_log_type,{77},77,[112,114,111,109,111,116,101,95,97,119,97,114,100],[230,142,168,229,185,191,229,165,150,229,138,177]};
get({78}) ->
     {t_log_type,{78},78,[115,104,111,112,95,98,117,121,95,105,116,101,109,95,115,104,111,112],[229,133,145,230,141,162,229,149,134,229,159,142,232,180,173,228,185,176]};
get({79}) ->
     {t_log_type,{79},79,[115,104,111,112,95,98,117,121,95,114,101,115,111,117,114,99,101,95,115,104,111,112],[233,135,145,231,160,150,229,149,134,229,159,142,232,180,173,228,185,176]};
get({80}) ->
     {t_log_type,{80},80,[118,105,112,95,98,117,95,113,105,97,110],[118,105,112,232,161,165,231,173,190]};
get({81}) ->
     {t_log_type,{81},81,[122,104,117,95,120,105,97,110],[228,184,187,231,186,191,229,137,175,230,156,172]};
get({82}) ->
     {t_log_type,{82},82,[112,97,103,111,100,97],[231,136,172,229,161,148]};
get({83}) ->
     {t_log_type,{83},83,[119,111,114,108,100,95,98,111,115,115],[228,184,150,231,149,140,98,111,115,115]};
get({85}) ->
     {t_log_type,{85},85,[103,117,101,115,115,95,98,111,115,115],[231,140,156,228,184,128,231,140,156]};
get({86}) ->
     {t_log_type,{86},86,[115,104,105,115,104,105,95,98,111,115,115],[229,174,158,230,151,182,229,189,169]};
get({87}) ->
     {t_log_type,{87},87,[97,99,116,105,118,105,116,121,95,105,109,112,97,99,116,95,116,97,115,107,95,97,119,97,114,100],[230,180,187,229,138,168,229,134,178,230,166,156,228,187,187,229,138,161,229,165,150,229,138,177]};
get({88}) ->
     {t_log_type,{88},88,[97,99,116,105,118,105,116,121,95,105,109,112,97,99,116,95,114,97,110,107,95,97,119,97,114,100,95,99,108,111,115,101],[230,180,187,229,138,168,229,134,178,230,166,156,230,142,146,229,144,141,229,165,150,229,138,177,231,187,147,231,174,151]};
get({89}) ->
     {t_log_type,{89},89,[109,101,114,103,101],[233,129,147,229,133,183,229,144,136,230,136,144]};
get({90}) ->
     {t_log_type,{90},90,[112,97,103,111,100,97,95,114,97,110,107,95,97,119,97,114,100],[231,136,172,229,161,148,230,142,146,229,144,141,229,165,150,229,138,177]};
get({91}) ->
     {t_log_type,{91},91,[115,104,101,110,95,108,111,110,103],[231,165,158,233,190,153]};
get({92}) ->
     {t_log_type,{92},92,[103,111,111,100,115,95,115,104,111,112,95,116,105,109,101,115],[233,135,145,231,160,150,229,149,134,229,186,151,232,180,173,228,185,176,230,172,161,230,149,176]};
get({93}) ->
     {t_log_type,{93},93,[102,105,114,115,116,95,99,104,97,114,103,101],[233,166,150,229,133,133,229,165,150,229,138,177]};
get({94}) ->
     {t_log_type,{94},94,[98,114,97,118,101,95,111,110,101,95,115,121,115],[229,139,135,230,149,162,232,128,133,239,188,136,49,118,49,239,188,137]};
get({95}) ->
     {t_log_type,{95},95,[115,116,101,112,95,98,121,95,115,116,101,112,95,115,121,115],[230,173,165,230,173,165,231,180,167,233,128,188]};
get({96}) ->
     {t_log_type,{96},96,[116,117,114,110,95,116,97,98,108,101],[232,189,172,231,155,152,230,138,189,229,165,150]};
get({97}) ->
     {t_log_type,{97},97,[109,97,110,121,95,112,101,111,112,108,101,95,115,104,105,115,104,105],[231,187,132,233,152,159,230,151,182,230,151,182,229,189,169]};
get({98}) ->
     {t_log_type,{98},98,[114,101,100,95,112,97,99,107,101,116,95,97,119,97,114,100],[231,186,162,229,140,133,229,165,150,229,138,177]};
get({99}) ->
     {t_log_type,{99},99,[109,105,115,115,105,111,110,95,115,116,101,112,95,98,121,95,115,116,101,112,95,115,121,95,102,105,103,104,116],[230,173,165,230,173,165,231,180,167,233,128,188,229,137,175,230,156,172,230,140,145,230,136,152]};
get({100}) ->
     {t_log_type,{100},100,[105,110,118,101,116,115,95,97,119,97,114,100],[230,138,149,232,181,132,232,174,161,229,136,146,229,165,150,229,138,177]};
get({101}) ->
     {t_log_type,{101},101,[109,105,115,115,105,111,110,95,101,105,116,104,101,114,95,111,114],[228,186,140,233,128,137,228,184,128,231,191,187,229,128,141]};
get({103}) ->
     {t_log_type,{103},103,[100,114,97,119,95,109,111,110,101,121],[229,155,158,230,148,182,230,172,161,230,149,176]};
get({104}) ->
     {t_log_type,{104},104,[104,101,114,111,95,117,112,95,115,116,97,114],[232,139,177,233,155,132,229,141,135,230,152,159]};
get({105}) ->
     {t_log_type,{105},105,[99,97,114,100,95,97,119,97,114,100],[229,141,161,231,137,140,229,155,190,233,137,180,229,165,150,229,138,177]};
get({106}) ->
     {t_log_type,{106},106,[109,105,115,115,105,111,110,95,115,99,101,110,101,95,98,111,115,115,95,108,111,99,97,116,105,111,110],[228,184,150,231,149,140,229,156,186,230,153,175,66,79,83,83,45,228,189,141,231,189,174]};
get({107}) ->
     {t_log_type,{107},107,[109,105,115,115,105,111,110,95,115,99,101,110,101,95,98,111,115,115,95,116,105,109,101,95,97,110,100,95,99,111,117,110,116],[228,184,150,231,149,140,229,156,186,230,153,175,66,79,83,83,45,229,136,128,230,149,176,229,146,140,231,167,146,230,149,176]};
get({108}) ->
     {t_log_type,{108},108,[104,101,114,111,95,117,110,108,111,99,107],[232,139,177,233,155,132,232,167,163,233,148,129]};
get({109}) ->
     {t_log_type,{109},109,[102,117,110,99,116,105,111,110,95,109,111,110,115,116,101,114,95,102,97,110,112,97,105],[229,138,159,232,131,189,230,128,170,231,191,187,231,137,140]};
get({110}) ->
     {t_log_type,{110},110,[102,117,110,99,116,105,111,110,95,109,111,110,115,116,101,114,95,108,97,98,97],[229,138,159,232,131,189,230,128,170,230,139,137,233,156,184]};
get({111}) ->
     {t_log_type,{111},111,[102,117,110,99,116,105,111,110,95,109,111,110,115,116,101,114,95,122,104,117,97,110,112,97,110],[229,138,159,232,131,189,230,128,170,232,189,172,231,155,152]};
get({112}) ->
     {t_log_type,{112},112,[100,117,111,98,97,111,95,115,104,111,112],[229,164,186,229,174,157,229,149,134,229,186,151]};
get({113}) ->
     {t_log_type,{113},113,[115,101,105,122,101,95,116,114,101,97,115,117,114,101],[229,164,186,229,174,157,232,189,172,231,155,152]};
get({114}) ->
     {t_log_type,{114},114,[115,101,105,122,101,95,101,120,116,114,97,95,97,119,97,114,100],[229,164,186,229,174,157,232,189,172,231,155,152,229,165,150,229,138,177]};
get({115}) ->
     {t_log_type,{115},115,[99,97,114,100,95,115,117,109,109,111,110,95,97,119,97,114,100],[229,155,190,233,137,180,229,143,172,229,148,164,229,165,150,229,138,177]};
get({116}) ->
     {t_log_type,{116},116,[105,116,101,109,95,111,112,101,110,95,98,111,120],[229,188,128,229,174,157,231,174,177]};
get({117}) ->
     {t_log_type,{117},117,[102,117,110,99,116,105,111,110,95,109,111,110,115,116,101,114,95,122,104,97,100,97,110],[229,138,159,232,131,189,230,128,170,231,130,184,229,188,185]};
get({118}) ->
     {t_log_type,{118},118,[99,104,97,114,103,101,95,100,105,97,109,111,110,100,95,115,104,111,112],[229,133,133,229,128,188,233,146,187,231,159,179,229,149,134,229,159,142]};
get({119}) ->
     {t_log_type,{119},119,[116,120,122,95,108,101,118,101,108,95,97,119,97,114,100],[233,128,154,232,161,140,232,175,129,229,165,150,229,138,177]};
get({120}) ->
     {t_log_type,{120},120,[116,120,122,95,112,117,114,99,104,97,115,101,95,108,101,118,101,108],[232,180,173,228,185,176,233,128,154,232,161,140,232,175,129,231,173,137,231,186,167]};
get({121}) ->
     {t_log_type,{121},121,[116,120,122,95,112,117,114,99,104,97,115,101,95,117,110,108,111,99,107],[228,187,152,232,180,185,232,167,163,233,148,129,233,146,187,231,159,179,233,128,154,232,161,140,232,175,129]};
get({122}) ->
     {t_log_type,{122},122,[116,120,122,95,116,97,115,107,95,100,97,105,108,121,95,97,119,97,114,100],[233,128,154,232,161,140,232,175,129,230,175,143,230,151,165,228,187,187,229,138,161,229,165,150,229,138,177]};
get({123}) ->
     {t_log_type,{123},123,[116,120,122,95,116,97,115,107,95,109,111,110,116,104,95,97,119,97,114,100],[233,128,154,232,161,140,232,175,129,230,156,136,229,186,166,228,187,187,229,138,161,229,165,150,229,138,177]};
get({124}) ->
     {t_log_type,{124},124,[112,108,97,121,101,114,95,108,101,118,101,108,95,97,119,97,114,100],[231,142,169,229,174,182,229,141,135,231,186,167,229,165,150,229,138,177]};
get({125}) ->
     {t_log_type,{125},125,[106,105,97,110,103,106,105,110,99,104,105,95,114,101,119,97,114,100],[229,165,150,233,135,145,230,177,160,229,165,150,229,138,177]};
get({126}) ->
     {t_log_type,{126},126,[109,105,115,115,105,111,110,95,104,101,114,111,95,112,107,95,98,111,115,115],[232,139,177,233,155,132,80,107,98,111,115,115]};
get({127}) ->
     {t_log_type,{127},127,[108,101,105,99,104,111,110,103,95,114,101,119,97,114,100],[231,180,175,229,133,133,229,165,150,229,138,177]};
get({128}) ->
     {t_log_type,{128},128,[115,107,122,104],[233,129,147,229,133,183,230,151,182,231,169,186,232,189,172,230,141,162]};
get({129}) ->
     {t_log_type,{129},129,[99,104,97,110,103,101,95,110,97,109,101],[230,148,185,229,144,141]};
get({130}) ->
     {t_log_type,{130},130,[109,111,110,101,121,95,116,104,114,101,101],[230,145,135,233,146,177,230,160,145,229,165,150,229,138,177]};
get({131}) ->
     {t_log_type,{131},131,[98,108,105,110,100,95,98,111,120],[231,155,178,231,155,146,230,182,136,232,128,151]};
get({132}) ->
     {t_log_type,{132},132,[109,97,116,99,104,95,115,99,101,110,101],[229,140,185,233,133,141,229,156,186]};
get({133}) ->
     {t_log_type,{133},133,[109,97,116,99,104,95,115,99,101,110,101,95,114,97,110,107],[229,140,185,233,133,141,229,156,186,230,142,146,232,161,140,229,165,150,229,138,177]};
get({134}) ->
     {t_log_type,{134},134,[122,104,105,103,111,117,95,115,104,111,112],[231,155,180,232,180,173,229,149,134,229,186,151]};
get({136}) ->
     {t_log_type,{136},136,[114,101,102,105,108,108,95,99,97,114,100,95,115,104,111,112],[229,133,133,229,128,188,229,141,161,229,133,145,230,141,162,229,149,134,229,159,142]};
get({137}) ->
     {t_log_type,{137},137,[99,111,108,111,114,95,98,97,108,108,95,114,101,119,97,114,100],[229,189,169,231,144,131,229,164,167,229,165,150,229,165,150,229,138,177]};
get({138}) ->
     {t_log_type,{138},138,[102,105,110,105,115,104,95,98,111,117,110,116,121,95,116,97,115,107],[229,174,140,230,136,144,232,181,143,233,135,145,228,187,187,229,138,161,229,165,150,229,138,177]};
get({139}) ->
     {t_log_type,{139},139,[114,101,115,101,116,95,98,111,117,110,116,121,95,116,97,115,107],[233,135,141,231,189,174,232,181,143,233,135,145,228,187,187,229,138,161,230,182,136,232,128,151]};
get({140}) ->
     {t_log_type,{140},140,[98,105,110,100,95,109,111,98,105,108,101],[231,187,145,229,174,154,230,137,139,230,156,186,229,143,183,231,160,129,229,165,150,229,138,177]};
get({141}) ->
     {t_log_type,{141},141,[103,105,102,116,95,109,97,105,108],[232,181,160,231,164,188]};
get({142}) ->
     {t_log_type,{142},142,[108,97,98,97],[229,176,143,230,184,184,230,136,143,230,139,137,233,156,184]};
get({143}) ->
     {t_log_type,{143},143,[111,110,101,95,118,115,95,111,110,101,95,101,118,101,114,121,95,114,97,110,107,95,97,119,97,114,100],[49,118,49,230,175,143,230,151,165,230,142,146,232,161,140,229,165,150,229,138,177]};
get({144}) ->
     {t_log_type,{144},144,[98,105,103,95,119,104,101,101,108],[230,151,160,229,176,189,229,175,185,229,134,179]};
get({145}) ->
     {t_log_type,{145},145,[115,104,97,107,101,95,116,114,101,101],[230,145,135,228,184,150,231,149,140,230,160,145]};
get({999}) ->
     {t_log_type,{999},999,[99,101,115,104,105],[230,181,139,232,175,149,229,156,186,230,153,175]};
get({1000}) ->
     {t_log_type,{1000},1000,[117,112,100,97,116,101,95,118,101,114,115,105,111,110,95,114,101,112,97,105,114,49],[50,48,50,49,48,52,49,52,231,137,136,230,156,172,230,155,180,230,150,176,228,191,174,229,164,141,233,129,147,229,133,183,40,229,133,145,230,141,162,229,136,184,232,189,172,233,147,182,229,184,129,41]};
get(_Id) ->
    null.
