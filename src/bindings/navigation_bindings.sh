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

# Bind: ctrl-f, brings the user to the currently selected entry.
bind_commands+=('--bind' "ctrl-f:track+clear-query+hide-preview+execute-silent(echo 'hidden' >| $purr_preview_visible_cache;)")
rebind_in_default_command_suite "ctrl-f"
rebind_in_adb_command_suite "ctrl-f"
rebind_in_history_command_suite "ctrl-f"
rebind_in_serial_command_suite "ctrl-f"

# Bind: home/end, similar to page-up/page-down for preview.
bind_commands+=('--bind' "home:preview-page-up")
rebind_in_default_command_suite "home"
rebind_in_adb_command_suite "home"
rebind_in_history_command_suite "home"
rebind_in_serial_command_suite "home"

bind_commands+=('--bind' "end:preview-page-down")
rebind_in_default_command_suite "end"
rebind_in_adb_command_suite "end"
rebind_in_history_command_suite "end"
rebind_in_serial_command_suite "end"
