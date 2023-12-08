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

__purr_create_files() {
	local dir_name=$1

	if [ -z $dir_name ]; then
		echo "Can't parse directory name."
		exit 1
	fi

	# File to print input into.
	purr_input_cache="$dir_name/purr-input-cache.purr"
	/usr/bin/touch $purr_input_cache

	# File to print input into.
	purr_instruction_cache="$dir_name/instructions.purr"
	/usr/bin/touch $purr_instruction_cache

	# File to use for editor input.
	purr_editor_input_cache="$dir_name/editor-input-cache.purr"
	/usr/bin/touch $purr_editor_input_cache

	# File to use to keep track of input stream.
	purr_input_stream_cache="$dir_name/input-stream.purr"
	/usr/bin/touch $purr_input_stream_cache

	# File to use to keep track of the stream header message.
	purr_stream_header_cache="$dir_name/stream-header.purr"
	/usr/bin/touch $purr_stream_header_cache

	# File to use to keep track of the query during aborting commands.
	purr_query_cache="$dir_name/query-cache.purr"
	/usr/bin/touch $purr_query_cache

	# File to use to keep track of the sort header message.
	purr_sort_header_cache="$dir_name/sort-header.purr"
	/usr/bin/touch $purr_sort_header_cache

	# File to use to keep track of whether scroll lock is on.
	purr_slock_cache="$dir_name/scroll-lock-header.purr"
	/usr/bin/touch $purr_slock_cache

	# File to use to keep track of the serial number.
	purr_serial_cache="$dir_name/serial-cache.purr"
	/usr/bin/touch $purr_serial_cache

	# File to use to keep track of the state of the device connection.
	purr_connection_state_cache="$dir_name/connection-state.purr"
	/usr/bin/touch $purr_connection_state_cache

	# File to use to keep track of the state of the fzf preview window's visibility.
	purr_preview_visible_cache="$dir_name/preview-visibility-cache.purr"
	/usr/bin/touch $purr_preview_visible_cache

	# File to use to keep track of the state of the fzf preview window's command.
	purr_preview_command_cache="$dir_name/preview-command-cache.purr"
	/usr/bin/touch $purr_preview_command_cache

	# Pipe to communicate with the background handler.
	thread_io_pipe=$dir_name/thread_io_pipe
	mkfifo $thread_io_pipe

	# File to communicate what the accept command intent was.
	purr_accept_command_cache="$dir_name/purr_accept_command_cache.purr"
	/usr/bin/touch $purr_accept_command_cache

	# File to keep track of what time we want to start at.
	purr_time_start_cache="$dir_name/purr_time_start_cache.purr"
	/usr/bin/touch $purr_time_start_cache

	purr_unique_cache="$dir_name/purr_unique_cache.purr"
	/usr/bin/touch $purr_unique_cache

	# Files to input cache the streams into.
	purr_error_input_cache="$dir_name/error-input-cache.purr"
	purr_warning_input_cache="$dir_name/warning-input-cache.purr"
	purr_info_input_cache="$dir_name/info-input-cache.purr"
	purr_verbose_input_cache="$dir_name/verbose-input-cache.purr"

	# Files to input cache the unique version of the streams into.
	purr_error_unique_checksum_cache="$dir_name/error-unique-checksum-cache.purr"
	purr_warning_unique_checksum_cache="$dir_name/warning-unique-checksum-cache.purr"
	purr_info_unique_checksum_cache="$dir_name/info-unique-checksum-cache.purr"
	purr_verbose_unique_checksum_cache="$dir_name/verbose-unique-checksum-cache.purr"

	# Files to input cache the unique version of the streams into.
	purr_error_input_cache_unique="$dir_name/error-unique-input-cache.purr"
	purr_warning_input_cache_unique="$dir_name/warning-unique-input-cache.purr"
	purr_info_input_cache_unique="$dir_name/info-unique-input-cache.purr"
	purr_verbose_input_cache_unique="$dir_name/verbose-unique-input-cache.purr"

	# File to use for purr history. This file is not removed between sessions.
	purr_history_cache="/var/tmp/history.purr"
	/usr/bin/touch $purr_history_cache

	# File to use for the purr history counter.
	purr_history_counter_cache="$dir_name/history-counter.purr"
	/usr/bin/touch $purr_history_counter_cache

	# File to use for purr history location.
	purr_history_pointer_cache="$dir_name/history-pointer.purr"
	/usr/bin/touch $purr_history_pointer_cache

	purr_spc_purpose_cache="$dir_name/spc-purpose-cache.purr"
	/usr/bin/touch $purr_spc_purpose_cache

	# We'll use this to cache the result of ADB commands.
	purr_adb_cache="$dir_name/adb-cache.purr"
	/usr/bin/touch $purr_adb_cache
}

# Writes the instruction file which will be displayed in the
# instruction header when purr starts.
__purr_print_instructions() {
	local purr_instruction_cache=$1

	echo "\x1b[1;1m\x1b[1;4mInstructions\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-p:\x1b[1;0m Toggle this preview window on and off" >>$purr_instruction_cache
	echo "  \x1b[1;1mShift-up/down:\x1b[1;0m Scroll up/down in the instruction window" >>$purr_instruction_cache
	echo "  \x1b[1;1mEscape:\x1b[1;0m Exit" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mStream Modes\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mF1/2/3/4:\x1b[1;0m Show Error/Warning/Info/Verbose streams, respectively" >>$purr_instruction_cache
	echo "  \x1b[1;1mF5:\x1b[1;0m Show the serial selection menu" >>$purr_instruction_cache
	echo "  \x1b[1;1mF6:\x1b[1;0m Enter ADB command mode" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-r:\x1b[1;0m Show the history menu" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mPreview\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-p:\x1b[1;0m Toggles the preview window on/off" >>$purr_instruction_cache
	echo "  \x1b[1;1mF7:\x1b[1;0m Shows the instruction preview" >>$purr_instruction_cache
	echo "  \x1b[1;1mF9:\x1b[1;0m Shows line context in the current stream" >>$purr_instruction_cache
	echo "  \x1b[1;1mF10:\x1b[1;0m Shows line context in the verbose stream" >>$purr_instruction_cache
	echo "  \x1b[1;1mShift-up/down:\x1b[1;0m Scroll up/down in the preview window" >>$purr_instruction_cache
	echo "  \x1b[1;1mHome/End:\x1b[1;0m Scroll one page in the preview window" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mNavigation\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-s:\x1b[1;0m Enable Scroll Lock" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-j:\x1b[1;0m Toggle between Chronological and Relevance sort" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-f:\x1b[1;0m Go to selected line" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-alt-s:\x1b[1;0m Add selected lines tag to the query" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-alt-d:\x1b[1;0m Remove selected lines tag to the query, or adds inverse tag if it doesn't exist" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mADB Controls\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-w:\x1b[1;0m Issues 'adb logcat -c' to permanently wipe device logs" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-t:\x1b[1;0m Trims logs to the selected entries timestamp" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-alt-t:\x1b[1;0m Removes any applied trim" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-h:\x1b[1;0m In ADB command mode, attempts to get the help menu of a command" >>$purr_instruction_cache
	echo "  \x1b[1;1mEnter:\x1b[1;0m  In ADB command mode, execute the current query as:" >>$purr_instruction_cache
	echo "          'adb -s \$serial shell \$query'" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mHistory\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mAlt-shift-up/down:\x1b[1;0m Scroll up/down through history items" >>$purr_instruction_cache
	echo "  \x1b[1;1mEnter:\x1b[1;0m Select an item from the history menu" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mSerial\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mEnter:\x1b[1;0m Select an item from the serial menu" >>$purr_instruction_cache
	echo "" >>$purr_instruction_cache
	echo "\x1b[1;1m\x1b[1;4mMisc.\x1b[1;0m" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-v:\x1b[1;0m Open selected line in text editor" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-y:\x1b[1;0m Copy selected lines" >>$purr_instruction_cache
	echo "  \x1b[1;1mTab:\x1b[1;0m Select multiple lines" >>$purr_instruction_cache
	echo "  \x1b[1;1mCtrl-\:\x1b[1;0m Print simple device information to the clipboard and start a background process to save a bug report to /tmp/bug-report-\$device-\$date.zip." >>$purr_instruction_cache
}
