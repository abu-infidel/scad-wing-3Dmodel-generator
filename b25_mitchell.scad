// =============================================================================
//  North American B-25 Mitchell - parametric airframe generator for OpenSCAD
//
//  The wing is fully parametric (span, chords, sweep, dihedral, incidence,
//  twist, root and tip NACA airfoils ...). The defaults are the B-25H/J values.
//  The fuselage, tail, engines and landing gear are stylised from the three-view
//  proportions and are adjustable too.
//
//  Export an STL:
//    GUI:  F6 (Render), then File > Export > Export as STL
//    CLI:  openscad -o b25.stl b25_mitchell.scad
//          openscad -o b25.stl -D 'root_airfoil="2412"' -D wing_span_m=18 b25_mitchell.scad
//          scripts/export_stl.sh b25.stl -D tip_twist_deg=-1
//
//  Geometry is built in metres on the full-size aircraft (stations measured aft
//  from the nose, y to starboard, z up) and scaled to millimetres at the end.
//  The finished model has the nose on +X, the origin on the wing-root
//  quarter-chord point and the fuselage reference line on the XY plane.
// =============================================================================

/* [Output] */
// What to generate
part = "aircraft"; // [aircraft:Complete aircraft, wing_only:Wing only, airfoil_preview:Root and tip airfoil plates, none:Nothing (library use)]
// Mesh quality. "high" is slow to render but gives the smoothest STL
quality = "high"; // [draft, normal, high]
// Model scale denominator: 72 = 1:72 scale model (about 286 mm span); 1 = full size in millimetres
scale_denominator = 72; // [1:1:1000]

/* [Wing airfoil] */
// NACA airfoil at the wing root (B-25: 23017)
root_airfoil = "23017"; // [0006, 0009, 0010, 0012, 0015, 0018, 2409, 2412, 2415, 2418, 4409, 4412, 4415, 6409, 6412, 21012, 22012, 23009, 23012, 23015, 23017, 23018, 23021, 24012, 25012, custom]
// Optional: any NACA 4-digit or 5-digit code typed here replaces the root drop-down (for example 2411 or 23112)
root_airfoil_override = "";
// NACA airfoil at the wing tip (B-25: 4409)
tip_airfoil = "4409"; // [0006, 0009, 0010, 0012, 0015, 0018, 2409, 2412, 2415, 2418, 4409, 4412, 4415, 6409, 6412, 21012, 22012, 23009, 23012, 23015, 23017, 23018, 23021, 24012, 25012, custom]
// Optional: any NACA 4-digit or 5-digit code typed here replaces the tip drop-down
tip_airfoil_override = "";
// Thickness multiplier at the root (1 = true NACA thickness)
root_thickness_scale = 1.0; // [0.5:0.05:1.5]
// Thickness multiplier at the tip (1 = true NACA thickness)
tip_thickness_scale = 1.0; // [0.5:0.05:1.5]
// Extra trailing-edge thickness as a fraction of chord (0 = pure NACA formula; about 0.004 helps small prints)
trailing_edge_thickness = 0; // [0:0.0005:0.02]
// Where root-to-tip airfoil blending starts, as a fraction of the semi-span (-1 = at the end of the centre section)
airfoil_blend_start = -1; // [-1:0.01:0.95]

/* [Wing planform - metres, full-size aircraft] */
// Total wing span (B-25J: 67 ft 7 in = 20.60 m)
wing_span_m = 20.60; // [6:0.05:40]
// Half-span of the constant-chord centre section: nacelle station and dihedral break (B-25: 157 in = 3.99 m)
center_halfspan_m = 3.99; // [0.5:0.01:8]
// Chord on the aircraft centreline
root_chord_m = 3.30; // [0.5:0.01:6]
// Chord at the end of the centre section (the B-25 centre section has constant chord)
kink_chord_m = 3.30; // [0.5:0.01:6]
// Chord at the wing tip
tip_chord_m = 1.51; // [0.3:0.01:4]
// Leading-edge sweep of the centre section in degrees (positive = swept back)
le_sweep_inboard_deg = 0; // [-15:0.1:30]
// Leading-edge sweep of the outer panels in degrees
le_sweep_outboard_deg = 3; // [-15:0.1:30]
// Chord fraction the sweep angles refer to (0 = leading edge, 0.25 = quarter chord)
sweep_ref_chord_fraction = 0; // [0:0.05:1]
// Length over which the wing tip is rounded off (0 = flat tip)
wing_tip_round_m = 0.35; // [0:0.01:1.5]

/* [Wing angles] */
// Dihedral of the centre section in degrees (B-25H/J: 4 deg 38 min)
dihedral_center_deg = 4.64; // [-10:0.01:15]
// Dihedral of the outer panels in degrees (B-25H/J: 0 deg 22 min, the "gull wing")
dihedral_outer_deg = 0.36; // [-10:0.01:15]
// Incidence of the root section relative to the fuselage reference line
root_incidence_deg = 2.0; // [-5:0.1:10]
// Twist of the tip relative to the root, linear along the span (negative = washout; B-25: -2 deg 30 min)
tip_twist_deg = -2.49; // [-8:0.01:5]

/* [Wing position] */
// Fuselage station of the root leading edge, measured aft from the nose
wing_le_station_m = 5.60; // [2:0.01:10]
// Height of the wing root chord line above the fuselage reference line
wing_z_m = 0.05; // [-1:0.01:1.5]

/* [Fuselage] */
show_fuselage = true;
// Cockpit canopy and dorsal turret
show_canopy_and_turret = true;
// Nose and tail gun barrels
show_gun_barrels = true;
// Overall fuselage length (B-25J: 52 ft 11 in = 16.13 m)
fuselage_length_m = 16.13; // [8:0.01:30]
// Width multiplier
fuselage_width_scale = 1.0; // [0.6:0.01:1.6]
// Height multiplier
fuselage_height_scale = 1.0; // [0.6:0.01:1.6]

/* [Tail] */
show_tail = true;
// Horizontal stabiliser span
stab_span_m = 6.90; // [2:0.05:12]
stab_root_chord_m = 2.40; // [0.5:0.01:4]
stab_tip_chord_m = 1.25; // [0.3:0.01:3]
// Fuselage station of the stabiliser root leading edge
stab_le_station_m = 12.30; // [8:0.01:16]
// Height of the stabiliser above the fuselage reference line
stab_z_m = 0.55; // [-0.5:0.01:1.5]
// Distance of each fin from the centreline
fin_offset_m = 2.75; // [0.5:0.01:5]
// Fin height above the stabiliser (with the default landing gear this gives the published 4.98 m overall height)
fin_height_m = 2.55; // [0.5:0.01:4]
fin_root_chord_m = 2.20; // [0.5:0.01:4]
fin_tip_chord_m = 1.05; // [0.3:0.01:3]
fin_le_sweep_deg = 24; // [0:0.5:50]
// Tail airfoil at the root (NACA 4-digit)
tail_root_airfoil = "0012";
// Tail airfoil at the tips (NACA 4-digit)
tail_tip_airfoil = "0009";

/* [Engines and propellers] */
show_nacelles = true;
show_propellers = true;
// Nacelle distance from the centreline (-1 = at the end of the wing centre section)
nacelle_y_m = -1; // [-1:0.01:8]
// Fuselage station of the cowling lip
nacelle_front_station_m = 3.35; // [1:0.01:8]
// Nacelle diameter multiplier
nacelle_diameter_scale = 1.0; // [0.6:0.01:1.5]
// Nacelle axis height relative to the wing chord line at the nacelle station
nacelle_z_offset_m = -0.05; // [-1:0.01:1]
// Propeller diameter (B-25J: 12 ft 7 in = 3.8 m)
propeller_diameter_m = 3.80; // [1:0.05:6]
propeller_blades = 3; // [2:1:6]

/* [Landing gear] */
// Tricycle gear (switch off for a wheels-up display model)
show_landing_gear = true;

/* [Hidden] */
FULL_SIZE_AREA = 56.7;    // B-25J gross wing area in m^2 (610 sq ft), used for the console report only

q_idx      = quality == "draft" ? 0 : quality == "normal" ? 1 : 2;
AF_N       = [14, 30, 64][q_idx];        // airfoil points per surface
SEG_PER_M  = [0.5, 1.0, 2.0][q_idx];     // spanwise sections per metre
TIP_K      = [4, 8, 14][q_idx];          // wing-tip rounding sections
FUS_M      = [24, 60, 120][q_idx];       // fuselage sections
FUS_RING   = [24, 48, 72][q_idx];        // points per fuselage ring
$fn        = [32, 64, 120][q_idx];       // revolved bodies and spheres

// Custom airfoils (used when the drop-down says "custom"): Selig format, trailing edge
// -> upper surface -> leading edge -> lower surface -> trailing edge, [x, y] with chord 1
custom_root_airfoil = [];
custom_tip_airfoil  = [];

// ----------------------------------------------------------------------------
//  Small helpers
// ----------------------------------------------------------------------------
function lerp(a, b, t) = a + (b - a) * t;
function clamp(x, lo, hi) = min(max(x, lo), hi);
function rev(v) = [for (i = [len(v) - 1 : -1 : 0]) v[i]];
function ones(n) = [for (i = [0 : n - 1]) 1];
function sorted(v) = len(v) < 2 ? v :
    let(p = v[0])
    concat(sorted([for (x = v) if (x < p) x]), [for (x = v) if (x == p) x], sorted([for (x = v) if (x > p) x]));
function dedupe(v, tol = 1e-6) = [for (i = [0 : len(v) - 1]) if (i == 0 || v[i] - v[i - 1] > tol) v[i]];

// 1-D cubic Hermite interpolation through knots (X ascending, Y values)
function _slope(X, Y, i) = let(n = len(X))
    i == 0 ? (Y[1] - Y[0]) / (X[1] - X[0]) :
    i == n - 1 ? (Y[n - 1] - Y[n - 2]) / (X[n - 1] - X[n - 2]) :
    (Y[i + 1] - Y[i - 1]) / (X[i + 1] - X[i - 1]);
function _seg(X, x) = let(n = len(X))
    x <= X[0] ? 0 : x >= X[n - 1] ? n - 2 : [for (i = [0 : n - 2]) if (X[i] <= x && x < X[i + 1]) i][0];
function hermite(X, Y, x) =
    let(i = _seg(X, x), h = X[i + 1] - X[i], t = clamp((x - X[i]) / h, 0, 1), t2 = t * t, t3 = t2 * t,
        m0 = _slope(X, Y, i) * h, m1 = _slope(X, Y, i + 1) * h)
    (2 * t3 - 3 * t2 + 1) * Y[i] + (t3 - 2 * t2 + t) * m0 + (-2 * t3 + 3 * t2) * Y[i + 1] + (t3 - t2) * m1;
function column(T, c) = [for (r = T) r[c]];

// ----------------------------------------------------------------------------
//  NACA airfoils (4-digit, 5-digit standard and reflex camber lines) + custom
//  An airfoil "loop" is a list of 2n+1 [x, y] points with chord 1:
//  upper trailing edge -> leading edge -> lower trailing edge.
// ----------------------------------------------------------------------------
function _d(code, i) = ord(code[i]) - 48;
function _all_digits(code) =
    len([for (i = [0 : len(code) - 1]) if (ord(code[i]) >= 48 && ord(code[i]) <= 57) 1]) == len(code);
function _int(code, from, cnt) = cnt <= 0 ? 0 : _d(code, from) * pow(10, cnt - 1) + _int(code, from + 1, cnt - 1);
function naca_valid(code) = is_string(code) && (len(code) == 4 || len(code) == 5) && _all_digits(code)
    && (len(code) == 4 || (_d(code, 1) >= 1 && _d(code, 1) <= 5 && _d(code, 2) <= 1
                           && !(_d(code, 2) == 1 && _d(code, 1) < 2)));

function cos_spacing(n) = [for (i = [0 : n]) (1 - cos(180 * i / n)) / 2];

// camber line -> [yc, dyc/dx]
function _camber4(x, m, p) =
    (p <= 0 || m <= 0) ? [0, 0] :
    x < p ? [m / (p * p) * (2 * p * x - x * x), 2 * m / (p * p) * (p - x)]
          : [m / pow(1 - p, 2) * ((1 - 2 * p) + 2 * p * x - x * x), 2 * m / pow(1 - p, 2) * (p - x)];
// [m, k1, k2/k1] for the standard (210..250) and reflex (221..251) 5-digit camber lines
function _c5par(P, Q) = Q == 0
    ? [[0.0580, 361.4, 0], [0.1260, 51.64, 0], [0.2025, 15.957, 0], [0.2900, 6.643, 0], [0.3910, 3.230, 0]][P - 1]
    : [[0.1300, 51.99, 0.000764], [0.2170, 15.793, 0.00677], [0.3180, 6.520, 0.0303], [0.4410, 3.191, 0.1355]][P - 2];
function _camber5(x, code) =
    let(L = _d(code, 0), P = _d(code, 1), Q = _d(code, 2), par = _c5par(P, Q),
        m = par[0], k1 = par[1] * L / 2, r = par[2])
    Q == 0
    ? (x < m ? [k1 / 6 * (pow(x, 3) - 3 * m * x * x + m * m * (3 - m) * x), k1 / 6 * (3 * x * x - 6 * m * x + m * m * (3 - m))]
             : [k1 * pow(m, 3) / 6 * (1 - x), -k1 * pow(m, 3) / 6])
    : (x < m ? [k1 / 6 * (pow(x - m, 3) - r * pow(1 - m, 3) * x - pow(m, 3) * x + pow(m, 3)),
                k1 / 6 * (3 * pow(x - m, 2) - r * pow(1 - m, 3) - pow(m, 3))]
             : [k1 / 6 * (r * pow(x - m, 3) - r * pow(1 - m, 3) * x - pow(m, 3) * x + pow(m, 3)),
                k1 / 6 * (3 * r * pow(x - m, 2) - r * pow(1 - m, 3) - pow(m, 3))]);
function _camber(code, x) = len(code) == 4 ? _camber4(x, _d(code, 0) / 100, _d(code, 1) / 10) : _camber5(x, code);
function naca_thickness_ratio(code) = len(code) == 4 ? _int(code, 2, 2) / 100 : _int(code, 3, 2) / 100;
// NACA half-thickness distribution (open trailing edge coefficient) plus optional extra TE thickness
function _yt(x, t, te) =
    5 * t * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x * x + 0.2843 * pow(x, 3) - 0.1015 * pow(x, 4)) + 0.5 * te * x;

function naca_loop(code, n, te = 0) =
    let(t = naca_thickness_ratio(code), xs = cos_spacing(n),
        up = [for (x = xs) let(c = _camber(code, x), yt = _yt(x, t, te), th = atan(c[1]))
                [x - yt * sin(th), c[0] + yt * cos(th)]],
        lo = [for (x = xs) let(c = _camber(code, x), yt = _yt(x, t, te), th = atan(c[1]))
                [x + yt * sin(th), c[0] - yt * cos(th)]])
    concat(rev(up), [for (i = [1 : n]) lo[i]]);

function _interp_surface(S, x) =
    let(idx = [for (i = [0 : len(S) - 2]) if (S[i][0] <= x && x <= S[i + 1][0]) i])
    len(idx) == 0 ? S[len(S) - 1][1] :
    let(i = idx[0], a = S[i], b = S[i + 1], d = b[0] - a[0]) d < 1e-12 ? a[1] : lerp(a[1], b[1], (x - a[0]) / d);
// Resample a Selig-format point list onto the same cosine grid used for the NACA airfoils
function custom_loop(P, n) =
    assert(len(P) >= 10, "custom airfoil: provide a Selig-format list of [x, y] points (at least 10)")
    let(xs_all = [for (p = P) p[0]], xmin = min(xs_all), xmax = max(xs_all), c = xmax - xmin,
        ile = [for (i = [0 : len(P) - 1]) if (P[i][0] == xmin) i][0],
        yle = P[ile][1],
        Q = [for (p = P) [(p[0] - xmin) / c, (p[1] - yle) / c]],
        upper = rev([for (i = [0 : ile]) Q[i]]),
        lower = [for (i = [ile : len(Q) - 1]) Q[i]],
        xs = cos_spacing(n),
        U = [for (x = xs) [x, _interp_surface(upper, x)]],
        L = [for (x = xs) [x, _interp_surface(lower, x)]])
    concat(rev(U), [for (i = [1 : n]) L[i]]);

function airfoil_loop(selection, override, custom, n, te) =
    let(code = override != "" ? override : selection)
    code == "custom" ? custom_loop(custom, n) :
    assert(naca_valid(code), str("Unsupported airfoil code \"", code,
        "\": use a NACA 4-digit code (e.g. 2412) or a 5-digit code with a 210-250 camber line (e.g. 23017)"))
    naca_loop(code, n, te);

function airfoil_code(selection, override) = override != "" ? override : selection;

// ----------------------------------------------------------------------------
//  Lofted lifting surfaces (wing, stabiliser, fins, propeller blades)
//
//  A planform vector P describes one half of a surface, measured from the root:
//   [0] length            [1] break station (centre section / kink)
//   [2] chord at root     [3] chord at break       [4] chord at end
//   [5] LE sweep inboard  [6] LE sweep outboard (deg, reference line below)
//   [7] sweep reference as chord fraction
//   [8] dihedral inboard  [9] dihedral outboard (deg)
//   [10] root incidence   [11] tip twist relative to root (deg)
//   [12] station where airfoil blending starts
//   [13] leading-edge x at the root  [14] z of the root chord line
//   [15] thickness scale at root  [16] thickness scale at end
//  A "record" is [y, chord, leading-edge x, z, incidence, blend, thickness scale].
// ----------------------------------------------------------------------------
function plan_chord(P, a) =
    a <= P[1] ? (P[1] > 0 ? lerp(P[2], P[3], a / P[1]) : P[2])
              : lerp(P[3], P[4], (a - P[1]) / (P[0] - P[1]));
function plan_refx(P, a) = a <= P[1] ? a * tan(P[5]) : P[1] * tan(P[5]) + (a - P[1]) * tan(P[6]);
function plan_z(P, a) = a <= P[1] ? a * tan(P[8]) : P[1] * tan(P[8]) + (a - P[1]) * tan(P[9]);
function plan_rec(P, a) =
    let(c = plan_chord(P, a), f = P[7],
        bl = a <= P[12] ? 0 : clamp((a - P[12]) / max(P[0] - P[12], 1e-9), 0, 1))
    [a, c, P[13] + f * plan_chord(P, 0) + plan_refx(P, a) - f * c, P[14] + plan_z(P, a),
     P[10] + P[11] * a / P[0], bl, lerp(P[15], P[16], a / P[0])];
// shrink a record about its quarter-chord point (used for the rounded tip)
function rec_scale(r, s) =
    let(pivot = r[2] + 0.25 * r[1], c = r[1] * s) [r[0], c, pivot - 0.25 * c, r[3], r[4], r[5], r[6]];

function surf_breaks(P, cap) =
    let(ycap = P[0] - cap)
    dedupe(sorted([for (y = [0, P[1], P[12], ycap]) if (y >= 0 && y <= ycap) y]));

// records from the root (y = 0) to the end of the surface, ascending
function surf_halfrecs(P, density, cap_k, cap) =
    assert(P[0] - cap > 1e-6 && cap >= 0, "surface too short for its tip rounding")
    let(B = surf_breaks(P, cap), yl = B[len(B) - 1],
        body = [for (i = [0 : len(B) - 2])
                    let(y0 = B[i], y1 = B[i + 1], n = max(2, ceil((y1 - y0) * density)))
                    for (k = [0 : n - 1]) plan_rec(P, lerp(y0, y1, k / n))],
        rounded = [for (k = [0 : cap_k - 1])
                    let(phi = 90 * k / cap_k) rec_scale(plan_rec(P, yl + cap * sin(phi)), cos(phi))])
    cap > 1e-6 ? concat(body, rounded) : concat(body, [plan_rec(P, yl)]);

function ring_from_rec(r, A, B) =
    let(ca = cos(r[4]), sa = sin(r[4]), c = r[1], px = r[2] + 0.25 * c)
    [for (i = [0 : len(A) - 1])
        let(u = lerp(A[i][0], B[i][0], r[5]), v = lerp(A[i][1], B[i][1], r[5]) * r[6],
            xl = (u - 0.25) * c, zl = v * c)
        [px + xl * ca + zl * sa, r[0], r[3] + zl * ca - xl * sa]];

// rings from the "negative" end, through the root, to the "positive" end
function surf_rings(Pneg, Ppos, A, B, density, cap_k, tipround_neg, tipround_pos) =
    let(pos = surf_halfrecs(Ppos, density, cap_k, tipround_pos),
        neg = surf_halfrecs(Pneg, density, cap_k, tipround_neg),
        negrecs = [for (i = [len(neg) - 1 : -1 : 1]) let(r = neg[i]) [-r[0], r[1], r[2], r[3], r[4], r[5], r[6]]])
    [for (r = concat(negrecs, pos)) ring_from_rec(r, A, B)];

// one-sided surface (root at y = 0): rings from the root outwards
function surf_rings_half(P, A, B, density, cap_k, cap) =
    [for (r = surf_halfrecs(P, density, cap_k, cap)) ring_from_rec(r, A, B)];

// ----------------------------------------------------------------------------
//  Loft: one closed polyhedron from a stack of equal-length rings.
//  The first and last ring are closed with triangle fans; winding is corrected
//  automatically from the signed volume, so ring order does not matter.
// ----------------------------------------------------------------------------
function ring_centroid(r) = ones(len(r)) * r / len(r);
function loft_points(rings) = concat([for (r = rings) each r], [ring_centroid(rings[0]), ring_centroid(rings[len(rings) - 1])]);
function loft_faces(S, N) =
    let(c0 = S * N, c1 = S * N + 1, o = (S - 1) * N)
    concat(
        [for (s = [0 : S - 2], j = [0 : N - 1])
            let(j2 = (j + 1) % N, a = s * N + j, b = s * N + j2, c = (s + 1) * N + j2, d = (s + 1) * N + j)
            each [[a, b, c], [a, c, d]]],
        [for (j = [0 : N - 1]) [c0, (j + 1) % N, j]],
        [for (j = [0 : N - 1]) [c1, o + j, o + (j + 1) % N]]);
function signed_volume(P, F) = [for (f = F) P[f[0]] * cross(P[f[1]], P[f[2]])] * ones(len(F)) / 6;

module loft(rings) {
    S = len(rings);
    N = len(rings[0]);
    pts = loft_points(rings);
    faces = loft_faces(S, N);
    // OpenSCAD wants faces clockwise seen from outside, i.e. negative signed volume
    polyhedron(points = pts, faces = signed_volume(pts, faces) > 0 ? [for (f = faces) [f[2], f[1], f[0]]] : faces,
               convexity = 10);
}

// ----------------------------------------------------------------------------
//  Wing definition
// ----------------------------------------------------------------------------
HALF_SPAN  = wing_span_m / 2;
BLEND_Y    = airfoil_blend_start < 0 ? center_halfspan_m : airfoil_blend_start * HALF_SPAN;
P_WING     = [HALF_SPAN, center_halfspan_m, root_chord_m, kink_chord_m, tip_chord_m,
              le_sweep_inboard_deg, le_sweep_outboard_deg, sweep_ref_chord_fraction,
              dihedral_center_deg, dihedral_outer_deg, root_incidence_deg, tip_twist_deg,
              BLEND_Y, wing_le_station_m, wing_z_m, root_thickness_scale, tip_thickness_scale];
AF_ROOT    = airfoil_loop(root_airfoil, root_airfoil_override, custom_root_airfoil, AF_N, trailing_edge_thickness);
AF_TIP     = airfoil_loop(tip_airfoil, tip_airfoil_override, custom_tip_airfoil, AF_N, trailing_edge_thickness);

module wing() {
    loft(surf_rings(P_WING, P_WING, AF_ROOT, AF_TIP, SEG_PER_M, TIP_K, wing_tip_round_m, wing_tip_round_m));
}

// ----------------------------------------------------------------------------
//  Fuselage, canopy, turret
// ----------------------------------------------------------------------------
// [station, top z, bottom z, half width] for the B-25J, measured aft from the nose
FUS_TABLE = [
    [0.20,  0.02, -0.24, 0.02], [0.25,  0.09, -0.31, 0.17], [0.35,  0.19, -0.42, 0.29],
    [0.55,  0.33, -0.56, 0.42], [0.95,  0.55, -0.72, 0.58], [1.60,  0.78, -0.84, 0.72],
    [2.40,  0.98, -0.90, 0.82], [3.40,  1.14, -0.92, 0.87], [4.60,  1.20, -0.93, 0.89],
    [6.00,  1.17, -0.93, 0.89], [7.50,  1.12, -0.91, 0.87], [9.00,  1.04, -0.85, 0.82],
    [10.50, 0.93, -0.68, 0.72], [12.00, 0.82, -0.42, 0.58], [13.50, 0.70, -0.12, 0.44],
    [14.80, 0.60,  0.12, 0.30], [15.90, 0.50,  0.28, 0.13]];
CANOPY_TABLE = [
    [2.55, 1.00, 0.80, 0.12], [2.85, 1.20, 0.75, 0.40], [3.30, 1.40, 0.75, 0.55], [3.90, 1.50, 0.75, 0.60],
    [4.80, 1.53, 0.75, 0.62], [5.60, 1.45, 0.75, 0.58], [6.20, 1.32, 0.75, 0.48], [6.60, 1.20, 0.75, 0.30]];

function super_ring(x, zt, zb, hw, N, e) =
    let(zc = (zt + zb) / 2, hh = max((zt - zb) / 2, 0.01), w = max(hw, 0.01))
    [for (k = [0 : N - 1]) let(a = 360 * k / N, c = cos(a), s = sin(a))
        [x, w * sign(c) * pow(abs(c), 2 / e), zc + hh * sign(s) * pow(abs(s), 2 / e)]];

// rings for a body defined by a station table, sampled with cosine spacing in x
function table_rings(T, m, N, e, xscale, wscale, hscale) =
    let(X = column(T, 0), ZT = column(T, 1), ZB = column(T, 2), HW = column(T, 3),
        x0 = X[0], x1 = X[len(X) - 1])
    [for (i = [0 : m]) let(x = lerp(x0, x1, (1 - cos(180 * i / m)) / 2))
        super_ring(x * xscale, hermite(X, ZT, x) * hscale, hermite(X, ZB, x) * hscale, hermite(X, HW, x) * wscale, N, e)];

FUS_XSCALE = fuselage_length_m / 16.13;

module fuselage() {
    loft(table_rings(FUS_TABLE, FUS_M, FUS_RING, 2.4, FUS_XSCALE, fuselage_width_scale, fuselage_height_scale));
}

module canopy_and_turret() {
    loft(table_rings(CANOPY_TABLE, max(12, FUS_M / 3), FUS_RING, 2.3, FUS_XSCALE, fuselage_width_scale, fuselage_height_scale));
    // dorsal turret dome
    translate([7.30 * FUS_XSCALE, 0, 1.08 * fuselage_height_scale])
        scale([1.25, 1, 0.95] * 0.40) sphere(r = 1);
}

module gun_barrels() {
    // nose gun (centre of the glazed nose) and twin tail guns
    translate([0, 0, -0.10 * fuselage_height_scale]) rotate([0, 90, 0]) cylinder(r = 0.035, h = 0.6 * FUS_XSCALE);
    for (s = [-1, 1])
        translate([15.30 * FUS_XSCALE, s * 0.07, 0.39 * fuselage_height_scale]) rotate([0, 90, 0])
            cylinder(r = 0.03, h = fuselage_length_m - 15.30 * FUS_XSCALE);
}

// ----------------------------------------------------------------------------
//  Tail: horizontal stabiliser with two end fins (H-tail)
// ----------------------------------------------------------------------------
AF_TAIL_ROOT = airfoil_loop(tail_root_airfoil, "", [], AF_N, 0);
AF_TAIL_TIP  = airfoil_loop(tail_tip_airfoil, "", [], AF_N, 0);
P_STAB = [stab_span_m / 2, 0, stab_root_chord_m, stab_root_chord_m, stab_tip_chord_m, 0, 5, 0.25,
          0, 0, 0, 0, 0, stab_le_station_m, stab_z_m, 1, 1];
FIN_LE = plan_rec(P_STAB, fin_offset_m)[2] - 0.20;
P_FIN_UP = [fin_height_m, 0, fin_root_chord_m, fin_root_chord_m, fin_tip_chord_m, 0, fin_le_sweep_deg, 0,
            0, 0, 0, 0, 0, FIN_LE, 0, 1, 1];
P_FIN_DN = [0.85, 0, fin_root_chord_m, fin_root_chord_m, fin_root_chord_m * 0.70, 0, 8, 0,
            0, 0, 0, 0, 0, FIN_LE, 0, 1, 1];

module tail() {
    loft(surf_rings(P_STAB, P_STAB, AF_TAIL_ROOT, AF_TAIL_TIP, SEG_PER_M, TIP_K, 0.25, 0.25));
    for (s = [-1, 1])
        translate([0, s * fin_offset_m, stab_z_m])
            rotate([90, 0, 0])
                loft(surf_rings(P_FIN_DN, P_FIN_UP, AF_TAIL_ROOT, AF_TAIL_TIP, SEG_PER_M, TIP_K, 0.45, 0.45));
}

// ----------------------------------------------------------------------------
//  Engine nacelles, spinners, propellers
// ----------------------------------------------------------------------------
NAC_Y  = nacelle_y_m < 0 ? center_halfspan_m : nacelle_y_m;
NAC_Z  = wing_z_m + plan_z(P_WING, NAC_Y) + nacelle_z_offset_m;
// outer cowling/nacelle profile: [distance aft of the cowl lip, radius]
NAC_PROFILE = [[0.00, 0.78], [0.12, 0.82], [0.40, 0.845], [0.90, 0.85], [1.50, 0.83], [2.10, 0.77],
               [2.80, 0.68], [3.60, 0.56], [4.50, 0.42], [5.30, 0.27], [5.90, 0.14], [6.25, 0.05], [6.35, 0.0]];
SPINNER_PROFILE = [[-0.95, 0.0], [-0.90, 0.119], [-0.85, 0.166], [-0.75, 0.228], [-0.60, 0.289], [-0.45, 0.329],
                   [-0.25, 0.363], [-0.10, 0.3757], [0.05, 0.38]];

module nacelle() {
    H = column(NAC_PROFILE, 0);  R = column(NAC_PROFILE, 1);
    m = [24, 48, 90][q_idx];
    outer = [for (i = [0 : m]) let(h = lerp(H[0], H[len(H) - 1], (1 - cos(180 * i / m)) / 2))
                [hermite(H, R, h) * nacelle_diameter_scale, h]];
    // outer skin from lip to tail, then back up the axis and round the inside of the cowl lip
    profile = concat([for (p = outer) [max(p[0], 0.0), p[1]]],
                     [[0, 0.30], [0.60 * nacelle_diameter_scale, 0.30], [0.66 * nacelle_diameter_scale, 0.0]]);
    rotate([0, 90, 0]) rotate_extrude() polygon(profile);
}

module spinner() {
    pts = concat([for (p = SPINNER_PROFILE) [p[1], p[0]]], [[0.25, 0.05], [0.25, 0.45], [0, 0.45]]);
    rotate([0, 90, 0]) rotate_extrude() polygon(pts);
}

PROP_R     = propeller_diameter_m / 2;
BLADE_ROOT = 0.30;
AF_BLADE   = airfoil_loop("0012", "", [], AF_N, 0);
AF_BLADE2  = airfoil_loop("0009", "", [], AF_N, 0);
P_BLADE    = [PROP_R - BLADE_ROOT, 0.45 * (PROP_R - BLADE_ROOT), 0.22, 0.34, 0.20, 0, 0, 0.25,
              0, 0, 38, -20, 0, -0.25 * 0.22, 0, 1.6, 1.3];

module blade() {
    // surface frame (chord x, span y, thickness z) -> aircraft frame (blade pointing +z,
    // leading edge towards +y, face of the blade towards the tail)
    translate([-0.30, 0, 0])
        multmatrix([[0, 0, -1, 0], [-1, 0, 0, 0], [0, 1, 0, BLADE_ROOT], [0, 0, 0, 1]])
            loft(surf_rings_half(P_BLADE, AF_BLADE, AF_BLADE2, SEG_PER_M, TIP_K, 0.12));
}

module nacelle_group() {
    nacelle();
    spinner();
    if (show_propellers)
        for (k = [0 : propeller_blades - 1]) rotate([360 * k / propeller_blades, 0, 0]) blade();
}

// ----------------------------------------------------------------------------
//  Landing gear (tricycle)
// ----------------------------------------------------------------------------
module tire(R, w, rim) {          // wheel with its axis along Y, centred on the origin
    rotate([90, 0, 0]) rotate_extrude()
        union() {
            hull() {
                translate([R - w * 0.42, 0]) circle(r = w * 0.42, $fn = 32);
                translate([rim, -w * 0.34]) square([0.01, w * 0.68]);
            }
            translate([0, -w * 0.30]) square([rim + 0.02, w * 0.6]);
        }
}

module gear_leg(top_z, axle_z, R, w, strut_r, fork_y) {   // origin: strut top, axle below
    translate([0, 0, axle_z]) tire(R, w, R * 0.45);
    translate([0, 0, axle_z]) rotate([90, 0, 0]) cylinder(r = strut_r * 0.7, h = 2 * fork_y, center = true);
    for (s = [-1, 1])
        hull() {
            translate([0, s * fork_y, axle_z]) sphere(r = strut_r * 0.7, $fn = 16);
            translate([0, s * fork_y * 0.2, axle_z + (top_z - axle_z) * 0.45]) sphere(r = strut_r * 0.9, $fn = 16);
        }
    hull() {
        translate([0, 0, axle_z + (top_z - axle_z) * 0.45]) sphere(r = strut_r, $fn = 24);
        translate([0, 0, top_z]) sphere(r = strut_r * 1.15, $fn = 24);
    }
}

module landing_gear() {
    ground_z = -1.85;
    // nose wheel
    translate([2.45 * FUS_XSCALE, 0, 0]) gear_leg(-0.60 * fuselage_height_scale, ground_z + 0.35, 0.35, 0.22, 0.07, 0.17);
    // main wheels under the nacelles
    for (s = [-1, 1])
        translate([6.40, s * NAC_Y, 0]) gear_leg(NAC_Z - 0.35, ground_z + 0.50, 0.50, 0.36, 0.10, 0.27);
}

// ----------------------------------------------------------------------------
//  Assembly
// ----------------------------------------------------------------------------
module aircraft_parts() {
    if (show_fuselage) fuselage();
    if (show_canopy_and_turret) canopy_and_turret();
    if (show_gun_barrels && show_fuselage) gun_barrels();
    wing();
    if (show_tail) tail();
    if (show_nacelles)
        for (s = [-1, 1]) translate([nacelle_front_station_m, s * NAC_Y, NAC_Z]) nacelle_group();
    if (show_landing_gear) landing_gear();
}

// stations are aft-positive: mirror so the nose points to +X, centre on the wing-root quarter chord, scale to mm
module output_frame() {
    scale(1000 / scale_denominator)
        mirror([1, 0, 0])
            translate([-(wing_le_station_m + 0.25 * root_chord_m), 0, 0])
                children();
}

module airfoil_preview() {
    s = 100;
    for (cfg = [[AF_ROOT, 0, root_thickness_scale], [AF_TIP, 1, tip_thickness_scale]])
        translate([cfg[1] * 120, 0, 0])
            linear_extrude(height = 2) polygon([for (p = cfg[0]) [p[0] * s, p[1] * s * cfg[2]]]);
}

if (part == "aircraft") output_frame() aircraft_parts();
else if (part == "wing_only") output_frame() wing();
else if (part == "airfoil_preview") airfoil_preview();

// ----------------------------------------------------------------------------
//  Console report (shown in the OpenSCAD console / stderr)
// ----------------------------------------------------------------------------
function trap_area(c0, c1, len_) = (c0 + c1) / 2 * len_;
function trap_c2(c0, c1, len_) = (c0 * c0 + c0 * c1 + c1 * c1) / 3 * len_;
WING_AREA = 2 * (trap_area(root_chord_m, kink_chord_m, center_halfspan_m)
                 + trap_area(kink_chord_m, tip_chord_m, HALF_SPAN - center_halfspan_m));
WING_MAC  = 2 * (trap_c2(root_chord_m, kink_chord_m, center_halfspan_m)
                 + trap_c2(kink_chord_m, tip_chord_m, HALF_SPAN - center_halfspan_m)) / WING_AREA;

assert(center_halfspan_m > 0 && center_halfspan_m < HALF_SPAN - wing_tip_round_m,
       "center_halfspan_m must lie between 0 and (half the span - wing_tip_round_m)");
assert(root_chord_m > 0 && kink_chord_m > 0 && tip_chord_m > 0, "chords must be positive");
assert(wing_tip_round_m >= 0 && wing_tip_round_m < HALF_SPAN - center_halfspan_m, "wing_tip_round_m is too large");

echo(str("B-25 wing: span ", wing_span_m, " m, area ", round(WING_AREA * 10) / 10, " m^2 (B-25J: ", FULL_SIZE_AREA,
         "), aspect ratio ", round(wing_span_m * wing_span_m / WING_AREA * 100) / 100,
         ", taper ", round(tip_chord_m / root_chord_m * 100) / 100,
         ", MAC ", round(WING_MAC * 100) / 100, " m"));
echo(str("Airfoils: root NACA ", airfoil_code(root_airfoil, root_airfoil_override), ", tip NACA ",
         airfoil_code(tip_airfoil, tip_airfoil_override), ", model scale 1:", scale_denominator,
         " -> span ", round(wing_span_m * 1000 / scale_denominator * 10) / 10, " mm"));
if (abs(WING_AREA - FULL_SIZE_AREA) / FULL_SIZE_AREA > 0.05)
    echo(str("NOTE: wing area differs from the B-25J reference of ", FULL_SIZE_AREA, " m^2 by more than 5 %"));
