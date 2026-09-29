#!/system/bin/sh
# APatch Manager "Action" button. Re-applies the setting and shows current state.
MODDIR=${0%/*}
SILENT=0
[ "$1" = "--silent" ] && SILENT=1

apply() {
  resetprop disable_hw_overlays 1 2>/dev/null
  resetprop persist.sys.disable_hw_overlays 1 2>/dev/null
  settings put global disable_hw_overlays 1 >/dev/null 2>&1
}

apply
[ "$SILENT" = "1" ] && exit 0

echo "disable_hw_overlays prop : $(getprop disable_hw_overlays)"
echo "Settings.Global value    : $(settings get global disable_hw_overlays)"
echo "Re-applied."
