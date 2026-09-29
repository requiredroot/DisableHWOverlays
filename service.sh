#!/system/bin/sh
# Enforces "Disable HW overlays" = ON (works on Magisk, KernelSU and APatch).
#
#  - applies the prop / Settings.Global value as soon as the framework is up
#  - re-applies it if the user (or a ROM script) switches the toggle back off
#
# APatch: late_start service mode is the recommended stage here, and is
# non-blocking. Never use setprop in post-fs-data on APatch.

MODDIR=${0%/*}
APPLY_INTERVAL=30

RESETPROP=$(command -v resetprop 2>/dev/null)
[ -z "$RESETPROP" ] && for p in /data/adb/magisk/resetprop /data/adb/ap/bin/resetprop /data/adb/ksu/bin/resetprop; do
  [ -x "$p" ] && RESETPROP="$p" && break
done

apply() {
  [ -n "$RESETPROP" ] && "$RESETPROP" disable_hw_overlays 1 2>/dev/null
  [ -n "$RESETPROP" ] && "$RESETPROP" persist.sys.disable_hw_overlays 1 2>/dev/null
  # fallback for setups where resetprop is unavailable
  if [ -z "$RESETPROP" ] && [ "$(getprop disable_hw_overlays)" != "1" ]; then
    setprop disable_hw_overlays 1 2>/dev/null
  fi
  if [ "$(settings get global disable_hw_overlays 2>/dev/null)" != "1" ]; then
    settings put global disable_hw_overlays 1 >/dev/null 2>&1
  fi
}

apply
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 2; done
apply

while true; do
  sleep "$APPLY_INTERVAL"
  apply
done
