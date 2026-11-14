<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Terminal</title>
  <desc>A terminal window seen from the front: a dark window with a big prompt and a text cursor, each piece with a hard shadow.</desc>
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
    <!-- The prompt. -->
    <path d="M140 176L234 252L140 328" fill="none" stroke="{{ icon_shadow }}" stroke-width="44" stroke-linecap="round" stroke-linejoin="round" transform="translate(0 8)"/>
    <path d="M140 176L234 252L140 328" fill="none" stroke="url(#main)" stroke-width="44" stroke-linecap="round" stroke-linejoin="round"/>
    <!-- The cursor, as Plain's, waiting for the next command. -->
    <rect x="300" y="186" width="40" height="132" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="300" y="186" width="40" height="132" rx="20" fill="{{ icon_mark }}"/>
    <rect x="315" y="214" width="10" height="76" rx="5" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
