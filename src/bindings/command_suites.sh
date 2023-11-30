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

# Double-click is bound by default, just unbind it here.
default_command_suite="unbind(double-click)"
adb_command_suite="unbind(double-click)"
history_command_suite="unbind(double-click)"
serial_command_suite="unbind(double-click)"

rebind_in_default_command_suite() {
	default_command_suite="$default_command_suite+rebind($1)"
}

rebind_in_adb_command_suite() {
	adb_command_suite="$adb_command_suite+rebind($1)"
}

rebind_in_history_command_suite() {
	history_command_suite="$history_command_suite+rebind($1)"
}

rebind_in_serial_command_suite() {
	serial_command_suite="$serial_command_suite+rebind($1)"
}

unbind_in_default_command_suite() {
	default_command_suite="$default_command_suite+unbind($1)"
}

unbind_in_adb_command_suite() {
	adb_command_suite="$adb_command_suite+unbind($1)"
}

unbind_in_history_command_suite() {
	history_command_suite="$history_command_suite+unbind($1)"
}

unbind_in_serial_command_suite() {
	serial_command_suite="$serial_command_suite+unbind($1)"
}
