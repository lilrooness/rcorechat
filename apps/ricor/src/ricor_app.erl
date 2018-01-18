-module(ricor_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Ret = case ricor_sup:start_link() of
        {ok, Pid} ->
            ok = riak_core:register([{vnode_module, ricor_vnode}]),
            ok = riak_core_node_watcher:service_up(ricor, self()),

            {ok, Pid};
        {error, Reason} ->
            {error, Reason}
    end,

    ets:new(connections, [named_table, public]),
    Ret,

    Dispatch = cowboy_router:compile([
        			      {'_', [{"/ws", ricor_websocket_handler, []}]}
        			     ]),

    {ok, Port} = application:get_env(ricor, cowboy_websocket_port),
    cowboy:start_clear(ws_listener, [{port, Port}], #{env => #{dispatch => Dispatch}}).

stop(_State) ->
    ok.
