<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Monologue</title>
  <desc>A record button seen from the front: a red button set in a dark puck, flanked by level bars, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="rec" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ mix icon_red icon_paper 25% }}"/>
      <stop offset="1" stop-color="{{ icon_red }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.25) translate(-256 -256)">
    <!-- Level bars on either side, as Omacut's trim handles. -->
    <g fill="{{ icon_shadow }}" transform="translate(0 8)">
      <rect x="52" y="218" width="24" height="76" rx="12"/>
      <rect x="88" y="186" width="24" height="140" rx="12"/>
      <rect x="400" y="186" width="24" height="140" rx="12"/>
      <rect x="436" y="218" width="24" height="76" rx="12"/>
    </g>
    <g fill="{{ icon_mark }}">
      <rect x="52" y="218" width="24" height="76" rx="12"/>
      <rect x="88" y="186" width="24" height="140" rx="12"/>
      <rect x="400" y="186" width="24" height="140" rx="12"/>
      <rect x="436" y="218" width="24" height="76" rx="12"/>
    </g>
    <!-- The puck; one hard shadow, as Hype's slides. -->
    <circle cx="256" cy="256" r="136" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="256" cy="256" r="136" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The button. -->
    <circle cx="256" cy="256" r="90" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="256" cy="256" r="90" fill="url(#rec)"/>
    <rect x="202" y="198" width="52" height="15" rx="7.5" fill="{{ icon_paper }}" opacity=".45"/>
  </g>
</svg>
