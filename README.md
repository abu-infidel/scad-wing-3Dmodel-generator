# Cessna 337 / O-2 Skymaster – parametric OpenSCAD model generator (no propellers)

An [OpenSCAD](https://openscad.org) program that builds a **Cessna 337 Super Skymaster** (the civil twin of the
military **O-2 Skymaster** "Oscar Deuce") and exports it as an **STL**. The **wing is fully parametric** – span,
chords, sweep, dihedral, incidence, twist and the **airfoil at the root and at the tip** – and the defaults are
the real Skymaster values where they are published (documented estimates otherwise, see
[Data and confidence](#data-and-confidence)). The central pod, push-pull engine positions, twin tail booms,
H-tail, wing struts and tricycle landing gear are included and adjustable too.

> **This version has no propellers.** The front (tractor) and rear (pusher) engine positions carry plain nose and
> tail cones instead of propeller blades; there is no propeller code or parameter in the script, and the tests
> check that nothing is turning at either engine plane. Turn the cones off with `show_engine_cones` if you want
> to fit your own propellers or spinners.

> **About the name.** There is no aircraft called a "Spymaster"; this is the **Skymaster** (Cessna 336/337, military
> O-2). If you meant a different aircraft, say so and the same generator can be re-targeted.

This branch is the Skymaster fork of the B-25 Mitchell generator on `main`; the airfoil engine, wing builder,
export scripts and test suite are shared in design, the airframe is new.

![Skymaster preview](docs/preview.png)

## Quick start

**GUI** – open `cessna_skymaster.scad` in OpenSCAD, open *Window ▸ Customizer*, change the parameters (pick the
root and tip airfoils from the drop-downs, or type any NACA code), press **F6** (render) and choose
*File ▸ Export ▸ Export as STL*. The saved presets in `cessna_skymaster.json` appear in the Customizer's preset
list.

**Command line**

```bash
openscad -o skymaster.stl cessna_skymaster.scad                          # the Skymaster as built, 1:72
scripts/export_stl.sh skymaster.stl                                      # same, as a (smaller) binary STL

# change the wing: airfoils, span, sweep, dihedral, washout ...
scripts/export_stl.sh skymaster.stl -D 'root_airfoil="2415"' -D 'tip_airfoil="0009"'
scripts/export_stl.sh skymaster.stl -D 'root_airfoil_override="23112"' -D wing_span_m=13 -D tip_twist_deg=-1
scripts/export_stl.sh skymaster.stl -D le_sweep_outboard_deg=8 -D dihedral_outer_deg=5 -D scale_denominator=48

# only the wing / airfoil plates / a quick draft / wheels up
scripts/export_stl.sh wing.stl -D 'part="wing_only"'
scripts/export_stl.sh plates.stl -D 'part="airfoil_preview"'
scripts/export_stl.sh draft.stl -D 'quality="draft"'
scripts/export_stl.sh wheels_up.stl -D show_landing_gear=false

# saved parameter sets
scripts/export_stl.sh skymaster.stl -p cessna_skymaster.json -P "Long span - 13.5 m, NACA 4412 to 2409"
```

The default `high` quality takes about 3 minutes to render on OpenSCAD 2021.01 and about 5 seconds with the
Manifold back end of newer versions (see [Render time](#render-time)); use `quality="draft"` for a quick look.

The console prints a wing report, for example
`Skymaster wing: span 11.58 m, area 18.7 m^2 (Cessna 337: 18.7), aspect ratio 7.19, taper 0.6, MAC 1.65 m`, and
warns when your changes move the wing area more than 5 % away from the real aircraft.

Developed and tested with **OpenSCAD 2021.01** (Ubuntu's package) and **2025.01.19**; it needs 2019.05 or newer
(`assert`, `each`, `is_string`).

## Conventions

* The model is built in metres on the full-size aircraft and scaled to **millimetres** at the end:
  `scale_denominator = 72` gives a 1:72 model (161 mm span, 126 mm long, 40 mm tall); `1` gives full size in mm.
* **Nose = +X**, starboard wing = +Y, up = +Z. The origin is the wing-root quarter-chord point, on the engine
  thrust line (the line through both engines, z = 0 inside the script).
* `quality` = `draft` / `normal` / `high` (default **high**). See [Render time](#render-time).

## Wing parameters

All lengths in metres on the full-size aircraft. The *source* column says how solid each default is (see
[Data and confidence](#data-and-confidence)).

| Parameter | Default | Meaning | Source |
|---|---|---|---|
| `root_airfoil` / `root_airfoil_override` | `2412` | airfoil on the centreline (drop-down, or any NACA code typed in the override) | published (as reported) |
| `tip_airfoil` / `tip_airfoil_override` | `2409` | airfoil at the tip | published (as reported) |
| `airfoil_blend_start` | `-1` | semi-span fraction where root→tip airfoil morphing starts (`-1` = end of the inboard panel) | assumed |
| `root_thickness_scale`, `tip_thickness_scale` | `1`, `1` | thickness multipliers (1 = true NACA thickness) | – |
| `trailing_edge_thickness` | `0` | extra blunt trailing edge as a fraction of chord (≈ 0.004 helps small prints) | – |
| `wing_span_m` | `11.58` | total span (38 ft 0 in; O-2A 38 ft 2 in = 11.63 m) | published |
| `center_halfspan_m` | `2.30` | half-span of the constant-chord inboard panel: strut and tail-boom station | **estimated** |
| `root_chord_m`, `kink_chord_m`, `tip_chord_m` | `1.83`, `1.83`, `1.105` | chords at the centreline, end of the inboard panel, tip (taper 0.6) | **estimated** – sized so the area is 201 sq ft (18.7 m²), aspect ratio 7.2 |
| `le_sweep_inboard_deg`, `le_sweep_outboard_deg` | `0`, `0` | sweep of the reference line on the inboard / outer panels | **estimated** (straight leading edge) |
| `sweep_ref_chord_fraction` | `0` | chord fraction the sweep refers to (`0` = leading edge, `0.25` = quarter chord) | – |
| `wing_tip_round_m` | `0.25` | length over which the tip is rounded (`0` = flat tip) | styling |
| `dihedral_center_deg`, `dihedral_outer_deg` | `3`, `3` | dihedral of the inboard / outer panels | **estimated** (typical Cessna value) |
| `root_incidence_deg` | `1.5` | root incidence | **estimated** |
| `tip_twist_deg` | `-2` | tip incidence relative to the root, linear (washout) | **estimated** |
| `wing_le_station_m`, `wing_z_m` | `2.45`, `0.95` | position of the root leading edge: station aft of the front cone tip and height above the thrust line (the wing sits on the cabin roof) | **estimated** |

### Airfoil selection

* Any **NACA 4-digit** code (`2412`, `2409`, `0012` …) and any **NACA 5-digit** code with a standard
  (`210`–`250`) or reflex (`221`–`251`) camber line (`23012`, `23112` …) – pick one from the drop-down or type it
  into `root_airfoil_override` / `tip_airfoil_override`. Bad codes stop the build with
  *Unsupported airfoil code …*.
* **Custom airfoils**: set the drop-down to `custom` and fill `custom_root_airfoil` / `custom_tip_airfoil`
  (in the *Hidden* section of the script, or with `-D 'custom_root_airfoil=[[1,0],…]'`) with Selig-format
  points (trailing edge → upper surface → leading edge → lower surface → trailing edge, chord 1). They are
  normalised and resampled onto the same grid as the NACA sections so root and tip can always be blended.
* The section is blended linearly from the root airfoil to the tip airfoil between `airfoil_blend_start` and the
  tip; with the defaults the NACA 2412 section runs out to the strut and boom station and the morph to NACA 2409
  happens on the outer panels.
* `part="airfoil_preview"` exports the two selected airfoils as 100 mm plates so you can see them.

### Other parts

* **Pod** (`show_pod`, `pod_width_scale`, `pod_height_scale`): cabin with the front and rear engine cowlings.
* **Engine cones** (`show_engine_cones`): the nose and tail cones that stand in for the propellers.
* **Tail** (`show_tail`, `boom_y_m`, `boom_z_m`, `boom_diameter_scale`, `stab_*`, `fin_*`, `tail_root_airfoil`,
  `tail_tip_airfoil`): twin booms from under the wing to two fins with the horizontal stabiliser between them;
  `stab_le_station_m` moves the stabiliser, the fins and the ends of the booms together.
* **Wing struts** (`show_wing_struts`, `strut_*`): one streamlined strut per side from the pod to the wing.
* **Landing gear** (`show_landing_gear`, `thrust_line_height_m`, `nose_gear_station_m`, `main_gear_station_m`,
  `main_gear_y_m`): tricycle gear; switch it off for a wheels-up display or print model. With the default
  `thrust_line_height_m` the overall height is 2.85 m, matching the published 9 ft 4 in.

## Parameter sets

`cessna_skymaster.json` holds saved sets: **Cessna 337 Skymaster default**, an **O-2A** set with the military
span, area and length (38 ft 2 in, 202.5 sq ft, 29 ft 2 in), a straight wing with NACA 2415→0009, a 13.5 m
long-span wing, a thin wing, and a wheels-up display model. Apply one with
`-p cessna_skymaster.json -P "<name>"` or from the Customizer. Save your own from the Customizer's `+` button.

## Render time

The airframe is a union of many lofted meshes, which OpenSCAD's CGAL back end evaluates slowly. Measured with
OpenSCAD 2021.01 on 4 cores (single-threaded CGAL):

| `quality` | triangles | OpenSCAD 2021.01 (CGAL) | peak memory |
|---|---|---|---|
| `draft` | ≈ 16 k | ≈ 23 s | ≈ 0.5 GB |
| `normal` | ≈ 42 k | ≈ 1 min 10 s | ≈ 1 GB |
| `high` (default) | ≈ 111 k | ≈ 3 min 15 s | ≈ 2.4 GB |

With a newer OpenSCAD and the Manifold back end the same default `high` model rendered in **about 5 seconds**
(OpenSCAD 2025.01.19: `openscad --backend=manifold -o skymaster.stl cessna_skymaster.scad`, or *Preferences ▸
Features ▸ Manifold* in the GUI), and both engines produce the same solid (volumes agree to 3 parts per million).
`part="wing_only"` renders in well under a second and F5 preview is instant at any quality.

## Data and confidence

**Published (used as given):** span 11.58 m (38 ft 0 in), wing area 18.7 m² (201 sq ft) → aspect ratio 7.2,
length 9.07 m (29 ft 9 in), height 2.84 m (9 ft 4 in), airfoils NACA 2412 (root) and NACA 2409 (tip), and the
layout itself – high strut-braced wing, a Continental IO-360 (210 hp) tractor engine in the nose and a pusher
engine behind the cabin, twin tail booms with the horizontal tail between the fins. The O-2A figures used by
the O-2A preset are 38 ft 2 in, 202.5 sq ft, 29 ft 2 in long and 9 ft 5 in high.

**Estimated:** root/kink/tip chords and taper, dihedral, incidence, washout, wing position, the pod section
table, boom spacing and section, tail dimensions, strut position and the landing-gear geometry. The chords
were chosen to reproduce the published wing area and aspect ratio (the report line above shows 18.7 m² and 7.19),
but the planform itself is not taken from a drawing. Please check them against a three-view drawing if you need
survey-grade accuracy – every one is a parameter.

**Caveat on sources.** Several museum and encyclopedia pages could not be opened from the environment this was
written in, so the numbers come from search-result summaries of:
[Wikipedia – Cessna Skymaster](https://en.wikipedia.org/wiki/Cessna_Skymaster) (layout, airfoils),
[GlobalAir – Cessna 337 specifications](https://www.globalair.com/aircraft-for-sale/specifications?specid=437)
(span, length, height, wing area, engines),
and for the military version [Wikipedia – Cessna O-2 Skymaster](https://en.wikipedia.org/wiki/Cessna_O-2_Skymaster),
the [Smithsonian NASM O-2A record](https://airandspace.si.edu/collection-objects/cessna-o-2a-super-skymaster-337m/nasm_A19830089000)
and the [Pima Air & Space Museum O-2A page](https://pimaair.org/museum-aircraft/cessna-o-2a/).
The airfoil pair, in particular, is "as reported" by those summaries; no source I could reach gave the dihedral,
incidence, taper or boom spacing, which is why those are marked as estimates.

## Tests

```bash
tests/run_tests.sh            # everything (a few minutes)
tests/run_tests.sh --full     # + whole-aircraft builds at draft quality
```

* `tests/airfoil_tests.scad` – `assert()` unit tests: NACA thickness/camber against published values, reflex
  camber lines closing, code validation, custom-airfoil round trip, planform records, tip rounding, loft volume
  and closed-manifold topology, body-table sanity.
* `tests/param_sweep.py` – builds STLs through the OpenSCAD CLI with many `-D` overrides (airfoils, span, chords,
  sweep, dihedral, incidence, twist, thickness, blending, scale, custom airfoils, presets, tail and gear options)
  and compares spanwise cross-sections with an independent numpy model (`tests/naca_reference.py`); also checks
  that bad input is rejected with a clear message and that **no propeller exists**: the script defines no
  propeller identifiers, and cross-sections at both engine planes contain nothing beyond the 0.25 m cones (a
  76 in propeller would reach 0.97 m) – with a negative control proving the check detects a blade.
* `tests/validate_stl.py` – watertight, consistent winding, positive volume, no degenerate faces, and optional
  extent / area / thickness checks for any STL.

## Limitations

* The pod, booms, tail, struts and gear are stylised: no windows, panel lines, exhausts, control-surface gaps or
  O-2A under-wing pylons; flaps and ailerons are not modelled separately.
* Fine details become very small at 1:72 (struts ≈ 0.8 mm thick, tail booms ≈ 5 mm wide); use a larger model
  (`scale_denominator = 48`) or `trailing_edge_thickness` for printing, or turn parts off with the `show_*`
  switches.
* OpenSCAD 2021.01 writes ASCII STL with 6 significant digits; the export script prefers binary STL.
