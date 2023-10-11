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

default_command_suite=$(
	tr -d '\n' <<-END
		rebind(f1)
		+rebind(f2)
		+rebind(f3)
		+rebind(f4)
		+rebind(f5)
		+rebind(f6)
		+rebind(f7)
		+rebind(f9)
		+rebind(f10)
		+rebind(ctrl-p)
		+rebind(ctrl-r)
		+rebind(ctrl-s)
		+rebind(ctrl-u)
		+rebind(ctrl-j)
		+rebind(ctrl-f)
		+rebind(ctrl-w)
		+rebind(ctrl-t)
		+rebind(ctrl-alt-t)
		+rebind(tab)
		+rebind(ctrl-v)
		+rebind(ctrl-y)
		+rebind(ctrl-alt-s)
		+rebind(ctrl-alt-d)
		+unbind(enter)
		+unbind(ctrl-h)
		+unbind(double-click)
	END
)

adb_command_suite=$(
	tr -d '\n' <<-END
		rebind(f1)
		+rebind(f2)
		+rebind(f3)
		+rebind(f4)
		+rebind(f5)
		+rebind(f6)
		+unbind(f7)
		+unbind(f9)
		+unbind(f10)
		+unbind(ctrl-p)
		+unbind(ctrl-r)
		+rebind(ctrl-s)
		+unbind(ctrl-u)
		+rebind(ctrl-j)
		+rebind(ctrl-f)
		+unbind(ctrl-w)
		+unbind(ctrl-t)
		+unbind(ctrl-alt-t)
		+rebind(tab)
		+rebind(ctrl-v)
		+rebind(ctrl-y)
		+rebind(enter)
		+rebind(ctrl-h)
		+unbind(ctrl-alt-s)
		+unbind(ctrl-alt-d)
		+unbind(double-click)
	END
)

history_command_suite=$(
	tr -d '\n' <<-END
		rebind(f1)
		+rebind(f2)
		+rebind(f3)
		+rebind(f4)
		+rebind(f5)
		+rebind(f6)
		+unbind(f7)
		+unbind(f9)
		+unbind(f10)
		+unbind(ctrl-p)
		+unbind(ctrl-r)
		+unbind(ctrl-s)
		+unbind(ctrl-u)
		+rebind(ctrl-j)
		+unbind(ctrl-f)
		+unbind(ctrl-w)
		+unbind(ctrl-t)
		+unbind(ctrl-alt-t)
		+unbind(tab)
		+unbind(ctrl-v)
		+unbind(ctrl-y)
		+rebind(enter)
		+unbind(ctrl-h)
		+unbind(ctrl-alt-s)
		+unbind(ctrl-alt-d)
		+unbind(double-click)
	END
)

serial_command_suite="$history_command_suite"
