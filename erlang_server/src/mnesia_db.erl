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
  get_trip_by_name/1, reset_trips/0, store_trip/3, update_partecipants/2, update_seats/2, update_date/2, update_pid/2,
  get_active_trips/0, get_partecipants/1, delete_trip/1, update_favorites/2, check_if_tripName_present/1, get_user_favorites/1, update_user_favorites/2]).

-record(user, {username, password, favorites}).
-record(trip, {name, pid, organizer, destination, date, seats, partecipants, user_add_to_favorites}).

start_mnesia() ->
  mnesia:create_schema([node()]),
  %% application:set_env(mnesia, dir, "~/mnesia_db_storage"),
  mnesia:start(),
  case mnesia:wait_for_tables([trip, user], 5000) == ok of
    true ->
      io:format("[MNESIA] Mnesia started correctly. ~n"),
      ok;
    false ->
      io:format("[MNESIA] New schema created. ~n"),
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
          password = Password,
          favorites = []
        });
        % mnesia_db:add_joined(Username);
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

get_user_favorites(Username) ->
  T = fun() ->
    %% {username, password, favorites}
    User = #user{username='$1', password ='$2', favorites = '$3'},
    Guard = {'==', '$1', Username},
    mnesia:select(user, [{User, [Guard], ['$3']}])
      end,
  mnesia:transaction(T).

update_user_favorites(NewValue, Username) ->
  T = fun() ->
    [Record] = mnesia:read({user, Username}),
    mnesia:write(Record#user{favorites = NewValue})
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
      name = Name,
      pid = Pid,
      organizer = Organizer,
      destination = Destination,
      date = Date,
      seats = Seats,
      partecipants = [],
      user_add_to_favorites = []
    })
    end,
  mnesia:transaction(T).

get_trip(Pid) ->
  T = fun() ->
    Trip = #trip{name='$1', pid='$2', organizer='$3', destination ='$4', date = '$5', seats ='$6', partecipants ='$7', user_add_to_favorites = '$8'},
    Guard = {'==', '$2', Pid},
    mnesia:select(trip, [{Trip, [Guard], [['$1', '$2', '$3', '$4', '$5', '$6', '$7', '$8']]}])
  end,
  mnesia:transaction(T).

get_active_trips() ->
  T = fun() ->
    %% {pid, organizer, name, destination, date, seats, partecipants}).
    Trip = #trip{name='$1', pid='$2', organizer='$3', destination ='$4', date = '$5', seats ='$6', partecipants ='$7', user_add_to_favorites = '$8'},
    Guard = {'>', '$5', erlang:system_time(1000)},
    mnesia:select(trip, [{Trip, [Guard], [['$1', '$2', '$3', '$4', '$5', '$6', '$7', '$8']]}])
      end,
  mnesia:transaction(T).

get_partecipants(TripName) ->
  T = fun() ->
    %% {pid, organizer, name, destination, date, seats, partecipants}).
    Trip = #trip{name='$1', pid='$2', organizer='$3', destination ='$4', date = '$5', seats ='$6', partecipants ='$7', user_add_to_favorites = '$8'},
    Guard = {'==', '$1', TripName},
    mnesia:select(trip, [{Trip, [Guard], ['$7']}])
      end,
  mnesia:transaction(T).

update_pid(NewValue, TripName) ->
  T = fun() ->
    [Record] = mnesia:read({trip, TripName}),
    mnesia:write(Record#trip{pid = NewValue})
      end,
  mnesia:transaction(T).

check_if_tripName_present(TripName) ->
  T = fun() ->
    io:format("[MNESIA] Checking if trip ~p already exists. ~n", [TripName]),
    case get_trip_by_name(TripName) of
      {atomic, []} ->
        io:format("[MNESIA] Trip ~p not exists in the database. ~n", [TripName]),
        false;
      _ ->
        io:format("[MNESIA] Trip ~p already exists. ~n", [TripName]),
        true
    end
      end,
  mnesia:transaction(T). %% {atomic, false}

update_partecipants(NewValue, TripName) ->
  T = fun() ->
    [Record] = mnesia:read({trip, TripName}),
    mnesia:write(Record#trip{partecipants = NewValue})
  end,
  mnesia:transaction(T).

update_favorites(NewValue, TripName) ->
  T = fun() ->
    [Record] = mnesia:read({trip, TripName}),
    mnesia:write(Record#trip{user_add_to_favorites = NewValue})
      end,
  mnesia:transaction(T).

update_seats(NewValue, TripName) ->
  T = fun() ->
    [Record] = mnesia:read({trip, TripName}),
    mnesia:write(Record#trip{seats = NewValue})
      end,
  mnesia:transaction(T).

update_date(NewValue, TripName) ->
  T = fun() ->
    [Record] = mnesia:read({trip, TripName}),
    mnesia:write(Record#trip{date = NewValue})
      end,
  mnesia:transaction(T).

store_trip(TripName, Seats, Partecipants) ->
  update_partecipants(Partecipants, TripName),
  update_seats(Seats, TripName).

get_trip_by_name(TripName) ->
  T = fun() ->
    %% {pid, organizer, name, destination, date, seats, partecipants}).
    Trip = #trip{name='$1', pid='$2', organizer='$3', destination ='$4', date = '$5', seats ='$6', partecipants ='$7', user_add_to_favorites = '$8'},
    Guard = {'==', '$1', TripName},
    mnesia:select(trip, [{Trip, [Guard], [['$1', '$2', '$3', '$4', '$5', '$6', '$7', '$8']]}])
      end,
  mnesia:transaction(T).

delete_trip(TripName) ->
  T = fun() ->
    io:format("[MNESIA] Deleting trip ~p. ~n", [TripName]),
    mnesia:delete({trip, TripName})
      end,
  mnesia:transaction(T).

reset_trips() ->
    mnesia:clear_table(trip).

