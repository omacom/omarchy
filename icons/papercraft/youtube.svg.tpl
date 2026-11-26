<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>YouTube</title>
  <desc>YouTube's logo in the theme's colors: its rounded screen in the main color with a pale play button, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The logo's own drawing, on its 24 unit square. -->
    <g transform="translate(88 88) scale(14)">
      <!-- Its silhouette, as one hard shadow, as Hype's slides. -->
      <g fill="{{ icon_shadow }}" transform="translate(0 .6)">
        <path d="M23.498 6.186a3.016 3.016 0 0 0 -2.122 -2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0 -9.377 .505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93 .502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871 .505 9.376 .505 9.376 .505s7.505 0 9.377 -.505a3.015 3.015 0 0 0 2.122 -2.136C24 15.93 24 12 24 12s0 -3.93 -.502 -5.814z"/>
        <path d="M9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
      </g>
      <!-- What the logo leaves open, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M23.498 6.186a3.016 3.016 0 0 0 -2.122 -2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0 -9.377 .505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93 .502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871 .505 9.376 .505 9.376 .505s7.505 0 9.377 -.505a3.015 3.015 0 0 0 2.122 -2.136C24 15.93 24 12 24 12s0 -3.93 -.502 -5.814z"/>
        <path d="M9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
      </g>
      <!-- The logo itself. -->
      <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" fill="url(#main)"/>
    </g>
  </g>
</svg>
