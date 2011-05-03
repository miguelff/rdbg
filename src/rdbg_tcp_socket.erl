%% Author: miguelfernandez
%% Created: 28/04/2011
%% Description: TODO: Add description to chainsaw
-module(rdbg_tcp_socket).

%%-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 open/2,
	 async_send/1,
	 init/3,
	 close/0
        ]).

%%
%% Includes
%%
-include("../include/rdbg_headers.hrl").

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Records & Macros - TODO: think about externalize them to an hrl file.
%% --------------------------------------------------------------------
-record(state, {host, port, socket}).

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------



%% {ok, Pid} }  | {error, posix_error()}
open(Host, Port) when (is_list(Host) orelse is_atom(Host)) andalso is_integer(Port) ->
		Pid = spawn_link(?MODULE, init, [self(),Host,Port]),
		receive
			{Pid,ok} -> {ok,Pid};
			{Pid,Error} -> Error;
			Else -> erlang:error(unkown_message,Else)
		end.
		   
		
async_send(Message) ->
  chainsaw_tracer ! {trace_message,Message}.

close()->
	chainsaw_tracer ! {stop,self()},
	receive
		ok -> ?DEBUG("Successfully stoped.");
		{error,Reason} -> ?ERROR(Reason)
	end.


init(Pid,Host,Port)->	
	%shall we discard the Pid after notifying the spawner that we have been correctly spawned?
	erlang:register(chainsaw_tracer,self()),
	State = #state{host=Host,port=Port},
	case gen_tcp:connect(State#state.host,State#state.port,[binary,{packet,0}]) of
		{ok,Socket} -> Pid ! {self(),ok}, loop(State#state{socket=Socket});
		Error -> Pid ! {self(),Error}
	end.

loop(State)->
	receive
		%the following is expected to be received by the client through the API.
		{trace_message,Message} when is_list(Message) -> case gen_tcp:send(State#state.socket, Message) of
															 ok -> loop(State);
															 {error, Reason} -> {tcp_error,Reason}
														 end;
		{stop,Pid} when is_pid(Pid) -> erlang:unregister(chainsaw_tracer),
									   Pid ! gen_tcp:close(State#state.socket);
		%the following are expected to be received by the TCP socket when it's got data to send back.												  
		{tcp,_Socket,Data}-> ?DEBUG({tcp_data_received,Data}),
							loop(State);
		{tcp_closed,Socket}-> ?DEBUG({tcp_closed,Socket}),
							  {tcp_closed,Socket};
		_ -> {error, unknown_message}
	end.

	
