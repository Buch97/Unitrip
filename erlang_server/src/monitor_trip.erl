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
-export([start_monitor/0, monitor_loop/1]).

start_monitor() ->
  io:format("[MONITOR] Monitor started with pid ~p. ~n", [self()]),
  register('monitor_trip', self()),
  monitor_loop([]).

monitor_loop(ServerState) ->
  receive
    {add_to_monitor, Pid} ->
      io:format("[MONITOR] Received a request for monitoring process ~p.~n", [Pid]),
      Res = monitor(process, Pid),
      NewServerState = ServerState ++ [Pid],
      io:format("[MONITOR] NewServerState: ~p, Reference: ~p.~n", [NewServerState, Res]),
      monitor_loop(NewServerState);
    {'DOWN', Ref, process, Pid, Reason} ->
      case Reason =:= killed orelse Reason =:= normal of
        true ->
          io:format("[MONITOR] The process ~p terminated with reason ~p and Ref ~p.~n", [Pid, Reason, Ref]),
          io:format("[MONITOR] Removing the process from the list.~n"),
          NewServerState = lists:delete(Pid, ServerState),
          io:format("[MONITOR] New ServerState: ~p.~n", [NewServerState]),
          monitor_loop(NewServerState);
        false ->
          %% restart the process that crashes
          io:format("[MONITOR] The process ~p terminated with reason ~p and Ref ~p.~n", [Pid, Reason, Ref]),
          Result = mnesia_db:get_trip(Pid),
          List = element(2, Result),
          TripName = lists:nth(1, List),
          Organizer = lists:nth(3, List),
          Destination = lists:nth(4, List),
          Date = lists:nth(5, List),
          Seats = lists:nth(6, List),
          Partecipants = lists:nth(7, List),
          User_Add_To_Favorites = lists:nth(8, List),
          NewPid = spawn( fun() -> trip:init_trip(TripName, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites) end),
          io:format("[MONITOR] Process ~p respawned with pid ~p. ~n", [Pid, NewPid]),
          mnesia_db:update_pid(NewPid, TripName),
          io:format("[MONITOR] Removing the process from the list.~n"),
          NewServerState = lists:delete(Pid, ServerState),
          io:format("[MONITOR] New ServerState: ~p.~n", [NewServerState]),
          self() ! {add_to_monitor, NewPid},
          monitor_loop(NewServerState)
      end;
    _ ->
      io:format("[MONITOR] Message not recognized. ~n"),
      monitor_loop(ServerState)
  end.


