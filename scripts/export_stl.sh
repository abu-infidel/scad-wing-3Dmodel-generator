#!/usr/bin/env bash
# Export the Cessna 337 / O-2 Skymaster model (no propellers) as an STL file.
#
#   scripts/export_stl.sh OUTPUT.stl [openscad options and -D overrides ...]
#
# Examples
#   scripts/export_stl.sh skymaster.stl
#   scripts/export_stl.sh skymaster.stl -D 'root_airfoil="2415"' -D 'tip_airfoil="0009"'
#   scripts/export_stl.sh skymaster.stl -D 'root_airfoil_override="23112"' -D wing_span_m=13 -D scale_denominator=100
#   scripts/export_stl.sh wing.stl -D 'part="wing_only"'
#   scripts/export_stl.sh preview.stl -D 'quality="draft"'
#   scripts/export_stl.sh skymaster.stl -p cessna_skymaster.json -P "Long span - 13.5 m, NACA 4412 to 2409"
#
# The output is a binary STL when this OpenSCAD supports it (smaller and more precise than ASCII);
# set ASCII_STL=1 to force ASCII. Wing/airframe parameters are listed in README.md.
set -euo pipefail

if [[ $# -lt 1 || "$1" == -h || "$1" == --help ]]; then
    sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi
out="$1"; shift
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v openscad >/dev/null 2>&1; then
    echo "error: openscad was not found in PATH (install it from https://openscad.org)" >&2
    exit 127
fi

fmt=()
if [[ -z "${ASCII_STL:-}" ]] && openscad --help 2>&1 | grep -q binstl; then
    fmt=(--export-format binstl)
fi

# relative paths (output file, -p parameter-set file) are resolved against the caller's directory
exec openscad ${fmt[@]+"${fmt[@]}"} -o "$out" "$@" "$here/cessna_skymaster.scad"
