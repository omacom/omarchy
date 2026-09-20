// Render with real browser APIs when the artifact is opened, not JSDOM layout.
export function markmapDocument(root, options, d3, markmap) {
  const json = value => JSON.stringify(value).replaceAll("<", "\\u003c");
  const script = value => value.replace(/<\/script/gi, "<\\/script");
  return `<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>NetClaw mind map</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; color: #172033; background: #f8fafc; font: 15px system-ui,sans-serif; }
  header { height: 84px; display: flex; align-items: center; justify-content: space-between; padding: 16px 28px; border-bottom: 1px solid #cbd5e1; gap: 16px; }
  strong { display: block; font-size: 18px; }
  p { margin: 6px 0 0; color: #475569; font-size: 13px; }
  button { padding: 9px 18px; border: 1px solid #94a3b8; border-radius: 6px; background: white; color: #172033; cursor: pointer; }
  button:focus-visible { outline: 3px solid #2563eb; }
  svg { display: block; width: 100vw; height: calc(100vh - 84px); }
  @media(max-width: 600px) { header { padding: 12px; } p { font-size: 11px; } }
</style>
<header><div><strong>NetClaw · Interactive mind map</strong><p>Scroll to zoom · Drag to pan · Click a branch to expand</p></div><button id="fit">Fit map</button></header>
<svg id="map" aria-label="Interactive mind map"></svg>
<script>${script(d3)}</script>
<script>${script(markmap)}</script>
<script>
  const data = ${json(root)};
  const options = ${json(options || {})};
  const map = markmap.Markmap.create('#map', {maxWidth: 320, duration: 250, ...options}, data);
  document.getElementById('fit').addEventListener('click', () => map.fit());
  document.fonts.ready.then(() => map.fit());
  window.addEventListener('resize', () => map.fit());
</script>
</html>`;
}
