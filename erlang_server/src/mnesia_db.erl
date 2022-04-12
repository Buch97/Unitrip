%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. apr 2022 16:34
%%%-------------------------------------------------------------------
-module(mnesia_db).
-author("matteo").

%%% API

-export([start_mnesia/0, add_user/2, check_user_present/1, get_user/1, delete_user/1, perform_login/2, get_trip/1, add_trip/6,
  get_trip_by_name/1, reset_trips/0, store_trip/3]).

-record(user, {username, password}).
-record(trip, {pid, organizer, name, destination, date, seats, partecipants}).

start_mnesia() ->
  mnesia:create_schema([node()]),
  io:format("[MNESIA] New schema created. ~n"),
  %% application:set_env(mnesia, dir, "~/mnesia_db_storage"),
  mnesia:start(),
  case mnesia:wait_for_tables([trip, user], 5000) == ok of
    true ->
      io:format("[MNESIA] Mnesia started correctly. ~n"),
      ok;
    false ->
      mnesia:create_table(user,
        [{attributes, record_info(fields, user)}, {disc_copies, [node()]}]),
      io:format("[MNESIA] Table user created. ~n"),
      mnesia:create_table(trip,
        [{attributes, record_info(fields, trip)}, {disc_copies, [node()]}]),
      io:format("[MNESIA] Table trip created. ~n")
  end.


%%%===================================================================
%%% USER OPERATIONS
%%%===================================================================

add_user(Username, Password) ->
  T = fun() ->
    case mnesia_db:check_user_present(Username) of
      {atomic, false} ->
        io:format("[MNESIA] Adding user ~p. ~n", [{Username, Password}]),
        mnesia:write(#user
        {
          username = Username,
          password = Password
        });
      _ ->
        false
    end
  end,
  mnesia:transaction(T).

%% using the function mnesia:read({Table, Key})
get_user(Username) ->
  T = fun() ->
    mnesia:read({user, Username})
  end,
  mnesia:transaction(T).

%% using the function mnesia:delete({Table, Key})
delete_user(Username) ->
  T = fun() ->
    io:format("[MNESIA] Deleting user ~p. ~n", [Username]),
    mnesia:delete({user, Username})
  end,
  mnesia:transaction(T).

check_user_present(Username) ->
  T = fun() ->
    io:format("[MNESIA] Checking if user ~p is present in the database. ~n", [Username]),
    case get_user(Username) of
      {atomic, []} ->
        io:format("[MNESIA] User ~p not present. ~n", [Username]),
        false;
      _ ->
        io:format("[MNESIA] User ~p already present in the database. ~n", [Username]),
        true
    end
  end,
  mnesia:transaction(T). %% {atomic, false}

perform_login(Username, Password) ->
  T = fun() ->
    io:format("[MNESIA] Performing login of the user ~p. ~n", [Username]),
    case mnesia_db:check_user_present(Username) of
      {atomic, true} ->
        {_, [{user, Username, Pass}]} = get_user(Username),
        case Password =:= Pass of
          true ->
            io:format("[MNESIA] Password correctly verified. ~n"),
            true;
          false ->
            io:format("[MNESIA] Incorrect password. ~n"),
            false
        end;
      _ ->
        false
    end
  end,
  mnesia:transaction(T).

%%%===================================================================
%%% TRIP OPERATIONS
%%%===================================================================

add_trip(Pid, Organizer, Name, Destination, Date, Seats) ->
  T = fun() ->
    io:format("[MNESIA] Adding trip ~p. ~n", [{Pid, Organizer, Name, Destination, Date, Seats}]),
    mnesia:write(#trip{
      pid = Pid,
      organizer = Organizer,
      name = Name,
      destination = Destination,
      date = Date,
      seats = Seats,
      partecipants = none
    })
    end,
  mnesia:transaction(T).

get_trip(Pid) ->
  T = fun() ->
    mnesia:read({trip, Pid})
  end,
  mnesia:transaction(T).

store_trip(Pid, Seats, Partecipants) ->
  ok.

get_trip_by_name(Name) ->
  T = fun() ->
    %% {pid, organizer, name, destination, date, seats, partecipants}).
    Trip = #trip{pid='$1', organizer='$2', name='$3', destination ='$4', date = '$5', seats ='$6', partecipants ='$7'},
    Guard = {'==', '$3', Name},
    mnesia:select(trip, [{Trip, [Guard], [['$1', '$2', '$3', '$4', '$5', '$6', '$7']]}])
      end,
  mnesia:transaction(T).

reset_trips() ->
  mnesia:clear_table(trip).

