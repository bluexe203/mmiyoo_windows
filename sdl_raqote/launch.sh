#!/bin/sh
mydir=`dirname "$0"`
midir="/mnt/SDCARD/App/parasyte/rootfs"

export HOME=$mydir
export PATH=$mydir:$midir/usr/local/sbin:$midir/usr/local/bin:$midir/usr/sbin:$midir/usr/bin:$midir/sbin:$midir/bin:$PATH
export LD_LIBRARY_PATH=$mydir/lib:$midir/lib:$midir/usr/lib:$LD_LIBRARY_PATH
export SDL_VIDEODRIVER=mmiyoo
export SDL_AUDIODRIVER=mmiyoo
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

cd $mydir
./sdl_raqote > "$LOGS_PATH"/sdl_raqote.txt 2>&1
