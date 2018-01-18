-module(ricor).

-export([
         ping/0,
	 put/2,
	 register/2
        ]).

-ignore_xref([
              ping/0,
	      put/2
             ]).

%% Public API

%% @doc Pings a random vnode to make sure communication is functional
ping() ->
    DocIdx = riak_core_util:chash_key({<<"ping">>, term_to_binary(os:timestamp())}),
    PrefList = riak_core_apl:get_primary_apl(DocIdx, 1, ricor),
    [{IndexNode, _Type}] = PrefList,
    riak_core_vnode_master:sync_spawn_command(IndexNode, ping, ricor_vnode_master).

put(Topic, Message) ->
    Index = riak_core_util:chash_key({<<"put">>, term_to_binary(Topic)}),
    PrefList = riak_core_apl:get_primary_apl(Index, 1, ricor),
    [{IndexNode, _Type}] = PrefList,
    riak_core_vnode_master:sync_spawn_command(IndexNode, {put, Topic, Message}, ricor_vnode_master).

register(Topic, Connection) ->
    Index = riak_core_util:chash_key({<<"put">>, term_to_binary(Topic)}),
    PrefList = riak_core_apl:get_primary_apl(Index, 1, ricor),
    [{IndexNode, _Type}] = PrefList,
    riak_core_vnode_master:sync_spawn_command(IndexNode, 
					      {register, Topic, Connection},
					      ricor_vnode_master).
