%%%-------------------------------------------------------------------
%% @doc erlang_server public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_server_app).
-author("matteo").
-behaviour(gen_server).

%% API export

-export([start_main_server/0, stop/1]).

%% API

start_main_server() ->
    mnesia_db:create_mnesia_schema(),
    Res = gen_server:start({local, main_server}, ?MODULE, [], []),
    io:format("[MAIN] Main server started with result ~p.~n", [Res]),
    Pid = spawn(?MODULE, loop_server, []),
    io:format("[MAIN] Main server spawned loop process with pid ~p. ~n", Pid),
    register(loop_server, Pid).

stop(_State) ->
    ok.

%% internal functions
