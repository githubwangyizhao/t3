%%% Generated automatically, no need to modify.
-module(t_laba).
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
     [{1001},{1002},{1101},{1102},{2001},{2002},{2101},{2102}].


get({1001}) ->
     {t_laba,{1001},1001,[230,139,137,233,156,184,229,136,157,229,143,183,230,156,186],1,[2,[2000,10000,50000,100000,1000000,20000,50000]],[[1000,9800],[2000,9800],[5000,9800],[10000,9800],[15000,9800],[20000,9800],[50000,9800]],[[2000,2000000],[10000,10000000],[50000,50000000],[100000,100000000],[1000000,1000000000],[20000,20000000],[50000,50000000]],[[3,6],[4,8],[5,10]],0,1,1002,[[1,0],[2,2500],[3,2500],[4,2500],[5,0]],[[1,[250,9750,0]],[2,[100,9900,0]],[3,[5,8000,1995]],[4,[1,7000,2999]],[5,[40,9960,0]]],[[0,2000,[1,1,1,1,2,2,3]],[1,4000,[1,1,1,1,2,2,2,3,3,4]],[2,3000,[1,1,1,2,2,2,2,3,3,4,4]],[3,2000,[2,2,2,2,3,3,3,4,4,5]],[4,1000,[2,2,3,3,3,3,4,4,4,5,5]],[5,1000,[3,3,4,4,4,5,5,5,6,6]],[6,1000,[3,4,4,4,4,5,5,5,6,6,7]],[7,1500,[1,2,3,4,5,6,7,8]],[8,2500,[1,2,3,4,5,6,7,8,9]],[9,3500,[1,2,3,4,5,6,7,8,9]],[10,4000,[1,2,3,4,5,6,7,8,9]],[11,5000,[2,3,4,5,6,7,8,9]],[12,6000,[3,4,5,6,7,8,9]],[13,7000,[4,5,6,7,8,9]],[14,8000,[5,6,7,8,9]],[15,9000,[6,7,8,9]],[16,10000,[7,8,9]]],[[3,8500],[4,1000],[5,500]],[[1,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[2,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[5,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[3,[[[3000000,4000000],30],[[2000000,3500000],10],[[900000,1200000],2960],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[4,[[[3000000,4000000],10],[[2000000,3500000],3],[[900000,1200000],2987],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]]],[[1,6000],[2,5500],[3,5000],[4,5000],[5,5000]],[[0,100000,24],[100001,500000,23],[500001,1000000,25],[1000001,5000000,22],[5000001,0,21]]};
get({1002}) ->
     {t_laba,{1002},1002,[230,139,137,233,156,184,229,136,157,229,143,183,230,156,186,102,114,101,101,103,97,109,101,230,168,161,229,188,143],0,[2,[2000,10000,50000,100000,1000000,20000,50000]],[],[[2000,2000000],[10000,10000000],[50000,50000000],[100000,100000000],[1000000,1000000000],[20000,20000000],[50000,50000000]],[[3,6],[4,8],[5,10]],1002,1,1,[[1,0],[2,10000],[3,10000],[4,10000],[5,0]],[[1,[250,9750,0]],[2,[100,9900,0]],[3,[5,8000,1995]],[4,[1,7000,2999]],[5,[40,9960,0]]],[[0,2000,[1,1,1,1,2,2,3]],[1,4000,[1,1,1,1,2,2,2,3,3,4]],[2,3000,[1,1,1,2,2,2,2,3,3,4,4]],[3,2000,[2,2,2,2,3,3,3,4,4,5]],[4,1000,[2,2,3,3,3,3,4,4,4,5,5]],[5,1000,[3,3,4,4,4,5,5,5,6,6]],[6,1000,[3,4,4,4,4,5,5,5,6,6,7]],[7,1500,[1,2,3,4,5,6,7,8]],[8,2500,[1,2,3,4,5,6,7,8,9]],[9,3500,[1,2,3,4,5,6,7,8,9]],[10,4000,[1,2,3,4,5,6,7,8,9]],[11,5000,[2,3,4,5,6,7,8,9]],[12,6000,[3,4,5,6,7,8,9]],[13,7000,[4,5,6,7,8,9]],[14,8000,[5,6,7,8,9]],[15,9000,[6,7,8,9]],[16,10000,[7,8,9]]],[[3,8500],[4,1000],[5,500]],[[1,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[2,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[5,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[3,[[[3000000,4000000],30],[[2000000,3500000],10],[[900000,1200000],2960],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[4,[[[3000000,4000000],10],[[2000000,3500000],3],[[900000,1200000],2987],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]]],[[1,6000],[2,5500],[3,5000],[4,5000],[5,5000]],[[0,100000,24],[100001,500000,23],[500001,1000000,25],[1000001,5000000,22],[5000001,0,21]]};
get({1101}) ->
     {t_laba,{1101},1101,[230,139,137,233,156,184,232,180,176,229,143,183,230,156,186,232,191,158,231,186,191],1,[2,[2000,10000,50000,100000,1000000,20000,50000]],[[1000,9800],[2000,9800],[5000,9800],[10000,9800],[15000,9800],[20000,9800],[50000,9800]],[[2000,2000000],[10000,10000000],[50000,50000000],[100000,100000000],[1000000,1000000000],[20000,20000000],[50000,50000000]],[[1,5],[2,7],[3,9]],1101,2,1102,[[1,200],[2,300],[3,500],[4,900],[5,1000]],[[1,[750,9500,0]],[2,[500,9750,0]],[3,[20,8000,1995]],[4,[5,7000,2999]],[5,[100,9900,0]]],[[0,800,[1,1,1,1,1,1,1,2,2,2,3]],[1,1500,[1,1,1,1,1,1,1,2,2,2,2,2,3,3,4]],[2,1000,[1,1,1,1,1,1,2,2,2,2,2,2,3,3,4,4]],[3,800,[1,1,1,1,2,2,2,2,2,3,3,3,4,4,5]],[4,500,[1,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5]],[5,500,[1,1,1,1,2,3,3,4,4,4,5,5,5,6,6]],[6,500,[1,1,1,1,2,3,4,4,4,4,5,5,5,6,6,7]],[7,800,[1,1,1,1,2,2,3,4,5,6,7,8]],[8,1500,[1,1,1,1,2,2,3,4,5,6,7,8]],[9,2500,[1,1,1,1,2,2,3,4,5,6,7,8]],[10,3000,[1,1,1,1,2,2,3,4,5,6,7,8]],[11,3500,[1,1,1,1,2,2,3,4,5,6,7,8]],[12,4000,[1,1,1,1,2,3,4,5,6,7,8]],[13,5000,[1,1,1,2,3,4,5,6,7,8]],[14,7000,[1,1,1,2,3,4,5,6,7,8]],[15,9000,[1,1,1,2,3,4,5,6,7,8]],[16,10000,[1,1,1,2,3,4,5,6,7,8]]],[[3,9400],[4,500],[5,100]],[[1,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[2,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[5,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[3,[[[2500000,4000000],5],[[1000000,2500000],10],[[800000,1000000],50],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4435],[[100000,200000],3000]]],[4,[[[2500000,4000000],5],[[1000000,2500000],5],[[800000,1000000],25],[[600000,800000],250],[[300000,600000],1500],[[200000,300000],4435],[[100000,200000],3780]]]],[[1,9000],[2,8500],[3,7000],[4,6000],[5,8000]],[[0,50000,34],[50001,150000,33],[150001,300000,35],[300001,500000,32],[500001,0,31]]};
get({1102}) ->
     {t_laba,{1102},1102,[230,139,137,233,156,184,232,180,176,229,143,183,230,156,186,232,191,158,231,186,191,102,114,101,101,103,97,109,101,230,168,161,229,188,143],0,[2,[2000,10000,50000,100000,1000000,20000,50000]],[],[[2000,2000000],[10000,10000000],[50000,50000000],[100000,100000000],[1000000,1000000000],[20000,20000000],[50000,50000000]],[[1,5],[2,7],[3,9]],1101,2,1,[[1,200],[2,300],[3,500],[4,900],[5,1000]],[[1,[750,9500,0]],[2,[500,9750,0]],[3,[20,8000,1995]],[4,[5,7000,2999]],[5,[100,9900,0]]],[[0,800,[1,1,1,1,1,1,1,2,2,2,3]],[1,1500,[1,1,1,1,1,1,1,2,2,2,2,2,3,3,4]],[2,1000,[1,1,1,1,1,1,2,2,2,2,2,2,3,3,4,4]],[3,800,[1,1,1,1,2,2,2,2,2,3,3,3,4,4,5]],[4,500,[1,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5]],[5,500,[1,1,1,1,2,3,3,4,4,4,5,5,5,6,6]],[6,500,[1,1,1,1,2,3,4,4,4,4,5,5,5,6,6,7]],[7,800,[1,1,1,1,2,2,3,4,5,6,7,8]],[8,1500,[1,1,1,1,2,2,3,4,5,6,7,8]],[9,2500,[1,1,1,1,2,2,3,4,5,6,7,8]],[10,3000,[1,1,1,1,2,2,3,4,5,6,7,8]],[11,3500,[1,1,1,1,2,2,3,4,5,6,7,8]],[12,4000,[1,1,1,1,2,3,4,5,6,7,8]],[13,5000,[1,1,1,2,3,4,5,6,7,8]],[14,7000,[1,1,1,2,3,4,5,6,7,8]],[15,9000,[1,1,1,2,3,4,5,6,7,8]],[16,10000,[1,1,1,2,3,4,5,6,7,8]]],[[3,9400],[4,500],[5,100]],[[1,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[2,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[5,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[3,[[[2500000,4000000],5],[[1000000,2500000],10],[[800000,1000000],50],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4435],[[100000,200000],3000]]],[4,[[[2500000,4000000],5],[[1000000,2500000],5],[[800000,1000000],25],[[600000,800000],250],[[300000,600000],1500],[[200000,300000],4435],[[100000,200000],3780]]]],[[1,9000],[2,8500],[3,7000],[4,6000],[5,8000]],[[0,50000,34],[50001,150000,33],[150001,300000,35],[300001,500000,32],[500001,0,31]]};
get({2001}) ->
     {t_laba,{2001},2001,[231,186,162,229,174,157,231,159,179,230,139,137,233,156,184,229,136,157,229,143,183,230,156,186],1,[52,[100,200,500,1000,1500,2000,5000]],[[100,9800],[200,9800],[500,9800],[1000,9800],[1500,9800],[2000,9800],[5000,9800]],[[100,100000],[200,200000],[500,500000],[1000,1000000],[1500,1500000],[2000,2000000],[5000,5000000]],[[3,6],[4,8],[5,10]],0,1,2002,[[1,0],[2,2500],[3,2500],[4,2500],[5,0]],[[1,[250,9750,0]],[2,[100,9900,0]],[3,[5,8000,1995]],[4,[1,7000,2999]],[5,[40,9960,0]]],[[0,2000,[1,1,1,1,2,2,3]],[1,4000,[1,1,1,1,2,2,2,3,3,4]],[2,3000,[1,1,1,2,2,2,2,3,3,4,4]],[3,2000,[2,2,2,2,3,3,3,4,4,5]],[4,1000,[2,2,3,3,3,3,4,4,4,5,5]],[5,1000,[3,3,4,4,4,5,5,5,6,6]],[6,1000,[3,4,4,4,4,5,5,5,6,6,7]],[7,1500,[1,2,3,4,5,6,7,8]],[8,2500,[1,2,3,4,5,6,7,8,9]],[9,3500,[1,2,3,4,5,6,7,8,9]],[10,4000,[1,2,3,4,5,6,7,8,9]],[11,5000,[2,3,4,5,6,7,8,9]],[12,6000,[3,4,5,6,7,8,9]],[13,7000,[4,5,6,7,8,9]],[14,8000,[5,6,7,8,9]],[15,9000,[6,7,8,9]],[16,10000,[7,8,9]]],[[3,8500],[4,1000],[5,500]],[[1,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[2,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[5,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[3,[[[3000000,4000000],30],[[2000000,3500000],10],[[900000,1200000],2960],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[4,[[[3000000,4000000],10],[[2000000,3500000],3],[[900000,1200000],2987],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]]],[[1,6000],[2,5500],[3,5000],[4,5000],[5,5000]],[[0,100000,24],[100001,500000,23],[500001,1000000,25],[1000001,5000000,22],[5000001,0,21]]};
get({2002}) ->
     {t_laba,{2002},2002,[231,186,162,229,174,157,231,159,179,230,139,137,233,156,184,229,136,157,229,143,183,230,156,186,102,114,101,101,103,97,109,101,230,168,161,229,188,143],0,[52,[100,200,500,1000,1500,2000,5000]],[],[[100,100000],[200,200000],[500,500000],[1000,1000000],[1500,1500000],[2000,2000000],[5000,5000000]],[[3,6],[4,8],[5,10]],1002,1,1,[[1,0],[2,10000],[3,10000],[4,10000],[5,0]],[[1,[250,9750,0]],[2,[100,9900,0]],[3,[5,8000,1995]],[4,[1,7000,2999]],[5,[40,9960,0]]],[[0,2000,[1,1,1,1,2,2,3]],[1,4000,[1,1,1,1,2,2,2,3,3,4]],[2,3000,[1,1,1,2,2,2,2,3,3,4,4]],[3,2000,[2,2,2,2,3,3,3,4,4,5]],[4,1000,[2,2,3,3,3,3,4,4,4,5,5]],[5,1000,[3,3,4,4,4,5,5,5,6,6]],[6,1000,[3,4,4,4,4,5,5,5,6,6,7]],[7,1500,[1,2,3,4,5,6,7,8]],[8,2500,[1,2,3,4,5,6,7,8,9]],[9,3500,[1,2,3,4,5,6,7,8,9]],[10,4000,[1,2,3,4,5,6,7,8,9]],[11,5000,[2,3,4,5,6,7,8,9]],[12,6000,[3,4,5,6,7,8,9]],[13,7000,[4,5,6,7,8,9]],[14,8000,[5,6,7,8,9]],[15,9000,[6,7,8,9]],[16,10000,[7,8,9]]],[[3,8500],[4,1000],[5,500]],[[1,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[2,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[5,[[[3000000,4000000],100],[[2000000,3500000],50],[[900000,1200000],2850],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[3,[[[3000000,4000000],30],[[2000000,3500000],10],[[900000,1200000],2960],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]],[4,[[[3000000,4000000],10],[[2000000,3500000],3],[[900000,1200000],2987],[[800000,1000000],2000],[[70000,900000],4000],[[500000,800000],500],[[500000,700000],500]]]],[[1,6000],[2,5500],[3,5000],[4,5000],[5,5000]],[[0,100000,24],[100001,500000,23],[500001,1000000,25],[1000001,5000000,22],[5000001,0,21]]};
get({2101}) ->
     {t_laba,{2101},2101,[230,139,137,233,156,184,232,180,176,229,143,183,230,156,186,232,191,158,231,186,191],1,[52,[100,200,500,1000,1500,2000,5000]],[[100,9800],[200,9800],[500,9800],[1000,9800],[1500,9800],[2000,9800],[5000,9800]],[[100,100000],[200,200000],[500,500000],[1000,1000000],[1500,1500000],[2000,2000000],[5000,5000000]],[[1,5],[2,7],[3,9]],1101,2,2102,[[1,200],[2,300],[3,500],[4,900],[5,1000]],[[1,[750,9500,0]],[2,[500,9750,0]],[3,[20,8000,1995]],[4,[5,7000,2999]],[5,[100,9900,0]]],[[0,800,[1,1,1,1,1,1,1,2,2,2,3]],[1,1500,[1,1,1,1,1,1,1,2,2,2,2,2,3,3,4]],[2,1000,[1,1,1,1,1,1,2,2,2,2,2,2,3,3,4,4]],[3,800,[1,1,1,1,2,2,2,2,2,3,3,3,4,4,5]],[4,500,[1,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5]],[5,500,[1,1,1,1,2,3,3,4,4,4,5,5,5,6,6]],[6,500,[1,1,1,1,2,3,4,4,4,4,5,5,5,6,6,7]],[7,800,[1,1,1,1,2,2,3,4,5,6,7,8]],[8,1500,[1,1,1,1,2,2,3,4,5,6,7,8]],[9,2500,[1,1,1,1,2,2,3,4,5,6,7,8]],[10,3000,[1,1,1,1,2,2,3,4,5,6,7,8]],[11,3500,[1,1,1,1,2,2,3,4,5,6,7,8]],[12,4000,[1,1,1,1,2,3,4,5,6,7,8]],[13,5000,[1,1,1,2,3,4,5,6,7,8]],[14,7000,[1,1,1,2,3,4,5,6,7,8]],[15,9000,[1,1,1,2,3,4,5,6,7,8]],[16,10000,[1,1,1,2,3,4,5,6,7,8]]],[[3,9400],[4,500],[5,100]],[[1,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[2,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[5,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[3,[[[2500000,4000000],5],[[1000000,2500000],10],[[800000,1000000],50],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4435],[[100000,200000],3000]]],[4,[[[2500000,4000000],5],[[1000000,2500000],5],[[800000,1000000],25],[[600000,800000],250],[[300000,600000],1500],[[200000,300000],4435],[[100000,200000],3780]]]],[[1,9000],[2,8500],[3,7000],[4,6000],[5,8000]],[[0,50000,34],[50001,150000,33],[150001,300000,35],[300001,500000,32],[500001,0,31]]};
get({2102}) ->
     {t_laba,{2102},2102,[230,139,137,233,156,184,232,180,176,229,143,183,230,156,186,232,191,158,231,186,191,102,114,101,101,103,97,109,101,230,168,161,229,188,143],0,[52,[100,200,500,1000,1500,2000,5000]],[],[[100,100000],[200,200000],[500,500000],[1000,1000000],[1500,1500000],[2000,2000000],[5000,5000000]],[[1,5],[2,7],[3,9]],1101,2,1,[[1,200],[2,300],[3,500],[4,900],[5,1000]],[[1,[750,9500,0]],[2,[500,9750,0]],[3,[20,8000,1995]],[4,[5,7000,2999]],[5,[100,9900,0]]],[[0,800,[1,1,1,1,1,1,1,2,2,2,3]],[1,1500,[1,1,1,1,1,1,1,2,2,2,2,2,3,3,4]],[2,1000,[1,1,1,1,1,1,2,2,2,2,2,2,3,3,4,4]],[3,800,[1,1,1,1,2,2,2,2,2,3,3,3,4,4,5]],[4,500,[1,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5]],[5,500,[1,1,1,1,2,3,3,4,4,4,5,5,5,6,6]],[6,500,[1,1,1,1,2,3,4,4,4,4,5,5,5,6,6,7]],[7,800,[1,1,1,1,2,2,3,4,5,6,7,8]],[8,1500,[1,1,1,1,2,2,3,4,5,6,7,8]],[9,2500,[1,1,1,1,2,2,3,4,5,6,7,8]],[10,3000,[1,1,1,1,2,2,3,4,5,6,7,8]],[11,3500,[1,1,1,1,2,2,3,4,5,6,7,8]],[12,4000,[1,1,1,1,2,3,4,5,6,7,8]],[13,5000,[1,1,1,2,3,4,5,6,7,8]],[14,7000,[1,1,1,2,3,4,5,6,7,8]],[15,9000,[1,1,1,2,3,4,5,6,7,8]],[16,10000,[1,1,1,2,3,4,5,6,7,8]]],[[3,9400],[4,500],[5,100]],[[1,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[2,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[5,[[[2500000,4000000],50],[[1000000,2500000],50],[[800000,1000000],250],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4000],[[100000,200000],2000]]],[3,[[[2500000,4000000],5],[[1000000,2500000],10],[[800000,1000000],50],[[600000,800000],500],[[300000,600000],2000],[[200000,300000],4435],[[100000,200000],3000]]],[4,[[[2500000,4000000],5],[[1000000,2500000],5],[[800000,1000000],25],[[600000,800000],250],[[300000,600000],1500],[[200000,300000],4435],[[100000,200000],3780]]]],[[1,9000],[2,8500],[3,7000],[4,6000],[5,8000]],[[0,50000,34],[50001,150000,33],[150001,300000,35],[300001,500000,32],[500001,0,31]]};
get(_Id) ->
    null.
