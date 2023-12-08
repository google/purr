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
	echo "$PURR_THREAD_START" >$thread_io_pipe
}

__purr_thread_stop_stream() {
	echo "$PURR_THREAD_STOP" >$thread_io_pipe
}

__purr_cleanup() {
	local dir_name=$1

	# Send a message to the background threads that they need to die.
	if [ -p $thread_io_pipe ]; then
		echo "$PURR_THREAD_CLEANUP" >$thread_io_pipe
	fi

	# Delete all of the cached state files.
	if [ -d $dir_name ] && [[ $delete_dir_flag = "true" ]]; then
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
