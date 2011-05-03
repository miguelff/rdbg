%% Author: miguelfernandez
%% Created: 03/05/2011
%% Description: TODO: Add description to rdbg
-module(rdbg).

%%
%% Exported Functions
%%
-export([tracer/2,
		 stop/0,
		 receive_traces/1]).



%%
%% Includes
%%
-include("../include/rdbg_headers.hrl").

%%
%% API Functions
%%

tracer(Host, Port) when (is_list(Host) orelse is_atom(Host)) andalso is_integer(Port) ->
		{ok, _ChainsawPid} = rdbg_tcp_socket:open(Host,Port),
		MessageReceiverPid = spawn_link(?MODULE,receive_traces,[1]),
		dbg:tracer(process,{fun dbg:dhandler/2,MessageReceiverPid}).

stop()->
	rdbg_tcp_socket:close(),
	dbg:stop_clear().

receive_traces(SeqNumber) ->
	receive
	{io_request,From,ReplyAs,{put_chars,io_lib,format,[FormatStr,Args]}} when is_pid(From) ->
		send(io_lib:format(FormatStr, Args),SeqNumber),
	 	From ! {io_reply,ReplyAs,ok},
	 	receive_traces(SeqNumber+1);
	Else -> erlang:error(unknown_message,Else)
    end.

%% sends the given TraceRequest to the chainsaw socket adapter 
send(Message,SeqNumber) ->
	rdbg_tcp_socket:async_send(log4j_message(timestamp(erlang:now()), 
											 SeqNumber, 
											 Message)).

timestamp({Mega, Seconds, Nano}) ->
	Mega * 1000000000 + Seconds + Nano div 1000.

log4j_message(Timestamp, SeqNumber, Message) ->
	[<<"<log4j:event logger=\"erlang.Process\" timestamp=\"">>, 
	 integer_to_list(Timestamp), 
	 <<"\" sequenceNumber=\"">>,
	 integer_to_list(SeqNumber),
	  <<"\" level=\"TRACE\" thread=\"main\"> <log4j:message><![CDATA[">>, 
	 Message, 
	 <<"]]></log4j:message></log4j:event>">>].