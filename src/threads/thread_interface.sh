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

__purr_start_stream() {
	echo "$PURR_THREAD_START" >>$purr_background_handler_cache
}

__purr_thread_stop_stream() {
	echo "$PURR_THREAD_STOP" >>$purr_background_handler_cache
}

__purr_cleanup() {
	local dir_name=$1

	# Send a message to the background threads that they need to die.
	if [ -f $purr_background_handler_cache ]; then
		echo "$PURR_THREAD_CLEANUP" >>$purr_background_handler_cache
	fi

	# Delete all of the cached state files.
	if [ -d $dir_name ]; then
		rm -r $dir_name &>/dev/null
	fi
}

# We want to avoid the case where we don't have any input coming through,
# causing a block until an error is thrown.
__wait_for_input_streams() {
	purr_timeout 0.1 wait_for_file $purr_verbose_input_cache
	purr_timeout 0.1 wait_for_file $purr_info_input_cache
	purr_timeout 0.1 wait_for_file $purr_warning_input_cache
	purr_timeout 0.1 wait_for_file $purr_error_input_cache
}
