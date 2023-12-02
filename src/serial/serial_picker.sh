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

# Queries the user to choose between all connected adb devices.
# Output: Serial number of the chosen adb device, to be used in adb -s $(pick_serial).
pick_serial() {

	# Checks if we want to return just the $ANDROID_SERIAL serial.
	if [ ! -z $ANDROID_SERIAL ]; then
		__pick_serial_wait $ANDROID_SERIAL
		echo $ANDROID_SERIAL
		return
	fi

	# Check if any ADB devices are found.
	local adb_devices=""
	local device_count=""
	while [ -z $adb_devices ]; do
		__pick_serial_wait

		adb_devices=$(eval "$adb_cmd_loc devices | tail -n +2 | sed '/^\s*$/d' | sort")
		device_count=$(echo $adb_devices | /usr/bin/wc -l)

		# Checks how many devices are in a non-connected state.
		local disconnected_devices=$(/usr/bin/grep ".*offline.*" <<<$adb_devices | sort)
		local disconnected_count=$(/usr/bin/grep -c ".*offline.*" <<<$adb_devices | sort)

		# Checks whether there are any devices left that can be connected to.
		if [ $disconnected_count -eq $device_count ]; then
			echo >&2 "All available devices are disconnected. Waiting..."
			sleep 2
			__pick_serial_wait

			adb_devices=""
			device_count=""
		elif [ $disconnected_count -ne 0 ]; then
			echo >&2 "Skipped offline devices:"
			echo >&2 $disconnected_devices
			adb_devices=$(/usr/bin/grep -v ".*offline.*" <<<$adb_devices | sort)
		fi
	done

	# Check if only one device is found. If it is, we'll just use it.
	if [ $device_count -eq 1 ]; then
		local stripped_device=$(echo "$adb_devices" | xargs)
	else
		if command -v rg &>/dev/null; then
			local stripped_device=$(FZF_DEFAULT_COMMAND="echo \"$adb_devices\"" fzf $fzfpnh "--height=25%" --preview-window=right,50%,wrap \
				"--preview=$adb_cmd_loc -s \$(cut -f1 <<< {}) shell getprop | rg '(ro.bootimage.build.date]|ro.product.name|ro.bootimage.build.version.incremental])' | awk -F ']:' '{print \$2}' | sed 's/]//g' | sed 's/\[//g' " | xargs)
		else
			local stripped_device=$(FZF_DEFAULT_COMMAND="echo \"$adb_devices\"" fzf $fzfpnh "--height=25%" | xargs)
		fi
	fi

	# If the user exits fzf without picking.
	if [ -z $stripped_device ]; then
		echo >&2 "No serial number selected."
		exit 18
	fi

	# Cuts the serial down to just the number.
	echo "$(cut -d' ' -f1 <<<$stripped_device)" # Grab the serial from selection.
}

# If we know which serial to look for, or we can't see any, we need to wait. ADB device connections
# can be fickle, and ADB sometimes reports devices before it really should.
__pick_serial_wait() {
	if [ ! -z $1 ]; then
		local serial_stmt="-s $1"
	fi

	# See if any devices are immediately connected before printing a connect message.
	purr_timeout 1 "$adb_cmd_loc $serial_stmt wait-for-device" 2>/dev/null
	ret=$?

	# If we can't find any immediate connections, go into a longer waiting period.
	if [ $ret -eq 124 ] || [ $ret -eq 142 ]; then
		echo >&2 "Waiting on a device to connect..."

		eval "$adb_cmd_loc $serial_stmt wait-for-device"

		echo >&2 "Device connected."
	fi
}
