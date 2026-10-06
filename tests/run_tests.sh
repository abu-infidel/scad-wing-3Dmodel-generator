#!/usr/bin/env bash
# Run the whole test suite.
#
#   tests/run_tests.sh            wing sweeps, presets, invalid input, unit tests, committed default STL
#   tests/run_tests.sh --full     the same plus whole-aircraft builds at draft quality (a few extra minutes)
#
# Requires: openscad (2019.05 or newer; developed on 2021.01), python3 with numpy and trimesh
#           (pip install numpy trimesh networkx scipy)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "== 1/4 OpenSCAD unit tests (airfoils, planform, loft)"
if ! out=$(openscad -D 'part="none"' -o "$tmp/unit.stl" tests/airfoil_tests.scad 2>&1); then
    echo "$out"
    echo "FAILED: OpenSCAD unit tests" >&2
    exit 1
fi
echo "$out" | grep "ALL AIRFOIL"

echo "== 2/4 Python reference model self-check"
python3 -I tests/naca_reference.py

echo "== 3/4 parameter sweeps (OpenSCAD CLI -> STL -> independent reference)"
python3 -I tests/param_sweep.py "$@"

echo "== 4/4 committed default STL"
if [[ -f stl/b25_mitchell_default.stl ]]; then
    python3 -I tests/param_sweep.py --only none --aircraft-stl stl/b25_mitchell_default.stl
    python3 -I tests/validate_stl.py stl/b25_mitchell_default.stl --span 286.05 --length 224.03 --tol 0.003
else
    echo "(stl/b25_mitchell_default.stl not present - skipped)"
fi
echo
echo "ALL TESTS PASSED"
