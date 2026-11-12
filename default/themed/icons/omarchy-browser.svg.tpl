<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Browser</title>
  <desc>A browser window seen from the front: a dark frame with an address bar around a pale page with a headline and lines of text, and a globe in front of its corner, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="96" width="344" height="304" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="96" width="344" height="304" rx="20" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The address bar. -->
    <rect x="100" y="118" width="296" height="28" rx="14" fill="{{ icon_edge }}"/>
    <!-- The page, with a headline and lines of text. -->
    <rect x="94" y="164" width="308" height="218" rx="12" fill="{{ icon_paper }}"/>
    <rect x="122" y="192" width="168" height="32" rx="12" fill="url(#main)"/>
    <g fill="{{ icon_ink }}">
      <rect x="122" y="248" width="236" height="16" rx="8"/>
      <rect x="122" y="282" width="180" height="16" rx="8" opacity=".55"/>
      <rect x="122" y="316" width="120" height="16" rx="8" opacity=".55"/>
    </g>
    <!-- The globe, in front of the window's corner. -->
    <circle cx="384" cy="360" r="64" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="384" cy="360" r="64" fill="{{ icon_mark }}"/>
    <g fill="none" stroke="{{ icon_shadow }}" stroke-width="9" opacity=".35">
      <ellipse cx="384" cy="360" rx="26" ry="58"/>
      <path d="M326 360H442M336 330H432M336 390H432"/>
    </g>
  </g>
</svg>
