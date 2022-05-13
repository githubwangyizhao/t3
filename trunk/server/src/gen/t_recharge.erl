%%% Generated automatically, no need to modify.
-module(t_recharge).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{10},{21},{22},{31},{32},{41},{51},{100},{101},{201},{202},{990},{1000},{2000},{3000},{4000},{5000},{6000},{7000},{8000},{9000},{10011},{10012},{10021},{10031},{40100},{40121},{40122},{40211},{40221},{40231},{40241},{99999},{100001},{100201},{400001},{400011},{400021},{400031},{400041},{400051},{400061},{400071}].


get({1}) ->
     {t_recharge,{1},1,[48,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,48,49],1,1,203,[],[],[229,133,133,229,128,188,48,46,57,57,231,190,142,229,133,131],0.99,0,0,70,99,[],[],0,0,1,1,0,[]};
get({2}) ->
     {t_recharge,{2},2,[49,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,49,49],2,1,204,[],[],[229,133,133,229,128,188,49,46,57,57,231,190,142,229,133,131],1.99,0,0,140,199,[],[],0,0,1,2,0,[]};
get({3}) ->
     {t_recharge,{3},3,[50,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,50,49],3,1,205,[],[],[229,133,133,229,128,188,50,46,57,57,231,190,142,229,133,131],2.99,0,0,210,299,[],[],0,0,1,3,0,[]};
get({4}) ->
     {t_recharge,{4},4,[55,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,51,49],4,1,206,[],[],[229,133,133,229,128,188,55,46,57,57,231,190,142,229,133,131],7.99,0,0,560,799,[],[],0,0,1,4,0,[]};
get({5}) ->
     {t_recharge,{5},5,[49,49,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,52,49],5,1,207,[],[],[229,133,133,229,128,188,49,49,46,57,57,231,190,142,229,133,131],11.99,0,0,840,1199,[],[],0,0,1,5,0,[]};
get({6}) ->
     {t_recharge,{6},6,[49,57,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,53,49],6,1,208,[],[],[229,133,133,229,128,188,49,57,46,57,57,231,190,142,229,133,131],19.99,0,0,1400,1999,[],[],0,0,1,6,0,[]};
get({7}) ->
     {t_recharge,{7},7,[50,57,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,54,49],7,1,209,[],[],[229,133,133,229,128,188,50,57,46,57,57,231,190,142,229,133,131],29.99,0,0,2100,2999,[],[],0,0,1,7,0,[]};
get({8}) ->
     {t_recharge,{8},8,[49,53,57,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,50,48,48,48,55,49],9,1,210,[],[],[229,133,133,229,128,188,49,53,57,46,57,57,231,190,142,229,133,131],159.99,0,0,11200,15999,[],[],0,0,1,7,0,[]};
get({10}) ->
     {t_recharge,{10},10,[233,166,150,229,133,133,51,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,102,105,114,115,116,95,50,48,49,48,48],100,1,202,[],[],[233,166,150,229,133,133,51,46,57,57,231,190,142,229,133,131],3.99,0,0,0,399,[],[],0,1,1,1,0,[]};
get({21}) ->
     {t_recharge,{21},21,[233,166,150,229,133,133,48,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,102,105,114,115,116,95,50,49],100,1,211,[],[],[233,166,150,229,133,133,48,46,57,57,231,190,142,229,133,131],0.99,0,0,0,99,[],[],0,1,1,1,0,[]};
get({22}) ->
     {t_recharge,{22},22,[233,166,150,229,133,133,55,46,57,57,231,190,142,229,133,131],[103,111,111,103,108,101,95,102,105,114,115,116,95,50,50],100,1,212,[],[],[233,166,150,229,133,133,55,46,57,57,231,190,142,229,133,131],7.99,0,0,0,799,[],[],0,1,1,1,0,[]};
get({31}) ->
     {t_recharge,{31},31,[231,155,180,229,141,135,50,48,231,186,167],[103,111,111,103,108,101,95,51,49],0,1,0,[],[],[231,155,180,229,141,135,50,48,231,186,167],1.99,19.99,0,0,199,[[2,500000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({32}) ->
     {t_recharge,{32},32,[231,155,180,229,141,135,52,48,231,186,167],[103,111,111,103,108,101,95,51,50],0,1,0,[],[],[231,155,180,229,141,135,52,48,231,186,167],9.99,99.99,0,0,999,[[2,1000000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({41}) ->
     {t_recharge,{41},41,[233,135,145,229,184,129,231,155,180,232,180,173],[103,111,111,103,108,101,95,52,49],0,1,0,[],[],[233,135,145,229,184,129,231,155,180,232,180,173],8.99,89.99,0,0,899,[],[],0,2,1,1,0,[]};
get({51}) ->
     {t_recharge,{51},51,[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],[103,111,111,103,108,101,95,53,49],0,1,0,[],[],[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],1.99,19.99,0,0,199,[],[],0,2,1,1,0,[]};
get({100}) ->
     {t_recharge,{100},100,[233,166,150,229,133,133,52,231,190,142,229,133,131],[102,105,114,115,116,95,99,104,97,114,103,101,95,49,48,48],100,0,111,[],[],[233,166,150,229,133,133,52,231,190,142,229,133,131],4,0,0,0,400,[],[],0,1,1,1,0,[]};
get({101}) ->
     {t_recharge,{101},101,[230,138,149,232,181,132,232,174,161,229,136,146],[103,111,111,103,108,101,95,116,111,117,95,122,105,95,106,105,95,104,117,97],0,1,201,[],[],[231,153,187,233,153,134,230,138,149,232,181,132,232,174,161,229,136,146],23.99,0,0,0,2399,[],[],0,3,1,1,0,[]};
get({201}) ->
     {t_recharge,{201},201,[233,166,150,229,133,133,52,231,190,142,229,133,131],[102,105,114,115,116,95,99,104,97,114,103,101,95,50,48,49],100,0,0,[],[],[233,166,150,229,133,133,52,231,190,142,229,133,131],4,0,0,0,400,[],[],0,1,1,1,0,[]};
get({202}) ->
     {t_recharge,{202},202,[233,166,150,229,133,133,56,231,190,142,229,133,131],[102,105,114,115,116,95,99,104,97,114,103,101,95,50,48,50],100,0,0,[],[],[233,166,150,229,133,133,56,231,190,142,229,133,131],8,0,0,0,800,[],[],0,1,1,1,0,[]};
get({990}) ->
     {t_recharge,{990},990,[50,231,190,142,229,133,131],[99,104,97,114,103,101,95,57,57,48],1,0,101,[],[],[229,133,133,229,128,188,50,231,190,142,229,133,131],2,0,0,200,200,[],[],0,0,1,1,0,[]};
get({1000}) ->
     {t_recharge,{1000},1000,[56,231,190,142,229,133,131],[99,104,97,114,103,101,95,49,48,48,48],2,0,102,[],[],[229,133,133,229,128,188,56,231,190,142,229,133,131],8,0,0,800,800,[],[],0,0,1,2,0,[]};
get({2000}) ->
     {t_recharge,{2000},2000,[51,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,50,48,48,48],3,0,103,[],[],[229,133,133,229,128,188,51,48,231,190,142,229,133,131],30,0,0,3000,3000,[],[],0,0,1,3,0,[]};
get({3000}) ->
     {t_recharge,{3000},3000,[49,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,51,48,48,48],4,0,104,[],[],[229,133,133,229,128,188,49,48,48,231,190,142,229,133,131],100,0,0,10000,10000,[],[],0,0,1,4,0,[]};
get({4000}) ->
     {t_recharge,{4000},4000,[51,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,52,48,48,48],5,0,105,[],[],[229,133,133,229,128,188,51,48,48,231,190,142,229,133,131],300,0,0,30000,30000,[],[],0,0,1,5,0,[]};
get({5000}) ->
     {t_recharge,{5000},5000,[53,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,53,48,48,48],6,0,106,[],[],[229,133,133,229,128,188,53,48,48,231,190,142,229,133,131],500,0,0,50000,50000,[],[],0,0,1,6,0,[]};
get({6000}) ->
     {t_recharge,{6000},6000,[56,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,54,48,48,48],7,0,107,[],[twd],[229,133,133,229,128,188,56,48,48,231,190,142,229,133,131],800,0,0,80000,80000,[],[],0,0,1,7,0,[]};
get({7000}) ->
     {t_recharge,{7000},7000,[50,48,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,55,48,48,48],8,0,108,[],[twd],[229,133,133,229,128,188,50,48,48,48,231,190,142,229,133,131],2000,0,0,200000,200000,[],[],0,0,1,8,0,[]};
get({8000}) ->
     {t_recharge,{8000},8000,[51,48,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,56,48,48,48],9,0,109,[indonesia,local],[twd],[229,133,133,229,128,188,51,48,48,48,231,190,142,229,133,131],3000,0,0,300000,300000,[],[],0,0,1,9,0,[]};
get({9000}) ->
     {t_recharge,{9000},9000,[53,48,48,48,231,190,142,229,133,131],[99,104,97,114,103,101,95,57,48,48,48],10,0,110,[],[indonesia,twd],[229,133,133,229,128,188,53,48,48,48,231,190,142,229,133,131],5000,0,0,500000,500000,[],[],0,0,1,9,0,[]};
get({10011}) ->
     {t_recharge,{10011},10011,[231,155,180,229,141,135,50,48,231,186,167],[99,104,97,114,103,101,95,49,48,48,49,49],0,0,0,[],[],[231,155,180,229,141,135,50,48,231,186,167],4,20,0,0,400,[[2,500000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({10012}) ->
     {t_recharge,{10012},10012,[231,155,180,229,141,135,52,48,231,186,167],[99,104,97,114,103,101,95,49,48,48,49,50],0,0,0,[],[],[231,155,180,229,141,135,52,48,231,186,167],10,50,0,0,1000,[[2,1000000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({10021}) ->
     {t_recharge,{10021},10021,[233,135,145,229,184,129,231,155,180,232,180,173],[99,104,97,114,103,101,95,49,48,48,50,49],0,0,0,[],[],[233,135,145,229,184,129,231,155,180,232,180,173],10,50,0,0,1000,[],[],0,2,1,1,0,[]};
get({10031}) ->
     {t_recharge,{10031},10031,[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],[99,104,97,114,103,101,95,49,48,48,51,49],0,0,0,[],[],[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],4,20,0,0,400,[],[],0,2,1,1,0,[]};
get({40100}) ->
     {t_recharge,{40100},40100,[233,166,150,229,133,133,51,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,102,105,114,115,116,95,51,48,49,48,48],100,2,302,[],[],[233,166,150,229,133,133,51,46,57,57,231,190,142,229,133,131],3.99,0,0,0,399,[],[],0,1,1,1,0,[]};
get({40121}) ->
     {t_recharge,{40121},40121,[233,166,150,229,133,133,48,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,102,105,114,115,116,95,52,48,49,50,49],100,2,211,[],[],[233,166,150,229,133,133,48,46,57,57,231,190,142,229,133,131],0.99,0,0,0,99,[],[],0,1,1,1,0,[]};
get({40122}) ->
     {t_recharge,{40122},40122,[233,166,150,229,133,133,55,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,102,105,114,115,116,95,52,48,49,50,50],100,2,212,[],[],[233,166,150,229,133,133,55,46,57,57,231,190,142,229,133,131],7.99,0,0,0,799,[],[],0,1,1,1,0,[]};
get({40211}) ->
     {t_recharge,{40211},40211,[231,155,180,229,141,135,50,48,231,186,167],[97,112,112,108,101,95,52,48,50,49,49],0,2,0,[],[],[231,155,180,229,141,135,50,48,231,186,167],1.99,19.99,0,0,199,[[2,500000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({40221}) ->
     {t_recharge,{40221},40221,[231,155,180,229,141,135,52,48,231,186,167],[97,112,112,108,101,95,52,48,50,50,49],0,2,0,[],[],[231,155,180,229,141,135,52,48,231,186,167],9.99,99.99,0,0,999,[[2,1000000],[201,100],[202,100]],[],0,5,1,1,0,[]};
get({40231}) ->
     {t_recharge,{40231},40231,[233,135,145,229,184,129,231,155,180,232,180,173],[97,112,112,108,101,95,52,48,50,51,49],0,2,0,[],[],[233,135,145,229,184,129,231,155,180,232,180,173],8.99,89.99,0,0,899,[],[],0,2,1,1,0,[]};
get({40241}) ->
     {t_recharge,{40241},40241,[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],[97,112,112,108,101,95,52,48,51,52,49],0,2,0,[],[],[230,138,128,232,131,189,228,185,166,231,155,180,232,180,173],1.99,19.99,0,0,199,[],[],0,2,1,1,0,[]};
get({99999}) ->
     {t_recharge,{99999},99999,[230,181,139,232,175,149],[116,101,115,116,95,99,104,97,114,103,101],0,0,0,[],[],[230,181,139,232,175,149,229,133,133,229,128,188],0.1,0,0,10,10,[],[],0,0,0,0,0,[]};
get({100001}) ->
     {t_recharge,{100001},100001,[230,138,149,232,181,132,232,174,161,229,136,146],[116,111,117,95,122,105,95,106,105,95,104,117,97],0,0,112,[],[],[231,153,187,233,153,134,230,138,149,232,181,132,232,174,161,229,136,146],24,0,0,0,2400,[],[],0,3,1,1,0,[]};
get({100201}) ->
     {t_recharge,{100201},100201,[230,138,149,232,181,132,232,174,161,229,136,146],[97,112,112,108,101,95,116,111,117,95,122,105,95,106,105,95,104,117,97],0,2,301,[],[],[231,153,187,233,153,134,230,138,149,232,181,132,232,174,161,229,136,146],23.99,0,0,0,2399,[],[],0,0,1,1,0,[]};
get({400001}) ->
     {t_recharge,{400001},400001,[48,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,48,49],1,2,303,[],[],[229,133,133,229,128,188,48,46,57,57,231,190,142,229,133,131],0.99,0,0,70,99,[],[],0,0,1,1,0,[]};
get({400011}) ->
     {t_recharge,{400011},400011,[49,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,49,49],2,2,304,[],[],[229,133,133,229,128,188,49,46,57,57,231,190,142,229,133,131],1.99,0,0,140,199,[],[],0,0,1,2,0,[]};
get({400021}) ->
     {t_recharge,{400021},400021,[50,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,50,49],3,2,305,[],[],[229,133,133,229,128,188,50,46,57,57,231,190,142,229,133,131],2.99,0,0,210,299,[],[],0,0,1,3,0,[]};
get({400031}) ->
     {t_recharge,{400031},400031,[55,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,51,49],4,2,306,[],[],[229,133,133,229,128,188,55,46,57,57,231,190,142,229,133,131],7.99,0,0,560,799,[],[],0,0,1,4,0,[]};
get({400041}) ->
     {t_recharge,{400041},400041,[49,49,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,52,49],5,2,307,[],[],[229,133,133,229,128,188,49,49,46,57,57,231,190,142,229,133,131],11.99,0,0,840,1199,[],[],0,0,1,5,0,[]};
get({400051}) ->
     {t_recharge,{400051},400051,[49,57,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,53,49],6,2,308,[],[],[229,133,133,229,128,188,49,57,46,57,57,231,190,142,229,133,131],19.99,0,0,1400,1999,[],[],0,0,1,6,0,[]};
get({400061}) ->
     {t_recharge,{400061},400061,[50,57,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,54,49],7,2,309,[],[],[229,133,133,229,128,188,50,57,46,57,57,231,190,142,229,133,131],29.99,0,0,2100,2999,[],[],0,0,1,7,0,[]};
get({400071}) ->
     {t_recharge,{400071},400071,[49,53,57,46,57,57,231,190,142,229,133,131],[97,112,112,108,101,95,51,48,48,48,55,49],9,2,310,[],[],[229,133,133,229,128,188,49,53,57,46,57,57,231,190,142,229,133,131],159.99,0,0,11200,15999,[],[],0,0,1,7,0,[]};
get(_Id) ->
    null.
