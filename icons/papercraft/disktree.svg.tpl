<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>disktree</title>
  <desc>A treemap of a disk seen from the front: a dark window filled with blocks sized by what they hold, one picked out to be removed, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The treemap: one block per folder, sized by what it holds, on an even
         gutter. -->
    <rect x="100" y="116" width="160" height="280" rx="14" fill="url(#main)"/>
    <rect x="124" y="140" width="72" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="272" y="116" width="140" height="120" rx="14" fill="{{ icon_paper }}"/>
    <rect x="272" y="248" width="64" height="148" rx="14" fill="{{ icon_edge }}"/>
    <rect x="348" y="328" width="64" height="68" rx="14" fill="{{ icon_ink }}"/>
    <!-- The block picked for removal, raised off the map. -->
    <rect x="348" y="248" width="64" height="68" rx="14" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="348" y="248" width="64" height="68" rx="14" fill="{{ icon_mark }}"/>
    <rect x="362" y="264" width="36" height="12" rx="6" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
