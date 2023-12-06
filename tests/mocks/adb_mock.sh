#!/usr/bin/env zsh

if grep -q "devices" <<<$@; then
	echo "List of devices attached"
	echo "emulator-5554	device"
elif grep -q "wait-for-device" <<<$@; then
	sleep 0.01
elif grep -q "logcat" <<<$@; then
	echo $mocked_adb_output
	sleep 9999999
fi
