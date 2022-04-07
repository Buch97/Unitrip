%%%-------------------------------------------------------------------
%% @doc erlang_server public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_server_app).
-author("matteo").
-behaviour(gen_server).

%% API export

-export([start_main_server/0, stop/1, register_request/2, init/1, handle_call/3]).

%%%-------------------------------------------------------------------
%%% API FUNCTIONS
%%%-------------------------------------------------------------------

start_main_server() ->
    mnesia_db:start_mnesia(),
    Res = gen_server:start({local, main_server}, ?MODULE, [], []),
    io:format("[MAIN_SERVER] OTP gen_server server started with result ~p.~n", [Res]),
    Res.

register_request(Username, Password) ->
    case mnesia_db:check_user_present(Username) =:= false of
        true ->
            gen_server:call(main_server, {register, Username, Password});
        false ->
            {false}
    end.

stop(_State) ->
    ok.

%%%-------------------------------------------------------------------
%%% gen_server CALLBACK FUNCTIONS
%%%-------------------------------------------------------------------

%The server state maintain the list of the active trips
init([]) ->
    {ok, []}.   % general format: {ok, InitialState}

handle_call({register, Username, Password}, _From, _ServerState) ->
    Result = mnesia_db:add_user(Username, Password),
    {reply, Result, _ServerState};
handle_call({login, Username, Password}, _From, _ServerState) ->
    Result = mnesia_db:perform_login(Username, Password),
    {reply, Result, _ServerState}.