# Force Disable HW Overlays

A Magisk module that forces the **Developer options → "Disable HW overlays"**
toggle to **ON** and keeps it there. Works on **Magisk, KernelSU and APatch**.

Hardware overlays are the dedicated display-plane layers the hardware composer
(HWC) hands off to the display hardware — video, camera previews, some UI
surfaces — so they get scanned out without any GPU compositing work.

Turning this option on sets `mDebugDisableHWC` in SurfaceFlinger, which calls
`forceClientComposition()` for **every** layer. The HWC overlay planes are then
never used and SurfaceFlinger composes the whole stack itself on the GPU.

So, despite the confusing name: this does **not** mean software/CPU rendering,
and it is not the same thing as "Force GPU rendering". It means *always
compose on the GPU instead of using the dedicated hardware overlay planes*.
That is the interesting case, because it bypasses the HWC path that is
otherwise invisible — it is how you surface overlay-plane bugs (green or black
video, DRM/hwdecode issues, clipping artifacts). The cost is extra GPU work and
memory bandwidth on every frame, so expect more heat, power draw and battery
use than the normal HWC path.

## Downloads

| File | Install with |
| --- | --- |
| `force_disable_hw_overlays-v1.1.zip` | Magisk app (**Modules → Install from storage**), KernelSU Manager, or a custom recovery |
| `force_disable_hw_overlays-v1.1.apm` | APatch Manager (**Modules → Install from storage**) |

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

This forces every layer through SurfaceFlinger's GPU composition path, skipping
the hardware composer's overlay planes. Frame rates are usually fine, but GPU
utilisation, heat and battery use go up. It is a debugging aid, not a
performance tweak. Remove the module to get the HWC overlay path back.
