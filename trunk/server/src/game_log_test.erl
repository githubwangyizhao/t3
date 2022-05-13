%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2021 下午 02:25:23
%%%-------------------------------------------------------------------
-module(game_log_test).
-author("Administrator").

-include("gen/db.hrl").
-include("p_message.hrl").
-include("common.hrl").

%% API
-export([
    main/0
]).

main() ->
    {ok, File} = open_log_file(),
    {ok, DateDirList} = file:list_dir("/data/log/game/indonesia_s1"),
%%    {ok, DateDirList} = file:list_dir("../src/test/game"),
    lists:foldl(
        fun(DateDir, Tmp) ->
            [_Y, DateDir1] = string:split(DateDir, "_"),
            [M, D] = string:split(DateDir1, "_"),
            IsCan =
                if
                    M > 3 ->
                        true;
                    M == 3 ->
                        if
                            D >= 25 ->
                                true;
                            true ->
                                false
                        end;
                    true ->
                        false
                end,
            if
                IsCan ->
                    FileName = "/data/log/game/indonesia_s1/" ++ DateDir ++ "/game.log",
                    put(game_sql_log_file_name, FileName),
                    {ok, IoDevice} = file:open(FileName, [read]),
%%            {ok, IoDevice} = file:open("../src/test/game/" ++ DateDir ++ "/game.log", [read]),
                    List = get_data(IoDevice),
                    NewList = lists:foldl(
                        fun(Data, TmpPlayerIdList) ->
                            PlayerStr = string:substr(Data, 28, 5),
                            PlayerId = util:to_int(PlayerStr),
                            case lists:member(PlayerId, TmpPlayerIdList) of
                                true ->
                                    TmpPlayerIdList;
                                false ->
                                    put(is_add_player, false),
                                    PromoteList =
                                        case catch util_string:string_to_term(string:substr(Data, 40)) of
                                            {m_player_adjust_tos, PromoteList1} ->
                                                PromoteList1;
                                            {'EXIT', ERROR} ->
                                                io:format("ERROR: ~p", [{PlayerId, Data, ERROR}]),
                                                []
                                        end,
                                    lists:foreach(
                                        fun(Ele) ->
                                            #'m_player_adjust_tos.attr_change'{attr = AttrFromProto, value = Value} = Ele,
                                            Attr = ?IF(is_binary(AttrFromProto), util:to_list(AttrFromProto), AttrFromProto),
                                            case Attr of
                                                "campaign" ->
                                                    FriendCode = ?IF(is_binary(Value), util:to_list(Value), Value),
                                                    case length(FriendCode) of
                                                        %% 处理好友邀请
                                                        CodeLength when CodeLength > 0 ->
%%                                                    io:format("查看数据 ~ts~n", [Value]),
                                                            case catch mod_unique_invitation_code:decode(FriendCode) of
                                                                ThisPlayerId when is_integer(ThisPlayerId) ->
                                                                    noop;
                                                                _ERROR ->
                                                                    case mod_player:get_player(PlayerId) of
                                                                        null ->
                                                                            ?INFO("db_player is null ,player_id ~p", [PlayerId]);
                                                                        DbPlayer ->
                                                                            #db_player{
                                                                                acc_id = AccId
                                                                            } = DbPlayer,
%%                                                                  AccId = "test",
                                                                            PlatformId = mod_server_config:get_platform_id(),
                                                                            Text = io_lib:format("UPDATE global_account SET `promote` = '~ts' WHERE `platform_id` = '~s' and `account` = '~s';~n", [Value, PlatformId, AccId]),
                                                                            file:write(File, unicode:characters_to_binary(Text)),
                                                                            put(is_add_player, true)
                                                                    end
                                                            end;
                                                        _ ->
                                                            noop
                                                    end;
                                                _R ->
                                                    noop
                                            end
                                        end,
                                        PromoteList
                                    ),
                                    case erase(is_add_player) of
                                        true ->
                                            [PlayerId | TmpPlayerIdList];
                                        false ->
                                            TmpPlayerIdList
                                    end
                            end
                        end,
                        Tmp, List
                    ),
                    file:close(IoDevice),
                    NewList;
                true ->
                    Tmp
            end
        end,
        [], DateDirList
    ),
    file:close(File),
    ok.

open_log_file() ->
    FileName = "/data/update_promote.sql",
%%    FileName = "../src/test/update_promote.sql",
    case filelib:is_file(FileName) of
        true -> ok;
        false -> ok = filelib:ensure_dir(FileName)
    end,
    file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 800}]). %% 字节bytes 毫秒milliseconds

get_data(IoDevice) ->
    get_data(IoDevice, "", [], false).
get_data(IoDevice, TmpData, TmpDataList, IsAdd) ->
    case catch io:fread(IoDevice, "", "~s") of
        eof ->
            TmpDataList;
        {ok, [Data]} ->
            NewIsAdd =
                if
                    Data == "{m_player_adjust_tos," ->
                        true;
                    true ->
                        IsAdd
                end,
            Data1 = string:split(Data, ":"),
            case length(Data1) of
                2 when length(Data) < 9 ->
                    case length(string:split(lists:last(Data1), ":")) of
                        2 ->
                            if
                                NewIsAdd ->
                                    get_data(IoDevice, "", [TmpData | TmpDataList], false);
                                true ->
                                    get_data(IoDevice, "", TmpDataList, false)
                            end;
                        _ ->
                            get_data(IoDevice, TmpData ++ " " ++ Data, TmpDataList, NewIsAdd)
                    end;
                _ ->
                    get_data(IoDevice, TmpData ++ " " ++ Data, TmpDataList, NewIsAdd)
            end;
        {'error', {'fread', FreadError}} ->
            ?INFO("FileName:~p,FreadError: ~p", [get(game_sql_log_file_name), FreadError]),
            get_data(IoDevice, "", TmpDataList, false);
        ERROR ->
            ?INFO("FileName:~p,Error: ~p", [get(game_sql_log_file_name), ERROR]),
            get_data(IoDevice, "", TmpDataList, false)
    end.
