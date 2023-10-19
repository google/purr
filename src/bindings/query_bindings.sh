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

# Bind: ctrl-alt-s, get tag from line and add it to query.
get_tag_cmd=(
	'execute-silent('
		'tag=$(echo "{}" | xargs | xargs | cut -d" " -f6);'
		'cur_query=$(echo "{q}" | xargs | xargs);'
		'if echo $cur_query | /usr/bin/grep -w -q -- "$tag"; then'
			"echo \"\$cur_query\" > $purr_query_cache;"
		'elif [ -z $cur_query ]; then'
			"echo \"\$tag\" > $purr_query_cache;"
		'else;'
			"echo \"\$cur_query \$tag\" > $purr_query_cache;"
		'fi;'
	')+transform-query('
		"cat $purr_query_cache;"
		"echo "" > $purr_query_cache;"
	')'
)
bind_commands+=('--bind' "ctrl-alt-s:$get_tag_cmd")
rebind_in_default_command_suite "ctrl-alt-s"
unbind_in_adb_command_suite "ctrl-alt-s"
unbind_in_history_command_suite "ctrl-alt-s"
unbind_in_serial_command_suite "ctrl-alt-s"


# Bind: ctrl-alt-d, get tag from line and add it as negative query.
remove_tag_cmd=(
	'execute-silent('
		'tag=$(echo "{}" | xargs | xargs | cut -d" " -f6);'
		'negative_tag="!$tag";'
		'cur_query=$(echo "{q}" | xargs | xargs);'
		'if echo $cur_query | /usr/bin/grep -w -q -- "$tag"; then'
			'untagged_query=$(echo "$cur_query" | /usr/bin/sed "s/\b$tag\b//g" | /usr/bin/sed "s/\b$tag//g" | xargs);'
			"echo \"\$untagged_query\" > $purr_query_cache;"
		'elif [ -z $cur_query ]; then'
			"echo \"\$negative_tag\" > $purr_query_cache;"
		'else;'
			"echo \"\$cur_query \$negative_tag\" > $purr_query_cache;"
		'fi;'
	')+transform-query('
		"cat $purr_query_cache;"
		"echo "" > $purr_query_cache;"
	')'
)
bind_commands+=('--bind' "ctrl-alt-d:$remove_tag_cmd")
rebind_in_default_command_suite "ctrl-alt-d"
unbind_in_adb_command_suite "ctrl-alt-d"
unbind_in_history_command_suite "ctrl-alt-d"
unbind_in_serial_command_suite "ctrl-alt-d"
