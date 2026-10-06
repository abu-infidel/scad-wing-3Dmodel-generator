// Unit tests for the airfoil / planform / loft library inside cessna_skymaster.scad.
//
//   openscad -D 'part="none"' -o /tmp/airfoil_tests.stl tests/airfoil_tests.scad
//
// Every check is an assert(): a failure aborts with an error and a non-zero exit status.
include <../cessna_skymaster.scad>

function approx(a, b, tol = 1e-4) = abs(a - b) <= tol;
function poly_area(p) = 0.5 * [for (i = [0 : len(p) - 1]) let(j = (i + 1) % len(p)) p[i][0] * p[j][1] - p[j][0] * p[i][1]] * ones(len(p));
function max_of(v) = max(v);
function max_thickness(code) = max([for (x = cos_spacing(400)) 2 * _yt(x, naca_thickness_ratio(code), 0)]);
function x_of_max_thickness(code) =
    let(xs = cos_spacing(400), th = [for (x = xs) _yt(x, naca_thickness_ratio(code), 0)], m = max(th))
    xs[[for (i = [0 : len(xs) - 1]) if (th[i] == m) i][0]];

// --- NACA thickness distribution: published NACA 0012 value at x/c = 0.5 is 0.05294
assert(approx(_yt(0.5, 0.12, 0), 0.05294, 6e-5), "NACA 0012 half thickness at 50 % chord");
assert(approx(_yt(0, 0.12, 0), 0, 1e-12), "thickness is zero at the leading edge");

// --- maximum thickness equals the last two digits, at about 30 % chord
for (code = ["0006", "0012", "0015", "2412", "4409", "23012", "23017", "24012"]) {
    t = naca_thickness_ratio(code);
    assert(approx(max_thickness(code), t, 0.0015 * t / 0.12 + 1e-4), str(code, ": max thickness ", max_thickness(code), " should be ", t));
    assert(approx(x_of_max_thickness(code), 0.30, 0.02), str(code, ": max thickness should sit near 30 % chord"));
}

// --- 4-digit camber lines
assert(approx(_camber("4409", 0.4)[0], 0.04, 1e-12), "NACA 4409: 4 % camber at 40 % chord");
assert(approx(_camber("4409", 0.4)[1], 0, 1e-12), "NACA 4409: zero slope at the point of maximum camber");
assert(approx(_camber("4409", 0)[0], 0, 1e-12) && approx(_camber("4409", 1)[0], 0, 1e-12), "camber line starts and ends on the chord");
assert(approx(_camber("2412", 0.4 - 1e-9)[0], _camber("2412", 0.4 + 1e-9)[0], 1e-6), "4-digit camber is continuous at x = p");
assert(approx(_camber("2412", 0.4 - 1e-9)[1], _camber("2412", 0.4 + 1e-9)[1], 1e-6), "4-digit slope is continuous at x = p");
assert(_camber("0012", 0.3)[0] == 0 && _camber("0012", 0.3)[1] == 0, "symmetric airfoil has no camber");

// --- 5-digit camber lines (23017 is a common 5-digit section; the Skymaster itself uses 4-digit sections)
m230 = 0.2025;
k230 = 15.957;
assert(approx(_camber("23017", m230)[0], k230 * pow(m230, 3) / 6 * (1 - m230), 1e-9), "NACA 230 camber at x = m");
assert(approx(_camber("23017", m230)[0], 0.017613, 2e-5), "NACA 23017 maximum camber is about 1.76 % chord");
assert(approx(_camber("23017", 0)[0], 0, 1e-12) && approx(_camber("23017", 1)[0], 0, 1e-12), "23017 camber line closes");
assert(approx(_camber("23017", m230 - 1e-9)[0], _camber("23017", m230 + 1e-9)[0], 1e-6), "230 camber continuous at x = m");
assert(approx(_camber("23017", m230 - 1e-9)[1], _camber("23017", m230 + 1e-9)[1], 1e-5), "230 slope continuous at x = m");
assert(approx(_camber("23017", 0.7)[1], -k230 * pow(m230, 3) / 6, 1e-9), "230 aft slope is constant");
// design lift scales the camber (L = 2 -> 0.3 CL; L = 4 would double it)
assert(approx(_camber("43017", m230)[0], 2 * _camber("23017", m230)[0], 1e-9), "5-digit camber scales with the first digit");
// reflex camber lines close and stay smooth
for (code = ["22112", "23112", "24112", "25112"]) {
    m = _c5par(_d(code, 1), 1)[0];
    assert(approx(_camber(code, 0)[0], 0, 1e-9) && approx(_camber(code, 1)[0], 0, 1e-9), str(code, ": reflex camber line must close"));
    assert(approx(_camber(code, m - 1e-9)[0], _camber(code, m + 1e-9)[0], 1e-6), str(code, ": continuous at x = m"));
    assert(approx(_camber(code, m - 1e-9)[1], _camber(code, m + 1e-9)[1], 1e-5), str(code, ": slope continuous at x = m"));
}

// --- code validation
for (code = ["0012", "2412", "4409", "23017", "23012", "21012", "25012", "23112", "0006"])
    assert(naca_valid(code), str(code, " should be accepted"));
for (code = ["", "12", "abcd", "26012", "20012", "12345", "21112", "123456", "00x2", "23O17"])
    assert(!naca_valid(code), str("\"", code, "\" should be rejected"));

// --- airfoil loops
for (code = ["0009", "0012", "2412", "4409", "23017", "23012", "23112"]) {
    n = 40;
    L = naca_loop(code, n, 0);
    t = naca_thickness_ratio(code);
    assert(len(L) == 2 * n + 1, str(code, ": loop length"));
    assert(abs(L[n][0]) < 1e-9, str(code, ": leading-edge point must be at index n"));
    assert(L[0][0] > 0.99 && L[2 * n][0] > 0.99, str(code, ": loop starts and ends at the trailing edge"));
    assert(L[0][1] > L[2 * n][1], str(code, ": loop runs from the upper to the lower trailing edge"));
    // the camber-normal offset puts the first upper-surface points marginally ahead of the leading edge
    // (about 0.14 % chord for the 17 % thick, 17 degree nose slope of 23017) and the trailing edge slightly aft of x = 1
    assert(min([for (p = L) p[0]]) > -0.005 && max([for (p = L) p[0]]) < 1.001, str(code, ": x within the chord"));
    A = abs(poly_area(L));
    assert(A > 0.6 * t && A < 0.76 * t, str(code, ": section area ", A, " implausible for t = ", t));
    assert(poly_area(L) * poly_area(naca_loop("0012", n, 0)) > 0, str(code, ": consistent winding direction"));
}
// symmetric airfoil: the lower surface mirrors the upper surface
S = naca_loop("0012", 32, 0);
assert(len([for (i = [0 : 64]) if (!approx(S[i][0], S[64 - i][0], 1e-12) || !approx(S[i][1], -S[64 - i][1], 1e-12)) 1]) == 0, "NACA 0012 must be symmetric");
// extra trailing-edge thickness opens the trailing edge by that amount
Lte = naca_loop("0012", 40, 0.01);
assert(approx(Lte[0][1] - Lte[80][1], naca_loop("0012", 40, 0)[0][1] * 2 + 0.01, 1e-9), "trailing_edge_thickness adds to the TE thickness");

// --- the Skymaster pair (2412 -> 2409) blends point-for-point
assert(len(AF_ROOT) == len(AF_TIP), "root and tip loops must have equal point counts");
assert(AF_N == 64 && len(AF_ROOT) == 129, "high quality uses 64 points per surface");

// --- custom (Selig) airfoil is resampled onto the common grid; a NACA 0012 round-trips
src = naca_loop("0012", 100, 0);
rs  = custom_loop(src, 64);
ref = naca_loop("0012", 64, 0);
assert(len(rs) == len(ref), "custom loop resampled to the requested point count");
maxerr = max([for (i = [0 : len(ref) - 1]) abs(rs[i][1] - ref[i][1])]);
assert(maxerr < 1.5e-3, str("custom airfoil round trip error ", maxerr));
// offset / scaled input (chord 2, leading edge at y = 0.1) is normalised
src2 = [for (p = src) [p[0] * 2 + 0.5, p[1] * 2 + 0.1]];
rs2 = custom_loop(src2, 64);
assert(max([for (i = [0 : len(ref) - 1]) abs(rs2[i][1] - rs[i][1])]) < 1e-9, "custom airfoil input is normalised to unit chord");

// --- planform records of the default Skymaster wing
r0 = plan_rec(P_WING, 0);
rk = plan_rec(P_WING, center_halfspan_m);
rt = plan_rec(P_WING, HALF_SPAN);
assert(approx(r0[1], 1.83, 1e-9) && approx(r0[3], wing_z_m, 1e-9) && approx(r0[4], 1.5, 1e-9) && r0[5] == 0, "wing root record");
assert(approx(rk[1], 1.83, 1e-9) && approx(rk[3], wing_z_m + 2.30 * tan(3.0), 1e-9) && approx(rk[5], 0, 1e-9), "end of inboard panel record");
assert(approx(rt[1], 1.105, 1e-9) && approx(rt[4], 1.5 - 2.0, 1e-9) && approx(rt[5], 1, 1e-9), "wing tip record");
assert(approx(rt[3], wing_z_m + 5.79 * tan(3.0), 1e-9), "uniform dihedral along the whole span");
assert(approx(rt[2], 2.45, 1e-9), "straight leading edge: the taper is all on the trailing edge");
assert(approx(rt[2] + rt[1], 2.45 + 1.105, 1e-9) && rt[2] + rt[1] < r0[2] + r0[1], "trailing edge sweeps forward on the tapered outer panel");
// sweep reference at quarter chord keeps the quarter-chord line on the requested sweep
Pq = [10, 4, 3, 3, 1.5, 0, 10, 0.25, 0, 0, 0, 0, 0, 0, 0, 1, 1];
assert(approx(plan_rec(Pq, 10)[2] + 0.25 * plan_rec(Pq, 10)[1], 0.75 + 6 * tan(10), 1e-9), "quarter-chord sweep reference");

// --- wing area / aspect ratio match the published values (201 sq ft = 18.7 m^2, AR 7.2)
assert(approx(WING_AREA, 18.7, 0.05), str("default wing area ", WING_AREA));
assert(approx(wing_span_m * wing_span_m / WING_AREA, 7.19, 0.03), "default aspect ratio");

// --- breakpoints / station generation
brk = surf_breaks(P_WING, wing_tip_round_m);
assert(len(brk) == 3 && approx(brk[0], 0, 1e-12) && approx(brk[1], 2.30, 1e-12) && approx(brk[2], 5.54, 1e-9), str("breakpoints ", brk));
recs = surf_halfrecs(P_WING, 2, 14, wing_tip_round_m);
assert(approx(recs[0][0], 0, 1e-12), "stations start at the root");
assert(len([for (i = [1 : len(recs) - 1]) if (recs[i][0] <= recs[i - 1][0]) 1]) == 0, "stations ascend strictly");
assert(recs[len(recs) - 1][0] < HALF_SPAN && recs[len(recs) - 1][0] > HALF_SPAN - 0.01, "rounded tip ends just inside the span");
assert(recs[len(recs) - 1][1] < 0.2 * 1.105, "chord shrinks to a small tip");
assert(sorted([3, 1, 2, 3, 0]) == [0, 1, 2, 3, 3] && dedupe([0, 1, 1, 2]) == [0, 1, 2], "sorting helpers");

// --- loft: a prismatic NACA 0012 wing must have volume = section area x span, and closed topology
Pp = [1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1];
Ap = naca_loop("0012", 40, 0);
rings = surf_rings(Pp, Pp, Ap, Ap, 4, 4, 0, 0);
pts = loft_points(rings);
fc = loft_faces(len(rings), len(rings[0]));
assert(approx(abs(signed_volume(pts, fc)), 2 * abs(poly_area(Ap)), 1e-9), "loft volume");
// every directed edge must appear exactly once and be matched by its reverse (closed 2-manifold)
edges = [for (f = fc) for (k = [0 : 2]) [f[k], f[(k + 1) % 3]]];
assert(len(edges) == 3 * len(fc), "edge list");
assert(len([for (e = edges) if (len([for (g = edges) if (g[0] == e[1] && g[1] == e[0]) 1]) != 1) 1]) == 0, "loft is a closed manifold");

// --- body tables stay physical after Hermite interpolation
for (T = [POD_TABLE, BOOM_TABLE]) {
    X = column(T, 0);
    for (i = [0 : 200]) {
        x = lerp(X[0], X[len(X) - 1], i / 200);
        assert(hermite(X, column(T, 3), x) > 0.0, str("half width must stay positive at x = ", x));
        assert(hermite(X, column(T, 1), x) - hermite(X, column(T, 2), x) > 0.0, str("top must stay above bottom at x = ", x));
    }
    for (k = [0 : len(X) - 1]) assert(approx(hermite(X, column(T, 1), X[k]), T[k][1], 1e-9), "Hermite interpolates the table knots");
}
// station tables must be strictly ascending (the boom stations follow the stabiliser position)
for (T = [POD_TABLE, BOOM_TABLE])
    assert(len([for (i = [1 : len(T) - 1]) if (T[i][0] <= T[i - 1][0]) 1]) == 0, "table stations ascend");
// the engine cones are simple profiles: radius grows monotonically from the tip to the base
assert(len([for (i = [1 : len(CONE_PROFILE) - 1]) if (CONE_PROFILE[i][0] <= CONE_PROFILE[i - 1][0] || CONE_PROFILE[i][1] <= CONE_PROFILE[i - 1][1]) 1]) == 0, "cone profile");
// the rear cone base must sit inside the pod and the pod's rear end must be rounded off
assert(REAR_CONE_TIP - 0.80 > POD_TABLE[len(POD_TABLE) - 4][0], "rear cone shaft starts inside the pod");

echo("ALL AIRFOIL / PLANFORM / LOFT TESTS PASSED");
cube(1);
