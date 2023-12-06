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

validate_runtime_purr_files() {
	dir_name=$1

	# Did we load the serial?
	grep -q -- "emulator-5554" $dir_name/serial-cache.purr
	grep -q -- "emulator-5554" $dir_name/connection-state.purr
	echo "Serial was loaded."

	# Did the input stream load to verbose?
	grep -q -- "verbose-input-cache.purr" $dir_name/input-stream.purr
	grep -q -- "Verbose" $dir_name/stream-header.purr
	echo "Input stream is verbose."

	# Is the handler processing IO?
	if [ -s $dir_name/background-handler-IO.purr ]; then
		return 1
	else
		echo "Thread IO working."
	fi

	# Did we start on the instruction preview? And it is visible?
	grep -q -- "instruction" $dir_name/preview-command-cache.purr
	grep -q -- "nohidden" $dir_name/preview-visibility-cache.purr
	echo "Preview set to instruction."

	# Did we start with our modes in the correct states?
	grep -q -- "Off" $dir_name/purr_unique_cache.purr
	grep -q -- "Off" $dir_name/scroll-lock-header.purr
	grep -q -- "Chronological" $dir_name/sort-header.purr
	echo "Modes set to correct starting states."

	# Did purr correctly pick up the adb output?
	verbose_cache_contents=$(cat $dir_name/verbose-input-cache.purr)
	if [[ "$verbose_cache_contents" = "$mocked_adb_output" ]]; then
		echo "Verbose cache is correct."
	else
		return 1
	fi
}

validate_exit_time_purr_files() {
	dir_name=$1

	# Has the handler been told to clean up?
	grep -q -- "purr_thread_cleanup" $dir_name/background-handler-IO.purr
	echo "Threads are in cleanup."

	# Did the handler actually do clean up?
	if [ ! -f $dir_name/verbose-input-cache.purr ]; then
		echo "Threads did actually cleanup."
	else
		return 1
	fi
}

USAGE=("purr_file_validator"
	"-a: Set the ADB binary path; likely the bundled adb_mock."
	"-p: Set the purr binary path.")

while getopts ':p:a:' flags; do
	case $flags in
	a) adb_mock_path=${OPTARG} ;;
	p) purr_binary_path=${OPTARG} ;;
	*) echo $USAGE ;;
	esac
done

if [ -z $purr_binary_path ]; then
	echo >&2 "Please provide the path to the purr binary through -p."
	exit 1
elif [ -z $adb_mock_path ]; then
	echo >&2 "Please provide the path to the adb mock binary through -a."
	exit 1
fi

# We need to specify this so we know where purr is going to put
# the files.
dir_name=$(mktemp -d /tmp/purr.XXXXXXXXXX)

# Fail on any error.
set -e

# Run purr in the background with the given ADB binary.
# -X makes sure we don't actually launch fzf and only do file validation.
# When in -X mode, purr sleeps for 5 seconds after reaching fzf.
{
	eval "$purr_binary_path -A $adb_mock_path -D $dir_name -X"
} &

# Wait for purr to start.
sleep 1

# Check that purr is OK during runtime.
validate_runtime_purr_files $dir_name

# Wait for purr to exit.
sleep 5

# Check that purr exited OK.
validate_exit_time_purr_files $dir_name

rm -r $dir_name

echo "Files looks valid!"
