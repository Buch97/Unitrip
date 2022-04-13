%%%-------------------------------------------------------------------
%% @doc erlang_server top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(erlang_server_sup).
-author("matteo").
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  %% start_link(ServerName, Module, Args, Options)
  {ServerState, Pid} = supervisor:start_link({global, ?MODULE}, ?MODULE, []),
  io:format("[SUPERVISOR] Supervisor spawned with result ~p.~n", [{ServerState, Pid}]),
  Pid.

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional

init(_Args) ->
  io:format("[SUPERVISOR] Init function started ~n"),
  SupFlags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 5},
  MainServer = #{id => erlang_server_app,
    start => {erlang_server_app, start_main_server, []},
    restart => permanent},
  % Monitor = #{id => monitor_trip,
  %   start => {monitor_trip, start_monitor, []},
  %   restart => permanent},
  ChildSpecs = [MainServer],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
