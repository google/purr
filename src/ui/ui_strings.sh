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

# Prompt for each input stream.
stream_error_msg="\x1b[1;31mError\x1b[1;0m\t\t"
stream_warn_msg="\x1b[1;33mWarning\x1b[1;0m\t\t"
stream_info_msg="\x1b[1;32mInfo\x1b[1;0m\t\t"
stream_verbose_msg="\x1b[1;34mVerbose\x1b[1;0m\t\t"
stream_focus_msg="\x1b[1;35mFocus\x1b[1;0m\t\t"
stream_adb_msg="\x1b[1;35mADB\x1b[1;0m\t\t"

# Prompt for scroll lock on/off.
slock_on_msg="\x1b[1;31mOn   \x1b[1;0m"
slock_off_msg="\x1b[1;32mOff  \x1b[1;0m"

# Prompt for scroll lock on/off.
unique_on_msg="\x1b[1;31mOn   \x1b[1;0m"
unique_off_msg="\x1b[1;32mOff  \x1b[1;0m"

# Prompt for each sorting mode.
sorting_chronological="\x1b[1;35mChronological\x1b[1;0m\t"
sorting_relevance="\x1b[1;36mRelevance\x1b[1;0m\t\t"

# Some reasonable defaults for FZF.
fzf_params=('--exact' '--ansi' '--tac' '--no-sort' '--multi' $query_string)
fzf_pretty=('--info' 'inline' '--pointer' '>')
fzf_header=('--header-first')
label_header="     Date   $(date +"%Z %z")    PID   TID"
fzf_label=('--border-label' $label_header '--border-label-pos' '1:top')
fzf_gui=('--border' '--margin' '0.5%' '--padding' '0.5%' '--height' '100%')

fzfpnh=($fzf_params $fzf_pretty $fzf_gui $custom_fzf_params $fzf_label)
fzfp=($fzfpnh $fzf_header)

# Some reasonable defaults for adb logcat.
teecmd=("|" 'tee' $purr_input_cache)
check_adb_status=("|" 'grep' '-q' '-v' '"Lost connection to device."')

load_generic_header=(
	"echo -n \"Stream: \";"
	"cat $purr_stream_header_cache | tr -d \"\n\";"
	"echo -n \"Sort: \";"
	"cat $purr_sort_header_cache | tr -d \"\n\";"
	"echo -n \"Scroll Lock: \";"
	"cat $purr_slock_cache | tr -d \"\n\";"
	"echo -n \"Unique: \";"
	"cat $purr_unique_cache | tr -d \"\n\";"
	"echo \"\x1b[1;2;37mPurr: Happy Logcat\x1b[1;0m\";"
)

# Handles the UI logic of reloading the header.
load_input_stream=(
	"if /usr/bin/grep -q \"History\" $purr_stream_header_cache; then"
		"cat $purr_input_stream_cache | zsh;"
	"elif /usr/bin/grep -q \"Serial\" $purr_stream_header_cache; then"
		"cat $purr_input_stream_cache | zsh;"
	"elif /usr/bin/grep -q \"ADB\" $purr_stream_header_cache; then"
		# If the user runs a command, put the full command as the first line.
		"if /usr/bin/grep -q \"$adb_cmd_loc -s\" $purr_input_stream_cache; then"
			"echo \"Command: \$(cat $purr_input_stream_cache)\";"
		"fi;"
		"cat $purr_input_stream_cache | zsh |& tee;" # Prints all streams to stdout.
	'else;'
		$update_serial_cmd
		"if $adb_cmd_loc devices | /usr/bin/grep \$serial &> /dev/null; then"
			"echo \"\x1b[1;32m  \$serial => \x1b[1;0m\" >| $purr_connection_state_cache;"
		'else;'
			"echo \"\x1b[1;31m  \$serial != \x1b[1;0m\" >| $purr_connection_state_cache;"
		'fi;'

		"cat $purr_input_stream_cache | zsh;"
	"fi;"
)

instruction_preview_command="cat $purr_instruction_cache"
instruction_preview_window="right,50%,nohidden,nofollow,wrap,<55(up,50%,nohidden,nofollow,wrap)"
instruction_preview_window_hidden="right,50%,hidden,nofollow,wrap,<55(up,50%,hidden,nofollow,wrap)"
hint_preview=("change-preview($instruction_preview_command)+change-preview-window($instruction_preview_window)+change-preview-label()+refresh-preview")

set_stream_error="echo \"/usr/bin/tail -F -n 99999999 $purr_error_input_cache $teecmd\" >| $purr_input_stream_cache;"
set_stream_warning="echo \"/usr/bin/tail -F -n 99999999 $purr_warning_input_cache $teecmd\" >| $purr_input_stream_cache;"
set_stream_info="echo \"/usr/bin/tail -F -n 99999999 $purr_info_input_cache $teecmd\" >| $purr_input_stream_cache;"
set_stream_verbose="echo \"/usr/bin/tail -F -n 99999999 $purr_verbose_input_cache $teecmd\" >| $purr_input_stream_cache;"

set_stream_error_unique="echo \"/usr/bin/tail -F -n 99999999 $purr_error_input_cache_unique $teecmd\" >| $purr_input_stream_cache;"
set_stream_warning_unique="echo \"/usr/bin/tail -F -n 99999999 $purr_warning_input_cache_unique $teecmd\" >| $purr_input_stream_cache;"
set_stream_info_unique="echo \"/usr/bin/tail -F -n 99999999 $purr_info_input_cache_unique $teecmd\" >| $purr_input_stream_cache;"
set_stream_verbose_unique="echo \"/usr/bin/tail -F -n 99999999 $purr_verbose_input_cache_unique $teecmd\" >| $purr_input_stream_cache;"

set_stream_adb="echo \"/usr/bin/tail -F -n 99999999 $purr_adb_cache $teecmd\" >| $purr_input_stream_cache;"

# Sets the stream header to a given message.
set_header_error="echo \"$stream_error_msg\" >| $purr_stream_header_cache;"
set_header_warning="echo \"$stream_warn_msg\" >| $purr_stream_header_cache;"
set_header_info="echo \"$stream_info_msg\" >| $purr_stream_header_cache;"
set_header_verbose="echo \"$stream_verbose_msg\" >| $purr_stream_header_cache;"
set_header_focus="echo \"$stream_focus_msg\" >| $purr_stream_header_cache;"
set_header_adb="echo \"$stream_adb_msg\" >| $purr_stream_header_cache;"

# Sets the sort header to a given message.
set_sort_chrono="echo \"$sorting_chronological\" >| $purr_sort_header_cache;"
set_sort_relevance="echo \"$sorting_relevance\" >| $purr_sort_header_cache;"

# Saves the current query for an fzf reboot.
save_current_query="echo {q} > $purr_query_cache;"

# Sets the scroll lock header to a given state.
set_slock_on="echo \"$slock_on_msg\" >| $purr_slock_cache;"
set_slock_off="echo \"$slock_off_msg\" >| $purr_slock_cache;"

# Sets the scroll lock header to a given state.
set_unique_on="echo \"$unique_on_msg\" >| $purr_unique_cache;"
set_unique_off="echo \"$unique_off_msg\" >| $purr_unique_cache;"

# Boolean to determine state of scroll lock.
is_slock_on="/usr/bin/grep -q  \"On\" \"$purr_slock_cache\""

# Boolean to determine state of unique mode.
is_unique_on="/usr/bin/grep -q  \"On\" \"$purr_unique_cache\""

# Boolean to determine state of sort order.
is_sort_chrono="/usr/bin/grep -q  \"Chronological\" \"$purr_sort_header_cache\""

# Injects an empty line to force fzf to refresh the input stream.
inject_empty_line="echo \"\";"

# Adds logic for handling history and serial selection.
stream_history_msg="\x1b[1;36mHistory\x1b[1;0m\t\t"
stream_serial_msg="\x1b[1;36mSerial\x1b[1;0m\t\t"

set_stream_history="echo \"cat $purr_history_cache\" >| $purr_input_stream_cache;"
set_header_history="echo \"$stream_history_msg\" >| $purr_stream_header_cache;"

set_stream_serial="echo \"$adb_cmd_loc devices | /usr/bin/tail -n +2 |/usr/bin/sed '/^\s*$/d' | /usr/bin/sort | awk '{print \$ 1}'\" >| $purr_input_stream_cache;"
set_header_serial="echo \"$stream_serial_msg\" >| $purr_stream_header_cache;"

hint_preview_window="top,70%,nohidden,wrap,+200/2"
hint_preview_window_hidden="top,70%,hidden,wrap,+200/2"

start_stream="echo \"$PURR_THREAD_START\" >> $purr_background_handler_cache;"
stop_stream="echo \"$PURR_THREAD_STOP\" >> $purr_background_handler_cache;"
