<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Zoom</title>
  <desc>Zoom's logo in the theme's colors: its disc in the main color with a pale video camera, with a hard shadow.</desc>
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
        <path d="M12 0a12 12 0 1 0 0 24a12 12 0 1 0 0-24z"/>
      </g>
      <!-- The logo's body. -->
      <path d="M12 0a12 12 0 1 0 0 24a12 12 0 1 0 0-24z" fill="url(#main)"/>
      <!-- Its mark, pale. -->
      <g fill="{{ icon_paper }}">
        <path d="M7 7.8h6.200a2 2 0 0 1 2 2v6.400h-6.200a2 2 0 0 1-2-2z"/>
        <path d="M16.200 11.200l3.300-2.500v6.600l-3.300-2.500z"/>
      </g>
    </g>
  </g>
</svg>
