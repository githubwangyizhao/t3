-module(util_websocket).

-export([
%%    send_packet/2,
%%    get_packet_data/1,
    parse_frames/1,
    pack_packet/1,
    unmask/3
]).
%%get_packet_data(Packet) ->
%%    <<_FIN:1, _RSV1:1, _RSV2:1, _RSV3:1,
%%        _OPCODE:4,
%%        _MASK:1,
%%        PAYLOADLEN:7,
%%        Rest/binary>> = Packet,
%%
%%    io:format("_OPCODE:~p~n", [{_FIN, _OPCODE, PAYLOADLEN}]),
%%    if
%%        PAYLOADLEN =< 125 ->
%%            <<MaskKey:32, PAYLOAD/binary>> = Rest,
%%%%            MASK_KEY = [MASK_KEY1, MASK_KEY2, MASK_KEY3, MASK_KEY4],
%%            unmask(PAYLOAD, MaskKey, 0);
%%%%            get_packet_data(binary_to_list(PAYLOAD), MASK_KEY, 0, []);
%%        PAYLOADLEN == 126 ->
%%            <<_LENGTH:16, MASK_KEY1:8, MASK_KEY2:8, MASK_KEY3:8, MASK_KEY4:8,
%%                PAYLOAD/binary>> = Rest,
%%            MASK_KEY = [MASK_KEY1, MASK_KEY2, MASK_KEY3, MASK_KEY4],
%%            get_packet_data(binary_to_list(PAYLOAD), MASK_KEY, 0, []);
%%        PAYLOADLEN == 127 ->
%%            <<_LENGTH:64, MASK_KEY1:8, MASK_KEY2:8, MASK_KEY3:8, MASK_KEY4:8,
%%                PAYLOAD/binary>> = Rest,
%%            MASK_KEY = [MASK_KEY1, MASK_KEY2, MASK_KEY3, MASK_KEY4],
%%            get_packet_data(binary_to_list(PAYLOAD), MASK_KEY, 0, [])
%%    end.
%%
%%get_packet_data([H | T], Key, Counter, Result) ->
%%    get_packet_data(T, Key, Counter + 1, [H bxor lists:nth((Counter rem 4) + 1, Key) | Result]);
%%get_packet_data([], _, _, Result) ->
%%    lists:reverse(Result).
%%

unmask(Data, undefined, _) ->
    Data;
unmask(Data, MaskKey, 0) ->
    mask(Data, MaskKey, <<>>);
%% We unmask on the fly so we need to continue from the right mask byte.
unmask(Data, MaskKey, UnmaskedLen) ->
    Left = UnmaskedLen rem 4,
    Right = 4 - Left,
    MaskKey2 = (MaskKey bsl (Left * 8)) + (MaskKey bsr (Right * 8)),
    mask(Data, MaskKey2, <<>>).

mask(<<>>, _, Unmasked) ->
    Unmasked;
mask(<<O:32, Rest/bits>>, MaskKey, Acc) ->
    T = O bxor MaskKey,
    mask(Rest, MaskKey, <<Acc/binary, T:32>>);
mask(<<O:24>>, MaskKey, Acc) ->
    <<MaskKey2:24, _:8>> = <<MaskKey:32>>,
    T = O bxor MaskKey2,
    <<Acc/binary, T:24>>;
mask(<<O:16>>, MaskKey, Acc) ->
    <<MaskKey2:16, _:16>> = <<MaskKey:32>>,
    T = O bxor MaskKey2,
    <<Acc/binary, T:16>>;
mask(<<O:8>>, MaskKey, Acc) ->
    <<MaskKey2:8, _:24>> = <<MaskKey:32>>,
    T = O bxor MaskKey2,
    <<Acc/binary, T:8>>.

%%send_packet(Socket, Data) ->
%%    Out = pack_packet(Data),
%%    io:format("send:~p~n", [Out]),
%%    ok = gen_tcp:send(Socket, Out).

pack_packet(Data) ->
    Len = iolist_size(Data),
    BinLen = payload_length_to_binary(Len),
    <<1:1, 0:3, 2:4, 0:1, BinLen/bits, Data/binary>>.
%%    [<<1:1, 0:3, 2:4, 0:1, BinLen/bits>>, Data].

payload_length_to_binary(N) ->
    case N of
        N when N =< 125 -> <<N:7>>;
        N when N =< 16#ffff -> <<126:7, N:16>>;
        N when N =< 16#7fffffffffffffff -> <<127:7, N:64>>
    end.




parse_frames(Frames) ->
    try parse_frames(Frames, []) of
        {Rest, Parsed} ->
            process_frames_2(Rest, Parsed, [])
    catch
        _:Reason ->
            {error, Reason}
    end.
%%
%% Websockets internal functions for RFC6455 and hybi draft
%%
process_frames_2(Rest, [], Acc) ->
    {Rest, lists:reverse(Acc)};
process_frames_2(Rest, [{Opcode, Payload} | T], Acc) ->
    case Opcode of
        8 -> close;
        _ ->
            process_frames_2(Rest, T, [Payload | Acc])
    end.

parse_frames(<<>>, Acc) ->
    {<<>>, lists:reverse(Acc)};
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    Mask:1,
    PayloadLen:7,
    MaskKey:32,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) when PayloadLen < 126 ->
%%    io:format("~p~n", [{PayloadLen, Mask, Rest}]),
    if
        Mask == 1 ->
            Payload2 = unmask(Payload, MaskKey, 0),
            parse_frames(Rest, [{Opcode, Payload2} | Acc]);
        true ->
            parse_frames(Rest, [{Opcode, Payload} | Acc])
    end;
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    Mask:1,
    126:7,
    PayloadLen:16,
    MaskKey:32,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) ->
    if
        Mask == 1 ->
            Payload2 = unmask(Payload, MaskKey, 0),
            parse_frames(Rest, [{Opcode, Payload2} | Acc]);
        true ->
            parse_frames(Rest, [{Opcode, Payload} | Acc])
    end;
%%parse_frames(<<_Fin:1,
%%    _Rsv:3,
%%    _Opcode:4,
%%    _Mask:1,
%%    126:7,
%%    _PayloadLen:16,
%%    _MaskKey:4/binary,
%%    _/binary-unit:8>> = PartFrame,
%%    Acc) ->
%%    ok = mochiweb_socket:exit_if_closed(mochiweb_socket:setopts(Socket, [{packet, 0}, {active, once}])),
%%    receive
%%        {tcp_closed, _} ->
%%            mochiweb_socket:close(Socket),
%%            exit(normal);
%%        {ssl_closed, _} ->
%%            mochiweb_socket:close(Socket),
%%            exit(normal);
%%        {tcp_error, _, _} ->
%%            mochiweb_socket:close(Socket),
%%            exit(normal);
%%        {Proto, _, Continuation} when Proto =:= tcp orelse Proto =:= ssl ->
%%            parse_frames(Socket, <<PartFrame/binary, Continuation/binary>>,
%%                Acc);
%%        _ ->
%%            mochiweb_socket:close(Socket),
%%            exit(normal)
%%    after
%%        5000 ->
%%            mochiweb_socket:close(Socket),
%%            exit(normal)
%%    end;
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    Mask:1,
    127:7,
    0:1,
    PayloadLen:63,
    MaskKey:32,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) ->
    if
        Mask == 1 ->
            Payload2 = unmask(Payload, MaskKey, 0),
            parse_frames(Rest, [{Opcode, Payload2} | Acc]);
        true ->
            parse_frames(Rest, [{Opcode, Payload} | Acc])
    end;
parse_frames(Rest, Acc) ->
    {Rest, lists:reverse(Acc)}.