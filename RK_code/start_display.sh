#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
# 固定使用板卡本地屏幕，避免继承SSH的X11转发显示。
export DISPLAY=:0
export XAUTHORITY=/home/linaro/.Xauthority
export LD_LIBRARY_PATH="$ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export ADAS_REFERENCE_PROFILE_LIB="$ROOT/lib/reference_runtime.so"
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
xrandr --output HDMI-1 --mode 1024x600 --scale 1x1
exec /usr/bin/python3 run.py --preview --hdmi-nav-profile material3_lower_left "$@"
