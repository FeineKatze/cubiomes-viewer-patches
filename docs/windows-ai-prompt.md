# Prompt to give an AI assistant (e.g. ChatGPT)

Copy everything below the line into the chat and attach/upload the `patches/` folder and `apply.sh`.

---

I want to build a patched version of Cubiomes Viewer for Windows. Walk me through it step by step, one step at a time, and tell me exactly what to type and where (Git Bash vs. Qt MinGW prompt). Wait for me to report the result of each step before continuing. If something fails, ask me for the exact error text.

Context (all verified on Linux; the Windows build is untested):
- Repo: https://github.com/SunnySlopes/cubiomes-viewer, use commit `169e8c5bc92147496e28abca92d0f07895ae0dec`.
- The repo uses a git submodule `cubiomes` (xpple/cubiomes). The pinned submodule commit is too old for this viewer commit (compile errors like "MC_26_3 was not declared"), so it must be switched to xpple/cubiomes commit `4f04235f3e6e25491a02a830e4f500f68045be17`.
- I have 11 patch files in `patches/`: `panning-fix.patch`, `structure-distance.patch`, `fast-spawn-toggle.patch`, `simd-toggle.patch`, `radial-biome-viewer.patch`, `qt6-combo-fix.patch`, `edge-cells-viewer.patch` (apply from the repo root, in this order, with `git apply --ignore-whitespace --whitespace=nowarn`) and `spawn-speedup.patch`, then `simd-noise.patch`, then `radial-biome-backend.patch`, then `edge-cells-backend.patch` (apply INSIDE the `cubiomes` folder, in this order, with `git apply --ignore-whitespace --whitespace=nowarn -p2`). `apply.sh` does the submodule switch and all eleven applications; run it in Git Bash from the repo root.
- Build toolchain the fork's own CI uses: Qt 5.15.2 with MinGW 8.1 64-bit. Build commands: `qmake CONFIG+=release` then `mingw32-make`. The .pro has a Windows branch that statically links libgcc/libstdc++ and builds a small helper (`libwinsane`) automatically.
- Do NOT use `-march=native` / CU_NATIVE (I want to share the exe with others). The new SIMD code uses AVX2 via function attributes and a runtime CPU check, so it works in a normal build.
- Success check: `release\cubiomes-viewer.exe --help` lists `--no-fast-spawn`.
- Then help me create a shareable folder with `windeployqt --dir cubiomes-viewer release\cubiomes-viewer.exe --compiler-runtime --no-translations` and copy the exe into it.
- Alternative if I do not want to install Qt locally: help me fork the repo, commit the patched files plus the submodule change, and let the existing `.github/workflows/windows-release.yaml` GitHub Actions workflow produce the build artifact.

Things the patches change, so you can recognise them: a "Fast spawn search" and a "SIMD biome noise (AVX2)" checkbox in Settings, `--no-fast-spawn` and `--no-simd` options, Ctrl+click on two structures to show the distance, smoother map dragging, and a "Within radial distance" option for the exact "at scale" biome conditions.
