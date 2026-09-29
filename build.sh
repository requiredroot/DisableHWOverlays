#!/bin/bash
# Builds both installable packages into ./out :
#   force_disable_hw_overlays-<version>.zip  -> Magisk / KernelSU (has update-binary)
#   force_disable_hw_overlays-<version>.apm  -> APatch Manager (no META-INF)
set -euo pipefail

cd "$(dirname "$0")"

ID=$(sed -n 's/^id=//p' module.prop)
VER=$(sed -n 's/^version=//p' module.prop)
OUTDIR=out
ZIP="$OUTDIR/${ID}-${VER}.zip"
APM="$OUTDIR/${ID}-${VER}.apm"

EXCLUDE=('build.sh' 'README.md' '.gitignore' 'out/*' '*.zip' '*.apm')

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# Magisk / KernelSU package (flashable from Magisk app, custom recovery, KernelSU manager)
zip -r9 "$ZIP" . -x "${EXCLUDE[@]}"

# APatch package: APatch installs APMs itself and does not use META-INF
zip -r9 "$APM" . -x "${EXCLUDE[@]}" 'META-INF/*'

chmod 644 "$ZIP" "$APM"
echo "built $ZIP"
echo "built $APM"
