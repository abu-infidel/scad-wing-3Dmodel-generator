#!/usr/bin/env python3
"""Parameter-sweep tests for b25_mitchell.scad.

Builds STLs through the OpenSCAD command line with many -D overrides and compares spanwise
cross-sections of the result with an independent reference model (naca_reference.py plus the
planform equations below), so airfoil selection, span, chords, sweep, dihedral, incidence, twist,
blending, thickness scaling, custom airfoils and model scale are all verified end to end.

    python3 tests/param_sweep.py            # wing-only sweeps (fast)
    python3 tests/param_sweep.py --full     # also draft-quality whole-aircraft builds
    python3 tests/param_sweep.py --aircraft-stl stl/b25_mitchell_default.stl   # check a finished default STL
"""
import argparse
import json
import math
import os
import subprocess
import sys
import tempfile
import time

import numpy as np
import trimesh

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import naca_reference as ref  # noqa: E402
import validate_stl as vs  # noqa: E402

SCAD = os.path.join(ROOT, "b25_mitchell.scad")

# B-25J defaults, mirrored from b25_mitchell.scad (the reference model must not read the SCAD file)
DEFAULTS = {
    "wing_span_m": 20.60, "center_halfspan_m": 3.99, "root_chord_m": 3.30, "kink_chord_m": 3.30,
    "tip_chord_m": 1.51, "le_sweep_inboard_deg": 0.0, "le_sweep_outboard_deg": 3.0,
    "sweep_ref_chord_fraction": 0.0, "wing_tip_round_m": 0.35,
    "dihedral_center_deg": 4.64, "dihedral_outer_deg": 0.36, "root_incidence_deg": 2.0, "tip_twist_deg": -2.49,
    "wing_le_station_m": 5.60, "wing_z_m": 0.05,
    "root_airfoil": "23017", "tip_airfoil": "4409", "root_airfoil_override": "", "tip_airfoil_override": "",
    "root_thickness_scale": 1.0, "tip_thickness_scale": 1.0, "trailing_edge_thickness": 0.0,
    "airfoil_blend_start": -1.0, "scale_denominator": 72,
}
AF_N = {"draft": 14, "normal": 30, "high": 64}
TIP_K = {"draft": 4, "normal": 8, "high": 14}

RESULTS = []


def check(case, label, measured, expected, tol, absolute=False):
    err = abs(measured - expected) if absolute else abs(measured - expected) / max(abs(expected), 1e-12)
    ok = err <= tol
    RESULTS.append((case, label, ok))
    unit = "" if absolute else " (rel)"
    print(f"  [{'PASS' if ok else 'FAIL'}] {label}: measured {measured:.4f}, expected {expected:.4f}, error {err:.5f}{unit}, tol {tol}")
    return ok


def check_true(case, label, cond, detail=""):
    RESULTS.append((case, label, bool(cond)))
    print(f"  [{'PASS' if cond else 'FAIL'}] {label} {detail}")
    return bool(cond)


def fmt(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, str):
        return '"' + v + '"'
    if isinstance(v, (list, tuple, np.ndarray)):
        return json.dumps(np.round(np.asarray(v, dtype=float), 6).tolist())
    return repr(v)


def run_openscad(out, overrides, part="wing_only", quality="high", extra=None, timeout=7200):
    cmd = ["openscad", "-o", out, "-D", f'part="{part}"', "-D", f'quality="{quality}"']
    for k, v in overrides.items():
        cmd += ["-D", f"{k}={fmt(v)}"]
    cmd += (extra or []) + [SCAD]
    t0 = time.time()
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    return proc, time.time() - t0


def build(workdir, name, overrides, part="wing_only", quality="high"):
    out = os.path.join(workdir, name + ".stl")
    proc, dt = run_openscad(out, overrides, part, quality)
    if proc.returncode != 0:
        print(proc.stderr[-2000:])
        raise RuntimeError(f"openscad failed for {name}")
    return trimesh.load(out, force="mesh", process=True), dt


# ---------------------------------------------------------------- reference wing model
def plan_z(p, a):
    k, ti, to = p["center_halfspan_m"], math.tan(math.radians(p["dihedral_center_deg"])), math.tan(math.radians(p["dihedral_outer_deg"]))
    return a * ti if a <= k else k * ti + (a - k) * to


def plan_refx(p, a):
    k, si, so = p["center_halfspan_m"], math.tan(math.radians(p["le_sweep_inboard_deg"])), math.tan(math.radians(p["le_sweep_outboard_deg"]))
    return a * si if a <= k else k * si + (a - k) * so


def plan_chord(p, a):
    half = p["wing_span_m"] / 2
    return float(np.interp(a, [0, p["center_halfspan_m"], half], [p["root_chord_m"], p["kink_chord_m"], p["tip_chord_m"]]))


def ref_section(p, a, quality="high"):
    """Expected outline (x, z in mm, nose = +x) of the wing section at spanwise station a (m)."""
    half = p["wing_span_m"] / 2
    n = AF_N[quality]
    code_r = p["root_airfoil_override"] or p["root_airfoil"]
    code_t = p["tip_airfoil_override"] or p["tip_airfoil"]
    lr = p.get("_loop_root") if p.get("_loop_root") is not None else ref.loop(code_r, n, p["trailing_edge_thickness"])
    lt = p.get("_loop_tip") if p.get("_loop_tip") is not None else ref.loop(code_t, n, p["trailing_edge_thickness"])
    bs = p["center_halfspan_m"] if p["airfoil_blend_start"] < 0 else p["airfoil_blend_start"] * half
    b = 0.0 if a <= bs else min(1.0, (a - bs) / (half - bs))
    thk = p["root_thickness_scale"] + (p["tip_thickness_scale"] - p["root_thickness_scale"]) * a / half
    c, c0, f = plan_chord(p, a), p["root_chord_m"], p["sweep_ref_chord_fraction"]
    lex = p["wing_le_station_m"] + f * c0 + plan_refx(p, a) - f * c
    z0 = p["wing_z_m"] + plan_z(p, a)
    inc = math.radians(p["root_incidence_deg"] + p["tip_twist_deg"] * a / half)
    loop = ref.blend(lr, lt, b)
    xl, zl = (loop[:, 0] - 0.25) * c, loop[:, 1] * thk * c
    xs = lex + 0.25 * c + xl * math.cos(inc) + zl * math.sin(inc)
    zz = z0 + zl * math.cos(inc) - xl * math.sin(inc)
    pivot = p["wing_le_station_m"] + 0.25 * p["root_chord_m"]
    k = 1000.0 / p["scale_denominator"]
    return np.column_stack([-(xs - pivot) * k, zz * k])


def measured_section(mesh, y_m, scale_den):
    y = y_m * 1000.0 / scale_den
    segs = trimesh.intersections.mesh_plane(mesh, [0, 1, 0], [0, y, 0])
    return np.asarray(segs).reshape(-1, 3)


def extents(xz):
    return xz[:, 0].min(), xz[:, 0].max(), xz[:, 1].min(), xz[:, 1].max()


def sample_stations(p, quality):
    ycap = p["wing_span_m"] / 2 - p["wing_tip_round_m"]
    return [round(f * ycap, 4) for f in (0.037, 0.171, 0.309, 0.443, 0.577, 0.713, 0.861, 0.937)]


def compare_sections(case, mesh, p, quality="high", tol=0.03, mirror=True):
    k = p["scale_denominator"]
    worst = 0.0
    for a in sample_stations(p, quality):
        ys = (a, -a) if mirror else (a,)
        for y in ys:
            m = extents(measured_section(mesh, y, k)[:, [0, 2]])
            r = extents(ref_section(p, a, quality))
            worst = max(worst, max(abs(mi - ri) for mi, ri in zip(m, r)))
    check(case, f"section outlines (x/z extents at {len(sample_stations(p, quality))} stations, both wings), worst deviation mm",
          worst, 0.0, tol, absolute=True)


# ---------------------------------------------------------------- test cases
def test_wing_cases(workdir):
    custom_r = ref.loop("0015", 80, 0.0)
    custom_t = ref.loop("2412", 80, 0.0)
    cases = [
        ("default_B25", {}),
        ("airfoils_2412_to_0009", {"root_airfoil": "2412", "tip_airfoil": "0009"}),
        ("airfoil_codes_by_text", {"root_airfoil": "0012", "tip_airfoil": "0012", "root_airfoil_override": "4412",
                                   "tip_airfoil_override": "23012"}),
        ("reflex_5digit_and_6409", {"root_airfoil": "6409", "tip_airfoil_override": "23112"}),
        ("thickness_and_trailing_edge", {"root_thickness_scale": 1.25, "tip_thickness_scale": 0.8,
                                         "trailing_edge_thickness": 0.012}),
        ("planform_span_chords_sweep", {"wing_span_m": 18.0, "center_halfspan_m": 3.0, "root_chord_m": 4.0,
                                        "kink_chord_m": 3.4, "tip_chord_m": 1.2, "le_sweep_inboard_deg": 5.0,
                                        "le_sweep_outboard_deg": 15.0, "sweep_ref_chord_fraction": 0.25,
                                        "wing_tip_round_m": 0.5}),
        ("angles_dihedral_incidence_twist", {"dihedral_center_deg": -3.0, "dihedral_outer_deg": 7.0,
                                             "root_incidence_deg": 3.5, "tip_twist_deg": -4.0}),
        ("position_and_blend_start", {"wing_le_station_m": 7.25, "wing_z_m": 0.4, "airfoil_blend_start": 0.6}),
        ("model_scale_1_to_100", {"scale_denominator": 100}),
        ("model_scale_full_size_mm", {"scale_denominator": 1}),
        ("tip_not_rounded", {"wing_tip_round_m": 0.0}),
    ]
    for name, ov in cases:
        print(f"\n== {name}  {ov if ov else '(defaults)'}")
        mesh, dt = build(workdir, name, ov)
        p = {**DEFAULTS, **ov}
        faults = vs.basic_checks(mesh)[1]
        check_true(name, f"mesh valid (watertight, consistent, positive volume) [{dt:.1f}s, {len(mesh.faces)} faces]", not faults, "; ".join(faults))
        k = 1000.0 / p["scale_denominator"]
        half = p["wing_span_m"] / 2
        cap = p["wing_tip_round_m"]
        y_end = half if cap == 0 else half - cap + cap * math.sin(math.radians(90 * (TIP_K["high"] - 1) / TIP_K["high"]))
        check(name, "span (mm)", float(mesh.extents[1]), 2 * y_end * k, 2e-4)
        # OpenSCAD 2021.01's ASCII STL writer keeps 6 significant digits: 0.1 mm at 10 m (1:1 scale)
        compare_sections(name, mesh, p, tol=0.35 if p["scale_denominator"] == 1 else 0.03)
        verts = np.round(mesh.vertices, 5)
        mirrored = np.round(mesh.vertices * np.array([1, -1, 1]), 5)
        key = lambda v: v[np.lexsort((v[:, 2], v[:, 1], v[:, 0]))]
        check_true(name, "port/starboard symmetry", np.allclose(key(verts), key(mirrored), atol=2e-5))

    # custom (Selig) airfoils resampled onto the common grid
    name = "custom_selig_airfoils"
    ov = {"root_airfoil": "custom", "tip_airfoil": "custom", "custom_root_airfoil": custom_r, "custom_tip_airfoil": custom_t}
    print(f"\n== {name}  (NACA 0015 -> NACA 2412 as point lists)")
    mesh, dt = build(workdir, name, ov)
    faults = vs.basic_checks(mesh)[1]
    check_true(name, f"mesh valid [{dt:.1f}s]", not faults, "; ".join(faults))
    p = {**DEFAULTS, "root_airfoil": "0015", "tip_airfoil": "2412"}
    compare_sections(name, mesh, p, tol=0.12)

    # draft / normal quality also produce valid wings
    for q in ("draft", "normal"):
        name = f"quality_{q}"
        print(f"\n== {name}")
        mesh, dt = build(workdir, name, {}, quality=q)
        faults = vs.basic_checks(mesh)[1]
        check_true(name, f"mesh valid [{dt:.1f}s, {len(mesh.faces)} faces]", not faults, "; ".join(faults))
        compare_sections(name, mesh, DEFAULTS, quality=q, tol=0.15)

    # orientation: nose +X, upper surface up, positive camber for 23017
    name = "orientation"
    print(f"\n== {name}")
    mesh, _ = build(workdir, name, {"root_incidence_deg": 0, "tip_twist_deg": 0, "dihedral_center_deg": 0,
                                   "dihedral_outer_deg": 0, "root_airfoil": "2412", "tip_airfoil": "2412"})
    sec = measured_section(mesh, 0.37, 72)
    k = 1000 / 72
    c = plan_chord(DEFAULTS, 0.37)
    lr = ref.loop("2412", 64)
    check(name, "upper surface height above chord line (mm)", sec[:, 2].max() - DEFAULTS["wing_z_m"] * k,
          lr[:, 1].max() * c * k, 0.003)
    check(name, "lower surface depth below chord line (mm)", DEFAULTS["wing_z_m"] * k - sec[:, 2].min(),
          -lr[:, 1].min() * c * k, 0.01)
    pivot_x = 0.0
    le_x = sec[:, 0].max()
    check_true(name, "leading edge points to +X (nose direction)", le_x > sec[:, 0].min() + 0.9 * c * k * 0.99 and le_x > 0)


def test_invalid_inputs(workdir):
    print("\n== invalid inputs must fail with a clear message")
    bad = [
        ("bad_airfoil_letters", {"root_airfoil_override": "9x12"}, "Unsupported airfoil code"),
        ("bad_airfoil_camber_line", {"tip_airfoil_override": "26012"}, "Unsupported airfoil code"),
        ("bad_airfoil_length", {"tip_airfoil_override": "123456"}, "Unsupported airfoil code"),
        ("kink_beyond_span", {"center_halfspan_m": 11.0}, "center_halfspan_m"),
        ("zero_chord", {"tip_chord_m": 0.0}, "chords must be positive"),
        ("tip_round_too_big", {"wing_tip_round_m": 9.0}, "wing_tip_round_m"),
        ("custom_airfoil_missing", {"root_airfoil": "custom"}, "custom airfoil"),
    ]
    for name, ov, msg in bad:
        proc, _ = run_openscad(os.path.join(workdir, name + ".stl"), ov)
        ok = proc.returncode != 0 and msg in proc.stderr
        check_true(name, f"rejected with message containing '{msg}'", ok, "" if ok else f"(rc={proc.returncode}) {proc.stderr[-300:]}")


def test_airfoil_preview(workdir):
    print("\n== part=airfoil_preview")
    out = os.path.join(workdir, "airfoil_preview.stl")
    proc, _ = run_openscad(out, {}, part="airfoil_preview")
    check_true("airfoil_preview", "builds", proc.returncode == 0, proc.stderr[-300:])
    mesh = trimesh.load(out, force="mesh", process=True)
    faults = vs.basic_checks(mesh, 2, 2)[1]
    check_true("airfoil_preview", "two watertight airfoil plates", not faults, "; ".join(faults))
    check("airfoil_preview", "two 100 mm plates 120 mm apart: x extent (mm)", float(mesh.extents[0]), 220.0, 0.004)
    check("airfoil_preview", "plate thickness (mm)", float(mesh.extents[2]), 2.0, 1e-6)


def typed(params):
    """JSON parameter-set values are strings; convert them using the types of DEFAULTS."""
    out = {}
    for k, v in params.items():
        if k in DEFAULTS:
            out[k] = v if isinstance(DEFAULTS[k], str) else float(v)
    return out


def test_presets(workdir):
    print("\n== parameter sets in b25_mitchell.json (-p file -P set)")
    path = os.path.join(ROOT, "b25_mitchell.json")
    if not os.path.exists(path):
        check_true("presets", "b25_mitchell.json exists", False)
        return
    sets = json.load(open(path))["parameterSets"]
    check_true("presets", "contains the B-25J default set", "B-25J default" in sets)
    check_true("presets", "contains at least 3 alternative sets", len(sets) >= 4, f"({len(sets)} sets)")
    for name, s in sets.items():
        out = os.path.join(workdir, "preset_" + "".join(ch if ch.isalnum() else "_" for ch in name) + ".stl")
        proc, dt = run_openscad(out, {}, part="wing_only", extra=["-p", path, "-P", name])
        ok = proc.returncode == 0 and os.path.exists(out)
        check_true("presets", f"set '{name}' builds [{dt:.1f}s]", ok, proc.stderr[-300:] if not ok else "")
        if not ok:
            continue
        mesh = trimesh.load(out, force="mesh", process=True)
        faults = vs.basic_checks(mesh)[1]
        check_true("presets", f"set '{name}' mesh valid", not faults, "; ".join(faults))
        p = {**DEFAULTS, **typed(s)}
        compare_sections(f"preset:{name}", mesh, p)
        half = p["wing_span_m"] / 2
        k = 1000.0 / p["scale_denominator"]
        cap = p["wing_tip_round_m"]
        y_end = half - cap + cap * math.sin(math.radians(90 * (TIP_K["high"] - 1) / TIP_K["high"]))
        check("presets", f"set '{name}' span (mm)", float(mesh.extents[1]), 2 * y_end * k, 2e-4)
    # the default set must reproduce the plain defaults exactly
    a = os.path.join(workdir, "preset_default_check.stl")
    b = os.path.join(workdir, "plain_default.stl")
    run_openscad(a, {}, part="wing_only", extra=["-p", path, "-P", "B-25J default"])
    run_openscad(b, {}, part="wing_only")
    ma, mb = trimesh.load(a, force="mesh"), trimesh.load(b, force="mesh")
    check_true("presets", "B-25J default set == plain defaults",
               np.allclose(ma.bounds, mb.bounds, atol=1e-6) and abs(ma.volume - mb.volume) < 1e-6 * mb.volume)


def test_aircraft_stl(path, label, k=1000 / 72, expect_gear=True):
    """Checks on a finished whole-aircraft STL built with default geometry parameters."""
    print(f"\n== whole aircraft: {label} ({path})")
    mesh = trimesh.load(path, force="mesh", process=True)
    metrics, faults = vs.basic_checks(mesh)
    check_true(label, f"mesh valid ({len(mesh.faces)} faces, {metrics['volume_mm3']:.0f} mm^3)", not faults, "; ".join(faults))
    pivot = 5.60 + 0.25 * 3.30
    lo, hi = mesh.bounds
    check(label, "length: nose station 0 .. tail station 16.13 m (mm)", float(hi[0] - lo[0]), 16.13 * k, 0.003)
    check(label, "nose position (+X end, mm)", float(hi[0]), pivot * k, 0.003)
    check(label, "tail position (-X end, mm)", float(lo[0]), -(16.13 - pivot) * k, 0.003)
    check(label, "span 20.60 m wing (mm)", float(hi[1] - lo[1]), 20.60 * k, 0.003)
    if expect_gear:
        check(label, "height with gear down vs published 4.98 m (mm)", float(hi[2] - lo[2]), 4.98 * k, 0.025)
    return mesh


def test_aircraft_variants(workdir):
    k = 1000 / 72
    base = {"quality": "draft"}
    variants = [
        ("aircraft_default_draft", {}),
        ("aircraft_no_gear_no_props", {"show_landing_gear": False, "show_propellers": False}),
        ("aircraft_long_fuselage_wide_wing", {"fuselage_length_m": 18.0, "wing_span_m": 24.0}),
        ("aircraft_other_airfoils", {"root_airfoil": "2415", "tip_airfoil": "0009", "dihedral_outer_deg": 3.0}),
        ("aircraft_wing_fuselage_only", {"show_tail": False, "show_nacelles": False, "show_landing_gear": False,
                                         "show_canopy_and_turret": False, "show_gun_barrels": False}),
    ]
    for name, ov in variants:
        print(f"\n== {name}  {ov if ov else '(defaults)'}")
        out = os.path.join(workdir, name + ".stl")
        proc, dt = run_openscad(out, ov, part="aircraft", quality="draft")
        if proc.returncode != 0:
            check_true(name, "builds", False, proc.stderr[-500:])
            continue
        mesh = trimesh.load(out, force="mesh", process=True)
        metrics, faults = vs.basic_checks(mesh)
        check_true(name, f"mesh valid [{dt:.0f}s, {len(mesh.faces)} faces]", not faults, "; ".join(faults))
        lo, hi = mesh.bounds
        p = {**DEFAULTS, **ov}
        if name == "aircraft_default_draft":
            test_aircraft_stl(out, name)
        elif name == "aircraft_no_gear_no_props":
            check_true(name, "no wheels below the nacelles (z min above -1.0 m)", lo[2] > -1.0 * k, f"zmin={lo[2]:.1f} mm")
        elif name == "aircraft_long_fuselage_wide_wing":
            check(name, "span 24 m (mm)", float(hi[1] - lo[1]), 24.0 * k, 0.004)
            check(name, "length 18 m (mm)", float(hi[0] - lo[0]), 18.0 * k, 0.004)
        elif name == "aircraft_other_airfoils":
            check(name, "span unchanged (mm)", float(hi[1] - lo[1]), 20.6 * k, 0.004)
        elif name == "aircraft_wing_fuselage_only":
            check_true(name, "fins removed (z max below 1.7 m)", hi[2] < 1.7 * k, f"zmax={hi[2]:.1f} mm")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--full", action="store_true", help="also build whole-aircraft variants at draft quality")
    ap.add_argument("--aircraft-stl", help="validate a finished default whole-aircraft STL")
    ap.add_argument("--only", choices=["wing", "invalid", "preview", "presets", "aircraft", "none"],
                    help="run one group ('none' = only the --aircraft-stl check)")
    ap.add_argument("--keep", help="directory to keep generated STLs in")
    args = ap.parse_args()

    workdir_ctx = tempfile.TemporaryDirectory() if not args.keep else None
    workdir = args.keep or workdir_ctx.name
    os.makedirs(workdir, exist_ok=True)

    groups = {
        "wing": lambda: test_wing_cases(workdir),
        "invalid": lambda: test_invalid_inputs(workdir),
        "preview": lambda: test_airfoil_preview(workdir),
        "presets": lambda: test_presets(workdir),
    }
    if args.only == "none":
        pass
    elif args.only in groups:
        groups[args.only]()
    elif args.only == "aircraft":
        test_aircraft_variants(workdir)
    else:
        for g in groups.values():
            g()
        if args.full:
            test_aircraft_variants(workdir)
    if args.aircraft_stl:
        test_aircraft_stl(args.aircraft_stl, "finished_default_stl")

    failed = [r for r in RESULTS if not r[2]]
    print(f"\n{len(RESULTS) - len(failed)} / {len(RESULTS)} checks passed")
    if failed:
        print("FAILED CHECKS:")
        for case, label, _ in failed:
            print(f"  - {case}: {label}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
