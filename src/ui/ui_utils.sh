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

__purr_set_start_preview() {
	prev_preview=$(cat $purr_preview_command_cache)
	prev_preview_vis=$(cat $purr_preview_visible_cache)

	if [ "$prev_preview" = "instruction" ]; then
		if [ "$prev_preview_vis" = "hidden" ]; then
			starter_preview_command=($instruction_preview_starter_hidden)
		elif [ "$prev_preview_vis" = "nohidden" ]; then
			starter_preview_command=($instruction_preview_starter)
		fi
	elif [ "$prev_preview" = "verbose" ]; then
		if [ "$prev_preview_vis" = "hidden" ]; then
			starter_preview_command=($verbose_hint_preview_starter_hidden)
		elif [ "$prev_preview_vis" = "nohidden" ]; then
			starter_preview_command=($verbose_hint_preview_starter)
		fi
	elif [ "$prev_preview" = "current" ]; then
		if [ "$prev_preview_vis" = "hidden" ]; then
			starter_preview_command=($current_hint_preview_starter_hidden)
		elif [ "$prev_preview_vis" = "nohidden" ]; then
			starter_preview_command=($current_hint_preview_starter)
		fi
	elif [ $instruction_flag = "true" ]; then
		starter_preview_command=($instruction_preview_starter)
		echo "instruction" >$purr_preview_command_cache
		echo "nohidden" >$purr_preview_visible_cache
	else
		starter_preview_command=($verbose_hint_preview_starter_hidden)
		echo "verbose" >$purr_preview_command_cache
		echo "hidden" >$purr_preview_visible_cache
	fi
}

__purr_set_start_command() {
	if /usr/bin/grep -q "History" $purr_stream_header_cache; then
		start_command=('--bind' "start:hide-preview+transform-header($load_generic_header)+$history_command_suite")
	elif /usr/bin/grep -q "ADB" $purr_stream_header_cache; then
		start_command=('--bind' "start:hide-preview+transform-header($load_generic_header)+$adb_command_suite")

		# Enables the cat facts easter egg.
		if [ "$cached_query" = "Give me cat facts!" ]; then
			adb_query_cmd="cat $purr_spc_purpose_cache"
		else
			adb_query_cmd="adb -s $serial shell $cached_query"
		fi

		cached_query=""

		echo $adb_query_cmd >$purr_input_stream_cache
	else
		start_command=('--bind' "start:transform-header($load_generic_header)+$default_command_suite")
	fi
}

__purr_start_editor() {

	# If there's nothing to edit, we just move on.
	if [ -z $accepted ]; then
		continue
	fi

	# Grab the context around the accepted line.
	if [ $(echo $accepted | wc -l) -eq 1 ]; then
		if command -v rg &>/dev/null; then
			rg --color=always -F "$accepted" $purr_input_cache -C 500 >$purr_editor_input_cache
		else
			/usr/bin/grep --color=always -F "$accepted" $purr_input_cache -C 500 >$purr_editor_input_cache
		fi
	else
		echo $accepted >$purr_editor_input_cache
	fi

	# Preferentially grab the editor from $EDITOR_PURR, then $EDITOR, then just use vim.
	if [ $EDITOR_PURR ]; then
		eval "$EDITOR_PURR $purr_editor_input_cache"
	elif [ $EDITOR ]; then
		eval "$EDITOR $purr_editor_input_cache"
	else
		echo "No editor detected. Overriding to vim."
		echo "Purr will read from \$EDITOR_PURR, then \$EDITOR, then default to vim."
		vim +501 $purr_editor_input_cache
	fi
}

__purr_update_prompt() {
	fzf_prompt=('--prompt' "  $serial -> ")
}
