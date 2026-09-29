#!/system/bin/sh
# Runs before system_server starts, so the framework already sees the option enabled.
#
# APatch: this stage is blocking and setprop WILL deadlock boot here,
# so only in-memory resetprop is used (resetprop -n).
MODDIR=${0%/*}

RESETPROP=$(command -v resetprop 2>/dev/null)
[ -z "$RESETPROP" ] && for p in /data/adb/magisk/resetprop /data/adb/ap/bin/resetprop /data/adb/ksu/bin/resetprop; do
  [ -x "$p" ] && RESETPROP="$p" && break
done

if [ -n "$RESETPROP" ]; then
  "$RESETPROP" -n disable_hw_overlays 1
  "$RESETPROP" -n persist.sys.disable_hw_overlays 1
fi
