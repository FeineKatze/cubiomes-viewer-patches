# Cubiomes Viewer patches

Patches for [Cubiomes Viewer](https://github.com/Cubitect/cubiomes-viewer) as updated for Minecraft 26.x by the [SunnySlopes fork](https://github.com/SunnySlopes/cubiomes-viewer), built against the [xpple/cubiomes](https://github.com/xpple/cubiomes) backend. They make searches and the map faster, add a few features, and fix some bugs. This is an unofficial, independent set of patches. It is not affiliated with Cubitect, SunnySlopes or xpple.

Tested base: viewer commit `169e8c5` ("fixed camp search condition wipes out all results") and cubiomes commit `4f04235` ("Add INFER_POSTFIX option"). The fork's own pinned cubiomes submodule is too old for that viewer commit (the build fails with `MC_26_3 was not declared`), so `apply.sh` switches the submodule to `4f04235` first.

## What the patches do

| Change | Details |
|---|---|
| Faster spawn search | The exact spawn lookup skips noise samples that cannot beat the best candidate so far. About 9× faster for searches with a Spawn condition. Identical results. |
| SIMD biome noise (AVX2) | Evaluates the biome noise for 4 points at once. Used for area generation (the map), strongholds, monument checks and spawn. Roughly 1.7–2.2× faster area generation, 1.5× strongholds, about 1.4× more on spawn searches. Identical results; runtime CPU detection with a normal fallback. |
| Radial area for exact biome conditions | "Overworld/Nether/End at scale" accept "Within radial distance" (a circle) as well as squares. Not available for the layer-based overworld of Minecraft 1.0–1.17. |
| Include cells touching the edge | Option for the radial area. A cell counts if any block of it is inside the circle, not only its corner. On by default for new conditions; saved conditions keep the old rule. |
| Show condition areas on the map | Each condition in the list has a tick box. Ticked conditions draw their area on the map (a circle for a radius, a rectangle otherwise), independent of selection. Areas relative to the world origin or to the spawn point are drawn, and they are hidden when you look at another dimension. Areas relative to other conditions are not drawn yet. The ticks are not saved with the session and everything starts unticked. Right-click a condition for "Show on the map". |
| Structure distance | Click a structure or spawn, then Ctrl+click another one to see the line and distance between them. |
| Map panning fix | Dragging no longer drops most of the mouse movement (it was sluggish with high-polling mice), and the map no longer glides on after you stop. |
| Qt 6 dropdown fix | The "Sampling scale" dropdown was completely greyed out in Qt 6 builds. |

Every speed feature has an off switch, in case something ever looks wrong:

| Feature | Settings checkbox | Command line | Environment variable |
|---|---|---|---|
| Fast spawn search | Fast spawn search | `--no-fast-spawn` | `CUBIOMES_NO_FAST_SPAWN=1` |
| SIMD biome noise | SIMD biome noise (AVX2) | `--no-simd` | `CUBIOMES_NO_SIMD=1` |

The flag and the environment variable override the checkbox.

## Build on Linux

You need `git`, `gcc`/`g++`, `make` and Qt 6 (`qmake6`). On Arch: `pacman -S base-devel qt6-base`.

```
./build-linux.sh            # clones, patches and builds into ./work/build
./build-linux.sh --no-build # clone and patch only
```

The script clones the fork, checks out the tested commits and applies the patches. The result is `work/build/cubiomes-viewer`. Delete `work/` before running it again.

To apply the patches to a checkout you already have, run `bash apply.sh` from the viewer's repository root (the folder with `cubiomes-viewer.pro`), with the submodule initialised.

## Build on Windows

The patches are plain C/C++/Qt source changes and should work on Windows, but **this has not been built or run on Windows or with Qt 5 yet**. The fork's own release workflow uses Qt 5.15.2 with MinGW.

1. Install Git for Windows and Qt 5.15.2 with MinGW 8.1 64-bit.
2. `git clone --recurse-submodules https://github.com/SunnySlopes/cubiomes-viewer`, then `git checkout 169e8c5bc92147496e28abca92d0f07895ae0dec`.
3. In Git Bash, from that folder: `bash /path/to/this/repo/apply.sh`.
4. In the Qt MinGW prompt: `qmake CONFIG+=release`, then `mingw32-make`.
5. `release\cubiomes-viewer.exe --help` should list `--no-simd`.

Do not add `-march=native` to a build you want to share. The AVX2 code does not need it: it is selected at runtime. [`docs/windows-ai-prompt.md`](docs/windows-ai-prompt.md) is a ready-made prompt for an AI assistant that walks you through the steps above.

## Automated builds

`.github/workflows/release.yml` builds the patched viewer for Linux (x86_64), Windows (x86_64, MinGW) and macOS (arm64) on GitHub Actions.

- Push a version tag such as `v1.0.0` to build everything and create a **draft** release with the binaries, a checksum file and the exact patched source archive.
- Or use "Run workflow" on the Actions tab to build without a release. The files are then available as workflow artifacts.

Linux builds need Qt 6 installed on your system. The Windows and macOS builds have not been tested on real machines yet.

## Patch order

`apply.sh` applies these in this order. The viewer patches go on the viewer repository, and the backend patches go on the `cubiomes/` submodule.

Viewer: `panning-fix`, `structure-distance`, `fast-spawn-toggle`, `simd-toggle`, `radial-biome-viewer`, `qt6-combo-fix`, `edge-cells-viewer`, `condition-shapes`.
Backend: `spawn-speedup`, `simd-noise`, `radial-biome-backend`, `edge-cells-backend`.

## How these were checked

- Spawn and SIMD changes: the old and new code agree on all 52,000 spawn lookups tested across 13 Minecraft versions (1.16–26.3), on 28.8 million noise values bit for bit, and on a suite covering area generation at every scale, strongholds and structure checks. In the viewer, old and new builds found identical seeds (for example 19,203 matches in one search) and identical results for all the example sessions.
- Radial and edge-cell conditions: compared against an independent exhaustive per-cell count (tens of thousands of comparisons across radii 10–128 and scales 1:4 and 1:16, no mismatches), and through the viewer on seeds 0–59,999.
- Speed numbers come from a single Ryzen 7 5800X and will differ on other hardware.
- Not tested: Windows, Qt 5, and clicking through every dialog on every platform.

## Known issues

- The "Biome samples" condition is a statistical test and behaves oddly at 100% coverage. Large areas can never pass, and tiny areas can pass by default even if they contain other biomes. For "only this biome in the area" use the exact "Overworld at scale" condition instead. This is existing behaviour and is not changed here.
- Cells at 1:4 are not the same as the game's per-block biomes near biome borders. Use scale 1:1 if you need per-block accuracy.

## License

Cubiomes Viewer is GPL-3.0, so these patches, which contain parts of it, are provided under the same license (see `LICENSE`). The cubiomes backend is MIT licensed; the patches to it are offered under the same terms as the code they modify.
