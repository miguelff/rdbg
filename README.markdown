#RDBG an erlang remote debug tracer

This simple library allows the programmer to send log4j tracing events
to chainsaw that will be received using an XMLSocketReceiver.

See [Chainsaw][1] Documentation for a quick tour on the tool.

##Usage

As in regular erlang tracing you would use `dbg:tracer().` to begin
tracing events in the console, you just have to use `rdbg:tracer(host,port).`
To send events to chainsaw (or any other log4j event viewer) listeing for XML
events on the host and port specified.

Once the tracing session begins you could use regular dbg module functions such as 
`dbg:p/2` and `dbg:tp/3` to define the trace events to capture.

When finishing, instead of calling the `dbg:stop_clear()` function, you will just
call 'rdbg:stop/0'.

[1] http://logging.apache.org/chainsaw/quicktour.html
