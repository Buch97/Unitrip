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

-export([create_mnesia_schema/0, add_user/2, check_user_present/1, get_user/1, delete_user/1, perform_login/2]).

-record(user, {username, password}).
-record(trip, {pid, country, city, users_list = [], timestamp}).

create_mnesia_schema() ->
  mnesia:create_schema([node()]),
  io:format("[MNESIA] New schema created. ~n"),
  application:set_env(mnesia, dir, "~/mnesia_db_storage"),
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
  Fun = fun() ->
    mnesia:write(#user
    {
      username = Username,
      password = Password
    })
        end,
  mnesia:activity(transaction, Fun).

%% using the function mnesia:read({Table, Key})
get_user(Username) ->
  Fun = fun() ->
    io:format("[MNESIA] Searching for user ~p. ~n", [Username]),
    mnesia:read({user, Username})
  end,
  mnesia:activity(transaction, Fun).

%% using the function mnesia:delete({Table, Key})
delete_user(Username) ->
  Fun = fun() ->
    io:format("[MNESIA] Deleting user ~p. ~n", [Username]),
    mnesia:delete({user, Username})
  end,
  mnesia:activity(transaction, Fun).

check_user_present(Username) ->
  Fun = fun() ->
    io:format("[MNESIA] Checking if user ~p is present in the database. ~n", [Username]),
    case get_user(Username) =:= [] of
      true ->
        io:format("[MNESIA] User ~p not present. ~n", [Username]),
        false;
      false ->
        io:format("[MNESIA] User ~p already present in the database. ~n", [Username]),
        true
    end
  end,
  Res = mnesia:activity(transactions, Fun),
  io:format("[MNESIA] Result of the transaction ~p~n", [Res]),
  Res.

perform_login(Username, Password) ->
  Fun = fun() ->
    io:format("[MNESIA] Performing login of the user ~p. ~n", [Username]),
    ({user, Username, Pass}) = get_user(Username),
    case Password =:= Pass of
      true ->
        io:format("[MNESIA] Password correctly verified. ~n"),
        true;
      false ->
        io:format("[MNESIA] Incorrect password. ~n"),
        false
    end
  end,
  mnesia:activity(transactions, Fun).

%%%===================================================================
%%% TRIP OPERATIONS
%%%===================================================================



