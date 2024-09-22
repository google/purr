OUTDIR?=$(CURDIR)/out
OBJDIR?=$(CURDIR)/obj
SRCDIR?=$(CURDIR)/src
RESDIR?=$(CURDIR)/res
TESTDIR?=$(CURDIR)/tests

PURRFILE ?=$(OUTDIR)/purr
PURRFILE_TEMP ?=$(OBJDIR)/purr

ADBMOCKFILE ?=$(OUTDIR)/adb_mock
ADBMOCKFILE_TEMP ?=$(OBJDIR)/adb_mock

FILETESTERFILE ?=$(OUTDIR)/file_tester
FILETESTERFILE_TEMP ?=$(OBJDIR)/file_tester

all: purr adb_mock file_tester

.PHONY: purr

purr:
	mkdir -p $(OUTDIR)
	mkdir -p $(OBJDIR)

	echo "" > $(PURRFILE)
	echo "" > $(PURRFILE_TEMP)

	# We first need the threading functions, since we use them as part of shell
	# env setup, specifically to create the cache files.
	cat $(SRCDIR)/threads/thread_background.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/threads/thread_controller.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/threads/thread_interface.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/threads/thread_setup.sh >> "$(PURRFILE_TEMP)"

	# We can then cleanly do shell setup.
	cat $(SRCDIR)/shell/shell_utils.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/shell/argument_parsing.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/shell/shell_env_check.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/shell/shell_env_init.sh >> "$(PURRFILE_TEMP)"

	# After we've validated the shell, we want to query for a serial number.
	cat $(SRCDIR)/serial/serial_picker.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/serial/serial_interface.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/serial/serial_init.sh >> "$(PURRFILE_TEMP)"

	# Load in all the UI utilities. We'll need these for setting up the fzf
	# environment in the next step.
	cat $(SRCDIR)/ui/ui_strings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/ui/ui_utils.sh >> "$(PURRFILE_TEMP)"

	# Finalizes the fzf environment; program is in a ready state at this point.
	# We just need to load in all the UI/UX elements from bindings.
	cat $(SRCDIR)/fzf_env/load_copy_program.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/fzf_env/fzf_default_state.sh >> "$(PURRFILE_TEMP)"

	# Load the binding libraries; this is the main block of code for purr.
	# Order here isn't super important, but the stream bindings need to be
	# at the very bottom after the command suites are fully initialized.
	cat $(SRCDIR)/bindings/command_suites.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/copy_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/history_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/input_trim_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/misc_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/mode_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/navigation_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/preview_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/query_bindings.sh >> "$(PURRFILE_TEMP)"
	cat $(SRCDIR)/bindings/stream_bindings.sh >> "$(PURRFILE_TEMP)"

	# Load the execution loop that actually makes things happen.
	cat $(SRCDIR)/execution_loop.sh >> "$(PURRFILE_TEMP)"

	# Remove comments/shebangs.
	sed -e '/^[ \t]*#/d' "$(PURRFILE_TEMP)" > $(PURRFILE)
	mv $(PURRFILE) "$(PURRFILE_TEMP)"

	# Add one shebang and the copyright notice.
	# We need a temp file since cat can't do it in-place.
	cat $(RESDIR)/header/purr_header.txt $(PURRFILE_TEMP)  > $(PURRFILE)

	# Grant execution permission.
	chmod +rwx $(PURRFILE)

.PHONY: adb_mock

adb_mock:
	mkdir -p $(OUTDIR)
	mkdir -p $(OBJDIR)

	echo "" > $(ADBMOCKFILE)
	echo "" > $(ADBMOCKFILE_TEMP)

	cat $(TESTDIR)/res/adb_log_example.sh >> "$(ADBMOCKFILE_TEMP)"
	cat $(TESTDIR)/mocks/adb_mock.sh >> "$(ADBMOCKFILE_TEMP)"

	# Remove comments/shebangs.
	sed -e '/^[ \t]*#/d' "$(ADBMOCKFILE_TEMP)" > $(ADBMOCKFILE)
	mv $(ADBMOCKFILE) "$(ADBMOCKFILE_TEMP)"

	# Add one shebang and the copyright notice.
	# We need a temp file since cat can't do it in-place.
	cat $(RESDIR)/header/purr_header.txt $(ADBMOCKFILE_TEMP)  > $(ADBMOCKFILE)

	# Grant execution permission.
	chmod +rwx $(ADBMOCKFILE)

.PHONY: file_tester

file_tester:
	mkdir -p $(OUTDIR)
	mkdir -p $(OBJDIR)

	echo "" > $(FILETESTERFILE)
	echo "" > $(FILETESTERFILE_TEMP)

	cat $(TESTDIR)/res/adb_log_example.sh >> "$(FILETESTERFILE_TEMP)"
	cat $(TESTDIR)/validators/file_validator.sh >> "$(FILETESTERFILE_TEMP)"

	# Remove comments/shebangs.
	sed -e '/^[ \t]*#/d' "$(FILETESTERFILE_TEMP)" > $(FILETESTERFILE)
	mv $(FILETESTERFILE) "$(FILETESTERFILE_TEMP)"

	# Add one shebang and the copyright notice.
	# We need a temp file since cat can't do it in-place.
	cat $(RESDIR)/header/purr_header.txt $(FILETESTERFILE_TEMP)  > $(FILETESTERFILE)

	# Grant execution permission.
	chmod +rwx $(FILETESTERFILE)

.PHONY: clean

clean:
	[ -e $(OUTDIR) ] && rm -r $(OUTDIR) || true
	[ -e $(OBJDIR) ] && rm -r $(OBJDIR) || true
