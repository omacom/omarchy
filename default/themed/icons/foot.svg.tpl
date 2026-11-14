<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Foot</title>
  <desc>A terminal window seen from the front: a dark window with a footprint in the main color and a text cursor in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The footprint: a sole and five toes. -->
    <g fill="{{ icon_shadow }}" transform="translate(0 8)">
      <ellipse cx="226" cy="300" rx="58" ry="82" transform="rotate(8 226 300)"/>
      <circle cx="160" cy="204" r="27"/>
      <circle cx="212" cy="176" r="21"/>
      <circle cx="258" cy="172" r="19"/>
      <circle cx="299" cy="186" r="17"/>
      <circle cx="332" cy="212" r="15"/>
    </g>
    <g fill="url(#main)">
      <ellipse cx="226" cy="300" rx="58" ry="82" transform="rotate(8 226 300)"/>
      <circle cx="160" cy="204" r="27"/>
      <circle cx="212" cy="176" r="21"/>
      <circle cx="258" cy="172" r="19"/>
      <circle cx="299" cy="186" r="17"/>
      <circle cx="332" cy="212" r="15"/>
    </g>
    <!-- The cursor, as Terminal's, waiting for the next command. -->
    <rect x="352" y="262" width="36" height="116" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="352" y="262" width="36" height="116" rx="18" fill="{{ icon_mark }}"/>
    <rect x="365" y="288" width="10" height="64" rx="5" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
