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

# Spawns 8 background threads; four to stream standard error/warning/info/verbose, and another
# four to stream the unique versions of the streams.
__purr_start_streams() {
	__purr_stream_background_file $purr_error_input_cache "*:E" $purr_serial_cache &
	__purr_stream_background_file $purr_warning_input_cache "*:W" $purr_serial_cache &
	__purr_stream_background_file $purr_info_input_cache "*:I" $purr_serial_cache &
	__purr_stream_background_file $purr_verbose_input_cache "*:V" $purr_serial_cache &

	__purr_stream_unique_file $purr_error_input_cache $purr_error_input_cache_unique $purr_error_unique_checksum_cache &
	__purr_stream_unique_file $purr_warning_input_cache $purr_warning_input_cache_unique $purr_warning_unique_checksum_cache &
	__purr_stream_unique_file $purr_info_input_cache $purr_info_input_cache_unique $purr_info_unique_checksum_cache &
	__purr_stream_unique_file $purr_verbose_input_cache $purr_verbose_input_cache_unique $purr_verbose_unique_checksum_cache &
}

# We can just kill the stream threads; they only interact with
# the stream file, so we don't care about is happening when they die.
__purr_cleanup_streams() {
	kill ${${(v)jobstates##*:*:}%=*}
	for pid in ${${(v)jobstates##*:*:}%=*}; do
		wait $pid
	done

	rm $purr_error_input_cache &> /dev/null
	rm $purr_warning_input_cache &> /dev/null
	rm $purr_info_input_cache &> /dev/null
	rm $purr_verbose_input_cache &> /dev/null

	rm $purr_error_input_cache_unique &> /dev/null
	rm $purr_warning_input_cache_unique &> /dev/null
	rm $purr_info_input_cache_unique &> /dev/null
	rm $purr_verbose_input_cache_unique &> /dev/null
}

# The function that runs the stream threads. Each should run an
# adb process that feeds information into the given file. We also
# want to make sure that only one thread is handling shared logic,
# so the verbose thread is responsible for this, as it has the most
# context. Since these threads are the only ones who directly interact
# with adb logcat, they are also responsible for monitoring the connection
# state of the device and ensuring they can cleanly resume if we lose
# the device.
__purr_stream_background_file() {
	local stream_file=$1
	local stream_command=$2
	local purr_serial_cache=$3

	# We only want the verbose background stream to perform certain actions.
	if grep -q "verbose" <<< "$stream_file"; then
		local am_verbose="true"
	else
		local am_verbose="false"
	fi

	# If the directory doesn't exist anymore, it's likely that we have exited.
	touch $stream_file &> /dev/null
	if [ $? -ne 0 ]; then
		exit
	fi

	# We don't know anything about the connection yet, even
	# though we should be in a good state.
	conn_status="unknown"

	while true; do

		# Make sure we have the most up to date serial.
		__purr_update_serial
		if [ -z $serial ]; then
			exit
		fi

		# If we disconnected, we want to make sure that the device is still offline.
		if [[ $conn_status = "potential" ]]; then
			timeout 2 "adb -s $serial wait-for-device" &> /dev/null

			# The device seems to have found itself, we can just reconnect.
			if [ $? -eq 0 ]; then
				echo "\x1b[1;36mPURR STATUS: Device Responding.\x1b[1;0m" >> $stream_file
				echo "\x1b[1;36mPURR STATUS: Restarting input from last seen timestamp.\x1b[1;0m" >> $stream_file
				conn_status="alive"
				if [ $am_verbose = "true" ]; then
					echo "\x1b[1;32m  $serial => \x1b[1;0m" > $purr_connection_state_cache 
				fi
			else # Otherwise, we'll enter a dead state and start polling for the device.
				echo "\x1b[1;36mPURR STATUS: Device Not Responding.\x1b[1;0m" >> $stream_file
				echo "\x1b[1;36mPURR STATUS: Locking input streams until device found.\x1b[1;0m" >> $stream_file
				conn_status="dead"
				if [ $am_verbose = "true" ]; then
					echo "\x1b[1;31m  $serial != \x1b[1;0m" > $purr_connection_state_cache
				fi
			fi
		else # If we aren't in potential mode, we poll for the device until we find it.
			adb -s $serial wait-for-device &> /dev/null
			if [ $? -eq 0 ]; then
				if [ $conn_status != "unknown" ]; then
					echo "\x1b[1;36mPURR STATUS: Device Responding.\x1b[1;0m" >> $stream_file
					echo "\x1b[1;36mPURR STATUS: Restarting input from last seen timestamp.\x1b[1;0m" >> $stream_file
				fi

				conn_status="alive"
				if [ $am_verbose = "true" ]; then
					echo "\x1b[1;32m  $serial => \x1b[1;0m" > $purr_connection_state_cache
				fi
			fi
		fi
		
		# Once we've established a device connection, we'll start streaming from logcat.
		if [ $conn_status = "alive" ]; then

			# Handles trimming logcat input to a specific timestamp.
			trim_time=$(cat $purr_time_start_cache)
			if [ -z $trim_time ]; then
				eval "adb -s $serial logcat -v color $custom_adb_params '$stream_command' >> $stream_file"
			else
				
				# We don't want the trim time to survive a thread cleanup,
				# so once the verbose thread is sure all the other threads
				# have read it, we wipe the state cache.
				if [ $am_verbose = "true" ]; then
					{
						sleep 1.5
						if [ -f $purr_time_start_cache ]; then
							echo "" > $purr_time_start_cache &> /dev/null
						fi
					} &
				fi
				eval "adb -s $serial logcat -v color $custom_adb_params -T '$trim_time'  '$stream_command' >> $stream_file"
			fi

			# We've been disconnected, and we're not sure what the state is. We'll
			# grab the last message sent so we can restart at the same timestamp.
			if [ $am_verbose = "true" ]; then
				trimmed_time=$(echo $(tail -1 $stream_file) | cut -d' ' -f1-2 | sed -e 's/\x1b\[[0-9;]*m//g');
				echo $trimmed_time > $purr_time_start_cache;
			fi

			echo "\x1b[1;36mPURR STATUS: Potential Connection Lost.\x1b[1;0m" >> $stream_file
			conn_status="potential"
		fi

		sleep 0.5
	done
}

__purr_stream_unique_file() {
	local stream_input_file=$1
	local stream_output_file=$2
	local stream_checksum_file=$3

	# If the directory doesn't exist anymore, it's likely that we have exited.
	touch $stream_output_file &> /dev/null
	if [ $? -ne 0 ]; then
		exit
	fi

	# If the directory doesn't exist anymore, it's likely that we have exited.
	touch $stream_checksum_file &> /dev/null
	if [ $? -ne 0 ]; then
		exit
	fi

	tail -s 0.1 -F --lines=+0 -- $stream_input_file 2> /dev/null | while read -r line; do
		trimmed_line_cksum=$(echo $line | awk '{$1=$1};1' | cut -d' ' -f5- -- | cksum | cut -d' ' -f1)
		if command -v rg &>/dev/null; then
			if ! rg -q "$trimmed_line_cksum" $stream_checksum_file 2> /dev/null; then
				echo "$line" >> $stream_output_file
				echo "$trimmed_line_cksum" >> $stream_checksum_file
			else
				echo "Erasing duplicate line..." >> $stream_output_file
			fi
		else
			if ! /usr/bin/grep -q "$trimmed_line_cksum" $stream_checksum_file 2> /dev/null; then
				echo "$line" >> $stream_output_file
				echo "$trimmed_line_cksum" >> $stream_checksum_file
			else
				echo "Erasing duplicate line..." >> $stream_output_file
			fi
		fi
	done
}
