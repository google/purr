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

PURR_THREAD_CLEANUP="purr_thread_cleanup"
PURR_THREAD_START="purr_thread_start"
PURR_THREAD_STOP="purr_thread_stop"

# The background handler is responsible for starting and killing
# the stream threads. It uses the purr_background_handler_cache
# as a one-way communication between the core process and itself,
# and then handles asynchronous processes related to the stream threads.
__purr_background_handler() {
	__purr_start_streams

	while read line; do
		if [ $line = "$PURR_THREAD_STOP" ]; then
			__purr_cleanup_streams
		elif [ $line = "$PURR_THREAD_START" ]; then
			__purr_start_streams
		elif [ $line = "$PURR_THREAD_CLEANUP" ]; then
			__purr_cleanup_streams
			exit 0
		fi
	done < <(/usr/bin/tail -f $purr_background_handler_cache 2>/dev/null)
}
