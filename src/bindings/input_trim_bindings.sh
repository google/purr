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

# Bind: ctrl-w, send a cache wipe request to logcat.
wipe_cmd=(
	'execute-silent('
		$stop_stream
		$update_serial_cmd
		'adb -s $serial logcat -c;'
		$set_slock_off
		"echo 'wipe' > $purr_accept_command_cache;"
		$save_current_query
		$start_stream
	')+accept'
)
bind_commands+=('--bind' "ctrl-w:$wipe_cmd")
rebind_in_default_command_suite "ctrl-w"
unbind_in_adb_command_suite "ctrl-w"
unbind_in_history_command_suite "ctrl-w"
unbind_in_serial_command_suite "ctrl-w"

# Bind: ctrl-t, trim input to the end of the file.
trim_cmd=(
	'execute-silent('
		"trimmed_time=\$(echo {} | cut -d' ' -f1-2);"
		'if [ ! -z $trimmed_time ]; then'
			$stop_stream
			$update_serial_cmd
			$set_slock_off
			"echo 'trim' > $purr_accept_command_cache;"
			# Grab the timestamp from the selected message.
			"echo \$trimmed_time > $purr_time_start_cache;"
			$save_current_query
			$start_stream
		'fi;'
	')+accept-non-empty'
)
bind_commands+=('--bind' "ctrl-t:$trim_cmd")
rebind_in_default_command_suite "ctrl-t"
unbind_in_adb_command_suite "ctrl-t"
unbind_in_history_command_suite "ctrl-t"
unbind_in_serial_command_suite "ctrl-t"

# Bind: ctrl-alt-t, de-trim input.
untrim_cmd=(
	'execute-silent('
		$stop_stream
		$update_serial_cmd
		$set_slock_off
		"echo 'trim' > $purr_accept_command_cache;"
		"echo '' > $purr_time_start_cache;"
		$save_current_query
		$start_stream
	')+accept'
)
bind_commands+=('--bind' "ctrl-alt-t:$untrim_cmd")
rebind_in_default_command_suite "ctrl-alt-t"
unbind_in_adb_command_suite "ctrl-alt-t"
unbind_in_history_command_suite "ctrl-alt-t"
unbind_in_serial_command_suite "ctrl-alt-t"
