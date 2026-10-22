# Changelog

All notable changes to these patches. Each release page shows the section of its version.
Newest changes go under "Unreleased" until a version is tagged.

## [Unreleased]

### Added
- Search timer: the status line under the progress bar shows how long the search has been running. It stops with the search, continues when you continue, starts from zero again when you clear the results while no search is running, and is saved in the session.

### Changed
- Faster spawn lookup, about 1.8 times faster (126 to 70 µs per seed). A spawn plus village search runs about 1.7 times faster in practice (58K to 100K seeds/s on 12 threads of a Ryzen 7 5800X). Results are identical, and everything stays behind the existing "Fast spawn search" switch.

## [0.1.1] - 2026-10-18

### Added
- Condition areas on the map: every condition in the list has a tick box. Ticked conditions draw their area (a circle for a radius, a rectangle otherwise) on the map, relative to the world origin or to the spawn point. They are hidden when you look at another dimension, are not saved with the session, and everything starts unticked.

### Fixed
- Windows: the zip now contains the MinGW and MSYS2 libraries the program needs. Version 0.1.0 failed to start on computers without MSYS2 with "libgcc_s_seh-1.dll was not found".

## [0.1.0] - 2026-10-17

First release, with builds for Linux, Windows and macOS.

### Added
- Faster spawn search, about 9 times faster for searches with a Spawn condition, with identical results. Off switch: Settings, `--no-fast-spawn` or `CUBIOMES_NO_FAST_SPAWN=1`.
- AVX2 vector code for the biome noise: faster map and area generation, strongholds, monument checks and spawn searches, with identical results. Off switch: Settings, `--no-simd` or `CUBIOMES_NO_SIMD=1`.
- Radial areas ("Within radial distance") for the exact "Overworld/Nether/End at scale" biome conditions, and an option to include cells that only touch the edge of the circle.
- Structure distance: click a structure or the spawn, then Ctrl+click another one to see the line and the distance between them.

### Fixed
- Map panning no longer drops most mouse movement (it was sluggish with high-polling mice), and the map no longer glides on after you stop.
- The "Sampling scale" dropdown of the biome conditions was completely greyed out in Qt 6 builds.

### Known issues
- The Windows zip was missing libraries (fixed in 0.1.1).
- The Windows and macOS builds have not been tested on real machines.
