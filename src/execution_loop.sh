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

# Creates background workers to stream the logcat input streams for us.
(__purr_background_handler &)

# Some actions in purr exit fzf, but shouldn't exit purr, so we need an execution loop.
while true; do

	# Grabs the last query from the user before fzf exited.
	cached_query="$(cat $purr_query_cache)"
	"" >$purr_query_cache &>/dev/null

	__purr_update_serial
	__purr_update_prompt

	__purr_set_start_command

	__purr_set_start_preview

	# Starts and runs the actual fzf process.
	if [ ! -z $cached_query ]; then
		accepted=$(FZF_DEFAULT_COMMAND="$load_input_stream" fzf $starter_preview_command $fzfp $fzf_prompt $bind_commands $start_command --query=$cached_query)
		ret=$?
	else
		accepted=$(FZF_DEFAULT_COMMAND="$load_input_stream" fzf $starter_preview_command $fzfp $fzf_prompt $bind_commands $start_command)
		ret=$?
	fi

	# fzf returns 0 when it normally exits, and returns 1 when it normally exists but does
	# not return an "accepted" string. These are the only codes on which we want break.
	if [ "$ret" -ne 0 ] && [ "$ret" -ne 1 ]; then
		break
	fi

	cached_query=""
	accept_cmd=""

	# The async processes might take a bit of time to process the accept command.
	purr_timeout 1 "wait_for_file $purr_accept_command_cache"

	# We'll use this to figure out the user input before fzf stopped.
	accept_cmd=$(cat $purr_accept_command_cache)
	"" >$purr_accept_command_cache &>/dev/null

	if [ "$accept_cmd" = "wipe" ] || [ "$accept_cmd" = "serial" ] || [ "$accept_cmd" = "trim" ]; then
		__wait_for_input_streams
	elif [ "$accept_cmd" = "adb_cmd" ] || [ "$accept_cmd" = "history" ]; then
		: # Left blank for clarity.
	elif [ "$accept_cmd" = "editor" ]; then
		__purr_start_editor
	else
		break
	fi
done

__purr_cleanup $dir_name
