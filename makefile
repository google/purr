OUTDIR?=$(CURDIR)/out
SRCDIR?=$(CURDIR)/src
RESDIR?=$(CURDIR)/res

PURRFILE ?=$(OUTDIR)/purr
PURRFILE_TEMP ?=$(OUTDIR)/purr_temp

all: purr

.PHONY: purr

purr: 
	mkdir -p $(OUTDIR)
	echo "" > $(PURRFILE)

	# We first need the threading functions, since we use them as part of shell
	# env setup, specifically to create the cache files.
	cat $(SRCDIR)/threads/thread_background.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/threads/thread_controller.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/threads/thread_interface.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/threads/thread_setup.sh >> "$(PURRFILE)"

	# We can then cleanly do shell setup.
	cat $(SRCDIR)/shell/shell_utils.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/shell/argument_parsing.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/shell/shell_env_check.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/shell/shell_env_init.sh >> "$(PURRFILE)"

	# After we've validated the shell, we want to query for a serial number.
	cat $(SRCDIR)/serial/serial_picker.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/serial/serial_interface.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/serial/serial_init.sh >> "$(PURRFILE)"

	# Load in all the UI utilities. We'll need these for setting up the fzf
	# environment in the next step.
	cat $(SRCDIR)/ui/ui_strings.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/ui/ui_utils.sh >> "$(PURRFILE)"

	# Finalizes the fzf environment; program is in a ready state at this point.
	# We just need to load in all the UI/UX elements from bindings.
	cat $(SRCDIR)/fzf_env/load_copy_program.sh >> "$(PURRFILE)"
	cat $(SRCDIR)/fzf_env/fzf_default_state.sh >> "$(PURRFILE)"

	# Load the binding libraries; this is the main block of code for purr.
	cat $(SRCDIR)/bindings/*.sh >> "$(PURRFILE)"

	# Load the execution loop that actually makes things happen.
	cat $(SRCDIR)/execution_loop.sh >> "$(PURRFILE)"

	# Remove comments/shebangs.
	sed -i -e '/^[ \t]*#/d' "$(PURRFILE)"

	# Add one shebang and the copyright notice.
	# We need a temp file since cat can't do it in-place.
	cat $(RESDIR)/header/purr_header.txt $(PURRFILE)  > $(PURRFILE_TEMP)

	# Undo the temp file swap
	mv -f $(PURRFILE_TEMP) $(PURRFILE)

	# Grant execution permission.
	chmod 777 $(PURRFILE)

.PHONY: clean

clean:
	[ -e $(OUTDIR) ] && rm -r $(OUTDIR) || true
