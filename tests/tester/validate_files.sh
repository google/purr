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

mocked_adb_output=$(cat <<-END
		--------- beginning of system
		11-30 11:51:17.111   520   565 V DisplayPowerController2[0]: Brightness [0.39763778] reason changing to: 'manual', previous reason: 'manual [ dim ]'.
		11-30 11:51:17.111   520   565 I DisplayPowerController2[0]: BrightnessEvent: disp=0, physDisp=local:4619827259835644672, brt=0.39763778, initBrt=0.05, rcmdBrt=NaN, preBrt=NaN, lux=0.0, preLux=0.0, hbmMax=1.0, hbmMode=off, rbcStrength=0, thrmMax=1.0, powerFactor=1.0, wasShortTermModelActive=false, flags=, reason=manual, autoBrightness=false, strategy=InvalidBrightnessStrategy
		--------- beginning of main
		11-30 11:51:17.159   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff101010
		11-30 11:51:17.186   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff111111
		11-30 11:51:17.197   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff121212
		11-30 11:51:17.214   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff131313
		11-30 11:51:17.231   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff141414
		11-30 11:51:17.247   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff151515
		11-30 11:51:17.264   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff161616
		11-30 11:51:17.281   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff171717
	END
)

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

while getopts ':p:a:' flags; do
	case $flags in
		p) purr_binary_path=${OPTARG} ;;
		a) adb_mock_path=${OPTARG} ;;
	esac
done

if [ -z $purr_binary_path ]; then
	>&2 echo "Please provide the path to the purr binary through -p."
	exit 1
elif [ -z $adb_mock_path ]; then
	>&2 echo "Please provide the path to the adb mock binary through -a."
	exit 1
fi

dir_name=$(mktemp -d /tmp/purr.XXXXXXXXXX)

set -e

{
	eval "$purr_binary_path -A $adb_mock_path -D $dir_name -X"
} &

sleep 1

validate_runtime_purr_files $dir_name

sleep 5

validate_exit_time_purr_files $dir_name

echo "Files looks valid!"
