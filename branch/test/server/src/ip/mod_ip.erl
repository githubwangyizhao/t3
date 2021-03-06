%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 12ζ 2020 δΈε 03:18:20
%%%-------------------------------------------------------------------
-module(mod_ip).
-author("Administrator").

-include("common.hrl").

%% API
-export([
  gen_ip_list_txt/0,
  is_valid_ip/1
]).

is_valid_ip(Ip) ->
  ?INFO("PlayerIP: ~s", [Ip]),
  ?INFO("BLACK IP LIST TXT FIlE NAME: ~s", [?BLACK_IP_LIST_TXT]),
  FileIsExists = filelib:wildcard(?BLACK_IP_LIST_TXT),
  if
    %% white ip list exists
    %% Is the player's ip valid
    length(FileIsExists) =:= 1 ->
      {ok, Value} = file:open(FileIsExists, [read]),
      Out = string_file:do(Value, []),

      InvalidIp =
      try
        lists:flatmap(
          fun (Ele) ->
            case re:run(Ele, "^[0-9.]+$", [unicode]) of
              %% it's not a string contain the numbers and dot only
              nomatch ->
%%                ?INFO("666: ~p", [Ele]),
                [continue];
              %% numbers and dot
              _ ->
                {RegExp, _} = lists:split(string:rchr(Ele, $.), Ele),
                MatchStr = re:replace(string:concat(RegExp, "*"), "\\.", "\\\\.", [global, {return, list}]),
                case re:run(Ip, MatchStr) of
                  nomatch ->
                    %% too many ip to don't log
%%                    ?INFO("valid ip"),
                    [continue];
                  _ ->
                    ?ERROR("invalid ip: ~s match ~s", [Ip, string:concat(RegExp, "*")]),
                    %% seems like break
                    throw({invalid_ip, Ip})
                end
            end
          end,
          Out
        )
      catch
        throw:{invalid_ip, Ip} -> Ip
      end,
      file:close(Value),
      if InvalidIp =:= Ip
        ->
          ?ERROR("invalid ip. kick out"),
          logout;
        true ->
          ok
      end;
    %% black ip list not exists. player login
    %% so far so good
    true ->
      ?INFO("not exists"),
      not_exists
  end.

gen_ip_list_txt() ->
  %% δ»ιη½?ζδ»ΆδΈ­θ―»εchineseiplist.txtζδ»Άηθ·―εΎ
  %% ε€ζ­ζδ»Άζ―ε¦ε­ε¨
  %% ζδ»ΆδΈε­ε¨ -> ζ§θ‘shθζ¬ηζζδ»Ά
  %% ζδ»Άε­ε¨ -> ok
  ?INFO("IP LIST TXT FIlE NAME: ~s", [?BLACK_IP_LIST_TXT]),

  Cmd = io_lib:format("sh ~s", [?UPDATE_BLACK_IP_LIST_TXT_SCRIPT]),
  ?INFO("CMD:~s", [Cmd]),
%%  {Time1, _} = statistics(wall_clock),
  Result = os:cmd(Cmd).
%%  {Time2, _} = statistics(wall_clock),
%%  Sec = (Time2 - Time1) / 1000.0,
%%  ?DEBUG("spend: ~p~ns", [Sec]),
%%  ?DEBUG("Result: ~p~n", [Result]).
