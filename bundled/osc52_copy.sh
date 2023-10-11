#!/bin/sh

OSC_52_MAX_SEQUENCE="100000"

die() {
	echo "ERROR: $*"
	exit 1
}

tmux_dcs() {
	printf '\033Ptmux;\033%s\033\\' "$1"
}

screen_dcs() {
	local limit=256
	echo "$1" |
		sed -E "s:.{$((limit - 4))}:&\n:g" |
		sed -E -e 's:^:\x1bP:' -e 's:$:\x1b\\:' |
		tr -d '\n'
}

print_seq() {
	local seq="$1"
	case ${TERM-} in
	screen*)
		if [ -n "${TMUX-}" ]; then
			tmux_dcs "${seq}"
		else
			screen_dcs "${seq}"
		fi
		;;
	tmux*)
		tmux_dcs "${seq}"
		;;
	*)
		echo "${seq}"
		;;
	esac
}

b64enc() {
	base64 | tr -d '\n'
}

osc_52_copy() {
	local str
	if [ $# -eq 0 ]; then
		str="$(b64enc)"
	else
		str="$(echo "$@" | b64enc)"
	fi
	if [ ${OSC_52_MAX_SEQUENCE} -gt 0 ]; then
		local len=${#str}
		if [ ${len} -gt ${OSC_52_MAX_SEQUENCE} ]; then
			die "selection too long to send to terminal:" \
				"${OSC_52_MAX_SEQUENCE} limit, ${len} attempted"
		fi
	fi
	print_seq "$(printf '\033]52;c;%s\a' "${str}")"
}

set -e

osc_52_copy "$@"
