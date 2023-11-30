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

REQUIRED_FZF_VERSION="0.40.0"

VERSION="2.0.0"

USAGE=("purr"
	"\n[-q: Sets the default query]"
	"\n[-i: Disables the instruction header]"
	"\n[-a: Set custom adb parameters as a string]"
	"\n[-f: Set custom fzf parameters as a string]"
	"\n[-v: Get version number]"
	"\n[-V: Get version of all dependencies]")

__purr_get_composite_version() {
	composite_version="Purr: $VERSION"

	if ! command -v fzf &>/dev/null; then
		composite_version="$composite_version fzf: Not Installed"
	else
		composite_version="$composite_version fzf: $(fzf --version)"
	fi

	if [ -z $ZSH_VERSION ]; then
		composite_version="$composite_version zsh: Not Installed"
	else
		composite_version="$composite_version zsh: $ZSH_VERSION"
	fi

	echo $composite_version
}

# Parse argument flags.
instruction_flag=true
while getopts ':a:f:ivVq:' flags; do
	case $flags in
	q) query_string="--query=${OPTARG}" ;;
	a) custom_adb_params=${OPTARG} ;;
	f) custom_fzf_params=${OPTARG} ;;
	i) instruction_flag=false ;;
	v)
		echo $VERSION
		exit 0
		;;
	V)
		echo "$(__purr_get_composite_version)"
		exit 0
		;;
	*)
		echo $USAGE
		exit 1
		;;
	esac
done
