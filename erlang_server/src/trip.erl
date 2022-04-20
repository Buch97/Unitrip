%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------

-module(trip).
-author("matteo").

-export([init_trip/7, interval_milliseconds/0, stop/0]).

interval_milliseconds()-> 1000.

init_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites) ->
  io:format("[TRIP_PROCESS] Starting a new erlang process with pid ~p.~n", [self()]),
  erlang:send_after(interval_milliseconds(), self(), {evaluate_exp_date}),
  %% io:format("[TRIP_PROCESS] Paramenters of the process: ~p.~n", [{Name, Organizer, Destination, Date, Seats, Partecipants}]),
  listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites).

listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites) ->
  receive
    {From, new_partecipant, Username} ->
      case Seats > 0 of
        true ->
          case lists:member(Username, Partecipants) of
            false ->
              case mnesia_db:check_user_present(Username) of
                {atomic, true} ->
                  NewSeats = Seats - 1,
                  NewListPartecipants = Partecipants ++ [Username],
                  Result = mnesia_db:update_partecipants(NewListPartecipants, Name),
                  io:format("[TRIP PROCESS] User ~p added. ~n", [Username]),
                  %% io:format("[TRIP PROCESS] Available seats: ~p. ~n", [NewSeats]),
                  From ! {self(), Result},
                  listener_trip(Name, Organizer, Destination, Date, NewSeats, NewListPartecipants, User_Add_To_Favorites);
                _ ->
                  io:format("[TRIP PROCESS] User ~p not present in the database. ~n", [Username]),
                  listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites)
              end;
            true ->
              io:format("[TRIP PROCESS] User ~p has already join the trip. ~n", [Username]),
              listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites)
          end;
        false ->
          io:format("[TRIP PROCESS] No more seats avaialable. ~n"),
          From ! {self(), false},
          listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites)
      end;
    {From, add_to_favorites, Username} ->
      NewFavorites = User_Add_To_Favorites ++ [Username],
      io:format("[TRIP PROCESS] User ~p added to favorites list. ~n", [Username]),
      io:format("[TRIP PROCESS] New favorites lists: ~p. ~n", [NewFavorites]),
      Result = mnesia_db:update_favorites(NewFavorites, Name),
      From ! {self(), Result},
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, NewFavorites);
    {From, delete_from_favorites, Username} ->
      NewFavorites = lists:delete(Username, User_Add_To_Favorites),
      io:format("[TRIP PROCESS] User ~p deleted from favorites list. ~n", [Username]),
      io:format("[TRIP PROCESS] New favorites lists: ~p. ~n", [NewFavorites]),
      Result = mnesia_db:update_favorites(NewFavorites, Name),
      From ! {self(), Result},
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, NewFavorites);
    {From, get_partecipants} ->
      From ! {self(), Partecipants},
      io:format("[TRIP PROCESS] List of partecipants: ~p. ~n", [Partecipants]),
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites);
    {From, get_seats} ->
      From ! {self(), Seats},
      io:format("[TRIP PROCESS] Available seats: ~p. ~n", [Seats]),
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites);
    {From, delete_partecipant, Username} ->
      NewSeats = Seats + 1,
      NewListPartecipants = lists:delete(Username, Partecipants),
      io:format("[TRIP PROCESS] New list of partecipants: ~p. ~n", [NewListPartecipants]),
      Result= mnesia_db:update_partecipants(NewListPartecipants, Name),
      From ! {self(), Result},
      listener_trip(Name, Organizer, Destination, Date, NewSeats, NewListPartecipants, User_Add_To_Favorites);
    {evaluate_exp_date} ->
      case erlang:system_time(1000) > Date of
        true ->
          mnesia_db:store_trip(Name, Seats, Partecipants),
          loop_server ! {self(), delete_trip, Name},
          io:format("[TRIP PROCESS] Trip expired, information stored in the database. ~n");
        false ->
          listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites)
      end;
    _ ->
      io:format("[TRIP PROCESS] Wrong message. ~n"),
      listener_trip(Name, Organizer, Destination, Date, Seats, Partecipants, User_Add_To_Favorites)
  end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

stop() ->
  ok.