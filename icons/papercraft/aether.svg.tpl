<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Aether</title>
  <desc>A theme being made, seen from the front: a dark window with a wallpaper in the main color and the palette drawn from it as a row of swatches, the picked one raised in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <clipPath id="wallpaper">
      <rect x="100" y="116" width="312" height="164" rx="14"/>
    </clipPath>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The wallpaper the colors come from. -->
    <rect x="100" y="116" width="312" height="164" rx="14" fill="url(#main)"/>
    <g clip-path="url(#wallpaper)">
      <circle cx="330" cy="176" r="26" fill="{{ icon_paper }}"/>
      <path d="M100 280V232C152 200 200 204 250 232C300 260 356 256 412 220V280Z" fill="{{ icon_shadow }}" opacity=".35"/>
    </g>
    <!-- The palette. -->
    <circle cx="138" cy="348" r="34" fill="{{ icon_paper }}"/>
    <circle cx="217" cy="348" r="34" fill="{{ icon_red }}"/>
    <circle cx="296" cy="348" r="34" fill="{{ icon_orange }}"/>
    <!-- The swatch picked as the accent, raised off the window. -->
    <circle cx="375" cy="344" r="38" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="375" cy="344" r="38" fill="{{ icon_mark }}"/>
    <circle cx="375" cy="344" r="12" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
