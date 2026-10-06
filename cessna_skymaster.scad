// =============================================================================
//  Cessna 337 / O-2 Skymaster - parametric airframe generator for OpenSCAD
//
//  The push-pull twin with twin tail booms: a strut-braced high wing, a central pod
//  carrying a front and a rear engine, and an H-tail between two fins.
//  THIS VERSION HAS NO PROPELLERS - the two engine positions carry plain nose and
//  tail cones instead.
//
//  The wing is fully parametric (span, chords, sweep, dihedral, incidence, twist,
//  root and tip NACA airfoils ...). Its defaults are the published Skymaster values
//  where they are known and documented estimates otherwise (see README.md). The pod,
//  booms, tail, struts and landing gear are stylised from three-view proportions and
//  are adjustable too.
//
//  Export an STL:
//    GUI:  F6 (Render), then File > Export > Export as STL
//    CLI:  openscad -o skymaster.stl cessna_skymaster.scad
//          openscad -o skymaster.stl -D 'root_airfoil="2415"' -D wing_span_m=13 cessna_skymaster.scad
//          scripts/export_stl.sh skymaster.stl -D tip_twist_deg=-1
//
//  Geometry is built in metres on the full-size aircraft (stations measured aft from
//  the front cone tip, y to starboard, z up with z = 0 on the engine thrust line) and
//  scaled to millimetres at the end. The finished model has the nose on +X and the
//  origin on the wing-root quarter-chord point, on the thrust line.
// =============================================================================

/* [Output] */
// What to generate
part = "aircraft"; // [aircraft:Complete aircraft, wing_only:Wing only, airfoil_preview:Root and tip airfoil plates, none:Nothing (library use)]
// Mesh quality. "high" is slow to render with older OpenSCAD versions but gives the smoothest STL
quality = "high"; // [draft, normal, high]
// Model scale denominator: 72 = 1:72 scale model (about 161 mm span); 1 = full size in millimetres
scale_denominator = 72; // [1:1:1000]

/* [Wing airfoil] */
// NACA airfoil at the wing root (Skymaster: 2412)
root_airfoil = "2412"; // [0006, 0009, 0010, 0012, 0015, 0018, 2409, 2412, 2415, 2418, 4409, 4412, 4415, 6409, 6412, 21012, 22012, 23009, 23012, 23015, 23017, 23018, 23021, 24012, 25012, custom]
// Optional: any NACA 4-digit or 5-digit code typed here replaces the root drop-down (for example 2411 or 23112)
root_airfoil_override = "";
// NACA airfoil at the wing tip (Skymaster: 2409)
tip_airfoil = "2409"; // [0006, 0009, 0010, 0012, 0015, 0018, 2409, 2412, 2415, 2418, 4409, 4412, 4415, 6409, 6412, 21012, 22012, 23009, 23012, 23015, 23017, 23018, 23021, 24012, 25012, custom]
// Optional: any NACA 4-digit or 5-digit code typed here replaces the tip drop-down
tip_airfoil_override = "";
// Thickness multiplier at the root (1 = true NACA thickness)
root_thickness_scale = 1.0; // [0.5:0.05:1.5]
// Thickness multiplier at the tip (1 = true NACA thickness)
tip_thickness_scale = 1.0; // [0.5:0.05:1.5]
// Extra trailing-edge thickness as a fraction of chord (0 = pure NACA formula; about 0.004 helps small prints)
trailing_edge_thickness = 0; // [0:0.0005:0.02]
// Where root-to-tip airfoil blending starts, as a fraction of the semi-span (-1 = at the end of the inboard panel)
airfoil_blend_start = -1; // [-1:0.01:0.95]

/* [Wing planform - metres, full-size aircraft] */
// Total wing span (Cessna 337: 38 ft 0 in = 11.58 m)
wing_span_m = 11.58; // [4:0.05:25]
// Half-span of the constant-chord inboard panel (strut and tail-boom station)
center_halfspan_m = 2.30; // [0.5:0.01:6]
// Chord on the aircraft centreline
root_chord_m = 1.83; // [0.5:0.01:4]
// Chord at the end of the inboard panel (constant chord inboard)
kink_chord_m = 1.83; // [0.5:0.01:4]
// Chord at the wing tip
tip_chord_m = 1.105; // [0.3:0.005:3]
// Leading-edge sweep of the inboard panel in degrees (positive = swept back)
le_sweep_inboard_deg = 0; // [-15:0.1:30]
// Leading-edge sweep of the outer panels in degrees
le_sweep_outboard_deg = 0; // [-15:0.1:30]
// Chord fraction the sweep angles refer to (0 = leading edge, 0.25 = quarter chord)
sweep_ref_chord_fraction = 0; // [0:0.05:1]
// Length over which the wing tip is rounded off (0 = flat tip)
wing_tip_round_m = 0.25; // [0:0.01:1]

/* [Wing angles] */
// Dihedral of the inboard panel in degrees
dihedral_center_deg = 3.0; // [-10:0.01:15]
// Dihedral of the outer panels in degrees
dihedral_outer_deg = 3.0; // [-10:0.01:15]
// Incidence of the root section relative to the thrust line
root_incidence_deg = 1.5; // [-5:0.1:10]
// Twist of the tip relative to the root, linear along the span (negative = washout)
tip_twist_deg = -2.0; // [-8:0.01:5]

/* [Wing position] */
// Fuselage station of the root leading edge, measured aft from the front cone tip
wing_le_station_m = 2.45; // [1:0.01:5]
// Height of the wing root chord line above the thrust line
wing_z_m = 0.95; // [0:0.01:2]

/* [Fuselage pod] */
show_pod = true;
// Nose and tail cones at the engine positions (this version has no propellers)
show_engine_cones = true;
// Width multiplier
pod_width_scale = 1.0; // [0.6:0.01:1.6]
// Height multiplier
pod_height_scale = 1.0; // [0.6:0.01:1.6]

/* [Tail booms and tail] */
// Twin booms, horizontal stabiliser and fins
show_tail = true;
// Distance of each tail boom (and fin) from the centreline
boom_y_m = 2.30; // [1:0.01:4]
// Height of the boom centreline above the thrust line
boom_z_m = 0.82; // [0:0.01:1.5]
// Boom diameter multiplier
boom_diameter_scale = 1.0; // [0.5:0.01:1.8]
// Horizontal stabiliser span (it spans between the fins and overhangs them slightly)
stab_span_m = 5.10; // [2:0.05:9]
stab_root_chord_m = 1.15; // [0.4:0.01:2.5]
stab_tip_chord_m = 0.90; // [0.3:0.01:2]
// Fuselage station of the stabiliser leading edge (moving it also moves the boom ends and fins)
stab_le_station_m = 7.90; // [6.8:0.01:12]
// Height of the stabiliser above the thrust line
stab_z_m = 0.96; // [-0.5:0.01:2]
// Fin height above the boom centreline (with the default landing gear this gives the published 2.84 m overall height)
fin_height_m = 0.70; // [0.3:0.01:2.5]
// Fin depth below the boom centreline
fin_below_m = 0.30; // [0.25:0.01:1]
fin_root_chord_m = 1.45; // [0.5:0.01:3]
fin_tip_chord_m = 0.85; // [0.3:0.01:2]
fin_le_sweep_deg = 25; // [0:0.5:50]
// Tail airfoil at the root (NACA 4-digit)
tail_root_airfoil = "0012";
// Tail airfoil at the tips (NACA 4-digit)
tail_tip_airfoil = "0009";

/* [Wing struts] */
show_wing_struts = true;
// Wing station where each strut meets the wing
strut_wing_y_m = 2.05; // [0.8:0.01:5]
strut_chord_m = 0.20; // [0.05:0.01:0.6]
strut_thickness_m = 0.06; // [0.02:0.005:0.2]

/* [Landing gear] */
// Tricycle gear (switch off for a wheels-up display model)
show_landing_gear = true;
// Height of the engine thrust line above the ground: sets the leg lengths and the overall height
thrust_line_height_m = 1.33; // [0.8:0.01:2]
nose_gear_station_m = 1.05; // [0.6:0.01:2]
main_gear_station_m = 3.35; // [2:0.01:5]
// Main wheel distance from the centreline
main_gear_y_m = 1.45; // [0.8:0.01:3]

/* [Hidden] */
FULL_SIZE_AREA = 18.7;    // Cessna 337 gross wing area in m^2 (201 sq ft), used for the console report only

q_idx      = quality == "draft" ? 0 : quality == "normal" ? 1 : 2;
AF_N       = [14, 30, 64][q_idx];        // airfoil points per surface
SEG_PER_M  = [0.5, 1.0, 2.0][q_idx];     // spanwise sections per metre
TIP_K      = [4, 8, 14][q_idx];          // wing-tip rounding sections
POD_M      = [24, 60, 120][q_idx];       // pod / boom sections
POD_RING   = [24, 48, 72][q_idx];        // points per pod ring
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
//  Lofted lifting surfaces (wing, stabiliser, fins)
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
//  Pod: cabin with the front and rear engine cowlings
// ----------------------------------------------------------------------------
// [station, top z, bottom z, half width]; z = 0 is the engine thrust line
POD_TABLE = [
    [0.40,  0.26, -0.26, 0.26], [0.46,  0.34, -0.34, 0.34], [0.60,  0.40, -0.42, 0.40],
    [1.00,  0.44, -0.50, 0.46], [1.60,  0.48, -0.56, 0.52], [2.00,  0.70, -0.62, 0.62],
    [2.45,  0.97, -0.62, 0.66], [3.20,  0.97, -0.62, 0.66], [4.10,  0.95, -0.62, 0.64],
    [4.80,  0.78, -0.58, 0.55], [5.40,  0.58, -0.50, 0.47], [6.00,  0.46, -0.44, 0.42],
    [6.30,  0.42, -0.40, 0.40], [6.42,  0.34, -0.33, 0.32]];

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

module pod() {
    loft(table_rings(POD_TABLE, POD_M, POD_RING, 2.3, 1, pod_width_scale, pod_height_scale));
}

// Nose and tail cones where the (omitted) propellers would be.
// Profile in [radius, distance from the tip]; the base is buried in the pod.
CONE_PROFILE = [[0, 0], [0.085, 0.04], [0.135, 0.10], [0.185, 0.20], [0.217, 0.32], [0.236, 0.44], [0.242, 0.52]];
REAR_CONE_TIP = 6.90;
module engine_cone() {   // tip at the origin, axis along +z
    rotate_extrude() polygon(concat(CONE_PROFILE, [[0.20, 0.52], [0.20, 0.80], [0, 0.80]]));
}
module engine_cones() {
    rotate([0, 90, 0]) engine_cone();                                   // front, pointing forward (-x stations)
    translate([REAR_CONE_TIP, 0, 0]) rotate([0, -90, 0]) engine_cone(); // rear, pointing aft
}

// ----------------------------------------------------------------------------
//  Tail booms, horizontal stabiliser between two fins
// ----------------------------------------------------------------------------
// [station, top z, bottom z, half width] relative to the boom centreline; the aft stations follow the stabiliser
BOOM_TABLE = [
    [3.20, 0.08, -0.06, 0.07], [3.45, 0.17, -0.17, 0.13], [3.80, 0.24, -0.24, 0.17], [5.00, 0.24, -0.24, 0.175],
    [stab_le_station_m - 1.60, 0.21, -0.21, 0.145], [stab_le_station_m - 0.60, 0.16, -0.16, 0.11],
    [stab_le_station_m + 0.10, 0.125, -0.125, 0.088], [stab_le_station_m + 0.55, 0.10, -0.10, 0.06]];

module booms() {
    for (s = [-1, 1])
        translate([0, s * boom_y_m, boom_z_m])
            loft(table_rings(BOOM_TABLE, POD_M, POD_RING, 2.2, 1, boom_diameter_scale, boom_diameter_scale));
}

AF_TAIL_ROOT = airfoil_loop(tail_root_airfoil, "", [], AF_N, 0);
AF_TAIL_TIP  = airfoil_loop(tail_tip_airfoil, "", [], AF_N, 0);
P_STAB = [stab_span_m / 2, 0, stab_root_chord_m, stab_root_chord_m, stab_tip_chord_m, 0, 0, 0,
          0, 0, 0, 0, 0, stab_le_station_m, stab_z_m, 1, 1];
FIN_LE     = stab_le_station_m - 0.28;
FIN_UP_CAP = min(0.30, 0.45 * fin_height_m);
FIN_DN_CAP = min(0.20, 0.50 * fin_below_m);
P_FIN_UP = [fin_height_m, 0, fin_root_chord_m, fin_root_chord_m, fin_tip_chord_m, 0, fin_le_sweep_deg, 0,
            0, 0, 0, 0, 0, FIN_LE, 0, 1, 1];
P_FIN_DN = [fin_below_m, 0, fin_root_chord_m, fin_root_chord_m, fin_root_chord_m * 0.80, 0, 8, 0,
            0, 0, 0, 0, 0, FIN_LE, 0, 1, 1];

module tail() {
    loft(surf_rings(P_STAB, P_STAB, AF_TAIL_ROOT, AF_TAIL_TIP, SEG_PER_M, TIP_K, 0.20, 0.20));
    for (s = [-1, 1])
        translate([0, s * boom_y_m, boom_z_m])
            rotate([90, 0, 0])
                loft(surf_rings(P_FIN_DN, P_FIN_UP, AF_TAIL_ROOT, AF_TAIL_TIP, SEG_PER_M, TIP_K, FIN_DN_CAP, FIN_UP_CAP));
}

// ----------------------------------------------------------------------------
//  Wing struts: one streamlined strut per side from the pod to the wing
// ----------------------------------------------------------------------------
module strut_end(p) {
    translate(p) scale([strut_chord_m / 2, strut_thickness_m / 2, strut_thickness_m / 2]) sphere(r = 1, $fn = 32);
}
module wing_struts() {
    x = wing_le_station_m + 0.38 * plan_chord(P_WING, strut_wing_y_m);
    for (s = [-1, 1])
        hull() {
            strut_end([x, s * 0.60, -0.38 * pod_height_scale]);
            strut_end([x, s * strut_wing_y_m, wing_z_m + plan_z(P_WING, strut_wing_y_m)]);
        }
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
    ground_z = -thrust_line_height_m;
    // nose wheel under the front cowling
    translate([nose_gear_station_m, 0, 0]) gear_leg(-0.35, ground_z + 0.20, 0.20, 0.13, 0.045, 0.10);
    // main wheels on cantilever legs from the sides of the pod
    for (s = [-1, 1]) {
        axle = [main_gear_station_m, s * main_gear_y_m, ground_z + 0.30];
        hull() {
            translate([main_gear_station_m, s * 0.50, -0.40]) sphere(r = 0.06, $fn = 24);
            translate(axle) sphere(r = 0.05, $fn = 24);
        }
        translate(axle) tire(0.30, 0.16, 0.135);
    }
}

// ----------------------------------------------------------------------------
//  Assembly
// ----------------------------------------------------------------------------
module aircraft_parts() {
    if (show_pod) pod();
    if (show_engine_cones) engine_cones();
    wing();
    if (show_wing_struts) wing_struts();
    if (show_tail) { booms(); tail(); }
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

// ---- parameter validation (before any geometry is built, so mistakes get a clear message) ----
assert(center_halfspan_m > 0 && center_halfspan_m < HALF_SPAN - wing_tip_round_m,
       "center_halfspan_m must lie between 0 and (half the span - wing_tip_round_m)");
assert(root_chord_m > 0 && kink_chord_m > 0 && tip_chord_m > 0, "chords must be positive");
assert(wing_tip_round_m >= 0 && wing_tip_round_m < HALF_SPAN - center_halfspan_m, "wing_tip_round_m is too large");
assert(stab_le_station_m > 6.5, "stab_le_station_m must be aft of the end of the pod (6.5 m)");
assert(fin_below_m > FIN_DN_CAP + 1e-6 && fin_height_m > FIN_UP_CAP + 1e-6, "fin_height_m / fin_below_m too small");

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

echo(str("Skymaster wing: span ", wing_span_m, " m, area ", round(WING_AREA * 10) / 10, " m^2 (Cessna 337: ", FULL_SIZE_AREA,
         "), aspect ratio ", round(wing_span_m * wing_span_m / WING_AREA * 100) / 100,
         ", taper ", round(tip_chord_m / root_chord_m * 100) / 100,
         ", MAC ", round(WING_MAC * 100) / 100, " m"));
echo(str("Airfoils: root NACA ", airfoil_code(root_airfoil, root_airfoil_override), ", tip NACA ",
         airfoil_code(tip_airfoil, tip_airfoil_override), ", model scale 1:", scale_denominator,
         " -> span ", round(wing_span_m * 1000 / scale_denominator * 10) / 10, " mm. This version has no propellers."));
if (abs(WING_AREA - FULL_SIZE_AREA) / FULL_SIZE_AREA > 0.05)
    echo(str("NOTE: wing area differs from the Cessna 337 reference of ", FULL_SIZE_AREA, " m^2 by more than 5 %"));
