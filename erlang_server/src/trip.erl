%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(trip).
-author("matteo").

-export([init_trip/5, interval_milliseconds/0, stop/0]).

interval_milliseconds()-> 1000.

init_trip(Organizer, Name, Destination, Date, Seats) ->
  io:format("[TRIP_PROCESS] Starting a new erlang process.~n"),
  erlang:send_after(interval_milliseconds(), self(), {evaluate_exp_date}),
  listener_trip(Organizer, Name, Destination, Date, Seats, []).

listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants) ->
  receive
    {From, new_partecipant, Username} ->
      case Seats /= 0 of
        true ->
          case mnesia_db:check_user_present(Username) of
            {atomic, true} ->
              NewSeats = Seats - 1,
              NewListPartecipants = Partecipants ++ [Username],
              io:format("[TRIP PROCESS] User ~p added. ~n", [Username]),
              io:format("[TRIP PROCESS] Available seats: ~p. ~n", [NewSeats]),
              From ! {self(), true},
              listener_trip(Organizer, Name, Destination, Date, NewSeats, NewListPartecipants);
            _ ->
              io:format("[TRIP PROCESS] User ~p not present in the database. ~n", [Username]),
              listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants)
          end;
        false ->
          io:format("[TRIP PROCESS] No more seats avaialable. ~n"),
          From ! {self(), false},
          listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants)
      end;
    {From, get_partecipants} ->
      From ! {self(), Partecipants},
      io:format("[TRIP PROCESS] List of partecipants: ~p. ~n", [Partecipants]),
      listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants);
    {From, get_seats} ->
      From ! {self(), Seats},
      io:format("[TRIP PROCESS] Available seats: ~p. ~n", [Seats]),
      listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants);
    {evaluate_exp_date} ->
      case erlang:system_time() > Date of
        true ->
          mnesia_db:store_trip(self(), Seats, Partecipants),
          io:format("[TRIP PROCESS] Trip expired, information stored in the database. ~n"),
          exit(self(), kill);
        false ->
          listener_trip(Organizer, Name, Destination, Date, Seats, Partecipants)
      end
  end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

stop() ->
  ok.