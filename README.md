# Force Disable HW Overlays

A Magisk module that forces the **Developer options → "Disable HW overlays"**
toggle to **ON** and keeps it there. Works on **Magisk, KernelSU and APatch**.

Hardware overlays are the small, GPU-composited surfaces SurfaceFlinger uses for
video, camera previews and some UI layers. Disabling them makes Android render
those through the CPU instead — which is what you want when debugging black
surfaces, video glitches or overlay-related rendering bugs, and what you *don't*
want in daily use, since it costs smoothness and battery.

## Downloads

| File | Install with |
| --- | --- |
| `force_disable_hw_overlays-v1.0.zip` | Magisk app (**Modules → Install from storage**), KernelSU Manager, or a custom recovery |
| `force_disable_hw_overlays-v1.0.apm` | APatch Manager (**Modules → Install from storage**) |

The two files have identical module contents; the `.apm` simply drops the
`META-INF` recovery installer that APatch doesn't use. Magisk and KernelSU are
fine with either file, but use the `.zip` if you plan to flash from recovery.

## What it does

| File | Stage | Purpose |
| --- | --- | --- |
| `system.prop` | boot | Sets `disable_hw_overlays=1` and `persist.sys.disable_hw_overlays=1` via Magisk/APatch `resetprop`. |
| `post-fs-data.sh` | pre-Zygote (blocking) | Re-applies the props with `resetprop -n` so the framework boots with the option already on. |
| `service.sh` | late_start service | Writes `Settings.Global.disable_hw_overlays = 1` so the Developer options toggle actually *shows* as enabled, then re-applies every 30s if anything turns it off. |
| `customize.sh` | install | Shows the root-manager-aware info and enables the setting immediately, so you don't have to reboot first. |
| `action.sh` | APatch Action button | Re-applies the setting on demand and prints the current state. |
| `boot-completed.sh` | APatch boot-completed | Runs `action.sh --silent` once Android is fully booted. |
| `uninstall.sh` | uninstall | Sets the toggle back to `0` when you remove the module. |

Notes on portability:

- **APatch**: `post-fs-data.sh` never calls `setprop` — on APatch that deadlocks
  boot, so only in-memory `resetprop -n` is used there. `resetprop` is resolved
  from `PATH` and, as a fallback, from `/data/adb/{magisk,ap/bin,ksu/bin}/resetprop`.
- `customize.sh` is *executed* by Magisk but *sourced* by APatch/KernelSU, so it
  is kept plain POSIX with no `set -e` / `exit`.
- `action.sh` and `boot-completed.sh` are APatch-only hooks; Magisk and KernelSU
  simply ignore them.
- No helper/library file is used, because Magisk only extracts a fixed list of
  module files — every script is self-contained on purpose.

## Install

1. Flash the package (see the table above).
2. Reboot — or don't: the setting is applied during install too.

Verify with:

```sh
settings get global disable_hw_overlays   # -> 1
getprop disable_hw_overlays               # -> 1
```

## Uninstall

Remove the module from your root manager and reboot. `uninstall.sh` puts the
toggle back to `0`, so it stops showing as enabled.

## Build from source

```sh
./build.sh      # writes out/*.zip and out/*.apm
```

## Disclaimer

Disabling HW overlays offloads compositing work to the CPU. Expect slightly
lower frame rates and a small battery hit. Reboot into a safe boot / remove the
module if your device misbehaves.
