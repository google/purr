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

# Load the instructions into the instruction cache.
__purr_print_instructions $purr_instruction_cache

# Set the default program state.
echo "\x1b[1;32m  $serial => \x1b[1;0m" >$purr_connection_state_cache
echo $stream_verbose_msg >|$purr_stream_header_cache
echo $slock_off_msg >|$purr_slock_cache
echo $unique_off_msg >|$purr_unique_cache
echo $sorting_chronological >|$purr_sort_header_cache
echo "/usr/bin/tail -F -n 99999999 $purr_verbose_input_cache $teecmd" >|$purr_input_stream_cache
echo -1 >|$purr_history_pointer_cache
echo 0 >|$purr_history_counter_cache

bind_commands=()

cat <<- "END" > $purr_spc_purpose_cache
							_                    )
							( \_                  |
				_,-'/'_ , ;-.               \
.                  ,-'  O  ( ` .<= `.              \
`.              ,'o O o 0     o , ,'-.           ,-'
`. `.          ,'o O 0/ 0 )___,.--','"""`--._,,--'
__>. \       ,: ' o O/. o/  __,`--'-.                _,-'
-._   `-``._/o 0 0(),| o/-''         `-.__      __,-'|
)_.   ` / ~':o ,-.\o \                 `----'     |
	`-.-| 0 o.`.\ /o|`.|                           |
		/o . ;.'`o|'|o \                           /
		|`,,'  `._/0|\',\                         /
		|`.|`._/ \o'||o |                         |
		/,`/       )./|.'|                         /
---------|.|--------\,\`--'-------------------------\
		|O|         \``.                           |
		|o|          `._)                          \
		|(|                                         \
		|O|                                          |
hh     |)|                                          |
		/(|                                          |
		(o/                                           |
		\)                                           /

Cats who can purr can't roar, and vice-versa.
Cheetahs can't roar, but they can meow and purr. 
This is because cheetahs are the cutest kittens at heart.
This has been Cat Facts with Alfred.
END
