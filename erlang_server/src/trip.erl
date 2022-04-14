%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------

-module(trip).
-author("matteo").

-export([init_trip/6, interval_milliseconds/0, stop/0]).

interval_milliseconds()-> 1000.

init_trip(Name, Organizer, Destination, Date, Seats, Partecipants) ->
  io:format("[TRIP_PROCESS] Starting a new erlang process with pid ~p.~n", [self()]),
  erlang:send_after(interval_milliseconds(), self(), {evaluate_exp_date}),
  %% io:format("[TRIP_PROCESS] Paramenters of the process: ~p.~n", [{Name, Organizer, Destination, Date, Seats, Partecipants}]),
  listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants).

listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants) ->
  receive
    {From, new_partecipant, Username} ->
      case Seats /= 0 of
        true ->
          case mnesia_db:check_user_present(Username) of
            {atomic, true} ->
              NewSeats = Seats - 1,
              NewListPartecipants = Partecipants ++ [Username],
              mnesia_db:update_partecipants(NewListPartecipants, Name),
              Result = mnesia_db:get_joined_by_username(Username),
              OldList = lists:nth(1, element(2, Result)),
              mnesia_db:update_joined_list(Name, Username, OldList),
              %% mnesia_db:update_seats(NewSeats, self()),
              io:format("[TRIP PROCESS] User ~p added. ~n", [Username]),
              %% io:format("[TRIP PROCESS] Available seats: ~p. ~n", [NewSeats]),
              From ! {self(), true},
              listener_trip(Name, Organizer, Destination, Date, NewSeats, NewListPartecipants);
            _ ->
              io:format("[TRIP PROCESS] User ~p not present in the database. ~n", [Username]),
              listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants)
          end;
        false ->
          io:format("[TRIP PROCESS] No more seats avaialable. ~n"),
          From ! {self(), false},
          listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants)
      end;
    {From, get_partecipants} ->
      From ! {self(), Partecipants},
      io:format("[TRIP PROCESS] List of partecipants: ~p. ~n", [Partecipants]),
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants);
    {From, get_seats} ->
      From ! {self(), Seats},
      io:format("[TRIP PROCESS] Available seats: ~p. ~n", [Seats]),
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants);
    {evaluate_exp_date} ->
      case erlang:system_time(1000) > Date of
        true ->
          mnesia_db:store_trip(Name, Seats, Partecipants),
          loop_server ! {self(), delete_trip},
          io:format("[TRIP PROCESS] Trip expired, information stored in the database. ~n"),
          exit(self(), kill);
        false ->
          listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants)
      end
  end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

stop() ->
  ok.