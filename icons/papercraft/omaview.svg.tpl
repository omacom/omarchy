<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Media Viewer</title>
  <desc>A photo print seen from the front, as Image Viewer's: a pale border around a sky in the main color, two mountains and a sun in the highlight, with a dark round play button on its corner, its triangle in the main color, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- Image Viewer's print, moved up and over to make room for the button. -->
    <g transform="translate(60 84) scale(.92) translate(-76 -100)">
      <!-- The print; one hard shadow, as Hype's slides. -->
      <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8.7)"/>
      <!-- The picture: sky, a far mountain and a near one. -->
      <rect x="100" y="124" width="312" height="264" rx="12" fill="url(#main)"/>
      <g stroke-width="16" stroke-linejoin="round">
        <path d="M190 400L312 244L420 372V400Z" fill="{{ icon_ink }}" stroke="{{ icon_ink }}"/>
        <path d="M92 400V344L184 262L300 400Z" fill="{{ icon_body }}" stroke="{{ icon_body }}"/>
      </g>
      <!-- The border, laid over the picture so it trims the mountains
           without a clip, which not every SVG renderer applies. -->
      <path d="M96 100H416A20 20 0 0 1 436 120V392A20 20 0 0 1 416 412H96A20 20 0 0 1 76 392V120A20 20 0 0 1 96 100Z M112 124A12 12 0 0 0 100 136V376A12 12 0 0 0 112 388H400A12 12 0 0 0 412 376V136A12 12 0 0 0 400 124Z" fill="{{ icon_paper }}" fill-rule="evenodd"/>
      <!-- The sun, raised off the sky. -->
      <circle cx="220" cy="186" r="30" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
      <circle cx="220" cy="186" r="30" fill="{{ icon_mark }}"/>
    </g>
    <!-- The play button on the print's corner, as Media Player's. -->
    <circle cx="380" cy="374" r="76" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="380" cy="374" r="76" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <path d="M358 332L418 374L358 416Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="14" stroke-linejoin="round" transform="translate(0 6)"/>
    <path d="M358 332L418 374L358 416Z" fill="url(#main)" stroke="url(#main)" stroke-width="14" stroke-linejoin="round"/>
  </g>
</svg>
