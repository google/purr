#!/usr/bin/env zsh

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Bind: Ctrl-h, ask for help in ADB command mode.
adb_help_cmd=(
	'execute-silent('
		'{'
			$set_stream_adb
			$set_header_adb
			$set_slock_off
		'} &'
		$update_serial_cmd
		'query={q};'
		'for string in "--help" "-h" "help"; do'
			'adb_help=$( { eval' "$adb_cmd_loc" '-s $serial shell $query $string" } 2>&1 );'
			'ret=$?;'
			# We are trying best-guesses on what a help prompt might look like here. There isn't
			# a standard for shell commands, so we're going to try the most common ones, and we
			# assume that if a request returns a bunch of lines, maybe it's just dumping help.
			'if { [ $ret -eq 0 ] && [ ! -s $adb_help ] } || [ $(wc -l <<< $adb_help) -ge 15 ]; then'
				"echo \"Ran \\\"adb -s \$serial shell \$query \$string\\\"\"  > $purr_adb_cache;"
				"echo \$adb_help >> $purr_adb_cache;"
				"exit;"
			'fi;'
		'done;'
		"echo \"Could not find help for \\\"\$query\\\"\" >> $purr_adb_cache;"
	')+reload('
		$load_input_stream
	')+disable-search'
)
bind_commands+=('--bind' "ctrl-h:$adb_help_cmd")
unbind_in_default_command_suite "ctrl-h"
rebind_in_adb_command_suite "ctrl-h"
unbind_in_history_command_suite "ctrl-h"
unbind_in_serial_command_suite "ctrl-h"

# We overload the hell of this command...
# Bind: enter, select history command or serial selection.
enter_cmd=(
	'transform-query('
		"if /usr/bin/grep -q \"History\" $purr_stream_header_cache; then"
			'echo {};'
		'else;'
			'echo {q};'
		'fi;'
	')+execute-silent('
		"if /usr/bin/grep -q \"History\" $purr_stream_header_cache; then"
			"echo 'history' > $purr_accept_command_cache;"
			$set_stream_verbose
			$set_header_verbose
			$set_slock_off
			$save_current_query
		"elif /usr/bin/grep -q \"Serial\" $purr_stream_header_cache; then"
			$stop_stream
			"accepted=\$(echo {});"
			'if [ ! -z $accepted ]; then'
				"echo {} > $purr_serial_cache;"
			'fi;'
			"echo 'serial' > $purr_accept_command_cache;"
			$set_stream_verbose
			$set_header_verbose
			$set_slock_off
			$save_current_query
			$start_stream
		"elif /usr/bin/grep -q \"ADB\" $purr_stream_header_cache; then"
			$set_slock_off
			"echo 'adb_cmd' > $purr_accept_command_cache;"
			$save_current_query
		"fi;"
	')+accept'
)
bind_commands+=('--bind' "enter:$enter_cmd")
unbind_in_default_command_suite "enter"
rebind_in_adb_command_suite "enter"
rebind_in_history_command_suite "enter"
rebind_in_serial_command_suite "enter"

# Adds logic to handle the prompt change to track serial numbers.
focus_cmd=(
	'transform-prompt('
		" connection_state=\$(cat $purr_connection_state_cache);"
		'echo $connection_state;'
	')'
)
bind_commands+=('--bind' "focus:$focus_cmd")

# Command to exit purr.
esc_cmd=(
	'execute-silent('
		"echo 'escape' > $purr_accept_command_cache;"
	')+accept'
)
bind_commands+=('--bind' "esc:$esc_cmd")
rebind_in_default_command_suite "esc"
rebind_in_adb_command_suite "esc"
rebind_in_history_command_suite "esc"
rebind_in_serial_command_suite "esc"

# Bind: ctrl-v, for going to the text editor.
cmd_editor=(
	"execute-silent("
		"accepted=\$(echo {});"
		'if [ ! -z $accepted ]; then'
			"echo 'editor' > $purr_accept_command_cache;"
			$save_current_query
		'fi;'
	')+accept-non-empty'
)
bind_commands+=('--bind' "ctrl-v:$cmd_editor")
rebind_in_default_command_suite "ctrl-v"
rebind_in_adb_command_suite "ctrl-v"
unbind_in_history_command_suite "ctrl-v"
unbind_in_serial_command_suite "ctrl-v"
