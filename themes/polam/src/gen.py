#!/usr/bin/env python3
"""Flat-vector farming wallpapers for the Omarchy 'polam' theme.

Detail target: themes/osaka-jade/backgrounds/3-mountain-moon -- the same flat
vector language, but with individual trees, foreground botany, irregular
ridgelines and a textured sky.

Everything picks its colour from one ramp via ramp(t), so the whole set reads
as a single system and re-theming is a matter of editing RAMP alone.

    python3 gen.py            # render every wallpaper (SVG -> $TMPDIR)
    python3 gen.py --test     # render the primitive test card only
"""
import bisect, math, os, random, sys, tempfile

W, H = 2360, 1000                  # 2.36:1, matching the stock backgrounds
HERE = os.path.dirname(os.path.abspath(__file__))
SVG_DIR = os.environ.get("POLAM_SVG_DIR",
                         os.path.join(tempfile.gettempdir(), "polam-svg"))

# --- polam palette: pale meadow light -> deep soil ---------------------
RAMP = [
    (232, 238, 216), (207, 220, 176), (180, 203, 139), (156, 184, 95),
    (135, 165, 84), (114, 145, 75), (95, 125, 66), (78, 107, 58),
    (63, 90, 50), (51, 73, 42), (41, 64, 34), (32, 51, 27),
    (26, 39, 21), (20, 24, 15),
]
INK = "#101508"                    # foreground silhouette colour


def ramp(t, shift=0.0):
    """Sample the ramp at t in [0,1]; 0 is lightest, 1 is darkest."""
    t = min(max(t + shift, 0.0), 1.0)
    x = t * (len(RAMP) - 1)
    i = min(int(x), len(RAMP) - 2)
    f = x - i
    a, b = RAMP[i], RAMP[i + 1]
    return "#%02x%02x%02x" % tuple(round(a[j] + (b[j] - a[j]) * f) for j in range(3))


def pts_attr(points):
    return " ".join("%.1f,%.1f" % p for p in points)


def poly(points, fill=None):
    f = ' fill="%s"' % fill if fill else ""
    return '<polygon points="%s"%s/>' % (pts_attr(points), f)


# =======================================================================
# geometry primitives
# =======================================================================
def bez(p0, p1, p2, p3, t):
    u = 1 - t
    return (u*u*u*p0[0] + 3*u*u*t*p1[0] + 3*u*t*t*p2[0] + t*t*t*p3[0],
            u*u*u*p0[1] + 3*u*u*t*p1[1] + 3*u*t*t*p2[1] + t*t*t*p3[1])


def ribbon(p0, p1, p2, p3, w0, w1, profile="taper", n=48):
    """A cubic centreline swept with a tapering width -> one filled outline.

    'taper' runs w0 -> w1 (horns, grass blades); 'leaf' bulges mid-span (ears).
    """
    left, right = [], []
    for i in range(n + 1):
        t = i / n
        pt = bez(p0, p1, p2, p3, t)
        nx = bez(p0, p1, p2, p3, min(t + 0.001, 1.0))
        px = bez(p0, p1, p2, p3, max(t - 0.001, 0.0))
        dx, dy = nx[0] - px[0], nx[1] - px[1]
        m = math.hypot(dx, dy) or 1.0
        ux, uy = -dy / m, dx / m
        if profile == "leaf":
            w = (w0 + (w1 - w0) * t) * math.sin(math.pi * t) ** 0.55
        else:
            w = (w0 + (w1 - w0) * t) * (1 - t) ** 0.45
        left.append((pt[0] + ux * w / 2, pt[1] + uy * w / 2))
        right.append((pt[0] - ux * w / 2, pt[1] - uy * w / 2))
    return poly(left + right[::-1])


def circle_path(cx, cy, r):
    return ("M%.1f,%.1f a%.1f,%.1f 0 1,0 %.1f,0 a%.1f,%.1f 0 1,0 %.1f,0 Z"
            % (cx - r, cy, r, r, 2 * r, r, r, -2 * r))


def bar(x1, y1, x2, y2, w):
    dx, dy = x2 - x1, y2 - y1
    m = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / m * w / 2, dx / m * w / 2
    return poly([(x1 + nx, y1 + ny), (x2 + nx, y2 + ny),
                 (x2 - nx, y2 - ny), (x1 - nx, y1 - ny)])


# =======================================================================
# detail engine -- the shared vocabulary every scene draws from
# =======================================================================
def ridge_points(y0, amp, rng, octaves=4, steps=220, x0=-60, x1=None, tilt=0.0):
    """An irregular ridgeline from summed sine octaves.

    Clean beziers read as 'computer drew this'; layered noise reads as terrain.
    """
    x1 = W + 60 if x1 is None else x1
    waves = [((k + 1) * rng.uniform(0.7, 1.5), rng.uniform(0, 2 * math.pi),
              amp / (1.75 ** k)) for k in range(octaves)]
    pts = []
    for i in range(steps + 1):
        x = x0 + (x1 - x0) * i / steps
        u = (x - x0) / (x1 - x0)
        y = y0 + tilt * (u - 0.5)
        for freq, phase, a in waves:
            y += a * math.sin(2 * math.pi * freq * u + phase)
        pts.append((x, y))
    return pts


def ridge_path(pts, fill, bottom=H):
    d = ("M%.1f,%.1f " % pts[0]) + " ".join("L%.1f,%.1f" % p for p in pts[1:])
    d += " L%.1f,%.1f L%.1f,%.1f Z" % (pts[-1][0], bottom, pts[0][0], bottom)
    return '<path d="%s" fill="%s"/>' % (d, fill)


def y_sampler(pts):
    """Interpolate a ridgeline's height at any x."""
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]

    def at(x):
        i = min(max(bisect.bisect_left(xs, x), 1), len(xs) - 1)
        x0, x1 = xs[i - 1], xs[i]
        y0, y1 = ys[i - 1], ys[i]
        f = 0.0 if x1 == x0 else (x - x0) / (x1 - x0)
        return y0 + (y1 - y0) * f
    return at


def bush(x, base, r, rng, lobes=None):
    """A shrub: taller than wide, many small lobes, twigs breaking the crown."""
    lobes = lobes or rng.randint(7, 11)
    out = []
    for i in range(lobes):
        u = (i + 0.5) / lobes
        cx = x + (u - 0.5) * r * 1.25 + rng.uniform(-r * 0.14, r * 0.14)
        cy = base - r * rng.uniform(0.35, 1.25)
        rr = r * rng.uniform(0.30, 0.55)
        out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>'
                   % (cx, cy, rr, rr * rng.uniform(0.75, 1.15)))
    for _ in range(rng.randint(3, 5)):
        a = math.radians(rng.uniform(-160, -20))
        ln = r * rng.uniform(0.8, 1.5)
        bx = x + rng.uniform(-r * 0.5, r * 0.5)
        by = base - r * rng.uniform(0.5, 1.0)
        out.append(bar(bx, by, bx + math.cos(a) * ln, by + math.sin(a) * ln,
                       max(r * 0.05, 1.0)))
    out.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>'
               % (x - r * 0.62, base - r * 0.40, r * 1.24, r * 0.40))
    return "".join(out)


def grass_tuft(x, base, h, rng, blades=None):
    """A fan of tapered blades -- the main foreground texture."""
    blades = blades or rng.randint(5, 9)
    out = []
    for _ in range(blades):
        lean = rng.uniform(-0.75, 0.75)
        hh = h * rng.uniform(0.5, 1.2)
        out.append(ribbon((x, base),
                          (x + lean * hh * 0.10, base - hh * 0.42),
                          (x + lean * hh * 0.48, base - hh * 0.80),
                          (x + lean * hh * 0.92, base - hh),
                          max(h * 0.085, 1.6), 0.5, n=20))
    return "".join(out)


def wheat(x, base, h, rng):
    """A stalk with a narrow segmented grain head and long aristas.

    A single ellipse here reads as a bulrush; wheat needs paired grains
    stepping up a narrow spine.
    """
    lean = rng.uniform(-0.34, 0.34)
    tip = (x + lean * h * 0.55, base - h)
    out = [ribbon((x, base), (x + lean * h * 0.10, base - h * 0.45),
                  (x + lean * h * 0.32, base - h * 0.80), tip,
                  max(h * 0.045, 1.4), max(h * 0.02, 0.8), n=20)]
    head_h = h * 0.34
    gw = max(h * 0.030, 1.0)
    g = ['<g transform="translate(%.1f,%.1f) rotate(%.1f)">'
         % (tip[0], tip[1], lean * 26)]
    g.append('<polygon points="%s"/>'                      # the spine
             % pts_attr([(-gw * 0.45, 0), (gw * 0.45, 0),
                         (gw * 0.30, head_h), (-gw * 0.30, head_h)]))
    rows = max(4, int(head_h / (gw * 2.1)))
    for i in range(rows):
        t = (i + 0.5) / rows
        y = head_h * t
        spread = gw * (1.5 + 0.9 * math.sin(math.pi * t))   # fattest mid-head
        for side in (-1, 1):
            g.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" '
                     'transform="rotate(%.1f %.1f %.1f)"/>'
                     % (side * spread * 0.55, y, spread * 0.62, gw * 0.95,
                        side * 34, side * spread * 0.55, y))
    for k in range(3):                                      # aristas
        a = math.radians(-90 + (k - 1) * 15)
        ln = head_h * rng.uniform(0.55, 0.95)
        g.append(bar(0, 0, math.cos(a) * ln, math.sin(a) * ln, max(gw * 0.30, 0.6)))
    g.append("</g>")
    out.append("".join(g))
    return "".join(out)


def _frond(bx, by, ang, length, rng, out, droop=0.6, mode="notched"):
    """One arching palm frond.

    'notched' is a solid blade with sawtooth leaflet edges -- the flat-vector
    idiom, and the one that holds up at wallpaper scale. 'solid' is the plain
    blade used for distant palms; 'hair' draws every leaflet as a line, which
    reads as sketchy rather than vector.
    """
    a = math.radians(ang)
    tip = (bx + math.cos(a) * length,
           by + math.sin(a) * length + droop * length * 0.55)
    c1 = (bx + math.cos(a) * length * 0.42,
          by + math.sin(a) * length * 0.42 - length * 0.07)
    c2 = (bx + math.cos(a) * length * 0.80,
          by + math.sin(a) * length * 0.80 + droop * length * 0.18)
    curve = ((bx, by), c1, c2, tip)

    if mode == "solid":
        out.append(ribbon(*curve, max(length * 0.30, 2.2),
                          max(length * 0.05, 0.8), profile="leaf", n=22))
        return

    def frame(t):
        p = bez(*curve, t)
        q = bez(*curve, min(t + 0.02, 1.0))
        dx, dy = q[0] - p[0], q[1] - p[1]
        m = math.hypot(dx, dy) or 1.0
        return p, (dx / m, dy / m), (-dy / m, dx / m)

    if mode == "hair":
        out.append(ribbon(*curve, max(length * 0.052, 1.6),
                          max(length * 0.052, 1.6) * 0.2, n=26))
        for i in range(1, 15):
            t = i / 15
            p, (ux, uy), (nx, ny) = frame(t)
            ll = length * 0.22 * math.sin(math.pi * t) ** 0.55 * rng.uniform(0.78, 1.18)
            for side in (-1, 1):
                out.append(bar(p[0], p[1], p[0] + nx * side * ll - ux * ll * 0.45,
                               p[1] + ny * side * ll - uy * ll * 0.45,
                               max(ll * 0.21, 1.0)))
        return

    steps = max(7, int(length / 14))
    half = lambda t: length * 0.26 * math.sin(math.pi * t) ** 0.52
    sides = {}
    for side in (1, -1):
        pts = []
        for i in range(steps + 1):
            t = i / steps
            p, (ux, uy), (nx, ny) = frame(t)
            ll = half(t) * rng.uniform(0.88, 1.12)
            pts.append((p[0] + nx * side * ll - ux * ll * 0.38,   # leaflet tip
                        p[1] + ny * side * ll - uy * ll * 0.38))
            t2 = min(t + 0.5 / steps, 1.0)
            p2, _, (nx2, ny2) = frame(t2)
            notch = half(t2) * 0.20
            pts.append((p2[0] + nx2 * side * notch,               # back to spine
                        p2[1] + ny2 * side * notch))
        sides[side] = pts
    out.append(poly([(bx, by)] + sides[1] + [tip] + sides[-1][::-1]))


def palm(x, base, h, rng, lean=None, fronds=None, detail=None):
    """A coconut palm: curved tapering trunk, arching crown, nut cluster.

    detail picks the frond mode: "notched" (default), "solid" for far palms,
    or "hair". Small palms fall back to "solid" automatically.
    """
    lean = rng.uniform(-0.20, 0.20) if lean is None else lean
    mode = ("notched" if h >= 95 else "solid") if detail is None else (
        detail if isinstance(detail, str) else ("notched" if detail else "solid"))
    top = (x + lean * h, base - h)
    c1 = (x + lean * h * 0.10, base - h * 0.42)
    c2 = (x + lean * h * 0.55, base - h * 0.78)
    out = [ribbon((x, base), c1, c2, top,
                  max(h * 0.058, 2.0), max(h * 0.030, 1.4), n=30)]
    n = fronds or rng.randint(7, 9)
    for i in range(n):
        ang = -196 + (i + 0.5) * (212.0 / n) + rng.uniform(-9, 9)
        _frond(top[0], top[1], ang, h * rng.uniform(0.34, 0.50), rng, out,
               droop=rng.uniform(0.45, 0.90), mode=mode)
    for _ in range(rng.randint(3, 5)):          # coconuts under the crown
        out.append('<circle cx="%.1f" cy="%.1f" r="%.1f"/>'
                   % (top[0] + rng.uniform(-h * 0.05, h * 0.05),
                      top[1] + rng.uniform(h * 0.012, h * 0.055),
                      max(h * 0.026, 1.2)))
    return "".join(out)


def bamboo(x, base, h, rng, lean=None):
    """One bamboo culm: segmented stalk with node collars and sparse leaves."""
    lean = rng.uniform(-0.07, 0.07) if lean is None else lean
    top = (x + lean * h, base - h)
    c1 = (x + lean * h * 0.20, base - h * 0.45)
    c2 = (x + lean * h * 0.60, base - h * 0.80)
    w0, w1 = max(h * 0.030, 1.6), max(h * 0.016, 1.0)
    out = [ribbon((x, base), c1, c2, top, w0, w1, n=28)]
    segs = rng.randint(5, 8)
    for i in range(1, segs):
        t = i / segs
        p = bez((x, base), c1, c2, top, t)
        ww = (w0 + (w1 - w0) * t) * 1.6
        out.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%.1f"/>'
                   % (p[0] - ww / 2, p[1] - ww * 0.16, ww, ww * 0.32, ww * 0.12))
        if t > 0.42:                            # leaves only up the top half
            for _ in range(rng.randint(2, 4)):
                a = math.radians(rng.uniform(-155, -25))
                ln = h * rng.uniform(0.10, 0.21)
                ex, ey = p[0] + math.cos(a) * ln, p[1] + math.sin(a) * ln
                mx, my = (p[0] + ex) / 2, (p[1] + ey) / 2
                out.append(ribbon((p[0], p[1]), (mx, my), (mx, my), (ex, ey),
                                  max(h * 0.024, 1.2), max(h * 0.004, 0.5),
                                  profile="leaf", n=14))
    return "".join(out)


def bamboo_clump(x, base, h, rng, culms=None):
    """Bamboo grows in clumps, never as a lone stick."""
    culms = culms or rng.randint(4, 7)
    out = []
    for i in range(culms):
        ox = (i - (culms - 1) / 2) * h * 0.065 + rng.uniform(-h * 0.02, h * 0.02)
        out.append(bamboo(x + ox, base + rng.uniform(-2, 2),
                          h * rng.uniform(0.60, 1.12), rng,
                          lean=rng.uniform(-0.11, 0.11)))
    return "".join(out)


def banana(x, base, h, rng):
    """A banana plant: short stout pseudostem, broad drooping paddle leaves."""
    stem_h = h * 0.38
    sw = max(h * 0.078, 2.5)
    top = (x, base - stem_h)
    out = [ribbon((x, base), (x, base - stem_h * 0.4),
                  (x, base - stem_h * 0.75), top, sw, sw * 0.62, n=14)]
    n = rng.randint(5, 8)
    for i in range(n):
        ang = -192 + (i + 0.5) * (204.0 / n) + rng.uniform(-13, 13)
        a = math.radians(ang)
        L = h * rng.uniform(0.50, 0.80)
        droop = rng.uniform(0.35, 0.78)
        tip = (top[0] + math.cos(a) * L,
               top[1] + math.sin(a) * L + droop * L * 0.50)
        c1 = (top[0] + math.cos(a) * L * 0.35,
              top[1] + math.sin(a) * L * 0.35 - L * 0.08)
        c2 = (top[0] + math.cos(a) * L * 0.75,
              top[1] + math.sin(a) * L * 0.75 + droop * L * 0.16)
        out.append(ribbon(top, c1, c2, tip, L * 0.36, L * 0.05,
                          profile="leaf", n=24))
    return "".join(out)


def banyan(x, base, h, rng, spread=None):
    """A spreading shade tree: heavy wide canopy, thick trunk, aerial roots."""
    spread = spread or h * rng.uniform(1.25, 1.70)
    trunk_h = h * rng.uniform(0.28, 0.40)
    tw = max(h * 0.085, 2.5)
    top = base - trunk_h
    out = [poly([(x - tw, base), (x + tw, base),
                 (x + tw * 0.6, top), (x - tw * 0.6, top)])]
    limbs = rng.randint(4, 6)
    for i in range(limbs):
        a = math.radians(-90 + (i - (limbs - 1) / 2) * rng.uniform(24, 40))
        ln = h * rng.uniform(0.26, 0.44)
        out.append(bar(x, top, x + math.cos(a) * ln, top + math.sin(a) * ln, tw))
    cy = base - h + spread * 0.17
    for _ in range(rng.randint(15, 22)):          # canopy wider than it is tall
        out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f"/>'
                   % (x + rng.uniform(-spread * 0.50, spread * 0.50),
                      cy + rng.uniform(-spread * 0.15, spread * 0.17),
                      spread * rng.uniform(0.13, 0.25),
                      spread * rng.uniform(0.13, 0.25) * rng.uniform(0.60, 0.88)))
    for _ in range(rng.randint(5, 9)):            # aerial roots
        rx = x + rng.uniform(-spread * 0.44, spread * 0.44)
        out.append(bar(rx, cy + spread * 0.12, rx + rng.uniform(-3, 3),
                       base - rng.uniform(0, h * 0.14), max(h * 0.013, 0.9)))
    return "".join(out)


def paddy(vx, vy, rng, fill, bottom=H, rows=20, tuft=52, x0=None, x1=None,
          gap_odds=0.10):
    """Rice seedlings in perspective rows -- rows compress toward the horizon."""
    x0 = -40 if x0 is None else x0
    x1 = W + 40 if x1 is None else x1
    out = []
    for i in range(rows):
        t = (i + 1) / rows
        y = vy + (bottom - vy) * t ** 2.1
        scale = (y - vy) / (bottom - vy)
        hh = max(tuft * scale, 3.0)
        sp = max(tuft * 0.85 * scale, 7.0)
        x = x0 + rng.uniform(0, sp)          # rows drift, they are hand-planted
        while x < x1:
            if rng.random() > gap_odds:
                out.append(grass_tuft(x, y + rng.uniform(-hh * 0.12, hh * 0.12),
                                      hh * rng.uniform(0.65, 1.30), rng,
                                      blades=rng.randint(3, 5)))
            x += sp * rng.uniform(0.62, 1.60)
    return '<g fill="%s">%s</g>' % (fill, "".join(out))


def terraces(vy, rng, bottom=H, bands=9, fill=None, opacity=0.16):
    """Sheets of standing water between paddy bunds, brightest near the horizon."""
    out = []
    for i in range(bands):
        t0, t1 = (i / bands) ** 2.1, ((i + 0.55) / bands) ** 2.1
        y0 = vy + (bottom - vy) * t0
        y1 = vy + (bottom - vy) * t1
        out.append('<rect x="0" y="%.1f" width="%d" height="%.1f" fill="%s" '
                   'opacity="%.3f"/>' % (y0, W, max(y1 - y0, 1.0), fill,
                                         opacity * (1.0 - 0.6 * (i / bands))))
    return "".join(out)


def grove(pts, rng, hmin, hmax, fill, spacing=40, sink=0.03, x0=None, x1=None,
          weights=None):
    """A farm boundary in palms, bamboo, banana, banyan and shrubs.

    Species cluster rather than alternating, which is how groves actually look.
    """
    weights = weights or {"palm": 0.34, "bamboo": 0.22, "banana": 0.16,
                          "banyan": 0.08, "bush": 0.20}
    kinds = list(weights)
    at = y_sampler(pts)
    x = pts[0][0] if x0 is None else x0
    end = pts[-1][0] if x1 is None else x1
    out = ['<g fill="%s">' % fill]
    kind, run = None, 0
    while x < end:
        if run <= 0:                        # commit to a species for a few plants
            kind = rng.choices(kinds, weights=[weights[k] for k in kinds])[0]
            run = rng.randint(1, 4)
        run -= 1
        h = rng.uniform(hmin, hmax)
        if kind == "palm":
            h *= rng.uniform(1.0, 1.5)
            out.append(palm(x, at(x) + h * sink, h, rng))
            x += spacing * rng.uniform(0.8, 1.7)
        elif kind == "bamboo":
            h *= rng.uniform(0.7, 1.1)
            out.append(bamboo_clump(x, at(x) + h * sink, h, rng))
            x += spacing * rng.uniform(0.9, 1.6)
        elif kind == "banana":
            h *= rng.uniform(0.45, 0.70)
            out.append(banana(x, at(x) + h * sink, h, rng))
            x += spacing * rng.uniform(0.5, 1.0)
        elif kind == "banyan":
            h *= rng.uniform(0.9, 1.3)
            out.append(banyan(x, at(x) + h * sink, h, rng))
            x += spacing * rng.uniform(1.6, 2.6)
        else:
            r = rng.uniform(hmin, hmax) * 0.30
            out.append(bush(x, at(x) + r * sink, r, rng))
            x += spacing * rng.uniform(0.35, 0.8)
    out.append("</g>")
    return "".join(out)


def undergrowth(at, rng, x0, x1, fill, h, spacing=34, wheat_odds=0.28,
                bush_odds=0.07, lift=0.0):
    """Grass, wheat and shrubs scattered along a baseline."""
    out = ['<g fill="%s">' % fill]
    x = x0
    while x < x1:
        base = at(x) + lift
        roll = rng.random()
        if roll < bush_odds:
            out.append(bush(x, base, h * rng.uniform(0.28, 0.52), rng))
        elif roll < bush_odds + wheat_odds:
            out.append(wheat(x, base, h * rng.uniform(0.75, 1.35), rng))
        else:
            out.append(grass_tuft(x, base, h * rng.uniform(0.55, 1.15), rng))
        x += spacing * rng.uniform(0.45, 1.5)
    out.append("</g>")
    return "".join(out)


def wisps(rng, ymin, ymax, n, fill, opacity=0.11, gid="soft", blur=9.0):
    """Soft horizontal cloud streaks.

    Unblurred these read as scratches on the sky, so the whole group goes
    through a gaussian blur.
    """
    out = ['<defs><filter id="%s" x="-20%%" y="-400%%" width="140%%" '
           'height="900%%"><feGaussianBlur stdDeviation="%.1f"/></filter></defs>'
           '<g filter="url(#%s)">' % (gid, blur, gid)]
    for _ in range(n):
        out.append('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" '
                   'fill="%s" opacity="%.3f"/>'
                   % (rng.uniform(-W * 0.05, W * 1.05), rng.uniform(ymin, ymax),
                      rng.uniform(W * 0.07, W * 0.33), rng.uniform(2.0, 7.0),
                      fill, opacity * rng.uniform(0.45, 1.55)))
    out.append("</g>")
    return "".join(out)


def birds(flock, fill=None, size=1.0):
    col = fill or ramp(0.60)
    out = []
    for (x, y, s) in flock:
        s *= size
        out.append('<path d="M%.1f,%.1f q%.1f,%.1f %.1f,0 q%.1f,%.1f %.1f,0" '
                   'fill="none" stroke="%s" stroke-width="%.1f" '
                   'stroke-linecap="round"/>'
                   % (x - 11 * s, y, 5.5 * s, -7 * s, 11 * s,
                      5.5 * s, -7 * s, 11 * s, col, 2.6 * s))
    return "".join(out)


# =======================================================================
# atmosphere
# =======================================================================
def sky(top_t, bot_t, height, gid):
    return ('<defs><linearGradient id="%s" x1="0" y1="0" x2="0" y2="1">'
            '<stop offset="0" stop-color="%s"/>'
            '<stop offset="1" stop-color="%s"/></linearGradient></defs>'
            '<rect x="0" y="0" width="%d" height="%.0f" fill="url(#%s)"/>'
            % (gid, ramp(top_t), ramp(bot_t), W, height, gid))


def glow(cx, cy, r, gid):
    return ('<defs><radialGradient id="%s" cx="%.4f" cy="%.4f" r="%.4f">'
            '<stop offset="0" stop-color="%s" stop-opacity="1"/>'
            '<stop offset="0.55" stop-color="%s" stop-opacity="0.45"/>'
            '<stop offset="1" stop-color="%s" stop-opacity="0"/>'
            '</radialGradient></defs>'
            '<rect x="0" y="0" width="%d" height="%d" fill="url(#%s)"/>'
            % (gid, cx / W, cy / H, r / W, ramp(0.06), ramp(0.22), ramp(0.34),
               W, H, gid))


def halo(cx, cy, rings=6, r0=330):
    return "".join('<path d="%s" fill="%s"/>'
                   % (circle_path(cx, cy, r0 * (j / rings) ** 1.25),
                      ramp(0.40 * (j / rings) ** 0.8))
                   for j in range(rings, 0, -1))


def svg(body, w=W, h=H):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
            'viewBox="0 0 %d %d">\n%s\n</svg>\n' % (w, h, w, h, body))


def write(name, body, w=W, h=H):
    os.makedirs(SVG_DIR, exist_ok=True)
    p = os.path.join(SVG_DIR, name + ".svg")
    with open(p, "w") as f:
        f.write(svg(body, w, h))
    print("wrote", p)


# =======================================================================
# primitive test card
# =======================================================================
def label(x, y, text):
    return ('<text x="%.0f" y="%.0f" font-family="monospace" font-size="19" '
            'fill="%s">%s</text>' % (x, y, ramp(0.30), text))


CARD_H = 1500


def test_card():
    rng = random.Random(11)
    p = ['<rect width="%d" height="%d" fill="%s"/>' % (W, CARD_H, ramp(0.88))]

    p.append(wisps(rng, 22, 96, 24, ramp(0.20), 0.20, "softC", 8.0))
    p.append(label(24, 26, "wisps() - sky striation"))

    p.append(label(24, 150, "palm() - coconut, near / mid / far-LOD"))
    for i, (tone, h) in enumerate([(0.80, 258), (0.62, 196), (0.44, 112)]):
        g = ['<g fill="%s">' % ramp(tone)]
        for k in range(3):
            g.append(palm(105 + i * 232 + k * 72, 470, h * rng.uniform(0.84, 1.06), rng))
        g.append("</g>")
        p.append("".join(g))

    p.append(label(790, 150, "bamboo_clump()"))
    g = ['<g fill="%s">' % ramp(0.74)]
    for k in range(2):
        g.append(bamboo_clump(850 + k * 150, 470, rng.uniform(205, 255), rng))
    g.append("</g>")
    p.append("".join(g))

    p.append(label(1120, 150, "banana()"))
    g = ['<g fill="%s">' % ramp(0.78)]
    for k in range(3):
        g.append(banana(1175 + k * 118, 470, rng.uniform(150, 195), rng))
    g.append("</g>")
    p.append("".join(g))

    p.append(label(1560, 150, "banyan() - spreading canopy + aerial roots"))
    g = ['<g fill="%s">' % ramp(0.80)]
    g.append(banyan(1760, 470, 250, rng))
    g.append(banyan(2120, 470, 205, rng))
    g.append("</g>")
    p.append("".join(g))

    pts = ridge_points(620, 26, rng, octaves=5)
    p.append(ridge_path(pts, ramp(0.56), bottom=760))
    p.append(grove(pts, rng, 54, 88, ramp(0.70), spacing=46))
    p.append(label(24, 560, "ridge_points() + grove() - species cluster, not alternate"))

    p.append(label(24, 812, "paddy() + terraces() - rice seedlings in perspective"))
    p.append('<rect x="0" y="830" width="%d" height="300" fill="%s"/>' % (W, ramp(0.70)))
    p.append(terraces(830, rng, bottom=1130, bands=8, fill=ramp(0.16), opacity=0.20))
    p.append(paddy(W / 2, 830, rng, ramp(0.88), bottom=1130, rows=17, tuft=44))

    p.append(label(24, 1190, "grass_tuft() / wheat() / undergrowth()"))
    g = ['<g fill="%s">' % INK]
    for k in range(7):
        g.append(grass_tuft(90 + k * 46, 1300, rng.uniform(58, 104), rng))
    for k in range(6):
        g.append(wheat(470 + k * 56, 1300, rng.uniform(88, 140), rng))
    g.append("</g>")
    p.append("".join(g))
    flat = ridge_points(1420, 9, rng, octaves=3)
    p.append(ridge_path(flat, ramp(0.86), bottom=CARD_H))
    p.append(undergrowth(y_sampler(flat), rng, -20, W + 20, INK, 72, spacing=30))
    return "\n".join(p)



# =======================================================================
# subjects
# =======================================================================
def cow(fill=INK):
    """Bull head, short thick neck and heavy shoulder, traced from the poll."""
    g = ['<g fill="%s">' % fill]
    g.append('<path d="M1105,335 '
             'C 1180,318 1248,330 1292,362 '
             'C 1330,398 1372,456 1402,504 '
             'C 1444,506 1478,518 1490,548 '
             'C 1500,578 1496,608 1476,626 '
             'C 1450,646 1408,654 1372,648 '
             'C 1322,658 1272,662 1230,656 '
             'C 1190,650 1156,668 1132,700 '
             'C 1112,742 1104,782 1112,822 '
             'C 1122,880 1136,940 1146,1000 '
             'L 618,1000 '
             'C 660,908 716,812 786,732 '
             'C 852,656 916,596 968,546 '
             'C 1000,494 1028,438 1052,396 '
             'C 1068,368 1084,348 1105,335 Z"/>')
    g.append(ribbon((1092, 470), (1030, 452), (960, 456), (888, 486),
                    70, 26, profile="leaf"))
    g.append(ribbon((1136, 408), (1030, 356), (952, 314), (898, 242), 72, 8))
    g.append(ribbon((1166, 400), (1274, 330), (1352, 300), (1420, 234), 68, 8))
    g.append("</g>")
    return "".join(g)


def wheel(cx, cy, r):
    out = ['<path fill-rule="evenodd" d="%s %s"/>'
           % (circle_path(cx, cy, r), circle_path(cx, cy, r * 0.60))]
    out.append('<path d="%s"/>' % circle_path(cx, cy, r * 0.24))
    for i in range(6):
        a = math.pi * i / 3
        dx, dy = math.cos(a), math.sin(a)
        nx, ny, w = -dy, dx, r * 0.055
        out.append(poly([(cx + dx * r * 0.18 + nx * w, cy + dy * r * 0.18 + ny * w),
                         (cx + dx * r * 0.62 + nx * w, cy + dy * r * 0.62 + ny * w),
                         (cx + dx * r * 0.62 - nx * w, cy + dy * r * 0.62 - ny * w),
                         (cx + dx * r * 0.18 - nx * w, cy + dy * r * 0.18 - ny * w)]))
    return "".join(out)


def tractor(x, base, scale=1.0, fill=INK):
    """Side view facing right: big drive wheel, small steer wheel, stack."""
    t = ['<g fill="%s" transform="translate(%.1f,%.1f) scale(%.4f) '
         'translate(-1200,-826)">' % (fill, x, base, scale)]
    t.append('<rect x="1052" y="636" width="150" height="86" rx="10"/>')
    t.append('<path d="M1196,650 L1386,650 C 1400,650 1406,658 1406,670 '
             'L1406,724 L1196,724 Z"/>')
    t.append('<rect x="1176" y="718" width="196" height="20" rx="8"/>')
    t.append('<rect x="1244" y="492" width="18" height="166" rx="7"/>')
    t.append('<rect x="1236" y="474" width="34" height="21" rx="8"/>')
    t.append('<path d="M1016,626 L1150,626 L1150,660 L1052,660 '
             'C 1030,660 1016,648 1016,632 Z"/>')
    t.append('<rect x="1000" y="470" width="196" height="19" rx="8"/>')
    t.append('<rect x="1012" y="482" width="14" height="150"/>')
    t.append('<rect x="1166" y="482" width="14" height="150"/>')
    t.append('<path d="M1024,606 L1128,606 L1128,632 L1024,632 Z"/>')
    t.append(wheel(1092, 722, 104))
    t.append(wheel(1340, 758, 58))
    t.append("</g>")
    return "".join(t)


def farmer(x, base, scale=1.0, fill=INK):
    """Walking away, hat and shouldered hoe."""
    f = ['<g fill="%s" transform="translate(%.1f,%.1f) scale(%.4f) '
         'translate(-1180,-744)">' % (fill, x, base, scale)]
    f.append(bar(1152, 744, 1168, 640, 21))
    f.append(bar(1206, 740, 1194, 640, 22))
    f.append('<path d="M1148,568 C 1154,552 1208,552 1214,568 '
             'L1204,648 L1158,648 Z"/>')
    f.append(bar(1152, 574, 1136, 644, 14))
    f.append(bar(1210, 574, 1236, 592, 14))
    f.append('<rect x="1172" y="550" width="17" height="22" rx="5"/>')
    f.append('<path d="M1158,556 C 1158,532 1204,532 1204,556 Z"/>')
    f.append('<ellipse cx="1181" cy="557" rx="40" ry="9"/>')
    f.append(bar(1228, 598, 1322, 486, 10))
    f.append(bar(1308, 474, 1338, 500, 9))
    f.append("</g>")
    return "".join(f)


def swirl_rings(cx, cy, rmax, n=30, lobes=3, amp=0.10, twist=2.6):
    """Concentric bands whose wobble rotates with radius -> the swirl."""
    out = []
    for k in range(n, 0, -1):
        t = k / n
        R = rmax * (t ** 1.28)
        col = ramp(t, 0.012 if k % 2 else -0.012)
        pts = [(cx + R * (1 + amp * math.sin(lobes * th + twist * (1 - t) * 2.4))
                * math.cos(th),
                cy + R * (1 + amp * math.sin(lobes * th + twist * (1 - t) * 2.4))
                * math.sin(th))
               for th in (2 * math.pi * s / 240 for s in range(240))]
        out.append(poly(pts, col))
    return "".join(out)


# =======================================================================
# scenes
# =======================================================================
def scene_cow():
    """The stag analogue: bull head in a swirl, over a palm-and-bamboo fringe."""
    rng = random.Random(3)
    cx, cy = 1180, 470
    p = [swirl_rings(cx, cy, 1560)]
    p.append('<path d="M0,742 C 520,660 900,900 1330,868 '
             'C 1720,840 2050,700 2360,640 L2360,1000 L0,1000 Z" '
             'fill="%s" opacity="0.92"/>' % ramp(0.80))
    p.append('<path d="M0,846 C 480,780 920,986 1380,948 '
             'C 1780,914 2080,812 2360,766 L2360,1000 L0,1000 Z" '
             'fill="%s"/>' % ramp(0.90))

    # a grove standing behind the swirl bands, reading as distant trees
    far = ridge_points(880, 12, rng, octaves=3)
    p.append(grove(far, rng, 58, 96, ramp(0.97), spacing=64,
                   weights={"palm": 0.46, "bamboo": 0.30, "banana": 0.14,
                            "banyan": 0.0, "bush": 0.10}))
    p.append(cow())

    # foreground fringe in front of the animal, tying it to the other scenes
    near = ridge_points(1012, 8, rng, octaves=3)
    p.append(undergrowth(y_sampler(near), rng, -20, W + 20, INK, 86, spacing=27))
    return "\n".join(p)


def scene_tractor():
    """Tractor cresting a ridge, six receding planes of grove and terrain."""
    rng = random.Random(21)
    sx, sy = 1180, 648
    p = [sky(0.92, 0.60, H, "skyA"), wisps(rng, 90, 470, 34, ramp(0.28), 0.17, "softA", 11.0),
         glow(sx, sy, 880, "glowA"), halo(sx, sy, 6, 320),
         '<path d="%s" fill="%s"/>' % (circle_path(sx, sy, 76), ramp(0.0)),
         birds([(560, 214, 1.0), (642, 170, 0.8), (714, 226, 0.9),
                (802, 184, 0.7), (486, 264, 0.7)], ramp(0.52))]

    planes = [(688, 20, 0.44, 26, 42, 0.52, 60),
              (742, 24, 0.53, 34, 56, 0.60, 54),
              (792, 26, 0.62, 44, 72, 0.69, 50)]
    for y0, amp, tone, hmin, hmax, gtone, sp in planes:
        pts = ridge_points(y0, amp, rng, octaves=4)
        p.append(ridge_path(pts, ramp(tone)))
        p.append(grove(pts, rng, hmin, hmax, ramp(gtone), spacing=sp))

    # the ridge the tractor crests
    ridge = ridge_points(846, 22, rng, octaves=4)
    p.append(ridge_path(ridge, ramp(0.76)))
    at = y_sampler(ridge)
    p.append(grove(ridge, rng, 52, 84, ramp(0.83), spacing=58, x0=1640))
    p.append(grove(ridge, rng, 52, 84, ramp(0.83), spacing=58, x1=760))

    f = ['<g fill="%s">' % ramp(0.86)]          # fence marching along the ridge
    tops = []
    for i in range(16):
        x = 240 + i * 34
        y, h, w = at(x), 44 - i * 0.9, 6.5 - i * 0.12
        f.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f"/>'
                 % (x - w / 2, y - h, w, h))
        tops.append((x, y - h))
    for frac in (0.15, 0.62):
        up = [(x, y + (44 - i * 0.9) * frac) for i, (x, y) in enumerate(tops)]
        f.append(poly(up + [(x, y + 5) for x, y in up[::-1]]))
    f.append("</g>")
    p.append("".join(f))

    p.append(tractor(1200, at(1200) + 6, 1.14))

    # foreground bank, closest and darkest
    near = ridge_points(942, 16, rng, octaves=4)
    p.append(ridge_path(near, ramp(0.90)))
    p.append(undergrowth(y_sampler(near), rng, -20, W + 20, INK, 80, spacing=28))
    return "\n".join(p)


def scene_paddy():
    """Farmer in flooded paddy, palms on the horizon against a low sun."""
    rng = random.Random(9)
    vx, vy = 1180, 524
    p = [sky(0.93, 0.60, H, "skyB"), wisps(rng, 70, 400, 34, ramp(0.28), 0.17, "softB", 11.0),
         glow(vx, vy, 900, "glowB"), halo(vx, vy, 5, 236),
         '<path d="%s" fill="%s"/>' % (circle_path(vx, vy, 78), ramp(0.0)),
         birds([(1660, 236, 1.0), (1744, 196, 0.8), (1820, 250, 0.9),
                (620, 214, 0.8), (700, 258, 0.6)], ramp(0.52))]

    # two grove bands on the skyline, the far one hazier
    for y0, tone, hmin, hmax, sp in [(516, 0.50, 26, 44, 56), (536, 0.62, 38, 62, 48)]:
        pts = ridge_points(y0, 7, rng, octaves=3)
        p.append(ridge_path(pts, ramp(tone), bottom=600))
        p.append(grove(pts, rng, hmin, hmax, ramp(tone + 0.07), spacing=sp))

    p.append('<g fill="%s">'                    # a farmstead on the skyline
             '<path d="M1742,540 L1742,492 L1790,466 L1838,492 L1838,540 Z"/>'
             '<rect x="1856" y="460" width="26" height="80"/>'
             '<path d="M1856,462 C 1860,446 1878,446 1882,462 Z"/>'
             '</g>' % ramp(0.72))

    p.append('<rect x="0" y="540" width="%d" height="%d" fill="%s"/>'
             % (W, H - 540, ramp(0.70)))
    p.append(terraces(540, rng, bottom=H, bands=9, fill=ramp(0.14), opacity=0.20))
    p.append(paddy(vx, 540, rng, ramp(0.86), bottom=H, rows=19, tuft=54))

    p.append('<defs><linearGradient id="depthB" x1="0" y1="0" x2="0" y2="1">'
             '<stop offset="0" stop-color="%s" stop-opacity="0"/>'
             '<stop offset="1" stop-color="%s" stop-opacity="0.58"/>'
             '</linearGradient></defs>'
             '<rect x="0" y="540" width="%d" height="%d" fill="url(#depthB)"/>'
             % (ramp(0.97), ramp(0.97), W, H - 540))

    p.append(farmer(1180, 742, 1.0))
    near = ridge_points(986, 10, rng, octaves=3)
    p.append(undergrowth(y_sampler(near), rng, -20, W + 20, INK, 74, spacing=30))
    return "\n".join(p)


SCENES = [("1-swirl-cow", scene_cow), ("2-tractor-ridge", scene_tractor),
          ("3-paddy-field", scene_paddy)]


if __name__ == "__main__":
    if "--test" in sys.argv:
        write("0-test-card", test_card(), W, CARD_H)
    else:
        for name, fn in SCENES:
            write(name, fn())
