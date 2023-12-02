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

if [ ! -z $COPY_PROGRAM ]; then
	purr_copy_program="$COPY_PROGRAM"
elif command -v pbcopy &>/dev/null && [ -z $SSH_TTY ]; then
	purr_copy_program="$(which pbcopy)"
elif command -v wl-copy &>/dev/null && [ $XDG_SESSION_TYPE = "wayland" ]; then
	purr_copy_program="wl-copy"
elif command -v xsel &>/dev/null && [ ! -z $DISPLAY ]; then
	purr_copy_program="xsel --clipboard --input"
elif command -v osc52_copy &>/dev/null; then
	purr_copy_program="osc52_copy"
fi

if [ -z $purr_copy_program ]; then
	echo >&2 "Could not identify a known copy program!"
	echo >&2 "You can set a copy program by exporting the 'COPY_PROGRAM' variable."
	echo >&2 "If your terminal supports it, an OSC52 program is bundled in bundled/osc52_copy."
	echo >&2 "purr will continue, but copy commands will not work."
fi
