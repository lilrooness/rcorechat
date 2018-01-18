-module(ricor_websocket_handler).

-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2]).

init(Req, State) ->
    {cowboy_websocket, Req, State, #{idle_timeout => 60000 * 20}}.

websocket_init(State) ->
    {ok, State}.

websocket_handle({text, Data}, State) ->
    ClientData = jsone:decode(Data, [{object_format, map}]),
    #{<<"command">> := Command, <<"topic">> := Topic} = ClientData,
    case Command of
      <<"register">> ->
        io:format("REGISTER: ~p~n", [Topic]),
        ricor:register(Topic, self());
      <<"message">> ->
        #{<<"message">> := Message} = ClientData,
        io:format("MESSAGE: ~p~n", [Message]),
	ricor:put(Topic, Message)
    end,

    {ok, State};

websocket_handle(Message, State) ->
    io:format("unrecognised message: ~p~n", [Message]),
    {ok, State}.

websocket_info(Message, State) ->
    io:format("RESPOND: ~p~n", [Message]),
    Response = jsone:encode(#{message => Message}),
    {reply, {text, Response}, State}.

