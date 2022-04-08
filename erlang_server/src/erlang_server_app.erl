%%%-------------------------------------------------------------------
%% @doc erlang_server public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_server_app).
-author("matteo").
-behaviour(gen_server).

%% API export

-import(mnesia_db, [start_mnesia/0, add_user/2, check_user_present/1, get_user/1, delete_user/1, perform_login/2]).
-export([start_main_server/0, stop/1, register_request/2, init/1, handle_call/3, login_request/2]).

%%%-------------------------------------------------------------------
%%% API FUNCTIONS
%%%-------------------------------------------------------------------

start_main_server() ->
    mnesia_db:start_mnesia(),
    Res = gen_server:start({local, main_server}, ?MODULE, [], []),
    io:format("[MAIN_SERVER] OTP gen_server server started with result ~p.~n", [Res]),
    Res.

register_request(Username, Password) ->
    case mnesia_db:check_user_present(Username) of
        {atomic, false} ->
            gen_server:call(main_server, {register, Username, Password});
        _ ->
            {false}
    end.

login_request(Username, Password) ->
    case mnesia_db:check_user_present(Username) of
        {atomic, true} ->
            gen_server:call(main_server, {login, Username, Password});
        _ ->
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
    io:format("[MAIN_SERVER] Result of the transaction ~p. ~n", [Result]),
    {reply, Result, _ServerState};
handle_call({login, Username, Password}, _From, _ServerState) ->
    Result = mnesia_db:perform_login(Username, Password),
    io:format("[MAIN_SERVER] Result of the transaction ~p. ~n", [Result]),
    {reply, Result, _ServerState}.