#!/system/bin/sh
# APatch-only hook (ignored by Magisk/KernelSU): runs once Android is fully booted.
MODDIR=${0%/*}
source "$MODDIR/action.sh" --silent
