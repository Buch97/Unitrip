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
 io:format("[LISTENER] Starting OTP gen_server"),
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
   io:format(" [LISTENER] Received a request for registration.~n"),
   Result = erlang_server_app:register_request(Username, Password),
   From ! {self(), Result}
 end,
 receive
  {From, login, {Username, Password}} ->
   io:format(" [LISTENER] Received a request for registration.~n"),
   Result = erlang_server_app:register_request(Username, Password),
   From ! {self(), Result}
 end,
 listener_server_loop().

%%%===================================================================
%%% Internal functions
%%%===================================================================
