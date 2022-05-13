%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    签名
%%% Created : 21. 五月 2018 15:36
%%%-------------------------------------------------------------------
-module(mod_signature).
-author("home").

%% API
-export([
    sign_str/1,         %% 平台sha值
    sign_str/2,         %% 平台sha值
    get_secret_str/0,
    sign_xml/2,         %% xml签名
    sign/1,             %% 签名
    sign/2              %% 签名
]).

-export([
    get_signature/0,
    get_signature/1,
    check_param_list/2, %% 验证参数(加平台)
    check_param_list/1  %% 验证参数
]).
-include("common.hrl").
-include("gen/table_enum.hrl").

%% @fun 签名
sign(List) ->
    sign(List, mod_server_config:get_platform_id()).
sign(List, Pf) ->
    KeyAtom = get_signature(Pf),
    ChargeShaStr = util_list:change_list_url(List),
    ShaStr = sign_str(List, Pf),
    lists:concat([ChargeShaStr, "&", KeyAtom, "=", ShaStr]).
sign_xml(List, Pf) ->
    KeyAtom = get_signature(Pf),
    SignStr = sign_str(List, Pf),
    ParamList = [{KeyAtom, SignStr} | List],
    xml:encode(ParamList).
%% @fun 获得签名值
sign_str(List) ->
    sign_str(List, mod_server_config:get_platform_id()).
sign_str(List, Pf) ->
    [Type, HashType, SecretStr] = get_secret_str(Pf),
    sign_str(List, Type, HashType, SecretStr).
sign_str(List, Type, HashType, SecretStr) ->
    case Type of
        hmac ->
            ChargeShaStr = util_list:change_list_url(lists:sort(List)),
            encrypt:hmac_sha(HashType, ChargeShaStr, SecretStr);
        hash ->
            ChargeShaStr = util_list:change_list_url(lists:sort(List)) ++ SecretStr,
            encrypt:sha(ChargeShaStr);
        rsaSha ->
            ChargeShaStr = util_list:change_list_url(lists:sort(List)),
            [ShaType, KeyFilePath, _] = SecretStr,
            KeyBin = encrypt:get_rsa_key_str(KeyFilePath),
            KeySignatureBin = public_key:sign(util:to_binary(ChargeShaStr), ShaType, KeyBin),
            base64:encode(KeySignatureBin);
        signList ->
            [[ShaType, SecretStr1]| _] = SecretStr,
            sign_str(List, ShaType, HashType, SecretStr1);
        md5 ->
            ChargeShaStr = util_list:change_list_url(lists:sort(List)),
            encrypt:md5(ChargeShaStr);
        vpMd5 ->   % v:值md5 p:加参数md5
            ChargeShaStr = util_list:change_list_url([Value || {_, Value} <- lists:sort(List)], "") ++ SecretStr,
            encrypt:md5(ChargeShaStr);
        vMd5pMd5 ->   % v:值md5 p:加参数md5
            ChargeShaStr = encrypt:md5(util_list:change_list_url([Value || {_, Value} <- lists:sort(List)], "")) ++ SecretStr,
            encrypt:md5(ChargeShaStr);
        dpmd5 ->    % md5 p加参数  d:转大写
            ChargeShaStr = util_list:change_list_url(lists:sort(List)) ++ SecretStr,
            string:to_upper(encrypt:md5(ChargeShaStr));
        spmd5 ->    % md5 p加参数  s:转小写
            ChargeShaStr = util_list:change_list_url(lists:sort(List)) ++ SecretStr,
%%            string:to_lower(encrypt:md5(ChargeShaStr))
            encrypt:md5(ChargeShaStr)
    end.
%%    encrypt:sha1(util:to_binary(ChargeShaStr)).

%% 验证参数
check_param_list(ParamList1) ->
    check_param_list(ParamList1, mod_server_config:get_platform_id()).
check_param_list(ParamList1, Pf) ->
    ParamList = [{util:to_atom(Key1), util:to_list(Value1)} || {Key1, Value1} <- ParamList1],
    KeyAtom = get_signature(Pf),
    case lists:keytake(KeyAtom, 1, ParamList) of
        {value, {_, Hash}, OtherList} ->
            case get_secret_str(Pf) of
                [_, rsaSha, SecretStr] ->
                    [ShaType, _, RsaKeyFilePath] = SecretStr,
                    ChargeShaStr = util_list:change_list_url(lists:sort(OtherList)),
                    Signature = base64:decode(Hash),
                    KeyBin = encrypt:get_rsa_key_str(RsaKeyFilePath),
                    ChargeShaBin = util:to_binary(ChargeShaStr),
                    case public_key:verify(ChargeShaBin, ShaType, Signature, KeyBin) of
                        true ->
                            noop;
                        _ ->
                            ?ERROR("检验参数不一致: sign:~p\tcalcSign: ~s~n", [Hash, ChargeShaBin]),
                            exit(error_sha)
                    end;
%%                [_, rsaPub, SecretStr] ->
%%                    [_ | RsaKeyFilePath] = SecretStr,
%%                    ChargeShaStr = util_list:change_list_url(lists:sort(OtherList)),
%%                    RsaKeyStr = util:to_list(encrypt:rsa_public_key_decode(Hash, RsaKeyFilePath)),
%%                    if
%%                        ChargeShaStr == RsaKeyStr ->
%%                            noop;
%%                        true ->
%%                            ?ERROR("检验参数不一致: sign:~p  >> calcSign: ~p~n", [RsaKeyStr, ChargeShaStr]),
%%                            exit(error_sha)
%%                    end;
                [signList, HashType, SecretStr] ->
                    [_,[ShaType, SecretStr2]] = SecretStr,
                    CheckHash = sign_str(OtherList, ShaType, HashType, SecretStr2),
                    if
                        CheckHash == Hash ->
                            noop;
                        true ->
                            ?ERROR("检验码不一致: sign:~p\t>> calckHash: ~p~n", [Hash, CheckHash]),
                            exit(error_sha)
                    end;
                _ ->
                    CheckHash = sign_str(OtherList, Pf),
                    if
                        CheckHash == Hash ->
                            noop;
                        true ->
                            ?ERROR("检验码不一致: sign:~p\t>> calckHash: ~p, OtherList:~p~n", [Hash, CheckHash, OtherList]),
                            exit(error_sha)
                    end
            end;
        _ ->
            ?ERROR("not_sign ParamList:~p~n", [ParamList]),
            exit(not_sign)
    end.

%% @fun 平台加密方式
get_secret_str() ->
    get_secret_str(mod_server_config:get_platform_id()).
get_secret_str(Pf) ->
    case Pf of
        ?PLATFORM_LOCAL ->
            [spmd5, md5, ?TH_MD5_APPKEY];
%%        ?CHANNEL_H56873 ->
%%            [vMd5pMd5, md5, ?H5_6873_APP_KEY];
%%        ?CHANNEL_YAYA ->
%%            [vpMd5, md5, ?YAYA_APP_KEY];
%%        ?PLATFORM_HD ->
%%            [hash, sha, ?HD_GAME_SECRET];
%%        ?PLATFORM_WX ->
%%            [hash, sha, ?WX_FY_SECRET];
%%        ?PLATFORM_MJB ->
%%            [hash, sha, ?WX_FY_SECRET];
%%        ?CHANNEL_MJB_H5 ->
%%            [hash, sha, ?MJB_H5_ZHI_FU_KEY];
%%        ?CHANNEL_DXLL ->
%%            [hash, sha, ?DXLL_ZHI_FU_SECRET];
%%        ?CHANNEL_XINGQIU ->
%%            [rsaSha, rsaSha, [sha256, ?XINGQIU_APP_PRIVATE_KEY_PATH, ?XINGQIU_APP_PUBLIC_KEY_PATH]];% [加密, 解密，[方式，密钥文件路径,解密文件路径]]
%%        ?PLATFORM_DJS ->
%%            [dpmd5, md5, "&key=" ++ ?DJS_SECRET_KEY];
%%        ?PLATFORM_AF ->
%%            [dpmd5, md5, "&key=" ++ ?AWY_PAY_KEY];
%%        ?PLATFORM_YK ->
%%            [dpmd5, md5, "&key=" ++ ?YK_APP_SECRET];
%%        ?PLATFORM_DOULUO ->
%%            [dpmd5, md5, "&key=" ++ ?DOU_LUO_APP_KEY];
%%        ?PLATFORM_GAT ->
%%            [spmd5, md5, ?GAT_ZHI_FU_KEY];
%%        ?PLATFORM_SJB ->
%%            [hash, sha, ?WX_FY_SECRET];
%%        ?PLATFORM_YLW ->
%%            [spmd5, md5, ?YLW_APP_KEY];
%%        ?CHANNEL_ZJ_H5 ->
%%            [spmd5, md5, "&" ++ ?ZJ_H5_ZHI_FU_KEY];
%%        ?CHANNEL_LANBAO ->
%%            [signList, md5, [[spmd5, ?LAN_BAO_APP_KEY], [spmd5, ?LAN_BAO_ZHI_FU_KEY]]]; % [[加密，加密参数], [解密,解密参数]]
%%        ?CHANNEL_VIVO ->
%%            [spmd5, md5, "&" ++ encrypt:md5(?VIVO_ZHI_FU_SECRET)];
%%        ?CHANNEL_VIVO_MJB ->
%%            [spmd5, md5, "&" ++ encrypt:md5(?VIVO_MJB_ZHI_FU_SECRET)];
%%        ?CHANNEL_MEIZU ->
%%            [spmd5, md5, io_lib:format("_~s_MZ_NOTIFY_~s", [?MEIZU_RPK_GNAME, ?MEIZU_ZHI_FU_SECRET])];
%%        ?PLATFORM_BAIDU ->
%%            [rsaPri, rsaPub, ["rsa_private_key.pem", "rsa_public_key.pem"]];
%%            [rsaSha, rsaSha, [sha, ?BAIDU_APP_PRIVATE_KEY_PATH, ?BAIDU_APP_PUBLIC_KEY_PATH]];% [加密, 解密，[方式，密钥文件路径,解密文件路径]]
%%        ?PLATFORM_OPPO ->
%%            [rsaSha, rsaSha, [sha256, ?OPPO_APP_PRIVATE_KEY_PATH, ?OPPO_APP_PUBLIC_KEY_PATH]];% [加密, 解密，[密钥文件路径,解密文件路径]]
%%        ?CHANNEL_OPPO_MJB ->
%%            [rsaSha, rsaSha, [sha256, ?OPPO_MJB_APP_PRIVATE_KEY_PATH, ?OPPO_MJB_APP_PUBLIC_KEY_PATH]];% [加密, 解密，[密钥文件路径,解密文件路径]]
%%        ?CHANNEL_HUAWEI ->
%%            [rsaSha, rsaSha, [sha256, ?HUAWEI_APP_PRIVATE_KEY_PATH, ?HUAWEI_APP_PUBLIC_KEY_PATH]];% [加密, 解密，[密钥文件路径,解密文件路径]]
%%            [hmac, sha256, ?WX_SECRET];
        ?PLATFORM_MOY ->
            [md5, md5, ?MoY_APP_SECRET];
        ?PLATFORM_INDONESIA ->
            [md5, md5, ""];
        _ ->
            [hash, sha, ""]
    end.
%% @fun 平台uri key
get_signature() ->
    get_signature(mod_server_config:get_platform_id()).
get_signature(Pf) ->
    case Pf of
%%        ?PLATFORM_HD ->
%%            signature;
        ?PLATFORM_MOY ->
            signature;
        ?PLATFORM_INDONESIA ->
            sign;
%%        ?PLATFORM_WX ->
%%            sign;
%%        ?PLATFORM_DXLL ->
%%            sign;
%%        ?PLATFORM_DJS ->
%%            sign;
%%        ?PLATFORM_AF ->
%%            sign;
%%        ?PLATFORM_YK ->
%%            sign;
%%        ?PLATFORM_YLW ->
%%            sign;
%%        ?PLATFORM_DOULUO ->
%%            sign;
%%        ?PLATFORM_SJB ->
%%            sign;
%%        ?PLATFORM_BAIDU ->
%%            rsaSign;
%%        ?PLATFORM_OPPO ->
%%            sign;
%%        ?CHANNEL_VIVO ->
%%            signature;
%%        ?CHANNEL_VIVO_MJB ->
%%            signature;
%%            session_key;
        _ ->
            sign
    end.
