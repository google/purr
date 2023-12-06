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

mocked_adb_output=$(cat <<-END
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
)
