<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Print Settings</title>
  <desc>A printer seen from the front: a pale sheet feeding in at the top, a dark body with a status light in the highlight, and a printed page in the main color coming out, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The blank sheet feeding in. -->
    <rect x="156" y="84" width="200" height="140" rx="16" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="156" y="84" width="200" height="140" rx="16" fill="{{ icon_paper }}"/>
    <!-- The body; one hard shadow, as Hype's slides. -->
    <rect x="72" y="172" width="368" height="172" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="72" y="172" width="368" height="172" rx="24" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <rect x="104" y="206" width="72" height="14" rx="7" fill="{{ icon_edge }}"/>
    <rect x="360" y="204" width="48" height="18" rx="9" fill="{{ icon_mark }}"/>
    <!-- The slot, and the printed page coming out of it. -->
    <rect x="124" y="268" width="264" height="24" rx="12" fill="{{ icon_shadow }}"/>
    <rect x="148" y="280" width="216" height="148" rx="16" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="148" y="280" width="216" height="148" rx="16" fill="url(#main)"/>
    <rect x="176" y="316" width="112" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="176" y="346" width="160" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="176" y="376" width="136" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
