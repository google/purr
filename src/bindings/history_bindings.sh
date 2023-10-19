#!/bin/zsh

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

# This code is a bit arcane, but here's basically what it's doing.
# When the query changes, we write an integer and start a timer.
# Once the timer ends, we check the integer; if it's not the same,
# we don't write to history. If it is, we check if we can find the
# query in the history file. We'll then either write it or move it
# to the top. This holistically allows us to write to history even 
# though queries are never "submitted".
history_input=(
	'execute-silent('
		'{'
			"seen_counter=\$(cat $purr_history_counter_cache);"
			'$(( seen_counter += 1 ));'
			"echo \$seen_counter >| $purr_history_counter_cache;"
			'sleep 3.5;'
			"cur_counter=\$(cat $purr_history_counter_cache);"
			'if [ $seen_counter -eq $cur_counter ]; then'
				'query={q};'
				"query=\$(echo \"\$query\" | xargs | tr -s ' ');"
				'if [ -z "$query" ]; then'
					':;'
				"elif /usr/bin/grep -cim1 -x \" *\$query *\" $purr_history_cache; then"
					"line=\$(/usr/bin/grep -n -x \" *\$query *\" $purr_history_cache | cut -d : -f 1);"
					"/usr/bin/sed -i \"\${line}d\" $purr_history_cache;"
					"echo \$query >> $purr_history_cache;"  
					"echo 0 >| $purr_history_pointer_cache;"
				'else;'
					"echo \$query >> $purr_history_cache;"
					"echo 0 >| $purr_history_pointer_cache;"
				'fi;'
			'fi;'
		'} &'
	')'
)
bind_commands+=('--bind' "change:$history_input")

# This just allows the user to use alt-shift-up/down to traverse
# history. We just keep track in the file of where they are. We
# wipe this pointer wheneever we add a new history entry.
history_up=(
	'transform-query('
		"line_count=\$(/usr/bin/wc -l < $purr_history_cache);"
		"cur_pointer=\$(cat $purr_history_pointer_cache);"
		'$(( cur_pointer += 1 ));'
		'if [ $cur_pointer -lt $line_count ]; then'
			"echo \$cur_pointer >| $purr_history_pointer_cache;"
		'else;'
			'$(( cur_pointer -= 1));'
		'fi;'
		'line_to_get="$((line_count - cur_pointer))";'
		"/usr/bin/sed -n -e \${line_to_get}p $purr_history_cache;"
	')'
)
bind_commands+=('--bind' "alt-shift-up:$history_up")
rebind_in_default_command_suite "alt-shift-up"
rebind_in_adb_command_suite "alt-shift-up"
rebind_in_history_command_suite "alt-shift-up"
rebind_in_serial_command_suite "alt-shift-up"

# See above.
history_down=(
	'transform-query('
		"line_count=\$(/usr/bin/wc -l < $purr_history_cache);"
		"cur_pointer=\$(cat $purr_history_pointer_cache);"
		'$(( cur_pointer -= 1 ));'
		'if [ $cur_pointer -ge -1 ]; then'
			"echo \$cur_pointer >| $purr_history_pointer_cache;"
		'else;'
			'$(( cur_pointer += 1));'
		'fi;'
		'line_to_get="$((line_count - cur_pointer))";'
		"/usr/bin/sed -n -e \${line_to_get}p $purr_history_cache;"
	')'
)
bind_commands+=('--bind' "alt-shift-down:$history_down")
rebind_in_default_command_suite "alt-shift-down"
rebind_in_adb_command_suite "alt-shift-down"
rebind_in_history_command_suite "alt-shift-down"
rebind_in_serial_command_suite "alt-shift-down"

# Bind: ctrl-r, show history file.
history_cmd=(
	'execute-silent('
		'{'
			$set_stream_history
			$set_header_history
			$set_slock_off
		'} &'
	')+reload('
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+clear-query+first+hide-preview+enable-search+$history_command_suite+execute-silent(echo 'hidden' >| $purr_preview_visible_cache;)"
)
bind_commands+=('--bind' "ctrl-r:$history_cmd")
rebind_in_default_command_suite "ctrl-r"
unbind_in_adb_command_suite "ctrl-r"
unbind_in_history_command_suite "ctrl-r"
unbind_in_serial_command_suite "ctrl-r"
