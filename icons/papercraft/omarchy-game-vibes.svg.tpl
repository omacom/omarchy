<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Game Vibes</title>
  <desc>A gamepad seen from the front: a dark body with a d-pad in the main color, four face buttons, and two small buttons between them, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.12) translate(-256 -276)">
    <!-- The body; one hard shadow, as Hype's slides. -->
    <path d="M156 160H356C410 160 436 190 444 240L458 330C466 380 430 404 400 386L356 342H156L112 386C82 404 46 380 54 330L68 240C76 190 102 160 156 160Z" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <path d="M156 160H356C410 160 436 190 444 240L458 330C466 380 430 404 400 386L356 342H156L112 386C82 404 46 380 54 330L68 240C76 190 102 160 156 160Z" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The d-pad. -->
    <g fill="url(#main)">
      <rect x="134" y="208" width="40" height="112" rx="10"/>
      <rect x="98" y="244" width="112" height="40" rx="10"/>
    </g>
    <!-- Face buttons. -->
    <circle cx="356" cy="214" r="21" fill="{{ icon_mark }}"/>
    <circle cx="398" cy="264" r="21" fill="{{ icon_main }}"/>
    <circle cx="356" cy="314" r="21" fill="{{ icon_mark }}"/>
    <circle cx="314" cy="264" r="21" fill="{{ icon_main }}"/>
    <!-- Select and start. -->
    <g fill="{{ icon_ink }}">
      <rect x="222" y="200" width="30" height="14" rx="7"/>
      <rect x="260" y="200" width="30" height="14" rx="7"/>
    </g>
  </g>
</svg>
