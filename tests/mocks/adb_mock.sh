#!/usr/bin/env zsh

if grep -q "devices" <<< $@; then
	echo "List of devices attached"
	echo "emulator-5554	device"
elif grep -q "wait-for-device" <<< $@; then
	sleep 0.01;
elif grep -q "logcat" <<< $@; then
	cat <<-END
		--------- beginning of system
		11-30 11:51:17.111   520   565 V DisplayPowerController2[0]: Brightness [0.39763778] reason changing to: 'manual', previous reason: 'manual [ dim ]'.
		11-30 11:51:17.111   520   565 I DisplayPowerController2[0]: BrightnessEvent: disp=0, physDisp=local:4619827259835644672, brt=0.39763778, initBrt=0.05, rcmdBrt=NaN, preBrt=NaN, lux=0.0, preLux=0.0, hbmMax=1.0, hbmMode=off, rbcStrength=0, thrmMax=1.0, powerFactor=1.0, wasShortTermModelActive=false, flags=, reason=manual, autoBrightness=false, strategy=InvalidBrightnessStrategy
		--------- beginning of main
		11-30 11:51:17.159   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff101010
		11-30 11:51:17.186   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff111111
		11-30 11:51:17.197   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff121212
		11-30 11:51:17.214   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff131313
		11-30 11:51:17.231   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff141414
		11-30 11:51:17.247   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff151515
		11-30 11:51:17.264   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff161616
		11-30 11:51:17.281   397   397 I android.hardware.lights-service.example: Lights setting state for id=1 to color ff171717
	END
	sleep infinity
fi
