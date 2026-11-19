<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Chromium</title>
  <desc>Chromium's logo in the theme's colors: its three joined segments in three shades of the main color around a pale ring and a center in the main color, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 24 unit square, as Chrome's. Each
         segment runs out from a line tangent to the ring, with no gap. -->
    <g transform="translate(88 88) scale(14)">
      <!-- Its silhouette, as one hard shadow, as Hype's slides. -->
      <circle cx="12" cy="12.6" r="12" fill="{{ icon_shadow }}"/>
      <!-- The top segment, darkest. -->
      <path d="M12 6.545H22.69A12 12 0 0 0 1.931 5.47L7.276 14.727Z" fill="{{ icon_main }}"/>
      <path d="M12 6.545H22.69A12 12 0 0 0 1.931 5.47L7.276 14.727Z" fill="{{ icon_shadow }}" fill-opacity=".3"/>
      <!-- The left segment, between the two. -->
      <path d="M7.276 14.727L1.931 5.47A12 12 0 0 0 11.379 23.985L16.724 14.727Z" fill="{{ icon_main }}"/>
      <!-- The right segment, lightest. -->
      <path d="M16.724 14.727L11.379 23.985A12 12 0 0 0 22.69 6.545H12Z" fill="{{ icon_paper }}"/>
      <path d="M16.724 14.727L11.379 23.985A12 12 0 0 0 22.69 6.545H12Z" fill="{{ icon_main }}" fill-opacity=".55"/>
      <!-- The ring, pale, around its center. -->
      <circle cx="12" cy="12" r="5.455" fill="{{ icon_paper }}"/>
      <circle cx="12" cy="12" r="4.364" fill="url(#main)"/>
    </g>
  </g>
</svg>
