%%%-------------------------------------------------------------------
%%% @author matteo
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. apr 2022 11:51
%%%-------------------------------------------------------------------
-module(loop_server).
-author("matteo").

-import(erlang_server_app, [start_main_server/0, stop/1, register_request/2]).
-export([init_listener/0]).


%%--------------------------------------------------------------------
%% @private
%% @doc
%% The init listener function starts the OTP gen_server and spawn the
%% process that exploit the loop.
%%
%% @end
%%--------------------------------------------------------------------

init_listener() ->
 io:format("[LISTENER] Starting OTP gen_server. ~n"),
 erlang_server_app:start_main_server(),
 LoopServer = spawn(fun() -> listener_server_loop() end ),
 io:format("[LISTENER] Loop server spawned with pid ~p. ~n", [LoopServer]),
 register('loop_server', LoopServer),
 LoopServer.

%%--------------------------------------------------------------------
%% @private
%% @doc
%%
%%
%% @end
%%--------------------------------------------------------------------

listener_server_loop() ->
 receive
  {From, register, {Username, Password}} ->
   io:format("[LISTENER] Received a request for registration.~n"),
   Result = erlang_server_app:register_request(Username, Password),
   From ! {self(), Result};
  {From, login, {Username, Password}} ->
   io:format("[LISTENER] Received a request for login.~n"),
   Result = erlang_server_app:login_request(Username, Password),
   From ! {self(), Result};
  {From, delete, Username} ->
   io:format("[LISTENER] Received a request for deleting user ~p.~n", [Username]),
   Result = erlang_server_app:delete_request(Username),
   From ! {self(), Result};
  {From, create_trip, {Organizer, Name, Destination, Date, Seats}} ->
   io:format("[LISTENER] Received a request for creating a new trip.~n"),
   Result = erlang_server_app:create_trip_request(Organizer, Name, Destination, Date, Seats),
   From ! {self(), Result};
  {From, get_trips} ->
   io:format("[LISTENER] Received a request for getting available trips.~n"),
   Result = erlang_server_app:get_trips_request(),
   From ! {self(), Result};
  {From, get_trip_by_name, Name} ->
   io:format("[LISTENER] Received a request for getting a trips by name.~n"),
   Result = erlang_server_app:trip_by_name(Name),
   From ! {self(), Result};
  {From, reset_trips} ->
   io:format("[LISTENER] Received a request for delete available trips.~n"),
   Result = erlang_server_app:reset_trips(),
   From ! {self(), Result}
 end,
 listener_server_loop().

%%%===================================================================
%%% Internal functions
%%%===================================================================
