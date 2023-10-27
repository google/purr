# purr

### Introduction
purr is a zsh CLI tool for viewing and searching through Android logcat output. It leverages [fzf](https://github.com/junegunn/fzf) to provide a simple yet powerful user interface, fuzzy-finding capabilities, and much more. 

### Motivation
While Android Studio's logcat viewer is sufficient for most app development, it breaks down when exposed to situations such as terminal-only access or when multiple devices need to be accessed quickly. When performing development on the Android operating system itself, developers revert to using raw `adb logcat` in shell.

This is sub-optimal and wastes a lot of time on writing `grep` statements and rooting through uncolored, unfiltered text with poor user experience. `purr` is meant as a solution to this; a powerful logcat viewer running entirely on the shell, capable of going through millions of logs quickly, while leveraging other shell-based solutions for common problems.

Purr can be used for simple app debugging, in which it provides a quicker interface than standard Logcat.

https://github.com/google/purr/assets/126256142/527bb85d-bf50-4ea8-b74f-7751098a3162

For more complex diagnosis, purr shines in quickly jumping around and isolating relevant logs.

https://github.com/google/purr/assets/126256142/fa490ac4-4f20-4049-87df-ffb2b10c3fb2

There's even a mode to search through `adb shell` results; no more grepping through dumpsys!

https://github.com/google/purr/assets/126256142/fb41ec9d-f5a7-43be-98be-9d04ed7b536e

### Dependencies

`purr` currently functions on Ubuntu Linux and Mac on zsh. It will attempt to source an `fzf` version locally if possible, but requires version `0.40.0` or higher.

If you do not have `fzf` `0.40.0` or higher locally, `purr` will use bundled `fzf` versions for `linux_x86_64`, `darwin_arm64` or `darwin_amd64` if applicable. If you have a different operating system, you need to download a `0.40.0` or higher `fzf` binary manually.

Support for Windows may be provided in future, but is not a current priority.

### Installation
1. Clone the repo
2. Add the scripts directory to your path
3. Run using `purr`


`purr` comes with two bundled programs:

* `purr_osc52_copy` is a fallback to copy to the system clipboard through SSH and TMUX sessions.
* `purr_fzf` is a bundled version of fzf `0.40.0` used if a higher version of `fzf` cannot be found.

### Guide
`purr` includes a simple tool to help select the device serial from `adb devices`, or can read from the `$ANDROID_SERIAL` environment variable if set. Otherwise, `purr` has six command-line parameters:

* -a: Sets custom parameters for `adb` that will be used as well as the defaults whenever an input stream is selected.
* -f: Sets custom parameters for `fzf`. Used on top of default parameters.
* -i: Disables the instruction preview on launch.
* -q: Set the default query string upon `purr` being opened.
* -v: Shows the `purr` version.
* -V: Shows a composite version of `purr` and dependencies.

Any other command-line parameters will print the help dialog.

Note that both `-a` and `-f` are read without validation; there is no guarantee that setting either parameter will not break `purr`.

#### Binds
The following hotkeys can be used:

#### General
* Escape: Exits `purr`. Ctrl-c and other methods also work, but may take longer, and may not gracefully exit.

#### Stream Modes
* F1/F2/F3/F4: Sets the logcat stream between Error/Warning/Info/Verbose, respectively.
* F5: Opens the serial selection menu. Pressing Enter will select and load the highlighted device.
* F6: Opens ADB command mode. Pressing Enter will execute the current query as an ADB shell command on the current device, and print the output to the finder window.
* Ctrl-r: Opens the history menu. Pressing Enter will load the selected history item into the query and return you to the verbose stream.

#### Preview Window
* Ctrl-p: Toggles the preview window on/off. By default, the window is on, but you can use the -i flag to make it default to off.
* F7: Show the instruction preview (on by default).
* F9: Shows context around the selected line in the currently selected input stream.
* F10: Shows context around the selected line in the verbose input stream.
* Shift-up/down: Scrolls one item up or down the preview window, respectively.
* Home/End: Scrolls one page up or down the preview window, respectively.

#### Navigation
* Ctrl-s: Enables scroll lock. While in scroll lock mode, your cursor will remain bound to the selected item as long as it remains in the search filter.
* Ctrl-f: Shorthand for enabling scroll lock and clearing the query. This allows you to go to the surrounding context of a selected item. Scroll lock will end once you move your cursor.
* Ctrl-j: Changes search modes between Chronological (default) and Relevance. This may be useful for fuzzy queries.
* Ctrl-alt-s: Adds the selected tag to your query. If the tag already exists in your query, do nothing.
* Ctrl-alt-d: Adds the inverse of the selected tag to your query. If the tag already exists in your query, remove it instead. Note that the inverse of the selected tag may also match non-tag lines in your log output.

#### ADB Shorthands
* Ctrl-t: Trims the logs to any logs after the currently selected items. Useful if attempting to isolate a specific issue after a certain point.
* Ctrl-alt-t: Untrims logs, reverting to showing all logs from the device.
* Ctrl-w: Wipes the logcat logs from the device.

#### Misc
* Tab: Select a line. Multiple lines can be selected simultaneously.
* Ctrl-y: Yanks selected lines into the system clipboard.
* Ctrl-v: Opens the text editor; see below.
* Ctrl-\\: Prints some basic device information into the system clipboard, and starts a background process to capture a bug report. The bug report is saved to /tmp/bugreport-$target-$device-$sdk-$date

#### History
`purr` saves a query string to history once it has not been changed for more than 3.5 seconds. You can use the following hotkeys to access history:

* Alt-shift-up: Move to the next entry in history.
* Alt-shift-down: Move to the previous entry in history.

When scrolling through history with alt-shift-up or alt-shift-down, your position in the history will reset once a string has been in the query for 3.5 seconds.

#### Editor
When you select a single line and press Ctrl-V, `purr` will open the selected line and surrounding context in a text editor. You can specify the text editor through the `$EDITOR` or `$EDITOR_PURR` environment variables; if no text editor is specified, `purr` will use `vim`. 

Note that logcat uses ANSI color codes to display color, so an editor that supports these codes is recommended; for example, [AnsiEsc](https://www.vim.org/scripts/script.php?script_id=302) for `Vim`.

If multiple lines are selected, only those selected lines will be opened in the text editor.

### Development
1. Clone the repo
2. Open in your favorite IDE/editor

### Dependencies
* [fzf](https://github.com/junegunn/fzf) - Bundled
* [zsh](https://github.com/zsh-users/zsh)
* [adb](https://developer.android.com/studio/command-line/adb)

### Support

If you've found an error, please file an issue:

https://github.com/google/purr/issues

Patches are encouraged, and may be submitted by forking this project and
submitting a pull request through GitHub.

License
=======

    Copyright 2022 Google LLC

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
