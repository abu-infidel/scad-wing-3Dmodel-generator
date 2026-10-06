"""Independent (numpy) reference implementation of NACA 4-digit, 5-digit and reflex-5-digit airfoils.

Used by param_sweep.py to check the OpenSCAD output against a second implementation of the same
published formulas (Abbott & von Doenhoff, "Theory of Wing Sections"). It deliberately shares no code
with b25_mitchell.scad.
"""
import numpy as np

# (P, Q) -> (m, k1, k2/k1) for the 5-digit camber lines; k1 is tabulated for design CL = 0.3 (L = 2)
FIVE_DIGIT = {
    (1, 0): (0.0580, 361.4, 0.0),
    (2, 0): (0.1260, 51.64, 0.0),
    (3, 0): (0.2025, 15.957, 0.0),
    (4, 0): (0.2900, 6.643, 0.0),
    (5, 0): (0.3910, 3.230, 0.0),
    (2, 1): (0.1300, 51.99, 0.000764),
    (3, 1): (0.2170, 15.793, 0.00677),
    (4, 1): (0.3180, 6.520, 0.0303),
    (5, 1): (0.4410, 3.191, 0.1355),
}


def cosine_x(n):
    """n+1 chordwise stations clustered at both ends."""
    return 0.5 * (1.0 - np.cos(np.linspace(0.0, np.pi, n + 1)))


def half_thickness(x, t, extra_te=0.0):
    """NACA half-thickness distribution (open trailing edge coefficient) + optional extra TE thickness."""
    x = np.asarray(x, dtype=float)
    poly = 0.2969 * np.sqrt(x) - 0.1260 * x - 0.3516 * x**2 + 0.2843 * x**3 - 0.1015 * x**4
    return 5.0 * t * poly + 0.5 * extra_te * x


def camber_line(code, x):
    """Return (yc, dyc/dx) for a NACA code."""
    x = np.asarray(x, dtype=float)
    if len(code) == 4:
        m, p = int(code[0]) / 100.0, int(code[1]) / 10.0
        if m == 0 or p == 0:
            return np.zeros_like(x), np.zeros_like(x)
        fwd = x < p
        yc = np.where(fwd, m / p**2 * (2 * p * x - x**2), m / (1 - p) ** 2 * ((1 - 2 * p) + 2 * p * x - x**2))
        dy = np.where(fwd, 2 * m / p**2 * (p - x), 2 * m / (1 - p) ** 2 * (p - x))
        return yc, dy
    L, P, Q = int(code[0]), int(code[1]), int(code[2])
    m, k1, r = FIVE_DIGIT[(P, Q)]
    k1 = k1 * L / 2.0
    fwd = x < m
    if Q == 0:
        yc = np.where(fwd, k1 / 6 * (x**3 - 3 * m * x**2 + m**2 * (3 - m) * x), k1 * m**3 / 6 * (1 - x))
        dy = np.where(fwd, k1 / 6 * (3 * x**2 - 6 * m * x + m**2 * (3 - m)), -k1 * m**3 / 6)
    else:
        common = -r * (1 - m) ** 3 * x - m**3 * x + m**3
        yc = np.where(fwd, k1 / 6 * ((x - m) ** 3 + common), k1 / 6 * (r * (x - m) ** 3 + common))
        dslope = -r * (1 - m) ** 3 - m**3
        dy = np.where(fwd, k1 / 6 * (3 * (x - m) ** 2 + dslope), k1 / 6 * (3 * r * (x - m) ** 2 + dslope))
    return yc, dy


def thickness_ratio(code):
    return int(code[-2:]) / 100.0


def loop(code, n, extra_te=0.0):
    """Airfoil outline as an (2n+1, 2) array: upper trailing edge -> leading edge -> lower trailing edge."""
    x = cosine_x(n)
    yc, dy = camber_line(code, x)
    yt = half_thickness(x, thickness_ratio(code), extra_te)
    th = np.arctan(dy)
    xu, yu = x - yt * np.sin(th), yc + yt * np.cos(th)
    xl, yl = x + yt * np.sin(th), yc - yt * np.cos(th)
    return np.vstack([np.column_stack([xu, yu])[::-1], np.column_stack([xl, yl])[1:]])


def blend(loop_a, loop_b, b):
    return (1.0 - b) * loop_a + b * loop_b


def z_extent(pts):
    return float(pts[:, 1].max() - pts[:, 1].min())


if __name__ == "__main__":
    # published sanity values
    assert abs(half_thickness(0.5, 0.12) - 0.05294) < 6e-5          # NACA 0012 at 50 % chord
    yc, _ = camber_line("23017", np.array([0.2025]))
    assert abs(yc[0] - 0.017613) < 2e-5                                # 23017 maximum camber
    yc, _ = camber_line("4409", np.array([0.4]))
    assert abs(yc[0] - 0.04) < 1e-12                                   # 4409 maximum camber
    print("naca_reference self-check OK")
