<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Media Player</title>
  <desc>A player seen from the front: a dark screen with a big play button in the main color and a scrubber below it with its handle in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The screen; one hard shadow, as Hype's slides. -->
    <rect x="64" y="106" width="384" height="300" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="64" y="106" width="384" height="300" rx="20" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- Play. -->
    <path d="M222 172L314 226L222 280Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="28" stroke-linejoin="round" transform="translate(0 8)"/>
    <path d="M222 172L314 226L222 280Z" fill="url(#main)" stroke="url(#main)" stroke-width="28" stroke-linejoin="round"/>
    <!-- The scrubber: what has played, what is left, and the handle between. -->
    <rect x="100" y="344" width="312" height="14" rx="7" fill="{{ icon_edge }}"/>
    <rect x="100" y="344" width="132" height="14" rx="7" fill="{{ icon_paper }}"/>
    <rect x="220" y="322" width="24" height="58" rx="12" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="220" y="322" width="24" height="58" rx="12" fill="{{ icon_mark }}"/>
    <rect x="229" y="338" width="6" height="26" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
