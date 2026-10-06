#!/usr/bin/env python3
"""Validate an STL produced by cessna_skymaster.scad.

Usage:
    validate_stl.py model.stl [--span MM] [--length MM] [--root-thickness MM]
                              [--tip-thickness MM] [--planform-area MM2]
                              [--min-bodies N --max-bodies N] [--tol FRACTION]

Always checks: watertight, consistent winding, positive volume, no NaNs.
The optional flags compare measured values to expectations within --tol
(default 2 %).  Exit status is non-zero if any check fails.
"""
import argparse
import json
import sys

import numpy as np
import trimesh


def slice_thickness(mesh, y):
    """Vertical extent (z) of the cross-section at spanwise position y, or None if empty."""
    section = mesh.section(plane_origin=[0, y, 0], plane_normal=[0, 1, 0])
    if section is None:
        return None
    pts = np.asarray(section.vertices)
    return float(pts[:, 2].max() - pts[:, 2].min())


def top_projected_area(mesh):
    """Area of the upward-facing triangles projected on the XY plane (planform area of a wing)."""
    tri = mesh.triangles
    normals = mesh.face_normals
    up = normals[:, 2] > 0
    a = tri[up]
    area = 0.5 * np.abs((a[:, 1, 0] - a[:, 0, 0]) * (a[:, 2, 1] - a[:, 0, 1])
                        - (a[:, 2, 0] - a[:, 0, 0]) * (a[:, 1, 1] - a[:, 0, 1]))
    return float(area.sum())


def basic_checks(mesh, min_bodies=1, max_bodies=1):
    """Topology checks every exported model must pass. Returns (metrics, list of failure strings)."""
    failures = []
    metrics = {
        "extents_mm": [round(float(v), 3) for v in mesh.extents],
        "bounds_mm": [[round(float(v), 3) for v in b] for b in mesh.bounds],
        "faces": int(len(mesh.faces)),
        "volume_mm3": round(float(mesh.volume), 1),
    }
    checks = {}

    def check(name, ok, detail=""):
        checks[name] = {"ok": bool(ok), "detail": detail}
        if not ok:
            failures.append(f"{name}: {detail}")

    check("finite", np.isfinite(mesh.vertices).all(), "NaN/inf vertices")
    check("watertight", mesh.is_watertight, "mesh has open edges")
    check("winding_consistent", mesh.is_winding_consistent, "inconsistent face winding")
    check("positive_volume", mesh.volume > 0, f"volume = {mesh.volume:.1f} (inside-out?)")
    degenerate = int((mesh.area_faces < 1e-12).sum())
    check("no_degenerate_faces", degenerate == 0, f"{degenerate} zero-area faces")
    bodies = len(mesh.split(only_watertight=False))
    metrics["bodies"] = bodies
    check("body_count", min_bodies <= bodies <= max_bodies,
          f"{bodies} separate bodies (expected {min_bodies}..{max_bodies})")
    metrics.update(checks)
    return metrics, failures


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("stl")
    ap.add_argument("--span", type=float, help="expected extent along Y (mm)")
    ap.add_argument("--length", type=float, help="expected extent along X (mm)")
    ap.add_argument("--root-thickness", type=float, help="expected thickness at y=0 (mm)")
    ap.add_argument("--tip-thickness", type=float, help="expected thickness near the tip (mm)")
    ap.add_argument("--tip-y", type=float, help="y (mm) at which --tip-thickness is measured")
    ap.add_argument("--planform-area", type=float, help="expected planform area (mm^2), wing_only parts")
    ap.add_argument("--min-bodies", type=int, default=1)
    ap.add_argument("--max-bodies", type=int, default=1)
    ap.add_argument("--tol", type=float, default=0.02, help="relative tolerance for numeric expectations")
    ap.add_argument("--json", action="store_true", help="print metrics as JSON only")
    args = ap.parse_args()

    mesh = trimesh.load(args.stl, force="mesh", process=True)
    metrics, failures = basic_checks(mesh, args.min_bodies, args.max_bodies)
    bodies = metrics["bodies"]
    ext = mesh.extents

    def rel(name, measured, expected):
        err = abs(measured - expected) / expected
        metrics[name] = {"measured": round(measured, 3), "expected": round(expected, 3), "error": round(err, 4)}
        if err > args.tol:
            failures.append(f"{name}: measured {measured:.3f}, expected {expected:.3f} ({err * 100:.2f} % off)")

    if args.span is not None:
        rel("span_mm", float(ext[1]), args.span)
    if args.length is not None:
        rel("length_mm", float(ext[0]), args.length)
    if args.root_thickness is not None:
        t = slice_thickness(mesh, 0.0)
        if t is None:
            failures.append("root_thickness: no section at y=0")
        else:
            rel("root_thickness_mm", t, args.root_thickness)
    if args.tip_thickness is not None:
        y = args.tip_y if args.tip_y is not None else 0.0
        t = slice_thickness(mesh, y)
        if t is None:
            failures.append(f"tip_thickness: no section at y={y}")
        else:
            rel("tip_thickness_mm", t, args.tip_thickness)
    if args.planform_area is not None:
        rel("planform_area_mm2", top_projected_area(mesh), args.planform_area)

    if args.json:
        print(json.dumps(metrics, indent=2))
    else:
        print(f"{args.stl}")
        print(f"  faces {metrics['faces']}, bodies {bodies}, volume {metrics['volume_mm3']} mm^3")
        print(f"  extents (X,Y,Z) mm: {metrics['extents_mm']}")
        for k, v in metrics.items():
            if isinstance(v, dict) and "ok" in v:
                print(f"  [{'PASS' if v['ok'] else 'FAIL'}] {k}")
            elif isinstance(v, dict) and "measured" in v:
                print(f"  [{'PASS' if v['error'] <= args.tol else 'FAIL'}] {k}: measured {v['measured']} vs expected {v['expected']} ({v['error'] * 100:.2f} %)")
    if failures:
        print("FAILED:\n  " + "\n  ".join(failures), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
