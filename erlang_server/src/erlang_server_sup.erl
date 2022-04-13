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
  Supervisor = supervisor:start_link({global, ?MODULE}, ?MODULE, []),
  io:format("[SUPERVISOR] Supervisor spawned."),
  Supervisor.

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
  LoopServer = #{id => loop_server,
    start => {loop_server, init_listener, []},
    restart => permanent},
  Monitor = #{id => monitor,
    start => {monitor, start_monitor, []},
    restart => permanent},
  ChildSpecs = [LoopServer, Monitor],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
