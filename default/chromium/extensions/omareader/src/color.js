// Color parsing and conversion. Colors are {r, g, b, a} with sRGB channels 0-255 and alpha 0-1.
(function (root) {
  'use strict';

  const NAMED_HEX =
    'aliceblue:f0f8ff,antiquewhite:faebd7,aqua:00ffff,aquamarine:7fffd4,azure:f0ffff,beige:f5f5dc,bisque:ffe4c4,' +
    'black:000000,blanchedalmond:ffebcd,blue:0000ff,blueviolet:8a2be2,brown:a52a2a,burlywood:deb887,cadetblue:5f9ea0,' +
    'chartreuse:7fff00,chocolate:d2691e,coral:ff7f50,cornflowerblue:6495ed,cornsilk:fff8dc,crimson:dc143c,cyan:00ffff,' +
    'darkblue:00008b,darkcyan:008b8b,darkgoldenrod:b8860b,darkgray:a9a9a9,darkgreen:006400,darkgrey:a9a9a9,' +
    'darkkhaki:bdb76b,darkmagenta:8b008b,darkolivegreen:556b2f,darkorange:ff8c00,darkorchid:9932cc,darkred:8b0000,' +
    'darksalmon:e9967a,darkseagreen:8fbc8f,darkslateblue:483d8b,darkslategray:2f4f4f,darkslategrey:2f4f4f,' +
    'darkturquoise:00ced1,darkviolet:9400d3,deeppink:ff1493,deepskyblue:00bfff,dimgray:696969,dimgrey:696969,' +
    'dodgerblue:1e90ff,firebrick:b22222,floralwhite:fffaf0,forestgreen:228b22,fuchsia:ff00ff,gainsboro:dcdcdc,' +
    'ghostwhite:f8f8ff,gold:ffd700,goldenrod:daa520,gray:808080,green:008000,greenyellow:adff2f,grey:808080,' +
    'honeydew:f0fff0,hotpink:ff69b4,indianred:cd5c5c,indigo:4b0082,ivory:fffff0,khaki:f0e68c,lavender:e6e6fa,' +
    'lavenderblush:fff0f5,lawngreen:7cfc00,lemonchiffon:fffacd,lightblue:add8e6,lightcoral:f08080,lightcyan:e0ffff,' +
    'lightgoldenrodyellow:fafad2,lightgray:d3d3d3,lightgreen:90ee90,lightgrey:d3d3d3,lightpink:ffb6c1,' +
    'lightsalmon:ffa07a,lightseagreen:20b2aa,lightskyblue:87cefa,lightslategray:778899,lightslategrey:778899,' +
    'lightsteelblue:b0c4de,lightyellow:ffffe0,lime:00ff00,limegreen:32cd32,linen:faf0e6,magenta:ff00ff,maroon:800000,' +
    'mediumaquamarine:66cdaa,mediumblue:0000cd,mediumorchid:ba55d3,mediumpurple:9370db,mediumseagreen:3cb371,' +
    'mediumslateblue:7b68ee,mediumspringgreen:00fa9a,mediumturquoise:48d1cc,mediumvioletred:c71585,' +
    'midnightblue:191970,mintcream:f5fffa,mistyrose:ffe4e1,moccasin:ffe4b5,navajowhite:ffdead,navy:000080,' +
    'oldlace:fdf5e6,olive:808000,olivedrab:6b8e23,orange:ffa500,orangered:ff4500,orchid:da70d6,palegoldenrod:eee8aa,' +
    'palegreen:98fb98,paleturquoise:afeeee,palevioletred:db7093,papayawhip:ffefd5,peachpuff:ffdab9,peru:cd853f,' +
    'pink:ffc0cb,plum:dda0dd,powderblue:b0e0e6,purple:800080,rebeccapurple:663399,red:ff0000,rosybrown:bc8f8f,' +
    'royalblue:4169e1,saddlebrown:8b4513,salmon:fa8072,sandybrown:f4a460,seagreen:2e8b57,seashell:fff5ee,' +
    'sienna:a0522d,silver:c0c0c0,skyblue:87ceeb,slateblue:6a5acd,slategray:708090,slategrey:708090,snow:fffafa,' +
    'springgreen:00ff7f,steelblue:4682b4,tan:d2b48c,teal:008080,thistle:d8bfd8,tomato:ff6347,turquoise:40e0d0,' +
    'violet:ee82ee,wheat:f5deb3,white:ffffff,whitesmoke:f5f5f5,yellow:ffff00,yellowgreen:9acd32,' +
    // CSS system colors, as they resolve on a light page.
    'canvas:ffffff,canvastext:000000,linktext:0000ee,visitedtext:551a8b,activetext:ff0000,buttonface:efefef,' +
    'buttontext:000000,buttonborder:767676,field:ffffff,fieldtext:000000,highlight:b5d5ff,highlighttext:000000,' +
    'selecteditem:0075ff,selecteditemtext:ffffff,mark:ffff00,marktext:000000,graytext:808080,accentcolor:0075ff,' +
    'accentcolortext:ffffff';

  const NAMED = new Map();
  for (const pair of NAMED_HEX.split(',')) {
    const [name, hex] = pair.split(':');
    NAMED.set(name, hexToRgb(hex));
  }

  function hexToRgb(hex) {
    let h = hex.replace('#', '');
    if (h.length === 3 || h.length === 4) h = h.split('').map((x) => x + x).join('');
    if (h.length !== 6 && h.length !== 8) return null;
    const n = parseInt(h, 16);
    if (Number.isNaN(n)) return null;
    if (h.length === 6) return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255, a: 1 };
    return {
      r: parseInt(h.slice(0, 2), 16),
      g: parseInt(h.slice(2, 4), 16),
      b: parseInt(h.slice(4, 6), 16),
      a: parseInt(h.slice(6, 8), 16) / 255,
    };
  }

  const clamp = (x, lo, hi) => (x < lo ? lo : x > hi ? hi : x);

  // ---- argument parsing -------------------------------------------------

  // Splits "1 2 3 / 0.5" or "1, 2, 3, 0.5" into {channels, alpha}.
  function splitArgs(inner, commaAlpha) {
    const [main, slashAlpha] = inner.split('/');
    const parts = main.replace(/,/g, ' ').trim().split(/\s+/).filter(Boolean);
    let alpha = slashAlpha !== undefined ? slashAlpha.trim() : undefined;
    if (alpha === undefined && commaAlpha && parts.length === 4) alpha = parts.pop();
    return { parts, alpha };
  }

  function num(token, percentScale = 1) {
    if (token === undefined) return NaN;
    if (token === 'none') return 0;
    if (token.endsWith('%')) return (parseFloat(token) / 100) * percentScale;
    return parseFloat(token);
  }

  function hue(token) {
    if (token === 'none') return 0;
    const v = parseFloat(token);
    if (token.endsWith('turn')) return v * 360;
    if (token.endsWith('grad')) return v * 0.9;
    if (token.endsWith('rad')) return (v * 180) / Math.PI;
    return v;
  }

  function alphaOf(token) {
    if (token === undefined) return 1;
    const a = num(token, 1);
    return Number.isFinite(a) ? clamp(a, 0, 1) : NaN;
  }

  // ---- conversions ------------------------------------------------------

  const toLinear = (c) => {
    c /= 255;
    return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  };
  const fromLinear = (c) => {
    const v = c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
    return clamp(v * 255, 0, 255);
  };

  function toOklab({ r, g, b }) {
    const lr = toLinear(r), lg = toLinear(g), lb = toLinear(b);
    const l = Math.cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb);
    const m = Math.cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb);
    const s = Math.cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb);
    return {
      L: 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
      a: 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
      b: 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s,
    };
  }

  function oklabToLinear(L, a, b) {
    const l = Math.pow(L + 0.3963377774 * a + 0.2158037573 * b, 3);
    const m = Math.pow(L - 0.1055613458 * a - 0.0638541728 * b, 3);
    const s = Math.pow(L - 0.0894841775 * a - 1.291485548 * b, 3);
    return [
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s,
    ];
  }

  // Out-of-gamut colors are pulled toward grey (same L) until they fit, so hue survives clipping.
  function fromOklab({ L, a, b }, alpha = 1) {
    let lin = oklabToLinear(L, a, b);
    const inGamut = (v) => v.every((c) => c >= -0.0005 && c <= 1.0005);
    if (!inGamut(lin)) {
      let lo = 0, hi = 1;
      for (let i = 0; i < 14; i++) {
        const k = (lo + hi) / 2;
        if (inGamut(oklabToLinear(L, a * k, b * k))) lo = k;
        else hi = k;
      }
      lin = oklabToLinear(L, a * lo, b * lo);
    }
    return { r: fromLinear(lin[0]), g: fromLinear(lin[1]), b: fromLinear(lin[2]), a: alpha };
  }

  function mul3(m, v) {
    return [
      m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2],
      m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2],
      m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2],
    ];
  }
  const XYZ65_TO_LSRGB = [
    [3.2409699419045226, -1.537383177570094, -0.4986107602930034],
    [-0.9692436362808796, 1.8759675015077202, 0.04155505740717559],
    [0.05563007969699366, -0.20397695888897652, 1.0569715142428786],
  ];
  const D50_TO_D65 = [
    [0.9554734527042182, -0.023098536874261423, 0.0632593086610217],
    [-0.028369706963208136, 1.0099954580058226, 0.021041398966943008],
    [0.012314001688319899, -0.020507696433477912, 1.3303659366080753],
  ];
  const LP3_TO_XYZ65 = [
    [0.4865709486482162, 0.26566769316909306, 0.1982172852343625],
    [0.2289745640697488, 0.6917385218365064, 0.079286914093745],
    [0, 0.04511338185890264, 1.043944368900976],
  ];

  function linearToRgb(lin, alpha) {
    return { r: fromLinear(lin[0]), g: fromLinear(lin[1]), b: fromLinear(lin[2]), a: alpha };
  }

  function labToRgb(L, a, b, alpha) {
    const k = 24389 / 27, e = 216 / 24389;
    const fy = (L + 16) / 116, fx = a / 500 + fy, fz = fy - b / 200;
    const xr = fx ** 3 > e ? fx ** 3 : (116 * fx - 16) / k;
    const yr = L > k * e ? fy ** 3 : L / k;
    const zr = fz ** 3 > e ? fz ** 3 : (116 * fz - 16) / k;
    const xyz50 = [xr * 0.96422, yr, zr * 0.82521];
    return linearToRgb(mul3(XYZ65_TO_LSRGB, mul3(D50_TO_D65, xyz50)), alpha);
  }

  function hslToRgb(h, s, l, alpha) {
    h = (((h % 360) + 360) % 360) / 360;
    s = clamp(s, 0, 1);
    l = clamp(l, 0, 1);
    const f = (n) => {
      const k = (n + h * 12) % 12;
      const a = s * Math.min(l, 1 - l);
      return l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1));
    };
    return { r: f(0) * 255, g: f(8) * 255, b: f(4) * 255, a: alpha };
  }

  function rgbToHsl({ r, g, b }) {
    r /= 255; g /= 255; b /= 255;
    const max = Math.max(r, g, b), min = Math.min(r, g, b);
    const l = (max + min) / 2;
    if (max === min) return { h: 0, s: 0, l };
    const d = max - min;
    const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    let h;
    if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
    else if (max === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    return { h: h * 60, s, l };
  }

  // ---- public parse -----------------------------------------------------

  const FN_RE = /^([a-z-]+)\((.*)\)$/s;

  function parse(input) {
    if (typeof input !== 'string') return null;
    const str = input.trim().toLowerCase();
    if (!str) return null;
    if (str[0] === '#') return /^#[0-9a-f]+$/.test(str) ? hexToRgb(str) : null;
    const named = NAMED.get(str);
    if (named) return { ...named };
    const m = FN_RE.exec(str);
    if (!m) return null;
    const fn = m[1];
    const inner = m[2];
    if (inner.includes('var(') || inner.includes('calc(') || /\bfrom\b/.test(inner)) return null;
    const { parts, alpha } = splitArgs(inner, fn !== 'color');
    const a = alphaOf(alpha);
    let c = null;
    switch (fn) {
      case 'rgb':
      case 'rgba':
        if (parts.length !== 3) return null;
        c = { r: num(parts[0], 255), g: num(parts[1], 255), b: num(parts[2], 255), a };
        break;
      case 'hsl':
      case 'hsla':
        if (parts.length !== 3) return null;
        c = hslToRgb(hue(parts[0]), num(parts[1], 100) / 100, num(parts[2], 100) / 100, a);
        break;
      case 'hwb': {
        if (parts.length !== 3) return null;
        let w = num(parts[1], 100) / 100, bl = num(parts[2], 100) / 100;
        if (w + bl >= 1) {
          const g = (w / (w + bl)) * 255;
          c = { r: g, g, b: g, a };
        } else {
          const base = hslToRgb(hue(parts[0]), 1, 0.5, a);
          const k = 1 - w - bl;
          c = { r: base.r * k + w * 255, g: base.g * k + w * 255, b: base.b * k + w * 255, a };
        }
        break;
      }
      case 'lab':
        if (parts.length !== 3) return null;
        c = labToRgb(num(parts[0], 100), num(parts[1], 125), num(parts[2], 125), a);
        break;
      case 'lch': {
        if (parts.length !== 3) return null;
        const C = num(parts[1], 150), h = (hue(parts[2]) * Math.PI) / 180;
        c = labToRgb(num(parts[0], 100), C * Math.cos(h), C * Math.sin(h), a);
        break;
      }
      case 'oklab':
        if (parts.length !== 3) return null;
        c = fromOklab({ L: num(parts[0], 1), a: num(parts[1], 0.4), b: num(parts[2], 0.4) }, a);
        break;
      case 'oklch': {
        if (parts.length !== 3) return null;
        const C = num(parts[1], 0.4), h = (hue(parts[2]) * Math.PI) / 180;
        c = fromOklab({ L: num(parts[0], 1), a: C * Math.cos(h), b: C * Math.sin(h) }, a);
        break;
      }
      case 'color': {
        if (parts.length !== 4) return null;
        const space = parts[0];
        const v = parts.slice(1).map((p) => num(p, 1));
        if (space === 'srgb') c = { r: v[0] * 255, g: v[1] * 255, b: v[2] * 255, a };
        else if (space === 'srgb-linear') c = linearToRgb(v, a);
        else if (space === 'display-p3') {
          const lin = v.map((x) => toLinear(clamp(x, 0, 1) * 255));
          c = linearToRgb(mul3(XYZ65_TO_LSRGB, mul3(LP3_TO_XYZ65, lin)), a);
        } else if (space === 'xyz' || space === 'xyz-d65') c = linearToRgb(mul3(XYZ65_TO_LSRGB, v), a);
        else if (space === 'xyz-d50') c = linearToRgb(mul3(XYZ65_TO_LSRGB, mul3(D50_TO_D65, v)), a);
        else return null;
        break;
      }
      default:
        return null;
    }
    if (![c.r, c.g, c.b, c.a].every(Number.isFinite)) return null;
    c.r = clamp(c.r, 0, 255);
    c.g = clamp(c.g, 0, 255);
    c.b = clamp(c.b, 0, 255);
    return c;
  }

  // HTML "rules for parsing a legacy colour value" (bgcolor="FFFFCC", <font color="chucknorris">).
  function parseLegacy(input) {
    if (typeof input !== 'string') return null;
    let s = input.trim();
    if (!s || s.toLowerCase() === 'transparent') return null;
    const named = NAMED.get(s.toLowerCase());
    if (named) return { ...named };
    if (/^#[0-9a-f]{3}$/i.test(s)) return hexToRgb(s);
    s = Array.from(s, (ch) => (ch.codePointAt(0) > 0xffff ? '00' : ch)).join('').slice(0, 128);
    if (s[0] === '#') s = s.slice(1);
    s = s.replace(/[^0-9a-f]/gi, '0');
    while (!s.length || s.length % 3) s += '0';
    let len = s.length / 3;
    let parts = [s.slice(0, len), s.slice(len, 2 * len), s.slice(2 * len)];
    if (len > 8) {
      parts = parts.map((p) => p.slice(len - 8));
      len = 8;
    }
    while (len > 2 && parts.every((p) => p[0] === '0')) {
      parts = parts.map((p) => p.slice(1));
      len--;
    }
    if (len > 2) parts = parts.map((p) => p.slice(0, 2));
    const [r, g, b] = parts.map((p) => parseInt(p, 16));
    return { r, g, b, a: 1 };
  }

  const hex2 = (v) => Math.round(clamp(v, 0, 255)).toString(16).padStart(2, '0');

  function format(c) {
    if (c.a >= 0.999) return `#${hex2(c.r)}${hex2(c.g)}${hex2(c.b)}`;
    const a = Math.round(c.a * 1000) / 1000;
    return `rgba(${Math.round(c.r)}, ${Math.round(c.g)}, ${Math.round(c.b)}, ${a})`;
  }

  function luminance(c) {
    return 0.2126 * toLinear(c.r) + 0.7152 * toLinear(c.g) + 0.0722 * toLinear(c.b);
  }

  function contrast(c1, c2) {
    const l1 = luminance(c1), l2 = luminance(c2);
    return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
  }

  function mixLab(x, y, t) {
    return { L: x.L + (y.L - x.L) * t, a: x.a + (y.a - x.a) * t, b: x.b + (y.b - x.b) * t };
  }

  root.OmareaderColor = {
    NAMED,
    parse,
    parseLegacy,
    format,
    hexToRgb,
    toOklab,
    fromOklab,
    rgbToHsl,
    hslToRgb,
    mixLab,
    contrast,
    luminance,
    clamp,
  };
})(globalThis);
