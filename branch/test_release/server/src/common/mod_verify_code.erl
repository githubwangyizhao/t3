%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 10月 2021 下午 03:26:09
%%%-------------------------------------------------------------------
-module(mod_verify_code).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("p_message.hrl").

-define(INVALID_OPERATION_LIST, [1,2]).
-define(EXPIRE, 10).
-define(CODE_LENGTH, 6).
%% 下次获取验证码的间隔时间 单位s
-define(NEXT_CLICK_TICK, 60).
-define(SMS_API_HOST(Env),
    case Env of
%%        "develop" -> "http://192.168.31.100:8100";
        "develop" -> "https://pay.daggerofbonuses.com";
        "testing" -> "https://pay.daggerofbonuses.com";
        "testing_oversea" -> "https://pay.daggerofbonuses.com";
        _ -> "https://pay.daggerofbonuses.com"
    end
).
-define(SMS_API_PATH(Env),
    case Env of
        "develop" -> "/sms/send";
        "testing" -> "/sms/send";
        "testing_oversea" -> "/sms/send";
        _ -> "/sms/send"
    end
).
-define(ALLOWED_OPERATION_LIST, [bind_mobile, presentation]).

%% API
-export([
    gen_sms_code/3,
    verify_code/3,
    get_code/2,
    get_mobile_from_center/1,
    call_sms_api/4,
    notice_sms_info/1
]).

notice_sms_info(Mobile) ->
    ReturnCode = ?IF(env:get(env, "production") =:= "develop", true, false),
    Now = util_time:timestamp(),
    SmsCodeList =
        lists:foldl(
            fun(Operation) ->
                CodeKey = {?MODULE, Mobile, Operation},
                case mod_cache:get(CodeKey) of
                    Code ->
                        ExpireKey = {?MODULE, Mobile, Operation, times},
                        Expire =
                            case ets:lookup(?ETS_CACHE, ExpireKey) of
                                [Limitation] when is_record(Limitation, ets_cache) ->
                                    Left = Now - Limitation#ets_cache.update_time - Limitation#ets_cache.expire_time,
                                    ?IF(Left > 0, Left, 0);
                                null -> 0
                            end,
                        SmsCodeInfo = #smscodeinfo{mobile = Mobile, type = Operation, expire = Expire},
                        ?IF(ReturnCode =:= true, SmsCodeInfo#smscodeinfo{code = Code}, SmsCodeInfo);
                    null ->
                        #smscodeinfo{mobile = Mobile, type = Operation, expire = 0}
                end
            end,
            [],
            ?ALLOWED_OPERATION_LIST
        ),
    ?DEBUG("SmsCodeList: ~p", [SmsCodeList]),
    Out = #m_verify_code_get_my_sms_code_toc{sms_code_info = SmsCodeList},
    ?DEBUG("notice_sms_info: ~p", [Out]),
    ok.

%% ----------------------------------
%% @doc 	生成验证码
%% @throws 	none
%% @end
%% ----------------------------------
gen_sms_code(PlayerId, Mobile1, Operation) when is_integer(Operation) ->
    ?ASSERT(lists:member(Operation, ?INVALID_OPERATION_LIST) =:= true, invalid_operation),
    case Operation of
        1 ->
            gen_sms_code(PlayerId, Mobile1, bind_mobile);
        2 ->
            gen_sms_code(PlayerId, "", presentation);
        O ->
            ?ERROR("invalid operation: ~p", [O]),
            exit(invalid_operation)
    end;
gen_sms_code(PlayerId, Mobile, Operation) when Operation =:= bind_mobile ->
    ?INFO("玩家(~p)绑定手机号~p获取短信验证码", [PlayerId, Mobile]),
    {AreaCode, PureMobile} = chk_mobile(Mobile),
    CodeKeyMobile = util:to_int(util:to_list(AreaCode) ++ util:to_list(PureMobile)),
    verify_sms_limitation(CodeKeyMobile, Operation),
    ?ASSERT(is_valid_mobile(PureMobile) =:= ok, invalid_mobile),
    {Code, Time} = push_code_2_ets(CodeKeyMobile, Operation),
%%    Region = get_region(PlayerId),
    Region = get_region_by_area_code(AreaCode),
    call_sms_api(PureMobile, Operation, Region, Code),
    {Code, Time};
gen_sms_code(PlayerId, _Mobile, Operation) when Operation =:= presentation ->
    #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
    Mobile1 = get_mobile_from_center(AccId),
    {AreaCode, Mobile} = chk_mobile(Mobile1),
    Region = get_region_by_area_code(AreaCode),
    CodeKeyMobile = util:to_int(util:to_list(AreaCode) ++ util:to_list(Mobile)),
    verify_sms_limitation(CodeKeyMobile, Operation),
    ?ASSERT(is_valid_mobile(util:to_int(CodeKeyMobile)) =:= ok, invalid_mobile),
    {Code, Time} = push_code_2_ets(CodeKeyMobile, Operation),
%%    PlatformId = mod_server_config:get_platform_id(),
%%    Region = get_region(PlatformId, AccId),
    Region = get_region_by_area_code(AreaCode),
    call_sms_api(Mobile, Operation, Region, Code),
    {Code, Time};
gen_sms_code(_PlayerId, _Mobile, _Operation) ->
    exit(invalid_param).

%% ----------------------------------
%% @doc 	校验指定手机号是否能生成短信验证码
%% @throws 	none
%% @end
%% ----------------------------------
%% 校验绑定手机验证码是否允许执行
%%verify_sms_limitation(_Mobile, Operation) when Operation =:= presentation ->
%%    ok;
verify_sms_limitation(Mobile, Operation) -> %%when Operation =:= bind_mobile ->
    Key = {?MODULE, Mobile, Operation, times},
    UpdateLimitation =
        case mod_cache:get(Key) of
            %% 缓存不存在或过期，暨玩家使用了邀请码 或 没使用邀请码但超过了邀请码限制时间
            null -> expire_or_not_exists;
            %% 缓存存在且未过期，表明玩家在不允许发送短信验证码的时候，点击了短信邀请码
            %% 提示非法操作
            OldTimesInEts ->
                ?INFO("~p重复获取~p次验证码", [Mobile, OldTimesInEts]),
                exit(invalid_operation)
        end,
    if
        UpdateLimitation =:= expire_or_not_exists ->
            NewTimes =
                case ets:lookup(?ETS_CACHE, Key) of
                    %% 缓存存在，暨用户获取了短信验证码，但是没有使用
                    %% 按照静态表配置，根据用户获取了几次验证码但没使用，生成新的限制时间
                    [OldData] when is_record(OldData, ets_cache) -> OldData#ets_cache.data + 1;
                    %% 缓存不存在，暨用户上次获取短信验证码后，成功使用
                    %% 因此本次获取短信验证码，需根据静态表配置，记录其获取短信验证码的次数
                    [] -> 1
                end,
            set_verify_limitation(Mobile, Operation, times, NewTimes);
        true -> false
    end.
%% ----------------------------------
%% @doc 	记录指定手机号码接收短信验证码的次数
%% @throws 	none 7,bind
%% @end
%% ----------------------------------
set_verify_limitation(Mobile, Operation, times, Times) ->
    Key = {?MODULE, Mobile, Operation, times},
%%    NewExpire = ?IF(Times =< ?SD_BIND_PHONE_NOT_MESSAGE, ?SD_BIND_PHONE_AUTH_CODE_TIME, ?SD_BIND_PHONE_UNUSED_AUTH_CODE_TIME),
    %% 每天短信验证码获取超过20次，就隔天才能获取
    Time = util_time:get_tomorrow_timestamp({0, 0, 0}) - util_time:timestamp(),
    NewExpire = ?IF(Times =< 20, ?SD_BIND_PHONE_AUTH_CODE_TIME, Time),
    mod_cache:update(Key, Times, NewExpire).
reset_verify_limitation(Mobile, Operation) ->
    Key = {?MODULE, Mobile, Operation, times},
    mod_cache:delete(Key).

%% ----------------------------------
%% @doc 	通过手机号码区号，查找国家/地区
%% @throws 	none
%% @end
%% ----------------------------------
get_region_by_area_code(AreaCode) ->
    ?DEBUG("get_region_by_area_code AreaCode: ~p", [{AreaCode, util:to_int(AreaCode)}]),
    Currency =
        case mod_server_rpc:call_center(mod_region_info, get_region_info, [util:to_int(AreaCode)]) of
            {'EXIT', Err} ->
                ?ERROR("获取获取地区区号与名字时失败: ~p", [Err]),
                "TWD";
            {_RegionByAreaCode, CurrencyByAreaCode} ->
                ?IF(CurrencyByAreaCode =:= noop, "TWD", CurrencyByAreaCode)
        end,
    ?INFO("Region: ~p", [{Currency, AreaCode}]),
    Currency.

%% ----------------------------------
%% @doc 	通过玩家编号查询隶属国家/地区
%% @throws 	none
%% @end
%% ----------------------------------
get_region(PlayerId) ->
    PlatformId = mod_server_config:get_platform_id(),
    #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
    get_region(PlatformId, AccId).

%% ----------------------------------
%% @doc 	通过玩家accId和platformId查询隶属国家/地区
%% @throws 	none
%% @end
%% ----------------------------------
get_region(PlatformId, AccId) ->
    case catch mod_server_rpc:call_center(mod_global_account, get_my_region, [AccId, PlatformId]) of
        {'EXIT', Err} ->
            ?ERROR("get_my_region ERROR: ~p", [Err]),
            exit(invalid_region);
        Region -> Region
    end.

%% ----------------------------------
%% @doc 	校验验证码
%% @throws 	none
%% @end
%% ----------------------------------
verify_code(Mobile1, Operation, Code) when is_integer(Operation) ->
    ?ASSERT(lists:member(Operation, ?INVALID_OPERATION_LIST) =:= true, invalid_operation),
    {AreaCode, PureMobile} = chk_mobile(Mobile1),
    CodeKeyMobile = util:to_int(util:to_list(AreaCode) ++ util:to_list(PureMobile)),
    case Operation of
        1 ->
            verify_code(CodeKeyMobile, bind_mobile, Code);
        2 ->
            verify_code(CodeKeyMobile, presentation, Code);
        O ->
            ?ERROR("invalid operation: ~p", [O]),
            exit(invalid_operation)
    end;
verify_code(Mobile, Operation, Code1) when is_atom(Operation) ->
    VerifyRes = get_code(Mobile, Operation),
    Code = util:to_int(Code1),
    ?DEBUG("VerifyRes: ~p", [{VerifyRes, Code, VerifyRes =:= Code}]),
    case VerifyRes of
        %% 验证码不存在或过期了
        null ->
            delete_code(Mobile, Operation),
            exit(expire);
        %% 验证码匹配
        MatchCode when MatchCode =:= Code ->
            delete_code(Mobile, Operation);
        %% 验证码不匹配
        MatchCode1 when MatchCode1 =/= Code ->
            exit(invalid_code);
        Other ->
            ?ERROR("VerifyRes Other: ~p", Other),
            exit(fail)
    end;
verify_code(_PlayerId, _Operation, _Code) ->
    exit(invalid_param).

%% ----------------------------------
%% @doc 	从中心服获取指定账号的mobile
%% @throws 	none
%% @end
%% ----------------------------------
get_mobile_from_center(AccId) ->
    PlatformId = mod_server_config:get_platform_id(),
    case catch mod_server_rpc:call_center(mod_global_account, get_mobile, [PlatformId, AccId]) of
        {'EXIT', Err} -> ?ERROR("err: ~p", [Err]), failure;
        MobileFromCenter -> MobileFromCenter
    end.

%% ------------------------------------------------- 私有方法 -----------------------------------------------------------

%% ----------------------------------
%% @doc 	验证手机号码是否有效
%% @throws 	none
%% @end
%% ----------------------------------
is_valid_mobile(Mobile) ->
    ?ASSERT(Mobile =/= failure, failure),
    if
        Mobile =:= 0 -> failure;
        true -> ok
    end.

%% ----------------------------------
%% @doc 	判断手机号码是否为空
%% @throws 	none
%% @end
%% ----------------------------------
chk_mobile(Mobile1) ->
    try
        Mobile2 = ?IF(is_list(Mobile1), Mobile1, util:to_list(Mobile1)),
        Mobile3 = ?IF(string:str(Mobile2, "-") =:= 0, "886-" ++ Mobile2, Mobile2),
        [AreaCode, Mobile] = string:tokens(Mobile3, "-"),
        {AreaCode, ?IF(is_integer(Mobile), Mobile, util:to_int(Mobile))}
    catch
        _:Reason ->
            ?ERROR("Reason: ~p", [Reason]),
            exit(invalid_mobile)
    end.

%% ----------------------------------
%% @doc 	生成指定长度的纯数字验证码
%% @throws 	none
%% @end
%% ----------------------------------
gen_code(Len) ->
    {Min, Max} =
        case Len of
            6 -> {lists:flatten(io_lib:format("~6..1w", [1])), lists:flatten(io_lib:format("~6..9w", [9]))};
            4 -> {lists:flatten(io_lib:format("~4..1w", [1])), lists:flatten(io_lib:format("~4..9w", [9]))}
        end,
    util_random:random_number(util:to_int(Min), util:to_int(Max)).

%% ----------------------------------
%% @doc 	将生成验证码，并存入缓存
%% @throws 	none
%% @end
%% ----------------------------------
push_code_2_ets(Mobile, Operation) ->
    Key = {?MODULE, Mobile, Operation},
%%    CodeIsExists = mod_cache:get(Key),
%%    Code =
%%        if
            %% 旧的验证码已经过期或不存在
%%            CodeIsExists =:= null ->
%%                NewCode = gen_code(?CODE_LENGTH),
%%                F =
%%                    fun() ->
%%                        ?INFO("~p push code into cache: ~p", [Mobile, {Key, NewCode}]),
%%                        NewCode
%%                    end,
%%                ExpireTime = ?SD_BIND_PHONE_AUTH_CODE_VALID_TIME,
%%                R = mod_cache:cache_data(Key, F, ExpireTime),
%%                ?DEBUG("cache: ~p", [R]),
%%                R;
%%            true -> CodeIsExists
%%        end,
    NewCode = gen_code(?CODE_LENGTH),
    ExpireTime = ?SD_BIND_PHONE_AUTH_CODE_VALID_TIME,
    F =
        fun() ->
            ?INFO("~p push code into cache: ~p", [Mobile, {Key, NewCode}]),
            NewCode
        end,
    Code = mod_cache:cache_data(Key, F, ExpireTime),
    ?DEBUG("cache: ~p", [Code]),
    {Code, util_time:timestamp() + ?SD_BIND_PHONE_AUTH_CODE_TIME}.

%% ----------------------------------
%% @doc 	获取验证码
%% @throws 	none
%% @end
%% ----------------------------------
get_code(Mobile, Operation) ->
    Key = {?MODULE, Mobile, Operation},
    mod_cache:get(Key).

%% ----------------------------------
%% @doc 	删除验证码
%% @throws 	none
%% @end
%% ----------------------------------
delete_code(Mobile, Operation) ->
    Key = {?MODULE, Mobile, Operation},
    DeleteRes = mod_cache:delete(Key),
    DeleteLimitationRes = reset_verify_limitation(Mobile, Operation),
    ?DEBUG("Key: ~p删除限制结果: ~p", [Key, DeleteLimitationRes]),
    ?DEBUG("Key: ~p删除结果: ~p", [Key, DeleteRes]).

%% ----------------------------------
%% @doc 	调用装备交易平台的短信接口 此处的手机号码需要去除掉地区区号
%% @throws 	none
%% @end
%% ----------------------------------
call_sms_api(Mobile, Operation1, Region, Code) ->
    Tran =
        fun() ->
            Env = env:get(env, "production"),
            Url = ?SMS_API_HOST(Env) ++ ?SMS_API_PATH(Env),
            Operation =
                case Operation1 of
                    bind_mobile -> 1;
                    presentation -> 2
                end,
            ReqData = [{"code", Code}, {"phone", Mobile}, {"platform", Region}, {"template_id", Operation}],
            case util_http:post(Url, json, ReqData) of
                {ok, Result1} ->
                    Result = jsone:decode(util:to_binary(Result1)),
                    RespCode = maps:get(<<"code">>, Result),
                    Msg = util:to_list(maps:get(<<"msg">>, Result)),
                    _Data = maps:get(<<"data">>, Result),
                    if
                        RespCode =:= 0 ->
                            ok;
                        true ->
                            ?ERROR("call sms api failure: ~p", [{RespCode, Msg}]),
                            failure
                    end;
                {error, Reason} ->
                    ?ERROR("\n fail2=>\n"
                    "  url: ~ts\n"
                    "  data: ~p\n"
                    "  reason: ~p\n",
                        [Url, ReqData, Reason]),
                    exit(invalid_api)
            end
        end,
    spawn(Tran).
