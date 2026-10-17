#!/usr/bin/env bash
# Clones the Cubiomes Viewer fork and the cubiomes backend at the tested commits,
# applies the patches in this repository and builds the result with Qt 6.
#
#   ./build-linux.sh              clone, patch and build into ./work/build
#   ./build-linux.sh --no-build   clone and patch only
#
# Needs: git, gcc/g++, make, qt6-base (qmake6). Start from a clean ./work
# (delete it to run again); the patches do not apply twice.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$HERE/work}"
VIEWER_REPO=https://github.com/SunnySlopes/cubiomes-viewer
VIEWER_COMMIT=169e8c5bc92147496e28abca92d0f07895ae0dec

if [ -e "$WORK/cubiomes-viewer" ]; then
    echo "$WORK/cubiomes-viewer already exists. Delete $WORK to start over." >&2
    exit 1
fi
mkdir -p "$WORK"
git clone --recurse-submodules "$VIEWER_REPO" "$WORK/cubiomes-viewer"
cd "$WORK/cubiomes-viewer"
git checkout "$VIEWER_COMMIT"
git submodule update --init
bash "$HERE/apply.sh"

[ "${1:-}" = "--no-build" ] && { echo "Patched source is in $WORK/cubiomes-viewer"; exit 0; }

mkdir -p "$WORK/build" && cd "$WORK/build"
qmake6 -o Makefile ../cubiomes-viewer/cubiomes-viewer.pro CONFIG+=release
make -j"$(nproc)"
echo "Built: $WORK/build/cubiomes-viewer"
