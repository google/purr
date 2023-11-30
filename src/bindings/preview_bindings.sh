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

# Bind: F7, set preview to the instruction menu..
instruction_preview_cache_command=$(cat <<-END
	echo 'nohidden' >| $purr_preview_visible_cache;
	echo 'instruction' >| $purr_preview_command_cache;
	END
)
bind_commands+=('--bind' "F7:$hint_preview+execute-silent($instruction_preview_command)")
rebind_in_default_command_suite "F7"
unbind_in_adb_command_suite "F7"
unbind_in_history_command_suite "F7"
unbind_in_serial_command_suite "F7"


# Bind: F9, highlight selected line and show 200 lines of context around it in current stream.
current_hint_preview_command=$(cat <<-END
	# Grab the line number from the input cache. This may not be unique if multiple lines are exact matches.
	line_number="\$(/usr/bin/grep -F -n -- {} $purr_input_cache | cut -d':' -f1)";

	if [ -z "\$line_number" ]; then
		echo "Could not identify selected line in input buffer!";
		echo "This should never happen; please report me as a bug!";
	else;

		# Get only the first line to display.
		first_line_number="\$(/usr/bin/head -n 1 <<< "\$line_number")";

		# Get the number of lines in the input file for pointer math!
		lines_in_input_file="\$(/usr/bin/wc -l $purr_input_cache | xargs | cut -d' ' -f1)";

		# Get the lines we need to put into the preview file.
		line_number_min=\$((first_line_number-200));
		line_number_max=\$((first_line_number+200));

		# Try not to overflow from the input file.
		if [ \$line_number_max -ge \$lines_in_input_file ]; then
			line_number_max=\$lines_in_input_file;
		fi;

		# Try not to underflow from the input file.
		if [ \$line_number_min -le 0 ]; then
			pad_top_number=\$((200 - first_line_number))
			line_number_min=0;
		fi;

		# Get the number we need to tail for.
		tail_line_numbers=\$((\$line_number_max - \$line_number_min));

		# Get the lines that need to be printed from the input cache.
		full_lines=\$(/usr/bin/head -n \$line_number_max $purr_input_cache  | /usr/bin/tail -n \$tail_line_numbers -q;);

		# If we don't have enough lines on the top, we'll pad with new lines so that
		# fzf can still send us to above the correct line in the preview.
		if [ ! -z "\$pad_top_number" ]; then
			for i in {1..\$pad_top_number}; do
				padding_string="\$padding_string\n";
			done;
			full_lines="\$padding_string""\$full_lines";
		fi;

		# Start building the preview. We need to do this piecemeal to make sure we can
		# highlight the relevant lines.
		preview_top=\$(echo \$full_lines | /usr/bin/head -n 199);

		# Since we aren't guarenteed that the selected line is unique, let's tell the user so
		# they understand why the line might seem different.
		if [ "\$(/usr/bin/wc -l <<< "\$line_number")" -ne 1 ]; then
			info_panel="\\n----------------";
			info_panel+="\\nSeeing multiple exact matches; highlighting first instance."
			info_panel+="\\nFirst Instance on line \$first_line_number";
			info_panel+="\\nDuplicates on line(s) \$(echo \$line_number | /usr/bin/tail -n +2 | /usr/bin/tr '\n' ' ')";
			info_panel+="\\n----------------";
		fi;

		# Highlight the line the user selected.
		highlighted_line="\$(echo -- \$full_lines | /usr/bin/head -n 200 -- | /usr/bin/tail -n 1 -q -- | cat -v -- | /usr/bin/sed -e "s/\^\[\[[0-9;]*m/\x1b[1;36m/g")";

		# We might not have lines at the bottom to print, so we need to check
		# how big the padded buffer is.
		full_lines_size=\$(echo \$full_lines | /usr/bin/wc -l);
		bottom_line_numbers=\$((\$full_lines_size - 200));

		# Load in the bottom of the preview.
		preview_bottom=\$(echo \$full_lines | /usr/bin/tail -n \$bottom_line_numbers);

		# Construct and print the preview.
		constructed_preview="\$preview_top\$info_panel\\n\$highlighted_line\\n\$preview_bottom";
		echo "\$constructed_preview";
	fi;
	END
)
current_hint_preview_cache_command=$(cat <<-END
	echo 'nohidden' >| $purr_preview_visible_cache;
	echo 'current' >| $purr_preview_command_cache;
	END
)
bind_commands+=('--bind' "F9:change-preview($current_hint_preview_command)+change-preview-label(F9: Current Stream)+change-preview-window($hint_preview_window)+refresh-preview+execute-silent($current_hint_preview_cache_command)")
rebind_in_default_command_suite "F9"
unbind_in_adb_command_suite "F9"
unbind_in_history_command_suite "F9"
unbind_in_serial_command_suite "F9"

# Bind: F10, highlight selected line and show 200 lines of context around it in verbose stream.
verbose_hint_preview_command=$(echo "$current_hint_preview_command" | sed "s:$purr_input_cache:$purr_verbose_input_cache:g")
verbose_hint_preview_cache_command=$(cat <<-END
	echo 'nohidden' >| $purr_preview_visible_cache;
	echo 'verbose' >| $purr_preview_command_cache;
	END
)
bind_commands+=('--bind' "F10:change-preview($verbose_hint_preview_command)+change-preview-label(F10: Verbose Stream)+change-preview-window($hint_preview_window)+refresh-preview+execute-silent($verbose_hint_preview_cache_command)")
rebind_in_default_command_suite "F10"
unbind_in_adb_command_suite "F10"
unbind_in_history_command_suite "F10"
unbind_in_serial_command_suite "F10"

# Bind: Ctrl-P, toggle preview on/off.
toggle_preview_cache_command=$(cat <<-END
	if [ \$(cat $purr_preview_visible_cache) = 'nohidden' ]; then;
		echo 'hidden' >| $purr_preview_visible_cache;
	else;
		echo 'nohidden' >| $purr_preview_visible_cache;
	fi
	END
)
bind_commands+=('--bind' "ctrl-p:toggle-preview+execute-silent($toggle_preview_cache_command)")
rebind_in_default_command_suite "ctrl-p"
unbind_in_adb_command_suite "ctrl-p"
unbind_in_history_command_suite "ctrl-p"
unbind_in_serial_command_suite "ctrl-p"
