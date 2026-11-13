<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Browser</title>
  <desc>A globe seen from the front: a disc in the main color with meridians and parallels, a highlight band at its equator, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <clipPath id="globe">
      <circle cx="256" cy="256" r="168"/>
    </clipPath>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The globe; one hard shadow, as Hype's slides. -->
    <circle cx="256" cy="256" r="168" fill="{{ icon_shadow }}" transform="translate(0 10)"/>
    <circle cx="256" cy="256" r="168" fill="url(#main)"/>
    <g clip-path="url(#globe)">
      <!-- The equator, in the highlight. -->
      <rect x="80" y="240" width="352" height="32" fill="{{ icon_mark }}"/>
      <!-- Meridians and parallels. -->
      <g fill="none" stroke="{{ icon_shadow }}" stroke-width="14" opacity=".35">
        <ellipse cx="256" cy="256" rx="72" ry="168"/>
        <path d="M256 88V424M100 176H412M100 336H412"/>
      </g>
    </g>
  </g>
</svg>
