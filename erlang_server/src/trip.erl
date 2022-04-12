%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(trip).
-author("matteo").

-export([stop/1, init_trip/5]).

init_trip(Organizer, Name, Destination, Date, Seats) ->
  io:format("[TRIP_NODE] Starting a new erlang node.~n"),
  listener_trip(Organizer, Name, Destination, Date, Seats, []).

listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants) ->
  receive
    {From, new_partecipant, Username} ->
      case Seats == 0 of
        true ->
          io:format("[TRIP NODE] No more seats avaialable. ~n"),
          From ! {self(), false},
          listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants);
        false ->
          NewSeats = Seats - 1,
          NewListPartecipants = Partecipants ++ [Username],
          io:format("[TRIP NODE] User ~p added. ~n", [Username]),
          io:format("[TRIP NODE] Available seats: ~p. ~n", [NewSeats]),
          From ! {self(), true},
          listener_trip(Organizer, Name, Destination, Date, NewSeats, NewListPartecipants)
      end
  end.

stop(_State) ->
  ok.
