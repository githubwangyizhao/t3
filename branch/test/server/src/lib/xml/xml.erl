%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 25. 十二月 2018 15:36
%%%-------------------------------------------------------------------
-module(xml).
-author("home").

%% API
-export([
    encode/1,
    decode/1,
    decode_file/1,
    file/2,
    string/2
]).

-include_lib("xmerl/include/xmerl.hrl").

%% @fun 解出xml Str字段
string(Str, XmlStr) ->
    {Doc, _} = xmerl_scan:string(XmlStr),
    Date = xmerl_xpath:string(Str, Doc),
    if
        Date =/= [] ->
            [#xmlElement{content = Content}] = Date,
            [#xmlText{value = Val}] = Content,
            Val;
        true ->
            ""
    end.

%% @fun 解出xml Str字段
file(Str, XmlFile) ->
    {Doc, _} = xmerl_scan:file(XmlFile),
    Date = xmerl_xpath:string(Str, Doc),
    if
        Date =/= [] ->
            [#xmlElement{content = Content}] = Date,
            [#xmlText{value = Val}] = Content,
            Val;
        true ->
            ""
    end.
%% @fun 解出xml Str字段
decode_file(XmlFile) ->
    {Doc, _} = xmerl_scan:file(XmlFile),
    Content = decode_handler(Doc),
    lists:foldl(
        fun(#xmlText{pos = Pos, parents = Parents, value = Value}, TextL1) ->
            {Key, _} = lists:nth(Pos, Parents),
            [{Key, Value} | TextL1]
        end, [], Content).

%% @fun 转成xml
encode(List) ->
    ParamList = encode_handler(List, []),
    XmlList = xmerl:export_simple_content(ParamList, xmerl_xml),
    "<xml>" ++ lists:flatten(XmlList) ++ "</xml>".
encode_handler([], L) ->
    L;
encode_handler([{Key, Value} | List], L) ->
    NewValue =
        case is_list(Value) of
            true ->
                case hd(Value) of
                    {_, _} ->
                        encode_handler(Value, []);
                    _ ->
                        case is_change_list(Value) of
                            false ->
                                io_lib:format("~p", [Value]);
                            _ ->
                                [Value]
                        end
                end;
            _ ->
                [util:to_list(Value)]
        end,
    encode_handler(List, [{util:to_atom(Key), NewValue} | L]).
is_change_list([]) ->
    true;
is_change_list([S | Str]) ->
    case is_integer(S) of
        true ->
            is_change_list(Str);
        _ ->
            false
    end.

% 模板1 "<xml><appid><![CDATA[wxfb419ccad0918b77]]></appid>\n<attach><![CDATA[3574026_99_30006_1]]></attach>\n<bank_type><![CDATA[PAB_CREDIT]]></bank_type>\n<cash_fee><![CDATA[600]]></cash_fee>\n<fee_type><![CDATA[CNY]]></fee_type>\n<is_subscribe><![CDATA[N]]></is_subscribe>\n<mch_id><![CDATA[1528748851]]></mch_id>\n<nonce_str><![CDATA[vgcscptmos]]></nonce_str>\n<openid><![CDATA[oxPjH5axXQ6vG0C4dx4rsnXqYZHM]]></openid>\n<out_trade_no><![CDATA[9900000035740261559180391]]></out_trade_no>\n<result_code><![CDATA[SUCCESS]]></result_code>\n<return_code><![CDATA[SUCCESS]]></return_code>\n<sign><![CDATA[91E273E5FFE3DE46073025B7F267EF22]]></sign>\n<time_end><![CDATA[20190530093957]]></time_end>\n<total_fee>600</total_fee>\n<trade_type><![CDATA[JSAPI]]></trade_type>\n<transaction_id><![CDATA[4200000329201905302914288753]]></transaction_id>\n</xml>"
% 模板2 "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><quicksdk_message><message><is_test>0</is_test><channel>134</channel><channel_uid>83044817</channel_uid><channel_order>0020190530164749256359</channel_order><game_order>9900000000108071559206064</game_order><order_no>13420190530164744409726593</order_no><pay_time>2019-05-30 16:47:58</pay_time><amount>1.00</amount><status>0</status><extras_params>10807_99_99999_1</extras_params></message></quicksdk_message>"
%% @fun 解xml
decode(Xml) ->
    ContentList = decode_shift(util:to_list(Xml), []),
    TextL =
        lists:foldl(
            fun(#xmlText{pos = Pos, parents = Parents, value = Value}, TextL1) ->
                {Key, _} = lists:nth(Pos, Parents),
                [{Key, Value} | TextL1]
            end, [], ContentList),
    TextL.
%% 转换内容的解析内容
decode_shift("", L) ->
    L;
decode_shift(Xml, L) ->
    {Doc, Doc1} = xmerl_scan:string(Xml),
    Content = decode_handler(Doc),
    decode_shift(Doc1, Content ++ L).

%% 处理内容的解析内容
decode_handler(Element) ->
    lists:flatten(decode_handler(Element, [])).
decode_handler(Element, L) ->
    case Element of
        #xmlText{pos = 1} ->
            [Element | L];
        #xmlElement{content = Content1} ->
            decode_handler(Content1, []) ++ L;
        ElementList when is_list(ElementList) ->
            [decode_handler(Element1, []) || Element1 <- ElementList];
        _ ->
            L
    end.
