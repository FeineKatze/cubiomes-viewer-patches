#!/usr/bin/env bash
# Prints the CHANGELOG.md section of one version, without its heading.
#   scripts/release-notes.sh 0.1.1        the notes of version 0.1.1
#   scripts/release-notes.sh Unreleased   the notes collected for the next release
# Exits with an error if there is no such section.
set -euo pipefail
[ $# -eq 1 ] || { echo "usage: $0 <version>" >&2; exit 2; }
cd "$(dirname "$0")/.."
awk -v ver="$1" '
    index($0, "## [" ver "]") == 1 { found = 1; next }
    found && /^## \[/               { exit }
    found                           { print }
    END                             { if (!found) exit 1 }
' CHANGELOG.md
