// Private-network classification for the service worker's cross-origin CSS fetch.
// Works on URL.hostname as Chrome canonicalizes it (IPv4 in dotted decimal, IPv6 in
// brackets and compressed hex, e.g. [::ffff:7f00:1]).
(function (root) {
  'use strict';

  const PRIVATE_SUFFIX = /\.(localhost|local|internal|lan|home\.arpa|intranet|corp)$/;

  function v4Private(a, b) {
    return a === 0 || a === 10 || a === 127 || (a === 169 && b === 254) || (a === 172 && b >= 16 && b <= 31) ||
      (a === 192 && b === 168) || (a === 100 && b >= 64 && b <= 127) || (a === 198 && (b === 18 || b === 19)) ||
      a >= 224;
  }

  // Expands an IPv6 literal (with optional trailing dotted quad) to 8 16-bit groups.
  function v6Groups(h) {
    let s = h;
    const dotted = /(\d+)\.(\d+)\.(\d+)\.(\d+)$/.exec(s);
    if (dotted) {
      const [a, b, c, d] = dotted.slice(1).map(Number);
      s = `${s.slice(0, dotted.index)}${((a << 8) | b).toString(16)}:${((c << 8) | d).toString(16)}`;
    }
    const halves = s.split('::');
    if (halves.length > 2) return null;
    const head = halves[0] ? halves[0].split(':') : [];
    const tail = halves.length === 2 && halves[1] ? halves[1].split(':') : [];
    const fill = halves.length === 2 ? 8 - head.length - tail.length : 0;
    if (fill < 0) return null;
    const groups = [...head, ...Array(fill).fill('0'), ...tail].map((g) => parseInt(g, 16));
    return groups.length === 8 && groups.every((g) => g >= 0 && g <= 0xffff) ? groups : null;
  }

  // Only global unicast IPv6 (2000::/3) counts as public; anything embedding an IPv4
  // address (mapped, compatible, 6to4, NAT64) or any local/special range is private.
  function v6Private(h) {
    const g = v6Groups(h);
    if (!g) return true;
    if (g[0] < 0x2000 || g[0] > 0x3fff) return true;
    if (g[0] === 0x2002) return true;
    if (g[0] === 0x2001 && (g[1] === 0x0db8 || g[1] < 0x0200)) return true;
    return false;
  }

  function isPrivateHost(hostname) {
    let h = String(hostname || '').toLowerCase().replace(/^\[|\]$/g, '').replace(/\.+$/, '');
    if (!h) return true;
    if (h.includes(':')) return v6Private(h);
    if (h === 'localhost' || PRIVATE_SUFFIX.test(h)) return true;
    const v4 = /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/.exec(h);
    if (v4) return v4Private(Number(v4[1]), Number(v4[2]));
    return !h.includes('.');
  }

  root.OmareaderNet = { isPrivateHost };
})(globalThis);
