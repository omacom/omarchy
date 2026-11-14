<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Image Viewer</title>
  <desc>A photo print seen from the front: a pale border around a sky in the main color, two mountains and a sun in the highlight, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <clipPath id="picture">
      <rect x="100" y="124" width="312" height="264" rx="12"/>
    </clipPath>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The print; one hard shadow, as Hype's slides. -->
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_paper }}"/>
    <!-- The picture: sky, a far mountain and a near one. -->
    <rect x="100" y="124" width="312" height="264" rx="12" fill="url(#main)"/>
    <g clip-path="url(#picture)" stroke-width="16" stroke-linejoin="round">
      <path d="M190 400L312 244L420 372V400Z" fill="{{ icon_ink }}" stroke="{{ icon_ink }}"/>
      <path d="M92 400V344L184 262L300 400Z" fill="{{ icon_body }}" stroke="{{ icon_body }}"/>
    </g>
    <!-- The sun, raised off the sky. -->
    <circle cx="220" cy="186" r="30" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <circle cx="220" cy="186" r="30" fill="{{ icon_mark }}"/>
  </g>
</svg>
