%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2021 17:50
%%%-------------------------------------------------------------------
-author("yizhao.wang").

% -----------------------------------------------------------------
% begin 仅供Mod模块调用
% -----------------------------------------------------------------
-define(getModTempPropList(),
	((fun() ->
		[_Module_@@@ | FiledDataList_@@@] = tuple_to_list(#?MODULE{}),
		lists:zip(record_info(fields, ?MODULE), FiledDataList_@@@)
	  end)())).

-define(getModTempDefault(Key),
	((fun() ->
		case Key of
			{_Key_@@@, _} ->
				proplists:get_value(util:to_atom(_Key_@@@), ?getModTempPropList());
			_ ->
				proplists:get_value(util:to_atom(Key), ?getModTempPropList())
		end
	end)())).

-define(getModDict(K), util:get_mod_dict(?MODULE, K, ?getModTempDefault(K))).                  %% 获取字典指定key
-define(setModDict(K, V), util:set_mod_dict(?MODULE, K, V)).     	   						   %% 设置字典指定key
-define(incrModDict(K), ?incrModDict(K, 1)).                                                   %% 累加字典指定key
-define(incrModDict(K, N), util:incr_mod_dict(?MODULE, K, N, ?getModTempDefault(K))).
-define(eraseModDict(K), util:erase_mod_dict(?MODULE, K)).									   %% 清除字典指定key
% -----------------------------------------------------------------
% end 仅供Mod模块调用
% -----------------------------------------------------------------