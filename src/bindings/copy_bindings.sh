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

# Bind: ctrl-y, print to clipboard.
cmd_clipboard=(
	"execute-silent("
		"lines=\"{+}\";"
		'eval "line_array=($lines)";'
		'new_line_array=$(printf "%s\n" "${line_array[@]}");'
		"echo \"\$new_line_array[@]\" | $purr_copy_program > $target_tty;"
	')+clear-selection'
)
bind_commands+=('--bind' "ctrl-y:$cmd_clipboard")
rebind_in_default_command_suite "ctrl-y"
rebind_in_adb_command_suite "ctrl-y"
unbind_in_history_command_suite "ctrl-y"
unbind_in_serial_command_suite "ctrl-y"

# Bind: ctrl-\, prints device information to the clipboard.
cmd_bug_report=(
	'execute-silent('
		$update_serial_cmd
		'info_array=("\`\`\`");'
		'info_array+=("\nFingerprint:" $(' "$adb_cmd_loc" ' -s $serial shell getprop | grep "ro.build.fingerprint"));'
		'info_array+=("\nSDK Version:" $(' "$adb_cmd_loc" ' -s $serial shell getprop | grep "ro.build.version.sdk"));'
		'info_array+=("\nGMS Version:" $(' "$adb_cmd_loc" ' -s $serial shell dumpsys package com.google.android.gms | grep "versionName" | /usr/bin/head -n 1));'
		'info_array+=("\n\`\`\`");'
		"echo \"\$info_array\" | $purr_copy_program > $target_tty;"
		'{'
			'bug_report_name="/tmp/bugreport-$(' "$adb_cmd_loc" ' -s $serial shell getprop ro.product.vendor.name)-$(' "$adb_cmd_loc" ' -s $serial shell getprop ro.product.vendor.device)-$(' "$adb_cmd_loc" ' -s $serial shell getprop ro.vendor.build.version.sdk)-$(date +"%d-%m-%Y::%H:%M:%S")";'
			'bug_report_error=$(' "$adb_cmd_loc" ' -s $serial bugreport $bug_report_name);'
			'if [ ! -f "${bug_report_name}.zip" ]; then '
				'echo $bug_report_error > "${bug_report_name}_err";'
			'fi;'
		'} &'
	')+clear-selection'
)
bind_commands+=('--bind' "ctrl-\:$cmd_bug_report")
rebind_in_default_command_suite "ctrl-\\"
rebind_in_adb_command_suite "ctrl-\\"
rebind_in_history_command_suite "ctrl-\\"
rebind_in_serial_command_suite "ctrl-\\"
