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

# Bind: F1, show logcat error stream.
error_cmd=(
	'execute-silent('
		'{'
			"if $is_unique_on; then"
				$set_stream_error_unique
			"else;"
				$set_stream_error
			"fi;"
			$set_header_error
			$set_slock_off
		'} &'
	')+reload('
		$inject_empty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+$default_command_suite"
)
bind_commands+=('--bind' "f1:$error_cmd")

# Bind: F2, show logcat warning stream.
warn_cmd=(
	'execute-silent('
		'{'
			"if $is_unique_on; then"
				$set_stream_warning_unique
			"else;"
				$set_stream_warning
			"fi;"
			$set_header_warning
			$set_slock_off
		'} &'
	')+reload('
		$inject_empty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+$default_command_suite"
)
bind_commands+=('--bind' "f2:$warn_cmd")

# Bind: F3, show logcat info stream.
info_cmd=(
	'execute-silent('
		'{'
			"if $is_unique_on; then"
				$set_stream_info_unique
			"else;"
				$set_stream_info
			"fi;"
			$set_header_info
			$set_slock_off
		'} &'
	')+reload('
		$inject_empty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+$default_command_suite"
)
bind_commands+=('--bind' "f3:$info_cmd")

# Bind: F4, show logcat verbose stream.
verb_cmd=(
	'execute-silent('
		'{'
			"if $is_unique_on; then"
				$set_stream_verbose_unique
			"else;"
				$set_stream_verbose
			"fi;"
			$set_header_verbose
			$set_slock_off
		'} &'
	')+reload('
		$inject_emppty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+$default_command_suite"
)
bind_commands+=('--bind' "f4:$verb_cmd")

# Bind: F5, show serial stream.
serial_cmd=(
	'execute-silent('
		'{'
			$set_stream_serial
			$set_header_serial
			$set_slock_off
		'} &'
	')+reload('
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+enable-search+hide-preview+$serial_command_suite+execute-silent(echo 'hidden' >| $purr_preview_visible_cache;)"
)
bind_commands+=('--bind' "f5:$serial_cmd")

# Bind: F6, open adb command mode.
adb_stream_cmd=(
	'execute-silent('
		'{'
			$set_stream_adb
			$set_header_adb
			$set_slock_off
		'} &'
	')+reload('
		$inject_empty_line
		$load_input_stream
	")+transform-header("
		$load_generic_header
	")+first+disable-search+hide-preview+$adb_command_suite+execute-silent(echo 'hidden' >| $purr_preview_visible_cache;)"
)
bind_commands+=('--bind' "f6:$adb_stream_cmd")
