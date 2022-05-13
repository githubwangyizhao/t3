%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    加密
%%% Created : 21. 五月 2018 14:05
%%%-------------------------------------------------------------------
-module(encrypt).
-author("home").

%% API
-export([
    md5/1,      % md5加密
    sha/1,      % sha加密
    sha/2,
    hmac_sha/2,  % sha加密
    hmac_sha/3,

    rsa_private_key_encode/2,   % 私钥加密
    rsa_private_key_decode/2,   % 私钥解密
    rsa_public_key_encode/2,    % 公钥加密
    rsa_public_key_decode/2,    % 公钥解密
    get_rsa_key_str/1           % 拿密钥内容
]).


%% @doc     md5加密
md5({file, File}) ->
    {ok, Bin} = file:read_file(File),
    Str = binary_to_list(Bin),
    md5(Str);
md5(S) ->
    Md5_bin = erlang:md5(S),
    Md5_list = binary_to_list(Md5_bin),
    lists:flatten(list_to_hex(Md5_list)).

%% @doc     sha加密
sha(ShaStr) ->
    sha(sha, ShaStr).
sha(HashType, ShaStr) ->
    ShaBin = crypto:hash(HashType, ShaStr),
    Md5_list = binary_to_list(ShaBin),
    lists:flatten(list_to_hex(Md5_list)).

%% @doc     sha加密
hmac_sha(ShaStr, Key) ->
    hmac_sha(sha, ShaStr, Key).

hmac_sha(HashType, ShaStr, Key) ->
    ShaBin = crypto:hmac(HashType, Key, ShaStr),
    Md5_list = binary_to_list(ShaBin),
    lists:flatten(list_to_hex(Md5_list)).

%% @doc     私钥加密
rsa_private_key_encode(Data, PrivateKeyFilePath) ->
    PriKey = get_rsa_key_str(PrivateKeyFilePath),
    base64:encode(public_key:encrypt_private(util:to_binary(Data), PriKey)).
%% @doc     私钥解密
rsa_private_key_decode(Signature, PrivateKeyFilePath) ->
    PriKey = get_rsa_key_str(PrivateKeyFilePath),
    public_key:decrypt_private(base64:decode(Signature), PriKey).

%% @doc     公钥加密
rsa_public_key_encode(Data, PublicKeyFilePath) ->
    PubKey = get_rsa_key_str(PublicKeyFilePath),
    base64:encode(public_key:encrypt_public(util:to_binary(Data), PubKey)).
%% @doc     公钥解密
rsa_public_key_decode(Signature, PublicKeyFilePath) ->
    PubKey = get_rsa_key_str(PublicKeyFilePath),
    public_key:decrypt_public(base64:decode(Signature), PubKey).
%% @fun 拿密钥内容
get_rsa_key_str(PublicKeyFilePath) ->
    {ok, PemBin} = file:read_file(PublicKeyFilePath),
    [Entry] = public_key:pem_decode(PemBin),
    public_key:pem_entry_decode(Entry).


%% @fun 转成16进制
%%lists:flatten(io_lib:format("~40.16.0b", [Bin])).
list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).
int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].
hex(N) when N < 10 ->
    $0 + N;
hex(N) when N >= 10, N < 16 ->
    $a + (N - 10).




