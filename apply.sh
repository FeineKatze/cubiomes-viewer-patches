#!/usr/bin/env bash
# Applies the patches to a checkout of SunnySlopes/cubiomes-viewer.
# Run from the REPO ROOT (the folder containing cubiomes-viewer.pro), e.g. in Git Bash:
#   bash /path/to/cubiomes-viewer-patches/apply.sh
set -euo pipefail
PATCHES="$(cd "$(dirname "$0")" && pwd)/patches"
BACKEND_COMMIT=4f04235f3e6e25491a02a830e4f500f68045be17   # xpple/cubiomes

[ -f cubiomes-viewer.pro ] || { echo "Run this from the repo root (cubiomes-viewer.pro not found)"; exit 1; }
[ -d cubiomes ] || { echo "cubiomes/ folder missing - run: git submodule update --init"; exit 1; }

# 1. the fork's latest code needs a newer backend than its pinned submodule
if git -C cubiomes rev-parse --git-dir >/dev/null 2>&1; then
    git -C cubiomes fetch origin
    git -C cubiomes checkout "$BACKEND_COMMIT"
else
    echo "NOTE: cubiomes/ is not a git checkout - make sure it is xpple/cubiomes @ $BACKEND_COMMIT"
fi

# 2. viewer patches (order matters). --ignore-whitespace tolerates CRLF checkouts.
for p in panning-fix structure-distance fast-spawn-toggle simd-toggle radial-biome-viewer qt6-combo-fix edge-cells-viewer; do
    git apply --ignore-whitespace --whitespace=nowarn "$PATCHES/$p.patch"
    echo "applied $p"
done

# 3. backend patches (paths inside the patches start with cubiomes/, so strip two levels)
(cd cubiomes && for p in spawn-speedup simd-noise radial-biome-backend edge-cells-backend; do
    git apply --ignore-whitespace --whitespace=nowarn -p2 "$PATCHES/$p.patch"
    echo "applied $p (backend)"
done)
echo "Done. Now build: qmake CONFIG+=release && mingw32-make"
