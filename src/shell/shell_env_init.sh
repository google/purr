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

dir_name=$(mktemp -d /tmp/purr.XXXXXXXXXX)

# Run cleanup if we exit abnormally.
trap "__purr_cleanup $dir_name" INT TERM

# Tell fzf to run commands in zsh.
SHELL=$(which zsh)

# Create the cache files we'll use to communicate with fzf.
__purr_create_files $dir_name

# If we are in TMUX or SSH, $TTY might not be the TTY we want to route to.
if [ -n "${TMUX-}" ]; then
	pane_active_tty=$(tmux list-panes -F "#{pane_active} #{pane_tty}" | awk '$1=="1" { print $2 }')
	if [ ! -z $SSH_TTY ]; then
		target_tty="${SSH_TTY:-$pane_active_tty}"
	else
		target_tty="${TTY:-$pane_active_tty}"
	fi
else
	target_tty="$TTY"
fi
