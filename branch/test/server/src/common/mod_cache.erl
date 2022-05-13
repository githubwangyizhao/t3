%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            通用缓存(ets)
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_cache).

-include("ets.hrl").
-include("logger.hrl").
%% API
-export([
    get/1,
    get/2,
    update/2,
    update/3,
    cache_data/3,
    delete/1
]).

%% ----------------------------------
%% @doc 	获取缓存数据
%% @throws 	none
%% @end
%% ----------------------------------
get(Id) ->
    get(Id, null).
get(Id, Default) ->
    case ets:lookup(?ETS_CACHE, Id) of
        [] ->
            Default;
        [R] ->
            #ets_cache{
                expire_time = ExpireTime,
                update_time = UpdateTime,
                data = Data
            } = R,
            if
                ExpireTime == 0 ->
                    Data;
                true ->
                    Now = util_time:timestamp(),
                    if Now >= UpdateTime + ExpireTime ->
                        %% 过期
%%                        ?DEBUG("缓存数据过期:~p", [Id]),
                        Default;
                        true ->
%%                            ?DEBUG("读取缓存数据:~p", [Id]),
                            Data
                    end
            end
    end.

get_dirty(Id) ->
    case ets:lookup(?ETS_CACHE, Id) of
        [] ->
            null;
        [R] ->
            R#ets_cache.data
    end.

%% ----------------------------------
%% @doc 	更新缓存数据
%% @throws 	none
%% @end
%% ----------------------------------
update(Id, Data) ->
    update(Id, Data, 0).
update(Id, Data, ExpireTime) ->
    if ExpireTime == 0 ->
        ets:insert(?ETS_CACHE, #ets_cache{
            id = Id,
            data = Data
        });
        true ->
            %% 有过期时间 ExpireTime 单位(s)
            ets:insert(?ETS_CACHE, #ets_cache{
                id = Id,
                data = Data,
                expire_time = ExpireTime,
                update_time = util_time:timestamp()
            })
    end.


%% @fun 缓存
cache_data(Id, Fun, ExpireTime) ->
    case mod_cache:get(Id) of
        null ->
            try Fun() of
                Data ->
                    mod_cache:update(Id, Data, ExpireTime),
                    Data
            catch
                _:Reason ->
                    ?ERROR("cache_data error:~p", [{Reason, Id, ExpireTime}]),
                    %% 更新缓存失败， 则尝试使用旧的缓存
                    case get_dirty(Id) of
                        null ->
                            null;
                        OldData ->
                            mod_cache:update(Id, OldData, ExpireTime),
                            OldData
                    end
            end;
%%            Data = Fun(),
%%            % 缓存时间 CacheTime (S)
%%            mod_cache:update(CacheKey, Data, CacheTime),
%%            Data;
        Data ->
            Data
    end.

%% ----------------------------------
%% @doc 	删除缓存
%% @throws 	none
%% @end
%% ----------------------------------
delete(Id) ->
    ets:delete(?ETS_CACHE, Id).
