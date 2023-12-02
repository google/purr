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

# Bind: ctrl-u, toggle unique mode.
unique_cmd=(
	'execute-silent('
		"if $is_unique_on; then"
			$set_unique_off
			"sed -i 's/verbose-unique/verbose/g' $purr_input_stream_cache;"
			"sed -i 's/info-unique/info/g' $purr_input_stream_cache;"
			"sed -i 's/warning-unique/warning/g' $purr_input_stream_cache;"
			"sed -i 's/error-unique/error/g' $purr_input_stream_cache;"
		"else;"
			$set_unique_on
			"sed -i 's/verbose/verbose-unique/g' $purr_input_stream_cache;"
			"sed -i 's/info/info-unique/g' $purr_input_stream_cache;"
			"sed -i 's/warning/warning-unique/g' $purr_input_stream_cache;"
			"sed -i 's/error/error-unique/g' $purr_input_stream_cache;"
		"fi;"
	')+reload('
		$inject_emppty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+$default_command_suite"
)
bind_commands+=('--bind' "ctrl-u:$unique_cmd")
rebind_in_default_command_suite "ctrl-u"
unbind_in_adb_command_suite "ctrl-u"
unbind_in_history_command_suite "ctrl-u"
unbind_in_serial_command_suite "ctrl-u"

# Bind: ctrl-s, toggle scroll lock.
stop_cmd=(
	'execute-silent('
		'{'
			"if $is_slock_on; then"
				$set_slock_off
			"else"
				$set_slock_on
			"fi"
		'} &'
	')+toggle-track+transform-header('
		$load_generic_header
	")+$default_command_suite"
)
bind_commands+=('--bind' "ctrl-s:$stop_cmd")
rebind_in_default_command_suite "ctrl-s"
rebind_in_adb_command_suite "ctrl-s"
unbind_in_history_command_suite "ctrl-s"
unbind_in_serial_command_suite "ctrl-s"

# Bind: ctrl-j, toggle chronological/relevance sort.
cmd_sort=(
	"toggle-sort+execute-silent("
		'{'
			"if $is_sort_chrono; then"
				$set_sort_relevance
			"else"
				$set_sort_chrono
			"fi"
		'} &'
	")+transform-header("
		$load_generic_header
	")+$default_command_suite"
)
bind_commands+=('--bind' "ctrl-j:$cmd_sort")
rebind_in_default_command_suite "ctrl-j"
rebind_in_adb_command_suite "ctrl-j"
rebind_in_history_command_suite "ctrl-j"
rebind_in_serial_command_suite "ctrl-j"
