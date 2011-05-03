LIBDIR		= `erl -eval 'io:format("~s~n", [code:lib_dir()])' -s init stop -noshell`
VERSION		= 0.0.1
CC  		= erlc
ERL     	= erl
EBIN		= ebin
CFLAGS  	= -I include -pa $(EBIN)
COMPILE		= $(CC) $(CFLAGS) -o $(EBIN)
EBIN_DIRS 	= $(wildcard deps/*/ebin)

all: ebin compile

compile:
	@$(ERL) -pa $(EBIN_DIRS) -noinput +B -eval 'case make:all() of up_to_date -> halt(0); error -> halt(1) end.'

edoc:
	@erl -noinput -eval 'edoc:application($(APP), "./", [{doc, "doc/"}, {files, "src/"}])' -s erlang halt

ebin:
	@mkdir ebin

clean:
	rm -rf ebin/*.beam ebin/erl_crash.dump erl_crash.dump
	rm -rf ebin/*.boot ebin/*.rel ebin/*.script
	rm -rf doc/*.html doc/*.css doc/erlang.png doc/edoc-info
