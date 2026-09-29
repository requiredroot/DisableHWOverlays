#!/system/bin/sh
# NOTE: Magisk EXECUTES this script, APatch/KernelSU SOURCE it.
# Keep it POSIX, no `set -e`, no `exit` (use abort if you must stop).

SKIPUNZIP=0

ui_print " "
ui_print "  Force Disable HW Overlays"
ui_print "  ------------------------"
ui_print "  Forces the \"Disable HW overlays\" developer option ON"
ui_print "  and keeps it on across reboots."
ui_print " "
ui_print "  GPU hardware overlays will be disabled: the CPU does more"
ui_print "  compositing, so expect slightly less smoothness and a bit"
ui_print "  more battery use."
ui_print " "
if [ "$APATCH" = "true" ]; then
  ui_print "  Detected: APatch"
elif [ "$KSU" = "true" ]; then
  ui_print "  Detected: KernelSU"
else
  ui_print "  Detected: Magisk"
fi
ui_print " "
ui_print "  Uninstall this module to get the option back."
ui_print " "

# apply immediately instead of waiting for the next reboot
settings put global disable_hw_overlays 1 >/dev/null 2>&1

ui_print "  Installed. Reboot to apply."
ui_print " "
