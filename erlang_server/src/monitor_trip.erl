%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. apr 2022 16:17
%%%-------------------------------------------------------------------
-module(monitor_trip).
-author("matteo").

%% API
-export([start_monitor/0]).

start_monitor() ->
  io:format("[MONITOR] Monitor started with pid ~p. ~n", [self()]),
  register('monitor_trip', self()).
  %monitor_loop().

monitor_loop() ->
  receive
    {_From, request, parameters} ->
      ok
  end.


